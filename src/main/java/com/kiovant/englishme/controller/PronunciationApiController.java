package com.kiovant.englishme.controller;

import com.google.firebase.auth.FirebaseToken;
import com.kiovant.englishme.dto.PronunciationAssessResponse;
import com.kiovant.englishme.dto.PronunciationAssessTextRequest;
import com.kiovant.englishme.dto.PronunciationAttemptHistoryItemResponse;
import com.kiovant.englishme.dto.PronunciationInsightResponse;
import com.kiovant.englishme.entity.PronunciationExercise;
import com.kiovant.englishme.entity.User;
import com.kiovant.englishme.repository.PronunciationExerciseRepository;
import com.kiovant.englishme.repository.UserRepository;
import com.kiovant.englishme.service.FirebaseAuthHelper;
import com.kiovant.englishme.service.PronunciationAssessmentService;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/pronunciation")
public class PronunciationApiController {

    private static final List<String> CEFR_ORDER = List.of("A1", "A2", "B1", "B2", "C1", "C2");

    private final PronunciationAssessmentService pronunciationAssessmentService;
    private final PronunciationExerciseRepository exerciseRepository;
    private final UserRepository userRepository;
    private final FirebaseAuthHelper authHelper;

    public PronunciationApiController(
            PronunciationAssessmentService pronunciationAssessmentService,
            PronunciationExerciseRepository exerciseRepository,
            UserRepository userRepository,
            FirebaseAuthHelper authHelper
    ) {
        this.pronunciationAssessmentService = pronunciationAssessmentService;
        this.exerciseRepository = exerciseRepository;
        this.userRepository = userRepository;
        this.authHelper = authHelper;
    }

    /**
     * Bài luyện âm theo level người học: thấy tất cả bài có level <= level của mình.
     * `level` (tùy chọn): lọc đúng một level cụ thể. `keyword`: tìm theo nội dung câu.
     */
    @GetMapping("/exercises")
    public List<PronunciationExercise> exercises(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestParam(value = "level", required = false, defaultValue = "") String level,
            @RequestParam(value = "keyword", required = false, defaultValue = "") String keyword
    ) {
        String userLevel = "C2";
        try {
            FirebaseToken token = authHelper.verifyBearer(authorization);
            userLevel = userRepository.findByFirebaseUid(token.getUid())
                    .map(User::getCefrLevel)
                    .filter(l -> l != null && !l.isBlank())
                    .map(String::toUpperCase)
                    .orElse("A1");
        } catch (Exception ignored) {
            // Chưa đăng nhập / chưa có level -> mặc định hiển thị từ A1.
            userLevel = "A1";
        }

        int idx = CEFR_ORDER.indexOf(userLevel);
        List<String> allowedLevels = idx < 0
                ? CEFR_ORDER
                : CEFR_ORDER.subList(0, idx + 1);

        return exerciseRepository.findForLearner(allowedLevels, level.trim(), keyword.trim());
    }

    @PostMapping("/assess")
    public PronunciationAssessResponse assess(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestParam("audio") MultipartFile audio,
            @RequestParam(value = "expectedText", required = false) String expectedText,
            @RequestParam(value = "referenceText", required = false) String referenceText,
            @RequestParam(value = "exerciseId", required = false) UUID exerciseId,
            @RequestParam(value = "lessonItemId", required = false) UUID lessonItemId,
            @RequestParam(value = "language", required = false, defaultValue = "en-us") String language
    ) {
        String text = expectedText != null ? expectedText : referenceText;
        UUID exId = exerciseId != null ? exerciseId : lessonItemId;
        FirebaseToken token = authHelper.verifyBearer(authorization);
        return pronunciationAssessmentService.assess(token.getUid(), audio, text, language, exId);
    }

    @PostMapping("/assess-text")
    public PronunciationAssessResponse assessText(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestBody PronunciationAssessTextRequest request
    ) {
        UUID exId = request.exerciseId() != null ? request.exerciseId() : request.lessonItemId();
        FirebaseToken token = authHelper.verifyBearer(authorization);
        return pronunciationAssessmentService.assessText(
                token.getUid(), request.referenceText(), request.spokenText(), exId);
    }

    @GetMapping("/history")
    public List<PronunciationAttemptHistoryItemResponse> history(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestParam(value = "exerciseId", required = false) UUID exerciseId,
            @RequestParam(value = "lessonItemId", required = false) UUID lessonItemId,
            @RequestParam(value = "limit", required = false, defaultValue = "20") int limit
    ) {
        UUID exId = exerciseId != null ? exerciseId : lessonItemId;
        FirebaseToken token = authHelper.verifyBearer(authorization);
        return pronunciationAssessmentService.history(token.getUid(), exId, limit);
    }

    /**
     * Insight cá nhân hóa phát âm: điểm TB, các từ phát âm yếu nhất, phân bố mức lỗi.
     * Tổng hợp từ toàn bộ lịch sử assess của user.
     */
    @GetMapping("/insights")
    public PronunciationInsightResponse insights(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestParam(value = "limit", required = false, defaultValue = "10") int limit
    ) {
        FirebaseToken token = authHelper.verifyBearer(authorization);
        return pronunciationAssessmentService.insights(token.getUid(), limit);
    }
}
