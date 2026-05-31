package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.DueCardResponse;
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
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@Service
public class StudySessionService {

    private static final int DEFAULT_LIMIT = 20;
    private static final int MAX_LIMIT = 100;

    private final UserRepository userRepository;
    private final DeskRepository deskRepository;
    private final FlashcardRepository flashcardRepository;
    private final FlashcardProgressRepository progressRepository;
    private final StudySessionRepository sessionRepository;
    private final SM2Service sm2Service;
    private final XpService xpService;

    public StudySessionService(UserRepository userRepository,
                               DeskRepository deskRepository,
                               FlashcardRepository flashcardRepository,
                               FlashcardProgressRepository progressRepository,
                               StudySessionRepository sessionRepository,
                               SM2Service sm2Service,
                               XpService xpService) {
        this.userRepository = userRepository;
        this.deskRepository = deskRepository;
        this.flashcardRepository = flashcardRepository;
        this.progressRepository = progressRepository;
        this.sessionRepository = sessionRepository;
        this.sm2Service = sm2Service;
        this.xpService = xpService;
    }

    // ── Due cards (preview, no session created) ──────────────────────────

    @Transactional(readOnly = true)
    public DueCardsResponse getDueCards(String firebaseUid, UUID deskId, int limit) {
        User user = loadUser(firebaseUid);
        Desk desk = loadAccessibleDesk(deskId, user.getId());
        int cap = clampLimit(limit);
        LocalDateTime now = LocalDateTime.now();

        // Danh sach (gioi han boi limit) — phuc vu hien thi/preview.
        List<DueCardResponse> dueCards = new ArrayList<>();
        List<FlashcardProgress> due = progressRepository.findDueProgress(
                user.getId(), desk.getId(), now, PageRequest.of(0, cap));
        for (FlashcardProgress p : due) {
            dueCards.add(toDueCard(p.getFlashcard(), p, false));
        }

        List<DueCardResponse> newCards = new ArrayList<>();
        int remaining = cap - dueCards.size();
        if (remaining > 0) {
            List<UUID> unseenIds = progressRepository.findUnseenFlashcardIds(
                    user.getId(), desk.getId(), PageRequest.of(0, remaining));
            for (Flashcard fc : flashcardRepository.findAllById(unseenIds)) {
                newCards.add(toDueCard(fc, null, true));
            }
        }

        // Tong THAT SU (khong gioi han limit) — phuc vu dem tien do tren UI.
        long totalDue = progressRepository.countDueProgress(user.getId(), desk.getId(), now);
        long totalNew = progressRepository.countUnseenFlashcards(user.getId(), desk.getId());

        return new DueCardsResponse(dueCards, newCards, totalDue, totalNew);
    }

    // ── Start session ────────────────────────────────────────────────────

    @Transactional
    public StudySessionStartResponse startSession(String firebaseUid, UUID deskId, int limit) {
        User user = loadUser(firebaseUid);
        Desk desk = loadAccessibleDesk(deskId, user.getId());
        int cap = clampLimit(limit);

        List<DueCardResponse> cards = getDueCardsInternal(user, desk, cap);
        if (cards.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "No cards available to study in this desk");
        }

        StudySession session = new StudySession();
        session.setUser(user);
        session.setDesk(desk);
        session.setStatus("active");
        session.setCardIds(cards.stream().map(DueCardResponse::flashcardId).toList());
        session.setTotalCards(cards.size());
        session.setMasteredCards(0);
        session.setAgainCards(0);
        session.setHardCards(0);
        session.setXpEarned(0);
        session.setNewWordsLearned(0);
        session = sessionRepository.save(session);

