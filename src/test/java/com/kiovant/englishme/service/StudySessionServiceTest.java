package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.DueCardsResponse;
import com.kiovant.englishme.dto.ReviewResponse;
import com.kiovant.englishme.dto.StudySessionStartResponse;
import com.kiovant.englishme.dto.StudySessionSummaryResponse;
import com.kiovant.englishme.dto.XpGrantResult;
import com.kiovant.englishme.entity.Desk;
import com.kiovant.englishme.entity.Flashcard;
import com.kiovant.englishme.entity.FlashcardProgress;
import com.kiovant.englishme.entity.StudySession;
import com.kiovant.englishme.entity.User;
import com.kiovant.englishme.repository.DeskRepository;
import com.kiovant.englishme.repository.FlashcardProgressRepository;
import com.kiovant.englishme.repository.FlashcardRepository;
import com.kiovant.englishme.repository.StudySessionRepository;
import com.kiovant.englishme.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.web.server.ResponseStatusException;

import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

/**
 * Unit test cho StudySessionService — vòng đời phiên học SM-2 (Trụ 1):
 * chọn thẻ due/new, dedup XP per thẻ, grant XP đúng 1 lần khi xong phiên.
 *
 * SM2Service dùng BẢN THẬT (fixed clock) — thuật toán là trọng tâm, không mock.
 */
class StudySessionServiceTest {

    private static final Clock FIXED_CLOCK =
            Clock.fixed(Instant.parse("2026-06-10T12:00:00Z"), ZoneOffset.UTC);
    private static final String UID = "uid-1";

    private UserRepository userRepository;
    private DeskRepository deskRepository;
    private FlashcardRepository flashcardRepository;
    private FlashcardProgressRepository progressRepository;
    private StudySessionRepository sessionRepository;
    private XpService xpService;
    private StudySessionService service;

    private User user;
    private Desk desk;

    @BeforeEach
    void setUp() {
        userRepository = mock(UserRepository.class);
        deskRepository = mock(DeskRepository.class);
        flashcardRepository = mock(FlashcardRepository.class);
        progressRepository = mock(FlashcardProgressRepository.class);
        sessionRepository = mock(StudySessionRepository.class);
        xpService = mock(XpService.class);
        service = new StudySessionService(
                userRepository, deskRepository, flashcardRepository,
                progressRepository, sessionRepository,
                new SM2Service(FIXED_CLOCK), xpService, FIXED_CLOCK);

        user = new User();
        user.setId(UUID.randomUUID());
        user.setFirebaseUid(UID);

        desk = new Desk();
        desk.setId(UUID.randomUUID());
        desk.setOwner(user);

        when(userRepository.findByFirebaseUid(UID)).thenReturn(Optional.of(user));
        when(deskRepository.findById(desk.getId())).thenReturn(Optional.of(desk));
        when(sessionRepository.save(any(StudySession.class))).thenAnswer(inv -> inv.getArgument(0));
        when(progressRepository.save(any(FlashcardProgress.class))).thenAnswer(inv -> inv.getArgument(0));
        when(xpService.readOnlyResult(any(), anyInt(), anyBoolean(), anyBoolean()))
                .thenReturn(new XpGrantResult(0, 100L, 0, false, false, List.of(), List.of()));
    }

    private Flashcard card(String word) {
        Flashcard fc = new Flashcard();
        fc.setId(UUID.randomUUID());
        fc.setDesk(desk);
        fc.setWord(word);
        return fc;
    }

    private FlashcardProgress progressFor(Flashcard fc) {
        FlashcardProgress p = new FlashcardProgress();
        p.setUser(user);
        p.setFlashcard(fc);
        p.setEasinessFactor(2.5);
        p.setRepetitions(2);
        p.setIntervalDays(6);
        return p;
    }

