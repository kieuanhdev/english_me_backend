package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.AdminStudySessionDetail;
import com.kiovant.englishme.dto.AdminStudySessionRow;
import com.kiovant.englishme.entity.Desk;
import com.kiovant.englishme.entity.StudySession;
import com.kiovant.englishme.entity.User;
import com.kiovant.englishme.repository.StudySessionRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
public class AdminStudySessionService {

    private final StudySessionRepository sessionRepository;

    public AdminStudySessionService(StudySessionRepository sessionRepository) {
        this.sessionRepository = sessionRepository;
    }

    // ── List ────────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public Page<AdminStudySessionRow> list(String status, String keyword, UUID deskId, int page, int size) {
        int safePage = Math.max(page, 0);
        int safeSize = Math.min(Math.max(size, 1), 100);
        Page<StudySession> result = sessionRepository.searchForAdmin(
                status == null ? "" : status.trim(),
                keyword == null ? "" : keyword.trim(),
                deskId,
                PageRequest.of(safePage, safeSize));
        return result.map(this::toRow);
    }

    @Transactional(readOnly = true)
    public AdminStudySessionDetail getDetail(UUID id) {
        StudySession s = sessionRepository.findWithUserAndDeskById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Study session không tồn tại."));
        return toDetail(s);
    }

    // ── Mapping ─────────────────────────────────────────────────────────────

    private AdminStudySessionRow toRow(StudySession s) {
        User u = s.getUser();
        Desk d = s.getDesk();
        return new AdminStudySessionRow(
                s.getId(),
                u == null ? null : u.getId(),
                u == null ? null : u.getFullName(),
                u == null ? null : u.getEmail(),
                d == null ? null : d.getId(),
                d == null ? null : d.getTitle(),
                d == null ? null : d.getCefrLevel(),
                s.getStatus(),
                s.getTotalCards(),
                s.getMasteredCards(),
                s.getHardCards(),
                s.getAgainCards(),
                s.getXpEarned(),
                s.getNewWordsLearned(),
                s.getStartedAt(),
                s.getCompletedAt());
    }

    private AdminStudySessionDetail toDetail(StudySession s) {
        User u = s.getUser();
        Desk d = s.getDesk();
        LocalDateTime end = s.getCompletedAt() != null ? s.getCompletedAt() : LocalDateTime.now();
        Long durationSeconds = s.getStartedAt() == null
                ? null
                : Math.max(0L, Duration.between(s.getStartedAt(), end).getSeconds());

        int again = nullToZero(s.getAgainCards());
        int hard = nullToZero(s.getHardCards());
        int mastered = nullToZero(s.getMasteredCards());
        int total = nullToZero(s.getTotalCards());
        int reviewed = again + hard + mastered;
        int remaining = Math.max(0, total - reviewed);

        /*
         * Quality 1-5 per card chưa được lưu trong DB (session chỉ aggregate 3 nhóm).
         * Mapping tạm:
         *   Quality 1-2  → "Again" (q < 3)
         *   Quality 3    → "Hard"
         *   Quality 4-5  → "Mastered" (q ≥ 4)
         */
        List<AdminStudySessionDetail.QualityBucket> buckets = new ArrayList<>();
        buckets.add(new AdminStudySessionDetail.QualityBucket("Again (q 1-2)", again));
        buckets.add(new AdminStudySessionDetail.QualityBucket("Hard (q 3)", hard));
        buckets.add(new AdminStudySessionDetail.QualityBucket("Mastered (q 4-5)", mastered));
        buckets.add(new AdminStudySessionDetail.QualityBucket("Chưa review", remaining));

        return new AdminStudySessionDetail(
                s.getId(),
                u == null ? null : u.getId(),
                u == null ? null : u.getFullName(),
                u == null ? null : u.getEmail(),
                d == null ? null : d.getId(),
                d == null ? null : d.getTitle(),
                d == null ? null : d.getCefrLevel(),
                s.getStatus(),
                s.getTotalCards(),
                s.getMasteredCards(),
                s.getHardCards(),
                s.getAgainCards(),
                s.getXpEarned(),
                s.getNewWordsLearned(),
                s.getStartedAt(),
                s.getCompletedAt(),
                durationSeconds,
                buckets);
    }

    private static int nullToZero(Integer v) {
        return v == null ? 0 : v;
    }
}
