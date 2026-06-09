package com.kiovant.englishme.service;

import com.kiovant.englishme.entity.User;
import com.kiovant.englishme.repository.PronunciationAttemptRepository;
import com.kiovant.englishme.repository.PronunciationWordFeedbackRepository;
import com.kiovant.englishme.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.*;

class PronunciationAssessmentServiceTest {

    private UserRepository userRepository;
    private PronunciationAttemptRepository attemptRepository;
    private PronunciationWordFeedbackRepository feedbackRepository;
    private CloudPronunciationClient client;
    private PronunciationScoringMapper mapper;
    private PronunciationRateLimiter limiter;
    private LevenshteinPronunciationScorer levenshteinScorer;
    private PronunciationAssessmentService service;

    @BeforeEach
    void setUp() {
        userRepository = mock(UserRepository.class);
        attemptRepository = mock(PronunciationAttemptRepository.class);
        feedbackRepository = mock(PronunciationWordFeedbackRepository.class);
        client = mock(CloudPronunciationClient.class);
        mapper = new PronunciationScoringMapper();
        limiter = mock(PronunciationRateLimiter.class);
        levenshteinScorer = mock(LevenshteinPronunciationScorer.class);
        service = new PronunciationAssessmentService(
                userRepository,
                attemptRepository,
                feedbackRepository,
                client,
                mapper,
                limiter,
                levenshteinScorer
        );
    }

    @Test
    void assess_shouldRejectEmptyReferenceText() {
        MockMultipartFile audio = new MockMultipartFile("audio", "a.webm", "audio/webm", new byte[]{1, 2, 3});
        assertThrows(ResponseStatusException.class, () ->
                service.assess("uid", audio, "   ", "en-us", null)
        );
    }

    @Test
    void assess_shouldRejectUnsupportedContentType() {
        MockMultipartFile audio = new MockMultipartFile("audio", "a.txt", "text/plain", new byte[]{1, 2});
        assertThrows(ResponseStatusException.class, () ->
                service.assess("uid", audio, "hello world", "en-us", null)
        );
    }

    @Test
    void assess_shouldReturnUserNotFoundWhenMissingUser() {
        when(userRepository.findByFirebaseUid("uid")).thenReturn(Optional.empty());
        MockMultipartFile audio = new MockMultipartFile("audio", "a.webm", "audio/webm", new byte[]{1, 2, 3});
        assertThrows(ResponseStatusException.class, () ->
                service.assess("uid", audio, "hello world", "en-us", null)
        );
        verify(limiter, times(1)).checkOrThrow("uid");
    }
}
