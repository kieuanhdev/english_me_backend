package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.*;
import com.kiovant.englishme.entity.*;
import com.kiovant.englishme.repository.*;
import com.kiovant.englishme.dto.XpGrantResult;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.time.LocalDate;
import java.util.*;

/**
 * Service Learning Hub — đọc DB thật theo LEARNING_PATH_BACKEND_SPEC.md.
 * Các bảng nguồn: cefr_levels, skills, support_tracks, learning_paths,
 * learning_path_activities, learning_lessons, learning_lesson_activities,
 * user_levels, user_path_progress, user_lesson_progress, user_lesson_attempts,
 * user_daily_goals.
 */
@Service
public class LearningService {

    private static final Set<String> VALID_SKILLS = Set.of("listening", "speaking", "reading", "writing");
    private static final String DEFAULT_LEVEL = "A1";
    private static final List<String> CEFR_ORDER = List.of("A1", "A2", "B1", "B2", "C1", "C2");

    private final UserRepository userRepository;
    private final CefrLevelRepository cefrLevelRepository;
    private final SkillRepository skillRepository;
    private final SupportTrackRepository supportTrackRepository;
    private final LearningPathRepository pathRepository;
    private final LearningPathActivityRepository pathActivityRepository;
    private final LearningLessonRepository lessonRepository;
    private final LearningLessonActivityRepository lessonActivityRepository;
    private final UserLevelRepository userLevelRepository;
    private final UserPathProgressRepository userPathProgressRepository;
    private final UserLessonProgressRepository userLessonProgressRepository;
    private final UserLessonAttemptRepository userLessonAttemptRepository;
    private final UserDailyGoalRepository userDailyGoalRepository;
    private final XpService xpService;

    public LearningService(UserRepository userRepository,
                           CefrLevelRepository cefrLevelRepository,
                           SkillRepository skillRepository,
                           SupportTrackRepository supportTrackRepository,
                           LearningPathRepository pathRepository,
                           LearningPathActivityRepository pathActivityRepository,
                           LearningLessonRepository lessonRepository,
                           LearningLessonActivityRepository lessonActivityRepository,
                           UserLevelRepository userLevelRepository,
                           UserPathProgressRepository userPathProgressRepository,
                           UserLessonProgressRepository userLessonProgressRepository,
                           UserLessonAttemptRepository userLessonAttemptRepository,
                           UserDailyGoalRepository userDailyGoalRepository,
                           XpService xpService) {
        this.userRepository = userRepository;
        this.cefrLevelRepository = cefrLevelRepository;
        this.skillRepository = skillRepository;
        this.supportTrackRepository = supportTrackRepository;
        this.pathRepository = pathRepository;
        this.pathActivityRepository = pathActivityRepository;
        this.lessonRepository = lessonRepository;
        this.lessonActivityRepository = lessonActivityRepository;
        this.userLevelRepository = userLevelRepository;
        this.userPathProgressRepository = userPathProgressRepository;
        this.userLessonProgressRepository = userLessonProgressRepository;
        this.userLessonAttemptRepository = userLessonAttemptRepository;
        this.userDailyGoalRepository = userDailyGoalRepository;
        this.xpService = xpService;
    }

