package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.CurriculumCompleteRequest;
import com.kiovant.englishme.dto.CurriculumDtos.*;
import com.kiovant.englishme.dto.CurriculumGradeDtos.*;
import com.kiovant.englishme.dto.GeneratePracticeRequest;
import com.kiovant.englishme.dto.GeneratePracticeResponse;
import com.kiovant.englishme.dto.XpGrantResult;
import com.kiovant.englishme.entity.*;
import com.kiovant.englishme.repository.*;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Service cho luồng GIÁO TRÌNH mới: Level → Unit → Lesson → Theory/Practice/Quiz.
 *
 * <p>Chạy SONG SONG với LearningService (paths cũ) — KHÔNG đụng /hub, /paths để tránh
 * regression. Endpoint riêng dưới /api/learning/curriculum/*.
 *
 * <p>Bám KE_HOACH_BE_BAI_TAP_VA_DU_LIEU.md: 1 bảng câu hỏi đa hình (learning_lesson_activities)
 * + cờ phase/counts_toward_mastery. Mastery gating: theory_viewed → practice → quiz ≥ pass.
 */
@Service
public class CurriculumService {

    private static final List<String> CEFR_ORDER = List.of("A1", "A2", "B1", "B2", "C1", "C2");
    private static final String DEFAULT_LEVEL = "A1";

    private final UserRepository userRepository;
    private final UserLevelRepository userLevelRepository;
    private final LearningUnitRepository unitRepository;
    private final LearningLessonRepository lessonRepository;
    private final LearningLessonActivityRepository activityRepository;
    private final UserUnitProgressRepository unitProgressRepository;
    private final UserLessonProgressRepository lessonProgressRepository;
    private final UserLessonAttemptRepository lessonAttemptRepository;
    private final XpService xpService;
    private final CurriculumGradingService gradingService;
    private final PracticeGenerationService practiceGenerationService;

    public CurriculumService(UserRepository userRepository,
                             UserLevelRepository userLevelRepository,
                             LearningUnitRepository unitRepository,
                             LearningLessonRepository lessonRepository,
                             LearningLessonActivityRepository activityRepository,
                             UserUnitProgressRepository unitProgressRepository,
                             UserLessonProgressRepository lessonProgressRepository,
                             UserLessonAttemptRepository lessonAttemptRepository,
                             XpService xpService,
                             CurriculumGradingService gradingService,
                             PracticeGenerationService practiceGenerationService) {
        this.userRepository = userRepository;
        this.userLevelRepository = userLevelRepository;
        this.unitRepository = unitRepository;
        this.lessonRepository = lessonRepository;
        this.activityRepository = activityRepository;
        this.unitProgressRepository = unitProgressRepository;
        this.lessonProgressRepository = lessonProgressRepository;
        this.lessonAttemptRepository = lessonAttemptRepository;
        this.xpService = xpService;
        this.gradingService = gradingService;
        this.practiceGenerationService = practiceGenerationService;
    }