    private StudySession activeSession(List<UUID> cardIds, int totalCards) {
        StudySession s = new StudySession();
        s.setId(UUID.randomUUID());
        s.setUser(user);
        s.setDesk(desk);
        s.setStatus("active");
        s.setCardIds(new ArrayList<>(cardIds));
        s.setTotalCards(totalCards);
        s.setMasteredCards(0);
        s.setHardCards(0);
        s.setAgainCards(0);
        s.setXpEarned(0);
        s.setNewWordsLearned(0);
        when(sessionRepository.findByIdAndUser_FirebaseUid(s.getId(), UID)).thenReturn(Optional.of(s));
        return s;
    }

    // ── getDueCards ───────────────────────────────────────────────────────

    @Test
    @DisplayName("getDueCards: due trước, new lấp phần còn lại của limit; count tổng KHÔNG bị limit")
    void getDueCardsFillsLimitWithDueThenNew() {
        Flashcard dueFc = card("due");
        Flashcard newFc = card("new");
        when(progressRepository.findDueProgress(eq(user.getId()), eq(desk.getId()), any(), any()))
                .thenReturn(List.of(progressFor(dueFc)));
        when(progressRepository.findUnseenFlashcardIds(eq(user.getId()), eq(desk.getId()), any()))
                .thenReturn(List.of(newFc.getId()));
        when(flashcardRepository.findAllById(List.of(newFc.getId()))).thenReturn(List.of(newFc));
        when(progressRepository.countDueProgress(eq(user.getId()), eq(desk.getId()), any())).thenReturn(20L);
        when(progressRepository.countUnseenFlashcards(user.getId(), desk.getId())).thenReturn(30L);

        DueCardsResponse res = service.getDueCards(UID, desk.getId(), 10);

        assertEquals(1, res.dueCards().size());
        assertEquals(1, res.newCards().size());
        assertTrue(res.newCards().get(0).isNew());
        assertEquals(20L, res.totalDue(), "count tổng phản ánh pool thật, không phải trang hiện tại");
        assertEquals(30L, res.totalNew());
    }

    // ── startSession ──────────────────────────────────────────────────────

    @Test
    @DisplayName("startSession: desk không còn thẻ nào -> 400 BAD_REQUEST")
    void startSessionThrowsWhenNoCards() {
        when(progressRepository.findDueProgress(any(), any(), any(), any())).thenReturn(List.of());
        when(progressRepository.findUnseenFlashcardIds(any(), any(), any())).thenReturn(List.of());

        ResponseStatusException ex = assertThrows(ResponseStatusException.class,
                () -> service.startSession(UID, desk.getId(), 10));
        assertEquals(400, ex.getStatusCode().value());
        verify(sessionRepository, never()).save(any());
    }

    @Test
    @DisplayName("startSession: tạo session active với đúng cardIds")
    void startSessionCreatesActiveSession() {
        Flashcard fc = card("apple");
        when(progressRepository.findDueProgress(any(), any(), any(), any()))
                .thenReturn(List.of(progressFor(fc)));
        when(progressRepository.findUnseenFlashcardIds(any(), any(), any())).thenReturn(List.of());

        StudySessionStartResponse res = service.startSession(UID, desk.getId(), 10);

        assertEquals(1, res.totalCards());
        verify(sessionRepository).save(argThat(s ->
                "active".equals(s.getStatus())
                        && s.getCardIds().equals(List.of(fc.getId()))
                        && s.getXpEarned() == 0));
    }

    // ── review ────────────────────────────────────────────────────────────

    @Test
    @DisplayName("review thẻ ngoài session -> 400, không chấm")
    void reviewRejectsCardOutsideSession() {
        StudySession session = activeSession(List.of(UUID.randomUUID()), 1);

        ResponseStatusException ex = assertThrows(ResponseStatusException.class,
                () -> service.review(UID, session.getId(), UUID.randomUUID(), 5, null));
        assertEquals(400, ex.getStatusCode().value());
        verify(progressRepository, never()).save(any());
    }

