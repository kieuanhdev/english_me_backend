package com.kiovant.englishme.controller;

import com.google.firebase.auth.FirebaseToken;
import com.kiovant.englishme.dto.PronunciationAssessResponse;
import com.kiovant.englishme.dto.PronunciationAssessTextRequest;
import com.kiovant.englishme.dto.PronunciationExerciseResponse;
import com.kiovant.englishme.dto.PronunciationInsightResponse;
import com.kiovant.englishme.entity.User;
import com.kiovant.englishme.repository.PronunciationExerciseRepository;
import com.kiovant.englishme.repository.UserRepository;
import com.kiovant.englishme.service.FirebaseAuthHelper;
import com.kiovant.englishme.service.PronunciationAssessmentService;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.util.List;
import java.util.Set;
import java.util.UUID;

@RestController
@RequestMapping("/api/pronunciation")
public class PronunciationApiController {

    private static final List<String> CEFR_ORDER = List.of("A1", "A2", "B1", "B2", "C1", "C2");

    // Giới hạn upload audio: 10MB + chỉ nhận MIME audio phổ biến (WAV/MP3/AAC/OGG).
    private static final long MAX_AUDIO_BYTES = 10L * 1024 * 1024;
    private static final Set<String> ALLOWED_AUDIO_TYPES = Set.of(
            "audio/wav", "audio/x-wav", "audio/wave", "audio/vnd.wave",
            "audio/mpeg", "audio/mp3", "audio/mp4", "audio/aac", "audio/ogg",
            "application/octet-stream" // một số client mobile gửi WAV với type generic
    );

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
    public List<PronunciationExerciseResponse> exercises(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestParam(value = "level", required = false, defaultValue = "") String level,
            @RequestParam(value = "keyword", required = false, defaultValue = "") String keyword
    ) {
        // Không có header Authorization -> khách vãng lai, hiển thị từ A1.
        // Có header nhưng token hỏng/hết hạn -> 401 (KHÔNG nuốt lỗi auth rồi
        // âm thầm phục vụ như A1 — che mất bug phía client).
        String userLevel;
        if (authorization == null || authorization.isBlank()) {
            userLevel = "A1";
        } else {
            FirebaseToken token = authHelper.verifyBearer(authorization);
            userLevel = userRepository.findByFirebaseUid(token.getUid())
                    .map(User::getCefrLevel)
                    .filter(l -> l != null && !l.isBlank())
                    .map(String::toUpperCase)
                    .orElse("A1");
        }

        int idx = CEFR_ORDER.indexOf(userLevel);
        List<String> allowedLevels = idx < 0
                ? CEFR_ORDER
                : CEFR_ORDER.subList(0, idx + 1);

        return exerciseRepository.findForLearner(allowedLevels, level.trim(), keyword.trim())
                .stream()
                .map(PronunciationExerciseResponse::from)
                .toList();
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

    /**
     * Chấm phát âm từ AUDIO thật (đề cương MT4): client upload file audio (LINEAR16/WAV
     * PCM mono 16kHz), backend gọi Google Cloud Speech-to-Text ra transcript rồi chấm
     * Levenshtein.
     *
     * Trả 422 UNPROCESSABLE_ENTITY khi STT chưa bật / không nhận ra tiếng nói — client
     * bắt mã này để fallback: tự STT on-device rồi gọi /assess-text.
     */
    @PostMapping(value = "/assess-audio", consumes = "multipart/form-data")
    public PronunciationAssessResponse assessAudio(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestPart("audio") MultipartFile audio,
            @RequestParam("referenceText") String referenceText,
            @RequestParam(value = "exerciseId", required = false) UUID exerciseId,
            @RequestParam(value = "lessonItemId", required = false) UUID lessonItemId
    ) {
        if (audio == null || audio.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "audio file is required");
        }
        if (audio.getSize() > MAX_AUDIO_BYTES) {
            throw new ResponseStatusException(HttpStatus.PAYLOAD_TOO_LARGE, "audio file exceeds 10MB");
        }
        String contentType = audio.getContentType();
        if (contentType == null || !ALLOWED_AUDIO_TYPES.contains(contentType.toLowerCase())) {
            throw new ResponseStatusException(HttpStatus.UNSUPPORTED_MEDIA_TYPE,
                    "unsupported audio type: " + contentType);
        }
        UUID exId = exerciseId != null ? exerciseId : lessonItemId;
        FirebaseToken token = authHelper.verifyBearer(authorization);

        byte[] bytes;
        try {
            bytes = audio.getBytes();
        } catch (IOException e) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "cannot read audio file");
        }

        PronunciationAssessResponse result =
                pronunciationAssessmentService.assessAudio(token.getUid(), referenceText, bytes, exId);
        if (result == null) {
            // STT chưa bật hoặc không nhận ra -> client fallback assess-text on-device.
            throw new ResponseStatusException(HttpStatus.UNPROCESSABLE_ENTITY, "stt_unavailable");
        }
        return result;
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