    // ═══════════════════════════════════════════════════════════════════
    // GET /api/learning/hub?level={code}
    // ═══════════════════════════════════════════════════════════════════
    @Transactional
    public LearningHubResponse getHub(String firebaseUid, String levelParam) {
        User user = loadUser(firebaseUid);
        UserLevel userLevel = ensureUserLevel(user);

        String selected = (levelParam != null && isValidLevel(levelParam))
                ? levelParam
                : userLevel.getSelectedLevel();
        if (!isValidLevel(selected)) selected = DEFAULT_LEVEL;

        // Persist lựa chọn level
        if (!selected.equals(userLevel.getSelectedLevel())) {
            userLevel.setSelectedLevel(selected);
            userLevelRepository.save(userLevel);
        }

        // Lấy paths của level đã chọn + bootstrap user_path_progress nếu cần.
        List<LearningPath> paths = pathRepository.findByLevelCodeAndIsActiveTrueOrderByDisplayOrderAsc(selected);
        Map<String, UserPathProgress> pathProgressMap = ensurePathProgress(user.getId(), paths);

        List<LearningHubResponse.PathSummary> pathSummaries = buildPathSummaries(paths, pathProgressMap);

        // Skill tracks (4 skill cố định, totalLessons + completedLessons theo DB).
        List<LearningHubResponse.SkillTrackSummary> skillTracks = buildSkillTracks(user.getId(), selected);

        // Support tracks (master data, progress 0 cho phase này).
        List<LearningHubResponse.SupportTrackSummary> supportTracks = buildSupportTracks();

        // Levels overview với progress = % path completed/level.
        List<LearningHubResponse.LevelSummary> levels = buildLevels(user.getId(), userLevel.getCurrentLevel());

        // Daily goal hôm nay.
        UserDailyGoal goal = ensureDailyGoal(user.getId());

        // currentPathId: ưu tiên path đang in_progress của selected level, fallback path đầu tiên available.
        String currentPathId = resolveCurrentPathId(paths, pathProgressMap);
        if (currentPathId != null && !currentPathId.equals(userLevel.getCurrentPathId())) {
            userLevel.setCurrentPathId(currentPathId);
            userLevelRepository.save(userLevel);
        }

        String nextRecommendedSkill = guessNextRecommendedSkill(user.getId(), selected);

        return new LearningHubResponse(
                userLevel.getCurrentLevel(),
                selected,
                currentPathId,
                nextRecommendedSkill,
                new LearningHubResponse.DailyGoal(goal.getTargetXp(), goal.getEarnedXp(), goal.getCompletedActivities()),
                levels,
                skillTracks,
                List.of(), // units rỗng theo spec — paths thay thế.
                pathSummaries,
                supportTracks
        );
    }

    // ═══════════════════════════════════════════════════════════════════
    // GET /api/learning/levels/{level}/skills/{skill}/lessons
    // ═══════════════════════════════════════════════════════════════════
    @Transactional(readOnly = true)
    public SkillLessonsResponse getSkillLessons(String firebaseUid, String level, String skill) {
        User user = loadUser(firebaseUid);
        validateLevel(level);
        validateSkill(skill);

        List<LearningLesson> lessons = lessonRepository
                .findByLevelCodeAndSkillCodeAndIsActiveTrueOrderByIdAsc(level, skill);

        Map<String, UserLessonProgress> progressMap = userLessonProgressRepository
                .findByUserIdAndLessonIdIn(user.getId(),
                        lessons.stream().map(LearningLesson::getId).toList())
                .stream().collect(java.util.stream.Collectors.toMap(UserLessonProgress::getLessonId, p -> p));

        List<SkillLessonsResponse.LessonSummary> summaries = new ArrayList<>();
        int order = 1;
        for (LearningLesson lesson : lessons) {
            UserLessonProgress p = progressMap.get(lesson.getId());
            String status = p != null ? p.getStatus() : (order == 1 ? "available" : "locked");
            summaries.add(new SkillLessonsResponse.LessonSummary(
                    lesson.getId(),
                    lesson.getUnitId(),
                    lesson.getTitle(),
                    lesson.getSubtitle(),
                    "lesson", // activityType placeholder cho FE skill-list (FE chỉ dùng để chọn icon)
                    lesson.getDurationMinutes(),
                    lesson.getXpReward(),
                    status,
                    order
            ));
            order++;
        }

        return new SkillLessonsResponse(
                level,
                skill,
                skillTitleVi(skill) + " " + level,
                "Bài học " + skillTitleVi(skill) + " cấp " + level + ".",
                summaries
        );
    }