    // ═══════════════════════════════════════════════════════════════════
    // POST /curriculum/lessons/{lessonId}/practice/generate
    // Sinh thêm câu hỏi trắc nghiệm (AI) từ lý thuyết bài học. KHÔNG ảnh
    // hưởng XP/mastery — chỉ để người học luyện thêm. Chấm điểm ở client.
    // ═══════════════════════════════════════════════════════════════════
    @Transactional(readOnly = true)
    public GeneratePracticeResponse generateExtraPractice(String firebaseUid, String lessonId,
                                                          GeneratePracticeRequest request) {
        loadUser(firebaseUid); // chỉ cần xác thực người dùng tồn tại
        LearningLesson lesson = lessonRepository.findById(lessonId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Lesson not found: " + lessonId));
        List<String> existing = request != null && request.existingQuestions() != null
                ? request.existingQuestions() : List.of();
        int count = request != null ? request.count() : 5;
        return new GeneratePracticeResponse(
                practiceGenerationService.generate(lesson, existing, count));
    }

    // ═══════════════════════════════════════════════════════════════════
    // GET /curriculum/levels/{level}/units
    // ═══════════════════════════════════════════════════════════════════
    @Transactional
    public LevelUnits getLevelUnits(String firebaseUid, String level) {
        User user = loadUser(firebaseUid);
        validateLevel(level);

        List<LearningUnit> units = unitRepository.findByLevelCodeAndIsActiveTrueOrderByDisplayOrderAsc(level);
        Map<String, UserUnitProgress> progressMap = ensureUnitProgress(user.getId(), units);

        List<UnitSummary> summaries = new ArrayList<>(units.size());
        int completedUnits = 0;
        for (LearningUnit u : units) {
            UserUnitProgress up = progressMap.get(u.getId());
            String status = up != null ? up.getStatus() : "locked";
            int total = up != null ? up.getTotalLessons() : 0;
            int done = up != null ? up.getCompletedLessons() : 0;
            if ("completed".equals(status)) completedUnits++;
            summaries.add(new UnitSummary(
                    u.getId(), u.getLevelCode(), u.getTitle(), u.getSubtitle(),
                    u.getDisplayOrder(), status, total, done,
                    u.getSkillCoverage() != null ? u.getSkillCoverage() : List.of()
            ));
        }

        int totalUnits = units.size();
        double levelProgress = totalUnits == 0 ? 0.0 : (double) completedUnits / totalUnits;
        boolean checkpointUnlocked = totalUnits > 0 && levelProgress >= 0.8; // Pha 4 mới mở thật

        return new LevelUnits(level, levelProgress, completedUnits, totalUnits, checkpointUnlocked, summaries);
    }

    // ═══════════════════════════════════════════════════════════════════
    // GET /curriculum/units/{unitId}
    // ═══════════════════════════════════════════════════════════════════
    @Transactional
    public UnitDetail getUnitDetail(String firebaseUid, String unitId) {
        User user = loadUser(firebaseUid);
        LearningUnit unit = unitRepository.findById(unitId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Unit not found: " + unitId));

        List<LearningLesson> lessons = lessonRepository.findByUnitIdAndIsActiveTrueOrderByLessonOrderAsc(unitId);
        Map<String, UserLessonProgress> lpMap = lessonProgressRepository
                .findByUserIdAndLessonIdIn(user.getId(), lessons.stream().map(LearningLesson::getId).toList())
                .stream().collect(Collectors.toMap(UserLessonProgress::getLessonId, p -> p));

        // Đảm bảo unit progress tồn tại (mở Unit đầu của level theo current_level).
        ensureUnitProgress(user.getId(), List.of(unit));

        List<LessonListItem> items = new ArrayList<>(lessons.size());
        int completed = 0;
        boolean prevCompleted = true; // lesson đầu available
        for (LearningLesson l : lessons) {
            UserLessonProgress lp = lpMap.get(l.getId());
            String status;
            if (lp != null && "completed".equals(lp.getStatus())) {
                status = "completed";
                completed++;
                prevCompleted = true;
            } else if (prevCompleted) {
                status = (lp != null && "in_progress".equals(lp.getStatus())) ? "in_progress" : "available";
                prevCompleted = false; // gating tuần tự: chỉ mở 1 lesson kế
            } else {
                status = "locked";
            }
            items.add(new LessonListItem(
                    l.getId(), l.getTitle(), l.getSubtitle(), l.getSkillCode(),
                    l.getLessonOrder(), status,
                    lp != null && Boolean.TRUE.equals(lp.getTheoryViewed()),
                    lp != null && lp.getBestScore() != null ? lp.getBestScore() : 0,
                    l.getXpReward(), l.getDurationMinutes()
            ));
        }

        UserUnitProgress up = unitProgressRepository
                .findById(new UserUnitProgressId(user.getId(), unitId)).orElse(null);
        String unitStatus = up != null ? up.getStatus() : "available";

        return new UnitDetail(
                unit.getId(), unit.getLevelCode(), unit.getTitle(), unit.getSubtitle(),
                unitStatus, completed, lessons.size(), items
        );
    }

    // ═══════════════════════════════════════════════════════════════════
    // GET /curriculum/lessons/{lessonId}  → theory + exercises(practice) + quiz
    // ═══════════════════════════════════════════════════════════════════
    @Transactional(readOnly = true)
    public LessonDetail getLessonDetail(String firebaseUid, String lessonId) {
        User user = loadUser(firebaseUid);
        LearningLesson lesson = lessonRepository.findById(lessonId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Lesson not found: " + lessonId));

        List<LearningLessonActivity> activities = activityRepository.findByLessonIdOrderByDisplayOrderAsc(lessonId);
        List<Map<String, Object>> exercises = new ArrayList<>();
        List<Map<String, Object>> quiz = new ArrayList<>();
        for (LearningLessonActivity a : activities) {
            Map<String, Object> dto = activityToMap(a);
            if ("quiz".equals(a.getPhase())) quiz.add(dto);
            else if ("practice".equals(a.getPhase())) exercises.add(dto);
            // phase=theory: hiện không dùng riêng (lý thuyết nằm ở theory_content)
        }

        UserLessonProgress lp = lessonProgressRepository
                .findById(new UserLessonProgressId(user.getId(), lessonId)).orElse(null);
        boolean theoryViewed = lp != null && Boolean.TRUE.equals(lp.getTheoryViewed());
        boolean practiceCompleted = lp != null && Boolean.TRUE.equals(lp.getPracticeCompleted());
        String status = lp != null ? lp.getStatus() : "available";
        int bestScore = lp != null && lp.getBestScore() != null ? lp.getBestScore() : 0;
        int lastScore = lp != null && lp.getLastScore() != null ? lp.getLastScore() : 0;

        // Tiến độ unit để FE dựng lại màn Kết quả khi mở bài đã hoàn thành.
        UserUnitProgress up = unitProgressRepository
                .findById(new UserUnitProgressId(user.getId(), lesson.getUnitId())).orElse(null);
        int totalLessons = up != null && up.getTotalLessons() != null ? up.getTotalLessons() : 0;
        int completedLessons = up != null && up.getCompletedLessons() != null ? up.getCompletedLessons() : 0;
        double unitProgress = totalLessons > 0 ? (double) completedLessons / totalLessons : 0.0;
        boolean unitCompleted = up != null && "completed".equals(up.getStatus());

        return new LessonDetail(
                lesson.getId(), lesson.getUnitId(), lesson.getLevelCode(), lesson.getSkillCode(),
                lesson.getTitle(), lesson.getSubtitle(), lesson.getXpReward(),
                lesson.getRequiredScoreToPass() != null ? lesson.getRequiredScoreToPass() : 70,
                theoryViewed,
                practiceCompleted,
                status,
                bestScore,
                lastScore,
                unitProgress,
                unitCompleted,
                lesson.getTheoryContent() != null ? lesson.getTheoryContent() : Map.of(),
                exercises, quiz
        );
    }

    // ═══════════════════════════════════════════════════════════════════
    // POST /curriculum/lessons/{lessonId}/theory/complete
    // ═══════════════════════════════════════════════════════════════════
    @Transactional
    public void completeTheory(String firebaseUid, String lessonId) {
        User user = loadUser(firebaseUid);
        LearningLesson lesson = lessonRepository.findById(lessonId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Lesson not found: " + lessonId));

        UserLessonProgress lp = lessonProgressRepository
                .findById(new UserLessonProgressId(user.getId(), lessonId))
                .orElseGet(() -> newLessonProgress(user.getId(), lesson));
        lp.setTheoryViewed(true);
        if ("locked".equals(lp.getStatus())) lp.setStatus("in_progress");
        else if ("available".equals(lp.getStatus())) lp.setStatus("in_progress");
        lessonProgressRepository.save(lp);
    }

    // ═══════════════════════════════════════════════════════════════════
    // POST /curriculum/lessons/{lessonId}/exercises/submit  (PRACTICE — BE chấm, không mastery)
    // ═══════════════════════════════════════════════════════════════════
    @Transactional
    public ExercisesResult submitExercises(String firebaseUid, String lessonId, SubmitRequest req) {
        User user = loadUser(firebaseUid);
        lessonRepository.findById(lessonId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Lesson not found: " + lessonId));

        // Chỉ chấm activity phase=practice của lesson.
        Map<String, LearningLessonActivity> practiceById = activityRepository
                .findByLessonIdOrderByDisplayOrderAsc(lessonId).stream()
                .filter(a -> "practice".equals(a.getPhase()))
                .collect(Collectors.toMap(LearningLessonActivity::getId, a -> a, (x, y) -> x));

        List<Map<String, Object>> answers = req.answers() != null ? req.answers() : List.of();
        List<AnswerFeedback> feedback = new ArrayList<>();
        List<String> retry = new ArrayList<>();
        int correct = 0;
        for (Map<String, Object> ans : answers) {
            String activityId = ans == null ? null : String.valueOf(ans.get("activityId"));
            LearningLessonActivity act = activityId == null ? null : practiceById.get(activityId);
            if (act == null) continue; // bỏ qua đáp án không khớp activity practice
            CurriculumGradingService.Graded g = gradingService.grade(act, ans);
            if (g.correct()) correct++;
            else retry.add(act.getId());
            feedback.add(new AnswerFeedback(
                    g.activityId(), g.type(), g.correct(), g.autoGraded(),
                    g.correctAnswer(), g.explanationVi()));
        }

        // Đánh dấu practice_completed khi đã làm hết câu practice và không còn câu sai.
        boolean allDone = correct == practiceById.size() && retry.isEmpty() && !practiceById.isEmpty();
        if (allDone) {
            UserLessonProgress lp = lessonProgressRepository
                    .findById(new UserLessonProgressId(user.getId(), lessonId))
                    .orElseGet(() -> {
                        LearningLesson l = lessonRepository.findById(lessonId).orElseThrow();
                        return newLessonProgress(user.getId(), l);
                    });
            lp.setPracticeCompleted(true);
            if ("available".equals(lp.getStatus()) || "locked".equals(lp.getStatus())) {
                lp.setStatus("in_progress");
            }
            lessonProgressRepository.save(lp);
        }

        return new ExercisesResult(practiceById.size(), correct, retry, feedback);
    }

    // ═══════════════════════════════════════════════════════════════════
    // POST /curriculum/lessons/{lessonId}/complete  (nộp mini-quiz, BE TỰ chấm, tính mastery)
    // ═══════════════════════════════════════════════════════════════════
    @Transactional
    public LessonResult completeLesson(String firebaseUid, String lessonId, CurriculumCompleteRequest req) {
        User user = loadUser(firebaseUid);
        LearningLesson lesson = lessonRepository.findById(lessonId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Lesson not found: " + lessonId));

        int timeSpent = req.timeSpentSeconds() != null ? req.timeSpentSeconds() : 0;
        int passThreshold = lesson.getRequiredScoreToPass() != null ? lesson.getRequiredScoreToPass() : 70;

        UserLessonProgress lp = lessonProgressRepository
                .findById(new UserLessonProgressId(user.getId(), lessonId))
                .orElseGet(() -> newLessonProgress(user.getId(), lesson));

        // Hard-gating: phải xem lý thuyết trước khi nộp quiz (409 THEORY_REQUIRED).
        if (!Boolean.TRUE.equals(lp.getTheoryViewed())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "THEORY_REQUIRED");
        }

        // ── BE TỰ CHẤM quiz từ đáp án thô (counts_toward_mastery=true) ──
        Map<String, LearningLessonActivity> quizById = activityRepository
                .findByLessonIdOrderByDisplayOrderAsc(lessonId).stream()
                .filter(a -> "quiz".equals(a.getPhase()) && Boolean.TRUE.equals(a.getCountsTowardMastery()))
                .collect(Collectors.toMap(LearningLessonActivity::getId, a -> a, (x, y) -> x));

        List<Map<String, Object>> answers = req.answers() != null ? req.answers() : List.of();
        int quizTotal = quizById.size();
        int quizCorrect = 0;
        for (Map<String, Object> ans : answers) {
            String activityId = ans == null ? null : String.valueOf(ans.get("activityId"));
            LearningLessonActivity act = activityId == null ? null : quizById.get(activityId);
            if (act == null) continue;
            if (gradingService.grade(act, ans).correct()) quizCorrect++;
        }
        // Fallback: nếu FE (tạm) vẫn gửi score và không gửi answers → dùng score.
        int score = quizTotal > 0
                ? (int) Math.round((double) quizCorrect / quizTotal * 100)
                : (req.score() != null ? req.score() : 0);

        boolean firstTimePass = !"completed".equals(lp.getStatus());
        boolean passed = score >= passThreshold;

        // 1) Lưu attempt (audit).
        UserLessonAttempt attempt = new UserLessonAttempt();
        attempt.setUserId(user.getId());
        attempt.setLessonId(lessonId);
        attempt.setScore((short) score);
        attempt.setXpEarned((short) 0);
        attempt.setTimeSpentSeconds(timeSpent);
        attempt.setAnswers(answers);
        lessonAttemptRepository.save(attempt);

        // 2) Cập nhật lesson progress.
        lp.setLastScore((short) score);
        if (lp.getBestScore() == null || score > lp.getBestScore()) lp.setBestScore((short) score);
        lp.setAttempts((lp.getAttempts() == null ? 0 : lp.getAttempts()) + 1);
        lp.setTimeSpentSeconds((lp.getTimeSpentSeconds() == null ? 0 : lp.getTimeSpentSeconds()) + timeSpent);
        if (passed) {
            lp.setStatus("completed");
            lp.setPracticeCompleted(true);
            if (lp.getMasteredAt() == null) lp.setMasteredAt(Instant.now());
            if (lp.getCompletedAt() == null) lp.setCompletedAt(Instant.now());
        } else if (!"completed".equals(lp.getStatus())) {
            lp.setStatus("in_progress");
        }
        lessonProgressRepository.save(lp);

        // 3) XP idempotent (chỉ pass lần đầu) — dùng chung key pattern với flow cũ.
        int actualXp = 0;
        XpGrantResult xp;
        if (passed && firstTimePass) {
            xp = xpService.grant(
                    user.getId(),
                    lesson.getXpReward(),
                    "lesson",
                    lessonId,
                    "lesson:" + lessonId + ":first_pass",
                    Map.of("score", score, "lessonId", lessonId,
                            "unitId", lesson.getUnitId() == null ? "" : lesson.getUnitId()),
                    // Cộng XP đúng kỹ năng của bài (reading/listening/...) thay vì luôn grammar.
                    lesson.getSkillCode()
            );
            actualXp = xp.xpEarned();
            lp.setXpEarned((lp.getXpEarned() == null ? 0 : lp.getXpEarned()) + actualXp);
            lessonProgressRepository.save(lp);
            attempt.setXpEarned((short) actualXp);
            lessonAttemptRepository.save(attempt);
        } else {
            // Không cộng XP (chưa pass hoặc đã pass trước đó) nhưng vẫn trả totalXp
            // + dailyEarnedXp hiện tại để FE đồng bộ state (Home/Progress/Profile).
            xp = xpService.readOnlyResult(user.getId(), 0, false, !firstTimePass);
        }

        // 4) Cập nhật unit progress + mở lesson/unit kế.
        double unitProgress = 0.0;
        boolean unitCompleted = false;
        String nextLessonId = null;
        if (lesson.getUnitId() != null) {
            UnitRollup rollup = recomputeUnitProgress(user.getId(), lesson.getUnitId());
            unitProgress = rollup.progress();
            unitCompleted = rollup.completed();
            if (passed) nextLessonId = findNextLessonInUnit(lesson.getUnitId(), lessonId);
        }

        return new LessonResult(
                passed, score, actualXp, unitProgress, unitCompleted, nextLessonId,
                xp.totalXp(), xp.dailyEarnedXp(), xp.streakUpdated(), xp.bonuses(), xp.newBadges());
    }

    // ═══════════════════════════════════════════════════════════════════
    // Helpers
    // ═══════════════════════════════════════════════════════════════════

    private User loadUser(String firebaseUid) {
        return userRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
    }

    private void validateLevel(String level) {
        if (level == null || !CEFR_ORDER.contains(level)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid level: " + level);
        }
    }

    private UserLessonProgress newLessonProgress(UUID userId, LearningLesson lesson) {
        UserLessonProgress n = new UserLessonProgress();
        n.setUserId(userId);
        n.setLessonId(lesson.getId());
        n.setStatus("available");
        return n;
    }

    /**
     * Bootstrap user_unit_progress cho các unit của level đang xem.
     * Unit đầu (display_order==1) của level mở 'available'; còn lại 'locked'.
     * (Pha 2 mở khoá tuần tự; bootstrap theo current_level làm kỹ hơn ở Pha sau.)
     */
    private Map<String, UserUnitProgress> ensureUnitProgress(UUID userId, List<LearningUnit> units) {
        if (units.isEmpty()) return Map.of();
        List<String> ids = units.stream().map(LearningUnit::getId).toList();
        Map<String, UserUnitProgress> existing = unitProgressRepository
                .findByUserIdAndUnitIdIn(userId, ids).stream()
                .collect(Collectors.toMap(UserUnitProgress::getUnitId, p -> p));

        for (LearningUnit u : units) {
            if (existing.containsKey(u.getId())) continue;
            UserUnitProgress up = new UserUnitProgress();
            up.setUserId(userId);
            up.setUnitId(u.getId());
            up.setStatus(u.getDisplayOrder() != null && u.getDisplayOrder() == 1 ? "available" : "locked");
            up.setTotalLessons((int) lessonRepository.countByUnitIdAndIsActiveTrue(u.getId()));
            up.setCompletedLessons(0);
            existing.put(u.getId(), unitProgressRepository.save(up));
        }
        return existing;
    }

    private record UnitRollup(double progress, boolean completed) {}

    /** Đếm lại lesson completed của unit → cập nhật status + mở unit kế khi completed. */
    private UnitRollup recomputeUnitProgress(UUID userId, String unitId) {
        List<LearningLesson> lessons = lessonRepository.findByUnitIdAndIsActiveTrueOrderByLessonOrderAsc(unitId);
        int total = lessons.size();
        Map<String, UserLessonProgress> lpMap = lessonProgressRepository
                .findByUserIdAndLessonIdIn(userId, lessons.stream().map(LearningLesson::getId).toList())
                .stream().collect(Collectors.toMap(UserLessonProgress::getLessonId, p -> p));
        int done = (int) lessons.stream()
                .filter(l -> {
                    UserLessonProgress lp = lpMap.get(l.getId());
                    return lp != null && "completed".equals(lp.getStatus());
                }).count();

        UserUnitProgress up = unitProgressRepository
                .findById(new UserUnitProgressId(userId, unitId))
                .orElseGet(() -> {
                    UserUnitProgress n = new UserUnitProgress();
                    n.setUserId(userId);
                    n.setUnitId(unitId);
                    return n;
                });
        up.setTotalLessons(total);
        up.setCompletedLessons(done);
        boolean completed = total > 0 && done >= total;
        if (completed) {
            up.setStatus("completed");
            if (up.getCompletedAt() == null) up.setCompletedAt(Instant.now());
        } else if (done > 0) {
            up.setStatus("in_progress");
            if (up.getStartedAt() == null) up.setStartedAt(Instant.now());
        }
        unitProgressRepository.save(up);

        // Mở khoá unit kế tiếp trong cùng level khi unit hiện tại completed.
        if (completed) {
            LearningUnit cur = unitRepository.findById(unitId).orElse(null);
            if (cur != null) {
                unitRepository.findByLevelCodeAndIsActiveTrueOrderByDisplayOrderAsc(cur.getLevelCode()).stream()
                        .filter(u -> cur.getDisplayOrder() != null
                                && u.getDisplayOrder() != null
                                && u.getDisplayOrder() == cur.getDisplayOrder() + 1)
                        .findFirst()
                        .ifPresent(next -> {
                            UserUnitProgress nx = unitProgressRepository
                                    .findById(new UserUnitProgressId(userId, next.getId()))
                                    .orElseGet(() -> {
                                        UserUnitProgress n = new UserUnitProgress();
                                        n.setUserId(userId);
                                        n.setUnitId(next.getId());
                                        n.setTotalLessons((int) lessonRepository.countByUnitIdAndIsActiveTrue(next.getId()));
                                        return n;
                                    });
                            if ("locked".equals(nx.getStatus())) {
                                nx.setStatus("available");
                                unitProgressRepository.save(nx);
                            }
                        });
            }
        }

        double progress = total == 0 ? 0.0 : (double) done / total;
        return new UnitRollup(progress, completed);
    }

    private String findNextLessonInUnit(String unitId, String currentLessonId) {
        List<LearningLesson> lessons = lessonRepository.findByUnitIdAndIsActiveTrueOrderByLessonOrderAsc(unitId);
        for (int i = 0; i < lessons.size(); i++) {
            if (currentLessonId.equals(lessons.get(i).getId()) && i + 1 < lessons.size()) {
                return lessons.get(i + 1).getId();
            }
        }
        return null;
    }

    /** Trả nguyên payload JSONB + thêm meta (id, type, phase, difficulty) để FE parse. */
    private Map<String, Object> activityToMap(LearningLessonActivity a) {
        Map<String, Object> m = new LinkedHashMap<>();
        if (a.getPayload() != null) m.putAll(a.getPayload());
        m.put("id", a.getId());
        m.put("type", a.getActivityType());
        m.put("phase", a.getPhase());
        if (a.getDifficulty() != null) m.put("difficulty", a.getDifficulty());
        return m;
    }
}
