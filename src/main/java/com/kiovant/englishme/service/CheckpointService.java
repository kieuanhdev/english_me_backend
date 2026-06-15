package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.CheckpointDtos.*;
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
 * Level Checkpoint Test — cơ chế LÊN CẤP CEFR nội sinh (Pha 4).
 *
 * <p>Theo §3.4 kế hoạch (bản đơn giản): rút câu từ chính các activity phase='quiz'
 * của lesson trong level; mở khi độ phủ unit ≥ required_unit_progress; pass ≥ pass_score
 * → nâng current_level + 100 XP (level_bonus, idempotent).
 */
@Service
public class CheckpointService {

    private static final List<String> CEFR_ORDER = List.of("A1", "A2", "B1", "B2", "C1", "C2");
    /** Dạng được phép vào checkpoint (chấm tự động khách quan). */
    private static final Set<String> AUTO_TYPES = Set.of(
            "multiple_choice", "grammar_fill_blank", "vocabulary_match",
            "sentence_ordering", "listening_choice");

    private final UserRepository userRepository;
    private final UserLevelRepository userLevelRepository;
    private final LearningUnitRepository unitRepository;
    private final LearningLessonRepository lessonRepository;
    private final LearningLessonActivityRepository activityRepository;
    private final UserUnitProgressRepository unitProgressRepository;
    private final UserUnitProgressRepository uupRepo; // alias rõ nghĩa khi mở unit mới
    private final LevelCheckpointTestRepository checkpointRepository;
    private final CheckpointTestAttemptRepository attemptRepository;
    private final CurriculumGradingService gradingService;
    private final XpService xpService;
    private final XpRuleService xpRuleService;

    public CheckpointService(UserRepository userRepository,
                             UserLevelRepository userLevelRepository,
                             LearningUnitRepository unitRepository,
                             LearningLessonRepository lessonRepository,
                             LearningLessonActivityRepository activityRepository,
                             UserUnitProgressRepository unitProgressRepository,
                             LevelCheckpointTestRepository checkpointRepository,
                             CheckpointTestAttemptRepository attemptRepository,
                             CurriculumGradingService gradingService,
                             XpService xpService,
                             XpRuleService xpRuleService) {
        this.userRepository = userRepository;
        this.userLevelRepository = userLevelRepository;
        this.unitRepository = unitRepository;
        this.lessonRepository = lessonRepository;
        this.activityRepository = activityRepository;
        this.unitProgressRepository = unitProgressRepository;
        this.uupRepo = unitProgressRepository;
        this.checkpointRepository = checkpointRepository;
        this.attemptRepository = attemptRepository;
        this.gradingService = gradingService;
        this.xpService = xpService;
        this.xpRuleService = xpRuleService;
    }

