package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.PronunciationAssessResponse;
import com.kiovant.englishme.dto.PronunciationErrorDto;
import com.kiovant.englishme.dto.PronunciationInsightResponse;
import com.kiovant.englishme.entity.PronunciationAttempt;
import com.kiovant.englishme.entity.PronunciationWordFeedback;
import com.kiovant.englishme.entity.User;
import com.kiovant.englishme.repository.PronunciationAttemptRepository;
import com.kiovant.englishme.repository.PronunciationWordFeedbackRepository;
import com.kiovant.englishme.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

/**
 * Unit test cho PronunciationAssessmentService — Trụ 2 (đánh giá phát âm AI).
 *
 * Trọng tâm: luồng assess-audio (Cloud STT) + fallback trả null cho client
 * tự STT on-device, persistence attempt/word-feedback, rate limit, insights.
 */
class PronunciationAssessmentServiceTest {

    private UserRepository userRepository;
    private PronunciationAttemptRepository attemptRepository;
    private PronunciationWordFeedbackRepository feedbackRepository;
    private PronunciationRateLimiter limiter;
    private LevenshteinPronunciationScorer levenshteinScorer;
    private GoogleSttService googleSttService;
    private PronunciationAssessmentService service;

    private User user;

    @BeforeEach
    void setUp() {
        userRepository = mock(UserRepository.class);
        attemptRepository = mock(PronunciationAttemptRepository.class);
        feedbackRepository = mock(PronunciationWordFeedbackRepository.class);
        limiter = mock(PronunciationRateLimiter.class);
        levenshteinScorer = mock(LevenshteinPronunciationScorer.class);
        googleSttService = mock(GoogleSttService.class);
        service = new PronunciationAssessmentService(
                userRepository,
                attemptRepository,
                feedbackRepository,
                limiter,
                levenshteinScorer,
                googleSttService
        );

        user = new User();
        user.setId(UUID.randomUUID());
        user.setFirebaseUid("uid");
        when(userRepository.findByFirebaseUid("uid")).thenReturn(Optional.of(user));
        when(attemptRepository.save(any(PronunciationAttempt.class))).thenAnswer(inv -> {
            PronunciationAttempt a = inv.getArgument(0);
            a.setId(UUID.randomUUID());
            return a;
        });
    }

    private PronunciationAssessResponse scoredResponse(String transcription) {
        return new PronunciationAssessResponse(
                85.0, 90.0, 80.0, 95.0, transcription,
                List.of(new PronunciationErrorDto("word", 1, "world", "word", "Phát âm 'world' có âm /l/")),
                "Khá tốt");
    }

    // ── Validation (giữ từ bản cũ) ────────────────────────────────────────

    @Test
    void assessText_shouldRejectEmptyReferenceText() {
        assertThrows(ResponseStatusException.class, () ->
                service.assessText("uid", "   ", "hello world", null)
        );
    }

    @Test
    void assessText_shouldRejectEmptySpokenText() {
        assertThrows(ResponseStatusException.class, () ->
                service.assessText("uid", "hello world", "   ", null)
        );
    }

    @Test
    void assessText_shouldReturnUserNotFoundWhenMissingUser() {
        when(userRepository.findByFirebaseUid("uid")).thenReturn(Optional.empty());
        assertThrows(ResponseStatusException.class, () ->
                service.assessText("uid", "hello world", "hello word", null)
        );
        verify(limiter, times(1)).checkOrThrow("uid");
    }

    @Test
    @DisplayName("referenceText đúng 300 ký tự -> pass; 301 -> 400")
    void referenceLengthBoundary() {
        when(levenshteinScorer.score(anyString(), anyString())).thenReturn(scoredResponse("x"));
        String ref300 = "a".repeat(300);
        assertDoesNotThrow(() -> service.assessText("uid", ref300, "a", null));

        String ref301 = "a".repeat(301);
        ResponseStatusException ex = assertThrows(ResponseStatusException.class,
                () -> service.assessText("uid", ref301, "a", null));
        assertEquals(HttpStatus.BAD_REQUEST, ex.getStatusCode());
    }

    // ── assessText: persistence + rate limit ─────────────────────────────

    @Test
    @DisplayName("assessText lưu attempt (provider=levenshtein) + word feedback từng lỗi")
    void assessTextPersistsAttemptAndWordFeedback() {
        when(levenshteinScorer.score("hello world", "hello word"))
                .thenReturn(scoredResponse("hello word"));

        PronunciationAssessResponse res = service.assessText("uid", "hello world", "hello word", null);

        assertEquals(85.0, res.score());
        ArgumentCaptor<PronunciationAttempt> attemptCaptor = ArgumentCaptor.forClass(PronunciationAttempt.class);
        verify(attemptRepository).save(attemptCaptor.capture());
        PronunciationAttempt saved = attemptCaptor.getValue();
        assertEquals("levenshtein", saved.getProvider());
        assertEquals(85, saved.getOverallScore());
        assertEquals(user, saved.getUser());

        @SuppressWarnings("unchecked")
        ArgumentCaptor<List<PronunciationWordFeedback>> fbCaptor =
                ArgumentCaptor.forClass((Class) List.class);
        verify(feedbackRepository).saveAll(fbCaptor.capture());
        assertEquals(1, fbCaptor.getValue().size());
        assertEquals("word", fbCaptor.getValue().get(0).getWord());
    }

