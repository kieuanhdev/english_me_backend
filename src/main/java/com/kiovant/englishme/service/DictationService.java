package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.DictationCompleteResponse;
import com.kiovant.englishme.dto.DictationSentenceResponse;
import com.kiovant.englishme.dto.DictationSessionResponse;
import com.kiovant.englishme.dto.XpGrantResult;
import com.kiovant.englishme.entity.DictationSentence;
import com.kiovant.englishme.entity.User;
import com.kiovant.englishme.repository.DictationSentenceRepository;
import com.kiovant.englishme.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * Luyện Nghe - chép chính tả (dictation). Khác exercise (không MCQ): TTS đọc
 * câu, user gõ lại, client chấm so khớp chuẩn hóa. Server cấp câu + lưu XP
 * (skill = listening). Không lưu phiên ở DB — sessionId chỉ làm khóa idempotency.
 */
@Service
public class DictationService {

    private static final int DEFAULT_SIZE = 5;
    private static final int MAX_SIZE = 20;
    /** Kỹ năng được cộng XP cho dictation. */
    private static final String SKILL = "listening";

    private final UserRepository userRepository;
    private final DictationSentenceRepository sentenceRepository;
    private final XpService xpService;
    private final XpRuleService xpRuleService;

    public DictationService(UserRepository userRepository,
                            DictationSentenceRepository sentenceRepository,
                            XpService xpService,
                            XpRuleService xpRuleService) {
        this.userRepository = userRepository;
        this.sentenceRepository = sentenceRepository;
        this.xpService = xpService;
        this.xpRuleService = xpRuleService;
    }

    @Transactional(readOnly = true)
    public DictationSessionResponse createSession(String firebaseUid, String level, int size) {
        loadUser(firebaseUid); // chỉ xác thực user tồn tại
        int cap = clampSize(size);

        String levelUpper = (level == null || level.isBlank()) ? null : level.trim().toUpperCase();
        List<DictationSentence> picked = levelUpper == null
                ? List.of()
                : sentenceRepository.findRandomByLevel(levelUpper, cap);
        if (picked.size() < cap) {
            // Thiếu câu đúng level → nới ra mọi level để phiên không rỗng.
            picked = sentenceRepository.findRandom(cap);
        }
        if (picked.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "No dictation sentences available");
        }

        List<DictationSentenceResponse> items = picked.stream()
                .map(s -> new DictationSentenceResponse(
                        s.getId().toString(),
                        s.getCefrLevel(),
                        s.getText(),
                        s.getHint(),
                        s.getAudioUrl()))
                .toList();

        String sessionId = UUID.randomUUID().toString();
        return new DictationSessionResponse(sessionId, levelUpper, items.size(), items);
    }

    @Transactional
    public DictationCompleteResponse complete(String firebaseUid, String sessionId, int correct, int total) {
        User user = loadUser(firebaseUid);
        if (sessionId == null || sessionId.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "sessionId is required");
        }
        if (total <= 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "total must be > 0");
        }
        int safeCorrect = Math.max(0, Math.min(correct, total));
        double accuracy = Math.round((safeCorrect * 1000.0) / total) / 10.0;

        // XP theo độ chính xác — tái dùng rule 'exercise'. skillOverride = listening.
        int candidateXp = xpRuleService.computeAccuracyBased("exercise", safeCorrect, total);
        XpGrantResult xp = xpService.grant(
                user.getId(),
                candidateXp,
                "dictation",
                sessionId,
                "dictation:" + sessionId + ":complete",
                Map.of("correct", safeCorrect, "total", total, "accuracy", accuracy),
                SKILL
        );

        return new DictationCompleteResponse(
                total,
                safeCorrect,
                total - safeCorrect,
                accuracy,
                xp.xpEarned(),
                xp.totalXp(),
                xp.dailyEarnedXp(),
                xp.streakUpdated(),
                xp.bonuses()
        );
    }

    private static int clampSize(int size) {
        if (size <= 0) return DEFAULT_SIZE;
        return Math.min(size, MAX_SIZE);
    }

    private User loadUser(String firebaseUid) {
        return userRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "User profile not found. Please sync account first."));
    }
}