        return new StudySessionStartResponse(session.getId(), desk.getId(), cards.size(), cards);
    }

    // ── Review a card ────────────────────────────────────────────────────

    @Transactional
    public ReviewResponse review(String firebaseUid, UUID sessionId, UUID flashcardId, int quality, Integer responseTimeMs) {
        User user = loadUser(firebaseUid);
        StudySession session = sessionRepository.findByIdAndUser_FirebaseUid(sessionId, firebaseUid)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Study session not found"));

        if ("completed".equalsIgnoreCase(session.getStatus())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Study session is already completed");
        }
        if (session.getCardIds() == null || !session.getCardIds().contains(flashcardId)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Flashcard is not part of this session");
        }

        int q = Math.max(0, Math.min(5, quality));

        Flashcard fc = flashcardRepository.findById(flashcardId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Flashcard not found"));

        Optional<FlashcardProgress> existing = progressRepository.findByUser_IdAndFlashcard_Id(user.getId(), flashcardId);
        boolean isNew = existing.isEmpty();
        FlashcardProgress progress = existing.orElseGet(() -> {
            FlashcardProgress p = new FlashcardProgress();
            p.setUser(user);
            p.setFlashcard(fc);
            return p;
        });

        sm2Service.applyReview(progress, q);
        progressRepository.save(progress);

        if (q < 3) {
            session.setAgainCards(safeIncr(session.getAgainCards()));
        } else if (q == 3) {
            session.setHardCards(safeIncr(session.getHardCards()));
        } else {
            session.setMasteredCards(safeIncr(session.getMasteredCards()));
        }
        if (isNew && q >= 3) {
            session.setNewWordsLearned(safeIncr(session.getNewWordsLearned()));
        }

        // XP CHỈ cộng khi hoàn thành cả session (xem getSummary). Ở mỗi thẻ chỉ
        // TÍCH LŨY "pending XP" vào session.xp_earned, KHÔNG grant vào total_xp.
        // Cộng đúng 1 lần/thẻ: chỉ cộng khi đây là lần review thẻ này trong phiên
        // (flashcardId chưa nằm trong reviewedCardIds) để retry không làm phình pending.
        int candidateXp = sm2Service.xpForQuality(q);
        if (session.getReviewedCardIds() == null) {
            session.setReviewedCardIds(new java.util.ArrayList<>());
        }
        if (!session.getReviewedCardIds().contains(flashcardId)) {
            session.getReviewedCardIds().add(flashcardId);
            session.setXpEarned((session.getXpEarned() == null ? 0 : session.getXpEarned()) + candidateXp);
        }
        session = sessionRepository.save(session);

        int reviewed = nullToZero(session.getMasteredCards())
                + nullToZero(session.getHardCards())
                + nullToZero(session.getAgainCards());

        // Review không grant → trả totalXp/dailyXp hiện tại (chưa đổi), xpEarned=0.
        // FE sẽ nhận XP thật ở bước getSummary khi session completed.
        XpGrantResult xpResult = xpService.readOnlyResult(user.getId(), 0, false, false);

        return new ReviewResponse(
                flashcardId,
                progress.getRepetitions(),
                progress.getEasinessFactor(),
                progress.getIntervalDays(),
                progress.getNextReviewAt(),
                0,                          // xpEarned per-thẻ = 0 (chỉ cộng khi xong session)
                xpResult.totalXp(),
                xpResult.dailyEarnedXp(),
                false,                      // streakUpdated chỉ xảy ra khi grant cuối phiên
                session.getXpEarned(),      // sessionXp = pending XP tích lũy
                reviewed,
                session.getTotalCards(),
                java.util.List.of()
        );
    }

    // ── Session summary ──────────────────────────────────────────────────

    @Transactional
    public StudySessionSummaryResponse getSummary(String firebaseUid, UUID sessionId) {
        User user = loadUser(firebaseUid);
        StudySession session = sessionRepository.findByIdAndUser_FirebaseUid(sessionId, firebaseUid)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Study session not found"));

        int reviewed = nullToZero(session.getMasteredCards())
                + nullToZero(session.getHardCards())
                + nullToZero(session.getAgainCards());

        // XP của session: chỉ grant khi phiên VỪA hoàn thành (review hết thẻ). Thoát
        // giữa chừng → session vẫn "active" → không grant → 0 XP cho phiên đó.
        XpGrantResult xpResult = null;
        boolean justCompleted = "active".equalsIgnoreCase(session.getStatus())
                && reviewed >= nullToZero(session.getTotalCards());
        if (justCompleted) {
            session.setStatus("completed");
            session.setCompletedAt(LocalDateTime.now());
            session = sessionRepository.save(session);

            int sessionXp = nullToZero(session.getXpEarned());
            // Grant 1 lần cho cả phiên. Idempotency theo sessionId (KHÔNG kèm ngày)
            // → gọi summary nhiều lần chỉ cộng đúng 1 lần. amount<=0 thì grant tự bỏ qua.
            xpResult = xpService.grant(
                    user.getId(),
                    sessionXp,
                    "sm2_review",
                    session.getId().toString(),
                    "sm2_session:" + session.getId() + ":complete",
                    java.util.Map.of(
                            "deskId", session.getDesk().getId().toString(),
                            "totalCards", nullToZero(session.getTotalCards())
                    )
            );
        }

        return new StudySessionSummaryResponse(
                session.getId(),
                session.getDesk().getId(),
                session.getStatus(),
                session.getTotalCards(),
                session.getMasteredCards(),
                session.getHardCards(),
                session.getAgainCards(),
                session.getXpEarned(),
                session.getNewWordsLearned(),
                session.getStartedAt(),
                session.getCompletedAt(),
                xpResult != null ? xpResult.totalXp() : null,
                xpResult != null && xpResult.streakUpdated(),
                xpResult != null ? xpResult.bonuses() : java.util.List.of()
        );
    }

    // ── Helpers ──────────────────────────────────────────────────────────

    private List<DueCardResponse> getDueCardsInternal(User user, Desk desk, int cap) {
        List<DueCardResponse> result = new ArrayList<>();
        LocalDateTime now = LocalDateTime.now();

        List<FlashcardProgress> due = progressRepository.findDueProgress(
                user.getId(), desk.getId(), now, PageRequest.of(0, cap));
        for (FlashcardProgress p : due) {
            result.add(toDueCard(p.getFlashcard(), p, false));
        }
        int remaining = cap - result.size();
        if (remaining > 0) {
            List<UUID> unseenIds = progressRepository.findUnseenFlashcardIds(
                    user.getId(), desk.getId(), PageRequest.of(0, remaining));
            if (!unseenIds.isEmpty()) {
                Map<UUID, Flashcard> byId = new HashMap<>();
                for (Flashcard fc : flashcardRepository.findAllById(unseenIds)) {
                    byId.put(fc.getId(), fc);
                }
                for (UUID id : unseenIds) {
                    Flashcard fc = byId.get(id);
                    if (fc != null) {
                        result.add(toDueCard(fc, null, true));
                    }
                }
            }
        }
        return result;
    }

    private static DueCardResponse toDueCard(Flashcard fc, FlashcardProgress p, boolean isNew) {
        return new DueCardResponse(
                fc.getId(),
                fc.getDesk().getId(),
                fc.getWord(),
                fc.getCefr(),
                fc.getIpa(),
                fc.getAudioUrl(),
                fc.getDefinition(),
                fc.getExample(),
                fc.getVietnamese(),
                fc.getViDefinition(),
                fc.getViExample(),
                p == null ? 0 : nullToZero(p.getRepetitions()),
                p == null ? 2.5 : p.getEasinessFactor(),
                p == null ? 0 : nullToZero(p.getIntervalDays()),
                p == null ? null : p.getNextReviewAt(),
                isNew
        );
    }

    private User loadUser(String firebaseUid) {
        return userRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "User profile not found. Please sync account first."));
    }

    private Desk loadAccessibleDesk(UUID deskId, UUID userId) {
        Desk desk = deskRepository.findById(deskId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Desk not found"));
        if (desk.getOwner() != null && !desk.getOwner().getId().equals(userId)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Desk not found");
        }
        return desk;
    }

    private static int clampLimit(int limit) {
        if (limit <= 0) return DEFAULT_LIMIT;
        return Math.min(limit, MAX_LIMIT);
    }

    private static int safeIncr(Integer v) {
        return (v == null ? 0 : v) + 1;
    }

    private static int nullToZero(Integer v) {
        return v == null ? 0 : v;
    }
}