    // ═══════════════════════════════════════════════════════════════════
    // GET /api/learning/paths/{pathId} (spec mục 4.3)
    // ═══════════════════════════════════════════════════════════════════
    @Transactional(readOnly = true)
    public LearningPathDetailResponse getPathDetail(String firebaseUid, String pathId) {
        User user = loadUser(firebaseUid);
        LearningPath path = pathRepository.findById(pathId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Path not found: " + pathId));

        List<LearningPathActivity> activities = pathActivityRepository
                .findByPathIdOrderByDisplayOrderAsc(pathId);

        UserPathProgress pathProgress = userPathProgressRepository
                .findById(new UserPathProgressId(user.getId(), pathId))
                .orElse(null);

        Map<String, UserLessonProgress> lessonProgress = userLessonProgressRepository
                .findByUserIdAndPathId(user.getId(), pathId).stream()
                .collect(java.util.stream.Collectors.toMap(UserLessonProgress::getLessonId, p -> p));

        // Tính status từng activity tuần tự theo display_order.
        // Status có thể là: completed, failed (đã làm xong nhưng chưa đạt pass),
        // in_progress, available, locked.
        List<LearningPathDetailResponse.ActivitySummary> activitySummaries = new ArrayList<>();
        boolean prevCompleted = true; // activity đầu mặc định available.
        for (LearningPathActivity act : activities) {
            UserLessonProgress lp = lessonProgress.get(act.getLessonId());
            String status;
            if (lp != null && "completed".equals(lp.getStatus())) {
                status = "completed";
                prevCompleted = true;
            } else if (lp != null && lp.getLastScore() != null) {
                // Đã có ít nhất 1 attempt nhưng chưa đạt → failed (cho phép làm lại).
                status = "failed";
                prevCompleted = true; // cho phép mở khoá activity kế tiếp dù chưa pass
            } else if (prevCompleted) {
                status = lp != null && "in_progress".equals(lp.getStatus()) ? "in_progress" : "available";
                prevCompleted = false;
            } else {
                status = "locked";
            }
            activitySummaries.add(new LearningPathDetailResponse.ActivitySummary(
                    act.getId(),
                    act.getLessonId(),
                    act.getPathId(),
                    act.getTitle(),
                    act.getSubtitle(),
                    act.getSkillCode(),
                    act.getActivityType(),
                    status,
                    act.getDisplayOrder(),
                    act.getDurationMinutes(),
                    act.getXpReward()
            ));
        }

        double progress = pathProgress != null && pathProgress.getTotalCount() > 0
                ? (double) pathProgress.getCompletedCount() / pathProgress.getTotalCount()
                : 0.0;
        String status = pathProgress != null ? pathProgress.getStatus() : "available";

        return new LearningPathDetailResponse(
                path.getId(),
                path.getLevelCode(),
                path.getTitle(),
                path.getDescription(),
                status,
                Math.min(1.0, progress),
                path.getRequiredScoreToPass(),
                activitySummaries
        );
    }

    // ═══════════════════════════════════════════════════════════════════
    // GET /api/learning/lessons/{lessonId}
    // ═══════════════════════════════════════════════════════════════════
    @Transactional(readOnly = true)
    public LessonDetailResponse getLessonDetail(String firebaseUid, String lessonId) {
        User user = loadUser(firebaseUid);
        String resolvedLessonId = resolveLessonId(lessonId);
        LearningLesson lesson = lessonRepository.findById(resolvedLessonId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Lesson not found: " + lessonId));

        List<LearningLessonActivity> activities = lessonActivityRepository
                .findByLessonIdOrderByDisplayOrderAsc(resolvedLessonId);

        UserLessonProgress progress = userLessonProgressRepository
                .findById(new UserLessonProgressId(user.getId(), resolvedLessonId))
                .orElse(null);
        String status = progress != null ? progress.getStatus() : "available";

        List<LessonDetailResponse.Activity> activityDtos = activities.stream()
                .map(this::toActivityDto)
                .toList();

        return new LessonDetailResponse(
                lesson.getId(),
                lesson.getLevelCode(),
                lesson.getSkillCode(),
                lesson.getUnitId(),
                lesson.getTitle(),
                lesson.getSubtitle(),
                lesson.getDurationMinutes(),
                lesson.getXpReward(),
                status,
                lesson.getContent(),
                activityDtos
        );
    }

    // ═══════════════════════════════════════════════════════════════════
    // POST /api/learning/lessons/{lessonId}/complete (spec mục 4.5)
    // ═══════════════════════════════════════════════════════════════════
    @Transactional
    public LessonCompleteResponse completeLesson(String firebaseUid, String lessonId, LessonCompleteRequest req) {
        User user = loadUser(firebaseUid);
        String resolvedLessonId = resolveLessonId(lessonId);
        LearningLesson lesson = lessonRepository.findById(resolvedLessonId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Lesson not found: " + lessonId));

        // Xác định pathId từ activity dẫn tới lesson này (nếu có).
        String pathId = resolvePathIdForLesson(resolvedLessonId);

        // 1) Ghi attempt
        UserLessonAttempt attempt = new UserLessonAttempt();
        attempt.setUserId(user.getId());
        attempt.setLessonId(resolvedLessonId);
        attempt.setScore((short) req.score());
        attempt.setXpEarned((short) 0); // sẽ set lại sau
        attempt.setTimeSpentSeconds(req.timeSpentSeconds());
        attempt.setAnswers(serializeAnswers(req.answers()));
        userLessonAttemptRepository.save(attempt);

        // 2) Update / tạo user_lesson_progress
        UserLessonProgress lp = userLessonProgressRepository
                .findById(new UserLessonProgressId(user.getId(), resolvedLessonId))
                .orElseGet(() -> {
                    UserLessonProgress n = new UserLessonProgress();
                    n.setUserId(user.getId());
                    n.setLessonId(resolvedLessonId);
                    n.setPathId(pathId);
                    n.setStatus("available");
                    return n;
                });

        boolean firstTimePass = !"completed".equals(lp.getStatus());
        int passThreshold = 70; // mặc định, có thể đọc từ path.required_score_to_pass.
        if (pathId != null) {
            passThreshold = pathRepository.findById(pathId)
                    .map(LearningPath::getRequiredScoreToPass)
                    .map(Short::intValue)
                    .orElse(70);
        }

        boolean passed = req.score() >= passThreshold;
        if (passed) lp.setStatus("completed");
        else if (!"completed".equals(lp.getStatus())) lp.setStatus("in_progress");

        lp.setLastScore((short) req.score());
        if (lp.getBestScore() == null || req.score() > lp.getBestScore()) {
            lp.setBestScore((short) req.score());
        }
        lp.setAttempts((lp.getAttempts() == null ? 0 : lp.getAttempts()) + 1);
        lp.setTimeSpentSeconds((lp.getTimeSpentSeconds() == null ? 0 : lp.getTimeSpentSeconds())
                + req.timeSpentSeconds());

        int candidateXp = (passed && firstTimePass) ? lesson.getXpReward() : 0;
        if (passed && firstTimePass) {
            lp.setCompletedAt(Instant.now());
        }
        userLessonProgressRepository.save(lp);

        // 3) Update user_path_progress khi pass lần đầu.
        if (passed && firstTimePass && pathId != null) {
            updatePathProgress(user.getId(), pathId);
        }

        // 4) Cộng XP idempotent qua XpService. Key = "lesson:{lessonId}:first_pass" — retry mạng
        //    hoặc submit lại sau khi đã pass đều KHÔNG cộng XP đôi.
        XpGrantResult xpResult;
        if (candidateXp > 0) {
            xpResult = xpService.grant(
                    user.getId(),
                    candidateXp,
                    "lesson",
                    resolvedLessonId,
                    "lesson:" + resolvedLessonId + ":first_pass",
                    java.util.Map.of(
                            "score", req.score(),
                            "lessonId", resolvedLessonId,
                            "pathId", pathId == null ? "" : pathId
                    )
            );
        } else {
            // Không có XP để cộng (đã pass từ trước, hoặc trượt) — vẫn cần trả totalXp.
            xpResult = xpService.readOnlyResult(user.getId(), 0, false, !firstTimePass);
        }
        int actualXp = xpResult.xpEarned();

        // Ghi xp_earned thực sự lên progress + attempt (có thể là 0 nếu duplicate idempotency).
        lp.setXpEarned((lp.getXpEarned() == null ? 0 : lp.getXpEarned()) + actualXp);
        userLessonProgressRepository.save(lp);
        attempt.setXpEarned((short) actualXp);
        userLessonAttemptRepository.save(attempt);

        // 5) Tính progress mới cho response.
        double levelProgress = computeLevelProgress(user.getId(), lesson.getLevelCode());
        double skillProgress = computeSkillProgress(user.getId(), lesson.getLevelCode(), lesson.getSkillCode());
        String nextLessonId = pathId != null ? findNextLessonInPath(pathId, resolvedLessonId) : null;

        return new LessonCompleteResponse(
                resolvedLessonId,
                passed,
                req.score(),
                actualXp,
                xpResult.totalXp(),
                xpResult.dailyEarnedXp(),
                levelProgress,
                skillProgress,
                nextLessonId,
                xpResult.streakUpdated(),
                xpResult.bonuses()
        );
    }

    // ═══════════════════════════════════════════════════════════════════
    // Helpers
    // ═══════════════════════════════════════════════════════════════════

    private User loadUser(String firebaseUid) {
        return userRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
    }

    private String resolveLessonId(String idOrActivityId) {
        if (lessonRepository.existsById(idOrActivityId)) {
            return idOrActivityId;
        }
        return pathActivityRepository.findById(idOrActivityId)
                .map(LearningPathActivity::getLessonId)
                .orElse(idOrActivityId);
    }

    private boolean isValidLevel(String level) {
        return level != null && CEFR_ORDER.contains(level);
    }

    private void validateLevel(String level) {
        if (!isValidLevel(level)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid level: " + level);
        }
    }

    private void validateSkill(String skill) {
        if (skill == null || !VALID_SKILLS.contains(skill)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid skill: " + skill);
        }
    }

    /** Tạo row user_levels nếu user mới mở learning hub. */
    private UserLevel ensureUserLevel(User user) {
        return userLevelRepository.findById(user.getId()).orElseGet(() -> {
            UserLevel ul = new UserLevel();
            ul.setUserId(user.getId());
            String level = user.getCefrLevel() != null ? user.getCefrLevel() : DEFAULT_LEVEL;
            ul.setCurrentLevel(level);
            ul.setSelectedLevel(level);
            return userLevelRepository.save(ul);
        });
    }

    /** Bootstrap user_path_progress cho mọi path của level đang xem. */
    private Map<String, UserPathProgress> ensurePathProgress(UUID userId, List<LearningPath> paths) {
        if (paths.isEmpty()) return Map.of();
        List<String> pathIds = paths.stream().map(LearningPath::getId).toList();
        Map<String, UserPathProgress> existing = userPathProgressRepository
                .findByUserIdAndPathIdIn(userId, pathIds).stream()
                .collect(java.util.stream.Collectors.toMap(UserPathProgress::getPathId, p -> p));

        for (LearningPath p : paths) {
            if (existing.containsKey(p.getId())) continue;
            UserPathProgress upp = new UserPathProgress();
            upp.setUserId(userId);
            upp.setPathId(p.getId());
            upp.setStatus(p.getDisplayOrder() == 1 ? "available" : "locked");
            upp.setTotalCount((int) pathActivityRepository.countByPathId(p.getId()));
            upp.setCompletedCount(0);
            existing.put(p.getId(), userPathProgressRepository.save(upp));
        }
        return existing;
    }

    /** Daily goal cho hôm nay (auto-create). */
    private UserDailyGoal ensureDailyGoal(UUID userId) {
        LocalDate today = LocalDate.now();
        return userDailyGoalRepository.findByUserIdAndGoalDate(userId, today).orElseGet(() -> {
            UserDailyGoal g = new UserDailyGoal();
            g.setUserId(userId);
            g.setGoalDate(today);
            return userDailyGoalRepository.save(g);
        });
    }

    private List<LearningHubResponse.PathSummary> buildPathSummaries(List<LearningPath> paths,
                                                                     Map<String, UserPathProgress> progress) {
        List<LearningHubResponse.PathSummary> list = new ArrayList<>(paths.size());
        for (LearningPath p : paths) {
            UserPathProgress upp = progress.get(p.getId());
            int total = upp != null ? upp.getTotalCount() : 0;
            int done = upp != null ? upp.getCompletedCount() : 0;
            double prog = total > 0 ? Math.min(1.0, (double) done / total) : 0.0;
            String status = upp != null ? upp.getStatus() : "locked";
            list.add(new LearningHubResponse.PathSummary(
                    p.getId(),
                    p.getLevelCode(),
                    p.getTitle(),
                    p.getDescription(),
                    p.getDisplayOrder(),
                    status,
                    prog,
                    total,
                    done,
                    p.getSkillsCoverage() != null ? p.getSkillsCoverage() : List.of()
            ));
        }
        return list;
    }

    private List<LearningHubResponse.SkillTrackSummary> buildSkillTracks(UUID userId, String level) {
        List<Skill> skills = skillRepository.findAllByOrderByDisplayOrderAsc();
        List<LearningHubResponse.SkillTrackSummary> list = new ArrayList<>(skills.size());
        for (Skill s : skills) {
            long total = lessonRepository.countByLevelCodeAndSkillCode(level, s.getCode());
            List<LearningLesson> lessons = lessonRepository
                    .findByLevelCodeAndSkillCodeAndIsActiveTrueOrderByIdAsc(level, s.getCode());
            long completed = 0;
            String nextLessonId = null;
            if (!lessons.isEmpty()) {
                Map<String, UserLessonProgress> map = userLessonProgressRepository
                        .findByUserIdAndLessonIdIn(userId, lessons.stream().map(LearningLesson::getId).toList())
                        .stream().collect(java.util.stream.Collectors.toMap(UserLessonProgress::getLessonId, p -> p));
                for (LearningLesson l : lessons) {
                    UserLessonProgress lp = map.get(l.getId());
                    if (lp != null && "completed".equals(lp.getStatus())) {
                        completed++;
                    } else if (nextLessonId == null) {
                        nextLessonId = l.getId();
                    }
                }
            }
            double progress = total > 0 ? (double) completed / total : 0.0;
            list.add(new LearningHubResponse.SkillTrackSummary(
                    s.getCode(),
                    s.getTitle(),
                    s.getDescription(),
                    s.getIcon(),
                    s.getAccentColor(),
                    progress,
                    (int) total,
                    (int) completed,
                    nextLessonId,
                    true
            ));
        }
        return list;
    }

    private List<LearningHubResponse.SupportTrackSummary> buildSupportTracks() {
        return supportTrackRepository.findAllByEnabledTrueOrderByDisplayOrderAsc().stream()
                .map(s -> new LearningHubResponse.SupportTrackSummary(
                        s.getType(), s.getTitle(), s.getDescription(), s.getRoute(),
                        0.0, s.getEnabled()))
                .toList();
    }

    private List<LearningHubResponse.LevelSummary> buildLevels(UUID userId, String currentLevel) {
        List<CefrLevel> rows = cefrLevelRepository.findAllByIsActiveTrueOrderByDisplayOrderAsc();
        List<LearningHubResponse.LevelSummary> list = new ArrayList<>(rows.size());
        int currentIdx = CEFR_ORDER.indexOf(currentLevel);
        if (currentIdx < 0) currentIdx = 0;

        // Level kế tiếp chỉ mở khi level hiện tại đạt ngưỡng hoàn thành (≥80% path).
        // Tránh cho user nhảy cấp khi chưa học đủ cấp đang theo.
        final double UNLOCK_THRESHOLD = 0.80;
        String curCode = currentIdx < CEFR_ORDER.size() ? CEFR_ORDER.get(currentIdx) : currentLevel;
        double currentProg = computeLevelProgress(userId, curCode);
        boolean nextUnlocked = currentProg >= UNLOCK_THRESHOLD;

        for (CefrLevel lv : rows) {
            int idx = CEFR_ORDER.indexOf(lv.getCode());
            double prog = computeLevelProgress(userId, lv.getCode());
            String status;
            boolean locked;
            if (idx < currentIdx) {
                status = "completed";
                locked = false;
            } else if (idx == currentIdx) {
                status = prog > 0 ? "in_progress" : "available";
                locked = false;
            } else if (idx == currentIdx + 1) {
                // Mở next chỉ khi current ≥ ngưỡng; chưa đạt thì khóa.
                locked = !nextUnlocked;
                status = nextUnlocked ? "available" : "locked";
            } else {
                status = "locked";
                locked = true;
            }
            list.add(new LearningHubResponse.LevelSummary(
                    lv.getCode(), lv.getTitle(), lv.getDescription(), prog, status, locked));
        }
        return list;
    }

    /** levelProgress = số path completed / tổng path active của level. */
    private double computeLevelProgress(UUID userId, String level) {
        List<LearningPath> paths = pathRepository.findByLevelCodeAndIsActiveTrueOrderByDisplayOrderAsc(level);
        if (paths.isEmpty()) return 0.0;
        Map<String, UserPathProgress> map = userPathProgressRepository
                .findByUserIdAndPathIdIn(userId, paths.stream().map(LearningPath::getId).toList())
                .stream().collect(java.util.stream.Collectors.toMap(UserPathProgress::getPathId, p -> p));
        long completed = paths.stream()
                .filter(p -> {
                    UserPathProgress upp = map.get(p.getId());
                    return upp != null && "completed".equals(upp.getStatus());
                }).count();
        return (double) completed / paths.size();
    }

    private double computeSkillProgress(UUID userId, String level, String skill) {
        long total = lessonRepository.countByLevelCodeAndSkillCode(level, skill);
        if (total == 0) return 0.0;
        List<LearningLesson> lessons = lessonRepository
                .findByLevelCodeAndSkillCodeAndIsActiveTrueOrderByIdAsc(level, skill);
        Map<String, UserLessonProgress> map = userLessonProgressRepository
                .findByUserIdAndLessonIdIn(userId, lessons.stream().map(LearningLesson::getId).toList())
                .stream().collect(java.util.stream.Collectors.toMap(UserLessonProgress::getLessonId, p -> p));
        long done = lessons.stream()
                .filter(l -> {
                    UserLessonProgress lp = map.get(l.getId());
                    return lp != null && "completed".equals(lp.getStatus());
                }).count();
        return (double) done / total;
    }

    private String resolveCurrentPathId(List<LearningPath> paths, Map<String, UserPathProgress> progress) {
        for (LearningPath p : paths) {
            UserPathProgress upp = progress.get(p.getId());
            if (upp != null && "in_progress".equals(upp.getStatus())) return p.getId();
        }
        for (LearningPath p : paths) {
            UserPathProgress upp = progress.get(p.getId());
            if (upp == null || "available".equals(upp.getStatus())) return p.getId();
        }
        return paths.isEmpty() ? null : paths.get(0).getId();
    }

    private String guessNextRecommendedSkill(UUID userId, String level) {
        List<Skill> skills = skillRepository.findAllByOrderByDisplayOrderAsc();
        double minProg = 1.1;
        String pick = "listening";
        for (Skill s : skills) {
            double p = computeSkillProgress(userId, level, s.getCode());
            if (p < minProg) { minProg = p; pick = s.getCode(); }
        }
        return pick;
    }

    private String resolvePathIdForLesson(String lessonId) {
        return pathActivityRepository.findFirstByLessonId(lessonId)
                .map(LearningPathActivity::getPathId)
                .orElse(null);
    }

    private void updatePathProgress(UUID userId, String pathId) {
        UserPathProgress upp = userPathProgressRepository
                .findById(new UserPathProgressId(userId, pathId))
                .orElseGet(() -> {
                    UserPathProgress n = new UserPathProgress();
                    n.setUserId(userId);
                    n.setPathId(pathId);
                    n.setStatus("in_progress");
                    n.setTotalCount((int) pathActivityRepository.countByPathId(pathId));
                    return n;
                });

        // Đếm số lesson trong path đã completed.
        List<LearningPathActivity> acts = pathActivityRepository.findByPathIdOrderByDisplayOrderAsc(pathId);
        List<String> lessonIds = acts.stream().map(LearningPathActivity::getLessonId).toList();
        long done = userLessonProgressRepository.findByUserIdAndLessonIdIn(userId, lessonIds).stream()
                .filter(p -> "completed".equals(p.getStatus()))
                .count();
        upp.setCompletedCount((int) done);
        if (upp.getTotalCount() == null || upp.getTotalCount() == 0) {
            upp.setTotalCount(acts.size());
        }
        if (done >= upp.getTotalCount() && upp.getTotalCount() > 0) {
            upp.setStatus("completed");
            if (upp.getCompletedAt() == null) upp.setCompletedAt(Instant.now());
        } else if (done > 0) {
            upp.setStatus("in_progress");
            if (upp.getStartedAt() == null) upp.setStartedAt(Instant.now());
        }
        userPathProgressRepository.save(upp);

        // Mở khóa path kế tiếp khi path hiện tại completed.
        if ("completed".equals(upp.getStatus())) {
            LearningPath cur = pathRepository.findById(pathId).orElse(null);
            if (cur != null) {
                pathRepository
                        .findByLevelCodeAndIsActiveTrueOrderByDisplayOrderAsc(cur.getLevelCode()).stream()
                        .filter(p -> p.getDisplayOrder() == cur.getDisplayOrder() + 1)
                        .findFirst()
                        .ifPresent(next -> {
                            UserPathProgress nx = userPathProgressRepository
                                    .findById(new UserPathProgressId(userId, next.getId()))
                                    .orElseGet(() -> {
                                        UserPathProgress n = new UserPathProgress();
                                        n.setUserId(userId);
                                        n.setPathId(next.getId());
                                        n.setTotalCount((int) pathActivityRepository.countByPathId(next.getId()));
                                        return n;
                                    });
                            if ("locked".equals(nx.getStatus())) {
                                nx.setStatus("available");
                                userPathProgressRepository.save(nx);
                            }
                        });
            }
        }
    }

    private String findNextLessonInPath(String pathId, String currentLessonId) {
        List<LearningPathActivity> acts = pathActivityRepository.findByPathIdOrderByDisplayOrderAsc(pathId);
        for (int i = 0; i < acts.size(); i++) {
            if (currentLessonId.equals(acts.get(i).getLessonId()) && i + 1 < acts.size()) {
                return acts.get(i + 1).getLessonId();
            }
        }
        return null;
    }

    private LessonDetailResponse.Activity toActivityDto(LearningLessonActivity row) {
        Map<String, Object> p = row.getPayload();
        String type = row.getActivityType();

        String question = strOrNull(p, "question");
        String correctOptionId = strOrNull(p, "correctOptionId");
        String explanationVi = strOrNull(p, "explanationVi");
        String expectedText = strOrNull(p, "expectedText");
        Integer minScoreToPass = intOrNull(p, "minScoreToPass");
        String prompt = strOrNull(p, "prompt");
        List<String> rubric = listOrNull(p, "rubric");
        String textAnswer = strOrNull(p, "textAnswer");

        List<LessonDetailResponse.Activity.Option> options = null;
        Object raw = p != null ? p.get("options") : null;
        if (raw instanceof List<?> rawList) {
            options = new ArrayList<>(rawList.size());
            for (Object item : rawList) {
                if (item instanceof Map<?, ?> opt) {
                    options.add(new LessonDetailResponse.Activity.Option(
                            String.valueOf(opt.get("id")),
                            String.valueOf(opt.get("text"))
                    ));
                }
            }
        }

        return new LessonDetailResponse.Activity(
                row.getId(),
                type,
                question,
                options,
                correctOptionId,
                explanationVi,
                expectedText,
                minScoreToPass,
                prompt,
                rubric,
                textAnswer
        );
    }

    private List<Map<String, Object>> serializeAnswers(List<LessonCompleteRequest.Answer> answers) {
        if (answers == null) return List.of();
        List<Map<String, Object>> list = new ArrayList<>(answers.size());
        for (LessonCompleteRequest.Answer a : answers) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("activityId", a.activityId());
            m.put("type", a.type());
            if (a.selectedOptionId() != null) m.put("selectedOptionId", a.selectedOptionId());
            if (a.isCorrect() != null) m.put("isCorrect", a.isCorrect());
            if (a.textAnswer() != null) m.put("textAnswer", a.textAnswer());
            list.add(m);
        }
        return list;
    }

    private String skillTitleVi(String skill) {
        return switch (skill) {
            case "listening" -> "Nghe";
            case "speaking" -> "Nói";
            case "reading" -> "Đọc";
            case "writing" -> "Viết";
            default -> skill;
        };
    }

    private String strOrNull(Map<String, Object> map, String key) {
        if (map == null) return null;
        Object v = map.get(key);
        return v == null ? null : String.valueOf(v);
    }

    private Integer intOrNull(Map<String, Object> map, String key) {
        if (map == null) return null;
        Object v = map.get(key);
        if (v instanceof Number n) return n.intValue();
        if (v instanceof String s) try { return Integer.parseInt(s); } catch (NumberFormatException ignored) { return null; }
        return null;
    }

    @SuppressWarnings("unchecked")
    private List<String> listOrNull(Map<String, Object> map, String key) {
        if (map == null) return null;
        Object v = map.get(key);
        if (v instanceof List<?> list) {
            List<String> out = new ArrayList<>(list.size());
            for (Object o : list) out.add(String.valueOf(o));
            return out;
        }
        return null;
    }
}
