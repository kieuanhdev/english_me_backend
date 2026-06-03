package com.kiovant.englishme.controller;

import com.kiovant.englishme.dto.CheckpointDtos.*;
import com.kiovant.englishme.dto.CurriculumCompleteRequest;
import com.kiovant.englishme.dto.CurriculumDtos.*;
import com.kiovant.englishme.dto.CurriculumGradeDtos.*;
import com.kiovant.englishme.dto.GeneratePracticeRequest;
import com.kiovant.englishme.dto.GeneratePracticeResponse;
import com.kiovant.englishme.service.CheckpointService;
import com.kiovant.englishme.service.CurriculumService;
import com.kiovant.englishme.service.FirebaseAuthHelper;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * API luồng GIÁO TRÌNH mới (Level → Unit → Lesson → Theory/Practice/Quiz).
 * Prefix /api/learning/curriculum/* — tách hẳn flow paths cũ (/hub, /paths).
 *
 * FE: đổi MockCurriculumRepository → ApiCurriculumRepository trỏ các path dưới đây.
 */
@RestController
@RequestMapping("/api/learning/curriculum")
public class CurriculumController {

    private final CurriculumService curriculumService;
    private final CheckpointService checkpointService;
    private final FirebaseAuthHelper authHelper;

    public CurriculumController(CurriculumService curriculumService,
                                CheckpointService checkpointService,
                                FirebaseAuthHelper authHelper) {
        this.curriculumService = curriculumService;
        this.checkpointService = checkpointService;
        this.authHelper = authHelper;
    }

    @GetMapping("/levels/{level}/units")
    public LevelUnits getLevelUnits(@RequestHeader("Authorization") String token,
                                    @PathVariable String level) {
        var decoded = authHelper.verifyBearer(token);
        return curriculumService.getLevelUnits(decoded.getUid(), level);
    }

    @GetMapping("/units/{unitId}")
    public UnitDetail getUnitDetail(@RequestHeader("Authorization") String token,
                                    @PathVariable String unitId) {
        var decoded = authHelper.verifyBearer(token);
        return curriculumService.getUnitDetail(decoded.getUid(), unitId);
    }

    @GetMapping("/lessons/{lessonId}")
    public LessonDetail getLessonDetail(@RequestHeader("Authorization") String token,
                                        @PathVariable String lessonId) {
        var decoded = authHelper.verifyBearer(token);
        return curriculumService.getLessonDetail(decoded.getUid(), lessonId);
    }

    @PostMapping("/lessons/{lessonId}/theory/complete")
    public void completeTheory(@RequestHeader("Authorization") String token,
                               @PathVariable String lessonId) {
        var decoded = authHelper.verifyBearer(token);
        curriculumService.completeTheory(decoded.getUid(), lessonId);
    }

    /** Nộp luyện tập — BE chấm từng câu, trả feedback. KHÔNG tính mastery. */
    @PostMapping("/lessons/{lessonId}/exercises/submit")
    public ExercisesResult submitExercises(@RequestHeader("Authorization") String token,
                                           @PathVariable String lessonId,
                                           @RequestBody SubmitRequest request) {
        var decoded = authHelper.verifyBearer(token);
        return curriculumService.submitExercises(decoded.getUid(), lessonId, request);
    }

    @PostMapping("/lessons/{lessonId}/complete")
    public LessonResult completeLesson(@RequestHeader("Authorization") String token,
                                       @PathVariable String lessonId,
                                       @RequestBody CurriculumCompleteRequest request) {
        var decoded = authHelper.verifyBearer(token);
        return curriculumService.completeLesson(decoded.getUid(), lessonId, request);
    }

    /** Sinh thêm câu hỏi trắc nghiệm (AI) từ lý thuyết bài — luyện thêm, không tính điểm/XP. */
    @PostMapping("/lessons/{lessonId}/practice/generate")
    public GeneratePracticeResponse generatePractice(@RequestHeader("Authorization") String token,
                                                     @PathVariable String lessonId,
                                                     @RequestBody GeneratePracticeRequest request) {
        var decoded = authHelper.verifyBearer(token);
        return curriculumService.generateExtraPractice(decoded.getUid(), lessonId, request);
    }

    // ── Level Checkpoint Test (Pha 4 — lên cấp CEFR) ──

    @GetMapping("/levels/{level}/checkpoint")
    public CheckpointState getCheckpoint(@RequestHeader("Authorization") String token,
                                         @PathVariable String level) {
        var decoded = authHelper.verifyBearer(token);
        return checkpointService.getCheckpoint(decoded.getUid(), level);
    }

    @PostMapping("/levels/{level}/checkpoint/submit")
    public CheckpointResult submitCheckpoint(@RequestHeader("Authorization") String token,
                                             @PathVariable String level,
                                             @RequestBody Map<String, Object> body) {
        var decoded = authHelper.verifyBearer(token);
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> answers =
                (List<Map<String, Object>>) body.getOrDefault("answers", List.of());
        return checkpointService.submitCheckpoint(decoded.getUid(), level, answers);
    }
}