    // ═══════════════════════════════════════════════════════════════════
    // GET /curriculum/levels/{level}/checkpoint
    // ═══════════════════════════════════════════════════════════════════
    @Transactional(readOnly = true)
    public CheckpointState getCheckpoint(String firebaseUid, String level) {
        User user = loadUser(firebaseUid);
        validateLevel(level);
        LevelCheckpointTest test = checkpointRepository.findByLevelCodeAndIsActiveTrue(level)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "No checkpoint for level " + level));

        double unitProgress = computeUnitProgress(user.getId(), level);
        double required = test.getRequiredUnitProgress().doubleValue();
        // Cho phép thi NGAY ("Thi luôn / bỏ qua") — không gác theo độ phủ unit nữa.
        // Ai muốn thử lên cấp mà chưa học hết unit vẫn vào thi được.
        boolean unlocked = true;
        boolean alreadyPassed = attemptRepository.existsByUserIdAndLevelCodeAndPassedTrue(user.getId(), level);
        String nextLevel = nextLevelOf(level);

        List<Map<String, Object>> questions = buildQuestions(level, test.getQuestionCount());

        return new CheckpointState(
                level, nextLevel, test.getTitle(), unlocked,
                round3(unitProgress), required, test.getPassScore(),
                alreadyPassed, questions
        );
    }

    // ═══════════════════════════════════════════════════════════════════
    // POST /curriculum/levels/{level}/checkpoint/submit
    // ═══════════════════════════════════════════════════════════════════
    @Transactional
    public CheckpointResult submitCheckpoint(String firebaseUid, String level, List<Map<String, Object>> answers) {
        User user = loadUser(firebaseUid);
        validateLevel(level);
        LevelCheckpointTest test = checkpointRepository.findByLevelCodeAndIsActiveTrue(level)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "No checkpoint for level " + level));

        // Không còn gate độ phủ unit — cho thi luôn để thử lên cấp (bỏ qua học).
        // BE chấm từ đáp án thô (lọc theo câu quiz thật của level).
        Map<String, LearningLessonActivity> byId = quizActivitiesOfLevel(level).stream()
                .collect(Collectors.toMap(LearningLessonActivity::getId, a -> a, (x, y) -> x));
        List<Map<String, Object>> ans = answers != null ? answers : List.of();
        int total = ans.size();
        int correct = 0;
        for (Map<String, Object> a : ans) {
            String activityId = a == null ? null : String.valueOf(a.get("activityId"));
            LearningLessonActivity act = activityId == null ? null : byId.get(activityId);
            if (act == null) continue;
            if (gradingService.grade(act, a).correct()) correct++;
        }
        int score = total > 0 ? (int) Math.round((double) correct / total * 100) : 0;
        boolean passed = score >= test.getPassScore();

        String fromLevel = level;
        String toLevel = nextLevelOf(level);
        boolean leveledUp = false;
        int xpEarned = 0;

        UserLevel ul = userLevelRepository.findById(user.getId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User level not found"));

        // Chỉ nâng nếu pass + có level kế + current_level đang ở đúng level này (không tụt/nhảy).
        boolean canPromote = passed && toLevel != null
                && CEFR_ORDER.indexOf(ul.getCurrentLevel()) <= CEFR_ORDER.indexOf(level);
        if (canPromote) {
            // +100 XP idempotent: key level:{from}:up → đã lên cấp 1 lần thì không cộng lại.
            int bonus = xpRuleService.baseAmount("level_bonus", 100);
            XpGrantResult xp = xpService.grant(
                    user.getId(), bonus, "level_bonus", level,
                    "level:" + fromLevel + ":up",
                    Map.of("fromLevel", fromLevel, "toLevel", toLevel, "score", score));
            xpEarned = xp.xpEarned();

            // Nâng current_level nếu đang thấp hơn toLevel.
            if (CEFR_ORDER.indexOf(ul.getCurrentLevel()) < CEFR_ORDER.indexOf(toLevel)) {
                ul.setCurrentLevel(toLevel);
                ul.setLastLevelUpAt(Instant.now());
                userLevelRepository.save(ul);
                // Đồng bộ luôn User.cefrLevel — đây là level mà dashboard/Home và 4
                // engine kỹ năng (dictation/reading/writing/...) đọc để chọn nội dung
                // theo trình độ. Nếu chỉ nâng user_level.current_level mà bỏ quên
                // cefrLevel thì lên cấp ở giáo trình KHÔNG kéo theo độ khó của 4 kỹ năng.
                if (CEFR_ORDER.indexOf(user.getCefrLevel()) < CEFR_ORDER.indexOf(toLevel)) {
                    user.setCefrLevel(toLevel);
                    userRepository.save(user);
                }
                leveledUp = true;
                openFirstUnitOfLevel(user.getId(), toLevel);
            } else {
                leveledUp = true; // đã ở level cao hơn từ trước → coi như đã lên cấp
            }
        }

        // Lưu attempt.
        CheckpointTestAttempt attempt = new CheckpointTestAttempt();
        attempt.setUserId(user.getId());
        attempt.setTestId(test.getId());
        attempt.setLevelCode(level);
        attempt.setScore((short) score);
        attempt.setPassed(passed);
        attempt.setLeveledUp(leveledUp);
        attempt.setAnswers(ans);
        attemptRepository.save(attempt);

        return new CheckpointResult(passed, score, test.getPassScore(),
                leveledUp, fromLevel, toLevel, xpEarned);
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

    private String nextLevelOf(String level) {
        int i = CEFR_ORDER.indexOf(level);
        return (i >= 0 && i < CEFR_ORDER.size() - 1) ? CEFR_ORDER.get(i + 1) : null;
    }

    /** Độ phủ = số unit completed / tổng unit của level. */
    private double computeUnitProgress(UUID userId, String level) {
        List<LearningUnit> units = unitRepository.findByLevelCodeAndIsActiveTrueOrderByDisplayOrderAsc(level);
        if (units.isEmpty()) return 0.0;
        Map<String, UserUnitProgress> map = unitProgressRepository
                .findByUserIdAndUnitIdIn(userId, units.stream().map(LearningUnit::getId).toList())
                .stream().collect(Collectors.toMap(UserUnitProgress::getUnitId, p -> p));
        long done = units.stream().filter(u -> {
            UserUnitProgress up = map.get(u.getId());
            return up != null && "completed".equals(up.getStatus());
        }).count();
        return (double) done / units.size();
    }

    /** Tất cả câu quiz (chấm tự động) của level. */
    private List<LearningLessonActivity> quizActivitiesOfLevel(String level) {
        List<String> unitIds = unitRepository
                .findByLevelCodeAndIsActiveTrueOrderByDisplayOrderAsc(level)
                .stream().map(LearningUnit::getId).toList();
        if (unitIds.isEmpty()) return List.of();
        List<String> lessonIds = lessonRepository.findByUnitIdInAndIsActiveTrue(unitIds)
                .stream().map(LearningLesson::getId).toList();
        if (lessonIds.isEmpty()) return List.of();
        return activityRepository.findQuizActivitiesByLessonIds(lessonIds).stream()
                .filter(a -> AUTO_TYPES.contains(a.getActivityType()))
                .toList();
    }

    /**
     * Rút đề: shuffle ổn định (theo id để resume nhất quán, KHÔNG dùng Random vì
     * có thể chặn ở môi trường test) + cắt theo question_count. Bỏ đáp án đúng.
     */
    private List<Map<String, Object>> buildQuestions(String level, int count) {
        List<LearningLessonActivity> pool = new ArrayList<>(quizActivitiesOfLevel(level));
        // Trộn nhẹ theo hashCode id (tất định) để không lộ thứ tự theo lesson.
        pool.sort(Comparator.comparingInt(a -> Integer.rotateLeft(a.getId().hashCode(), 7)));
        if (pool.size() > count) pool = pool.subList(0, count);

        List<Map<String, Object>> out = new ArrayList<>(pool.size());
        for (LearningLessonActivity a : pool) {
            Map<String, Object> m = new LinkedHashMap<>();
            if (a.getPayload() != null) m.putAll(a.getPayload());
            // Ẩn đáp án đúng — chấm ở server.
            m.remove("correctOptionId");
            m.remove("acceptedAnswers");
            m.remove("correctOrder");
            m.remove("explanationVi");
            // 'pairs' của vocabulary_match cần cho FE render → FE tự xáo trộn cột phải.
            m.put("id", a.getId());
            m.put("type", a.getActivityType());
            out.add(m);
        }
        return out;
    }

    /** Mở Unit đầu (display_order==1) của level mới sau khi lên cấp. */
    private void openFirstUnitOfLevel(UUID userId, String level) {
        unitRepository.findByLevelCodeAndIsActiveTrueOrderByDisplayOrderAsc(level).stream()
                .filter(u -> u.getDisplayOrder() != null && u.getDisplayOrder() == 1)
                .findFirst()
                .ifPresent(first -> {
                    UserUnitProgressId id = new UserUnitProgressId(userId, first.getId());
                    UserUnitProgress up = uupRepo.findById(id).orElseGet(() -> {
                        UserUnitProgress n = new UserUnitProgress();
                        n.setUserId(userId);
                        n.setUnitId(first.getId());
                        n.setTotalLessons((int) lessonRepository.countByUnitIdAndIsActiveTrue(first.getId()));
                        return n;
                    });
                    if ("locked".equals(up.getStatus())) {
                        up.setStatus("available");
                        uupRepo.save(up);
                    }
                });
    }

    private double round3(double v) {
        return Math.round(v * 1000.0) / 1000.0;
    }
}