    @Test
    @DisplayName("Rate limiter ném 429 -> propagate, KHÔNG chấm, KHÔNG lưu")
    void assessTextPropagatesRateLimit() {
        doThrow(new ResponseStatusException(HttpStatus.TOO_MANY_REQUESTS, "rate limit"))
                .when(limiter).checkOrThrow("uid");

        ResponseStatusException ex = assertThrows(ResponseStatusException.class,
                () -> service.assessText("uid", "hello", "hello", null));

        assertEquals(HttpStatus.TOO_MANY_REQUESTS, ex.getStatusCode());
        verify(attemptRepository, never()).save(any());
        verifyNoInteractions(levenshteinScorer);
    }

    // ── assessAudio: Cloud STT + fallback ─────────────────────────────────

    @Test
    @DisplayName("assessAudio: STT chưa bật -> null (client fallback), không tốn rate-limit quota")
    void assessAudioReturnsNullWhenSttNotConfigured() {
        when(googleSttService.isConfigured()).thenReturn(false);

        PronunciationAssessResponse res = service.assessAudio("uid", "hello", new byte[]{1}, null);

        assertNull(res);
        verify(limiter, never()).checkOrThrow(anyString());
        verify(attemptRepository, never()).save(any());
    }

    @Test
    @DisplayName("assessAudio: STT trả transcript rỗng (không nhận ra tiếng nói) -> null")
    void assessAudioReturnsNullWhenTranscriptEmpty() {
        when(googleSttService.isConfigured()).thenReturn(true);
        when(googleSttService.transcribe(any())).thenReturn("  ");

        PronunciationAssessResponse res = service.assessAudio("uid", "hello", new byte[]{1}, null);

        assertNull(res);
        verify(attemptRepository, never()).save(any());
    }

    @Test
    @DisplayName("assessAudio thành công -> chấm transcript, lưu provider=google-stt")
    void assessAudioScoresTranscriptAndPersists() {
        when(googleSttService.isConfigured()).thenReturn(true);
        when(googleSttService.transcribe(any())).thenReturn("hello word");
        when(levenshteinScorer.score("hello world", "hello word"))
                .thenReturn(scoredResponse("hello word"));

        PronunciationAssessResponse res = service.assessAudio("uid", "hello world", new byte[]{1}, null);

        assertNotNull(res);
        verify(limiter).checkOrThrow("uid");
        verify(attemptRepository).save(argThat(a -> "google-stt".equals(a.getProvider())));
    }

    @Test
    @DisplayName("assessAudio: transcript dài hơn 300 ký tự -> truncate về 300 trước khi chấm")
    void assessAudioTruncatesLongTranscript() {
        when(googleSttService.isConfigured()).thenReturn(true);
        when(googleSttService.transcribe(any())).thenReturn("b".repeat(400));
        when(levenshteinScorer.score(anyString(), anyString())).thenReturn(scoredResponse("b"));

        service.assessAudio("uid", "hello", new byte[]{1}, null);

        ArgumentCaptor<String> spokenCaptor = ArgumentCaptor.forClass(String.class);
        verify(levenshteinScorer).score(eq("hello"), spokenCaptor.capture());
        assertEquals(300, spokenCaptor.getValue().length());
    }

    // ── insights ──────────────────────────────────────────────────────────

    @Test
    @DisplayName("insights: chưa có attempt nào -> mọi số liệu = 0, không NPE")
    void insightsEmptyHistoryReturnsZeros() {
        when(attemptRepository.countByUser_FirebaseUid("uid")).thenReturn(0L);
        when(attemptRepository.averageOverallScore("uid")).thenReturn(null);
        when(feedbackRepository.findWeakWords(eq("uid"), any())).thenReturn(List.of());
        when(feedbackRepository.countByIssueType("uid")).thenReturn(List.of());

        PronunciationInsightResponse res = service.insights("uid", 10);

        assertEquals(0L, res.totalAttempts());
        assertEquals(0, res.averageScore());
        assertTrue(res.weakestWords().isEmpty());
    }

    @Test
    @DisplayName("insights: map weak words + issue breakdown từ aggregate rows")
    void insightsMapsWeakWordsAndBreakdown() {
        when(attemptRepository.countByUser_FirebaseUid("uid")).thenReturn(5L);
        when(attemptRepository.averageOverallScore("uid")).thenReturn(78.4);
        when(feedbackRepository.findWeakWords(eq("uid"), any())).thenReturn(List.<Object[]>of(
                new Object[]{"world", 40, 3L, 0, "Chú ý âm /l/"}
        ));
        when(feedbackRepository.countByIssueType("uid")).thenReturn(List.<Object[]>of(
                new Object[]{"good", 10L},
                new Object[]{"critical", 4L}
        ));

        PronunciationInsightResponse res = service.insights("uid", 10);

        assertEquals(5L, res.totalAttempts());
        assertEquals(78, res.averageScore());
        assertEquals(1, res.weakestWords().size());
        assertEquals("world", res.weakestWords().get(0).word());
        assertEquals("critical", res.weakestWords().get(0).lastIssueType(), "rank 0 -> critical");
        assertEquals(10L, res.issueBreakdown().good());
        assertEquals(4L, res.issueBreakdown().critical());
        assertEquals(0L, res.issueBreakdown().minor());
    }
}