    @Test
    @DisplayName("review lapse (q=0) trên thẻ 5 reps -> progress reset reps=0, interval=1")
    void reviewLapseResetsProgress() {
        Flashcard fc = card("apple");
        StudySession session = activeSession(List.of(fc.getId()), 1);
        FlashcardProgress p = progressFor(fc);
        p.setRepetitions(5);
        p.setIntervalDays(30);
        when(flashcardRepository.findById(fc.getId())).thenReturn(Optional.of(fc));
        when(progressRepository.findByUser_IdAndFlashcard_Id(user.getId(), fc.getId()))
                .thenReturn(Optional.of(p));

        ReviewResponse res = service.review(UID, session.getId(), fc.getId(), 0, null);

        assertEquals(0, res.repetitions());
        assertEquals(1, res.intervalDays());
        assertEquals(1, session.getAgainCards());
        assertEquals(0, session.getXpEarned(), "q<3 -> 0 XP pending");
    }

    @Test
    @DisplayName("review CÙNG thẻ 2 lần trong phiên -> pending XP chỉ cộng lần đầu")
    void reviewDeduplicatesPendingXpPerCard() {
        Flashcard fc = card("apple");
        StudySession session = activeSession(List.of(fc.getId()), 1);
        when(flashcardRepository.findById(fc.getId())).thenReturn(Optional.of(fc));
        when(progressRepository.findByUser_IdAndFlashcard_Id(user.getId(), fc.getId()))
                .thenReturn(Optional.empty());

        service.review(UID, session.getId(), fc.getId(), 5, null); // 3 XP pending
        ReviewResponse second = service.review(UID, session.getId(), fc.getId(), 4, null); // dedup

        assertEquals(3, session.getXpEarned(), "lần 2 không cộng thêm pending XP");
        assertEquals(3, second.sessionXp());
        // XP thật KHÔNG grant trong lúc review — chỉ khi getSummary lúc xong phiên.
        verify(xpService, never()).grant(any(), anyInt(), anyString(), anyString(), anyString(), any());
    }

    // ── getSummary ────────────────────────────────────────────────────────

    @Test
    @DisplayName("getSummary phiên chưa review hết -> KHÔNG grant XP, status giữ active")
    void getSummaryDoesNotGrantWhenIncomplete() {
        StudySession session = activeSession(List.of(UUID.randomUUID(), UUID.randomUUID()), 2);
        session.setMasteredCards(1); // 1/2 thẻ

        StudySessionSummaryResponse res = service.getSummary(UID, session.getId());

        assertEquals("active", res.status());
        assertNull(res.totalXp());
        verify(xpService, never()).grant(any(), anyInt(), anyString(), anyString(), anyString(), any());
    }

    @Test
    @DisplayName("getSummary phiên vừa review hết -> grant 1 lần, idempotency key theo sessionId; gọi lại không grant nữa")
    void getSummaryGrantsOnceOnCompletionThenIdempotent() {
        StudySession session = activeSession(List.of(UUID.randomUUID()), 1);
        session.setMasteredCards(1);
        session.setXpEarned(3);
        when(xpService.grant(any(), anyInt(), anyString(), anyString(), anyString(), any()))
                .thenReturn(new XpGrantResult(3, 103L, 3, true, false, List.of(), List.of()));

        StudySessionSummaryResponse first = service.getSummary(UID, session.getId());

        assertEquals("completed", first.status());
        assertEquals(103L, first.totalXp());
        verify(xpService).grant(eq(user.getId()), eq(3), eq("sm2_review"),
                eq(session.getId().toString()),
                eq("sm2_session:" + session.getId() + ":complete"), any());

        // Gọi lại: status đã completed -> nhánh justCompleted=false, không grant lần 2.
        StudySessionSummaryResponse secondCall = service.getSummary(UID, session.getId());
        assertEquals("completed", secondCall.status());
        verify(xpService, times(1)).grant(any(), anyInt(), anyString(), anyString(), anyString(), any());
    }
}
