package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.HomeDashboardResponse;
import com.kiovant.englishme.dto.VocabularyWordResponse;
import com.kiovant.englishme.entity.Flashcard;
import com.kiovant.englishme.entity.GrammarTopic;
import com.kiovant.englishme.entity.User;
import com.kiovant.englishme.entity.UserSkillXp;
import com.kiovant.englishme.entity.XpHistory;
import com.kiovant.englishme.repository.FlashcardProgressRepository;
import com.kiovant.englishme.repository.GrammarTopicRepository;
import com.kiovant.englishme.repository.UserDailyGoalRepository;
import com.kiovant.englishme.repository.UserLessonProgressRepository;
import com.kiovant.englishme.repository.UserRepository;
import com.kiovant.englishme.repository.UserSkillXpRepository;
import com.kiovant.englishme.repository.XpHistoryRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class HomeDashboardService {

    private static final String DEFAULT_LEVEL = "A1";
    /** Mục tiêu XP/ngày mặc định — khớp UserDailyGoal.targetXp default (=30). */
    private static final int DEFAULT_DAILY_XP_GOAL = 30;

    private final UserRepository userRepository;
    private final XpHistoryRepository xpHistoryRepository;
    private final WordOfDayService wordOfDayService;
    private final GrammarTopicRepository grammarTopicRepository;
    private final UserDailyGoalRepository userDailyGoalRepository;
    private final UserSkillXpRepository userSkillXpRepository;
    private final UserLessonProgressRepository userLessonProgressRepository;
    private final FlashcardProgressRepository flashcardProgressRepository;

    public HomeDashboardService(UserRepository userRepository,
                                XpHistoryRepository xpHistoryRepository,
                                WordOfDayService wordOfDayService,
                                GrammarTopicRepository grammarTopicRepository,
                                UserDailyGoalRepository userDailyGoalRepository,
                                UserSkillXpRepository userSkillXpRepository,
                                UserLessonProgressRepository userLessonProgressRepository,
                                FlashcardProgressRepository flashcardProgressRepository) {
        this.userRepository = userRepository;
        this.xpHistoryRepository = xpHistoryRepository;
        this.wordOfDayService = wordOfDayService;
        this.grammarTopicRepository = grammarTopicRepository;
        this.userDailyGoalRepository = userDailyGoalRepository;
        this.userSkillXpRepository = userSkillXpRepository;
        this.userLessonProgressRepository = userLessonProgressRepository;
        this.flashcardProgressRepository = flashcardProgressRepository;
    }

    @Transactional(readOnly = true)
    public HomeDashboardResponse getDashboard(String firebaseUid) {
        User user = userRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));

        String level = normalizeLevel(user.getCefrLevel());

        return new HomeDashboardResponse(
                buildUserInfo(user),
                buildDailyStats(user),
                buildWordOfDay(user, level),
                buildContinueLearning(user, level),
                buildRecommendations(user, level)
        );
    }

    private HomeDashboardResponse.HomeUserInfo buildUserInfo(User user) {
        return new HomeDashboardResponse.HomeUserInfo(
                user.getFullName(),
                user.getAvatarUrl(),
                user.getCefrLevel(),
                user.getTotalXp(),
                user.getCurrentStreak(),
                user.getLongestStreak()
        );
    }

    private HomeDashboardResponse.DailyStats buildDailyStats(User user) {
        LocalDate today = LocalDate.now();
        LocalDate weekStart = today.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));

        int xpToday = xpHistoryRepository.findByUser_IdAndActivityDate(user.getId(), today)
                .map(XpHistory::getXp)
                .orElse(0);
        int xpWeek = xpHistoryRepository.sumXpBetween(user.getId(), weekStart, today);
        int activeDays = xpHistoryRepository.countActiveDaysBetween(user.getId(), weekStart, today);

        // Mục tiêu XP của ngày hôm nay — đọc từ user_daily_goals (nguồn sự thật, cùng nơi
        // XpService tính daily_goal_bonus). Chưa có row hôm nay → dùng default 30.
        int xpGoal = userDailyGoalRepository.findByUserIdAndGoalDate(user.getId(), today)
                .map(g -> g.getTargetXp() == null ? DEFAULT_DAILY_XP_GOAL : g.getTargetXp().intValue())
                .orElse(DEFAULT_DAILY_XP_GOAL);

        // Số thẻ flashcard tới hạn ôn hôm nay (mọi desk) — nối thẳng SM-2 vào Home.
        long dueCards = flashcardProgressRepository.countAllDueProgress(user.getId(), LocalDateTime.now());

        return new HomeDashboardResponse.DailyStats(
                xpToday, xpWeek, activeDays, user.getCurrentStreak(), xpGoal, dueCards);
    }

    private HomeDashboardResponse.WordOfDay buildWordOfDay(User user, String level) {
        // Cá nhân hóa: ưu tiên từ trong flashcard user đang yếu / tới hạn ôn (gap thật của
        // user), thay vì 1 từ chung toàn site theo level. Fallback từ-theo-level nếu user
        // chưa có thẻ nào tới hạn.
        List<Flashcard> weak = flashcardProgressRepository.findWeakestDueFlashcards(
                user.getId(), LocalDateTime.now(), org.springframework.data.domain.PageRequest.of(0, 1));
        if (!weak.isEmpty()) {
            Flashcard f = weak.get(0);
            if (f.getWord() != null && !f.getWord().isBlank()) {
                String pos = (f.getPosJson() != null && !f.getPosJson().isEmpty()) ? f.getPosJson().get(0) : null;
                return new HomeDashboardResponse.WordOfDay(
                        f.getId(),
                        f.getWord(),
                        f.getIpa(),
                        pos,
                        f.getViDefinition(),
                        f.getDefinition(),
                        f.getExample(),
                        f.getViExample(),
                        f.getCefr()
                );
            }
        }

        // Nguồn "từ vựng của ngày" lấy từ WordOfDayService (đọc Oxford 5000 JSON +
        // cache theo ngày). Bảng vocabulary_word đã bị gỡ cùng tính năng "bộ từ vựng".
        VocabularyWordResponse w = wordOfDayService.getWordOfDay(
                (level == null || level.isBlank()) ? DEFAULT_LEVEL : level);
        if (w == null || w.word() == null || w.word().isBlank() || "N/A".equals(w.word())) {
            return null;
        }
        return new HomeDashboardResponse.WordOfDay(
                w.id(),
                w.word(),
                w.pronunciation(),
                w.partOfSpeech(),
                w.definitionVi(),
                w.definitionEn(),
                w.exampleSentence(),
                w.exampleTranslation(),
                w.level()
        );
    }

    /**
     * "Tiếp tục học" cá nhân hóa theo tiến độ thật:
     * <ol>
     *   <li>Có bài đang dở (status='in_progress'): nếu lần chấm gần nhất chưa đạt điểm pass
     *       -> "Làm lại" (retry); ngược lại -> "Tiếp tục" (continue). Chọn bài level thấp nhất,
     *       order nhỏ nhất.</li>
     *   <li>Không có bài dở -> fallback grammar topic đầu theo level (hành vi cũ).</li>
     * </ol>
     *
     * <p>Lưu ý: status 'failed' KHÔNG được lưu trong DB (LearningService chỉ lưu
     * 'in_progress'/'completed') — "chưa đạt" suy ra từ last_score < required_score.
     */
    private HomeDashboardResponse.ContinueLearning buildContinueLearning(User user, String level) {
        List<Object[]> inProgress =
                userLessonProgressRepository.findByStatusWithLesson(user.getId(), "in_progress", PageRequest.of(0, 1));
        if (!inProgress.isEmpty()) {
            Object[] row = inProgress.get(0);
            String lessonId = (String) row[0];
            String title = (String) row[1];
            String levelCode = (String) row[2];
            Integer lastScore = row[3] == null ? null : ((Number) row[3]).intValue();
            int requiredScore = row[4] == null ? 70 : ((Number) row[4]).intValue();

            boolean notPassedYet = lastScore != null && lastScore < requiredScore;
            String actionType = notPassedYet ? "retry" : "continue";
            String prefix = notPassedYet ? "Làm lại: " : "Tiếp tục: ";

            return new HomeDashboardResponse.ContinueLearning(
                    "lesson",
                    null,
                    lessonId,
                    prefix + title,
                    levelCode,
                    null,
                    actionType,
                    lastScore
            );
        }

        // Fallback: grammar topic đầu theo level (hành vi cũ).
        Optional<GrammarTopic> topic = grammarTopicRepository.findAllByOrderBySortOrderAscCategoryAscLevelAsc().stream()
                .filter(t -> level.equalsIgnoreCase(t.getLevel()))
                .findFirst();
        if (topic.isEmpty()) {
            topic = grammarTopicRepository.findAllByOrderBySortOrderAscCategoryAscLevelAsc().stream().findFirst();
        }
        if (topic.isEmpty()) {
            return null;
        }
        GrammarTopic t = topic.get();
        return new HomeDashboardResponse.ContinueLearning(
                "grammar",
                t.getId(),
                null,
                t.getTitle(),
                t.getLevel(),
                t.getSlug(),
                "grammar",
                null
        );
    }

    /** Tỉ lệ XP của 1 skill dưới ngưỡng này thì coi là "yếu", ưu tiên đẩy gợi ý lên đầu. */
    private static final double WEAK_SKILL_SHARE_THRESHOLD = 0.25;
    private static final List<String> SCORED_SKILLS = List.of("vocabulary", "grammar", "pronunciation");

    /**
     * Gợi ý cá nhân hóa: lấy catalog template theo level (band), rồi SẮP XẾP ưu tiên
     * theo kỹ năng yếu nhất của user (đọc user_skill_xp, V47).
     *
     * <p>User mới (chưa có XP kỹ năng nào) -> giữ thứ tự catalog gốc, không có reason
     * (fallback onboarding, không vỡ UX).
     */
    private List<HomeDashboardResponse.Recommendation> buildRecommendations(User user, String level) {
        List<HomeDashboardResponse.Recommendation> catalog = recommendationCatalog(level);
        if (catalog.isEmpty()) {
            return catalog;
        }

        // XP per-skill thật của user.
        Map<String, Integer> skillXp = new HashMap<>();
        int total = 0;
        for (UserSkillXp row : userSkillXpRepository.findByUserId(user.getId())) {
            int xp = row.getXp() == null ? 0 : row.getXp();
            skillXp.put(row.getSkill(), xp);
            if (SCORED_SKILLS.contains(row.getSkill())) {
                total += xp;
            }
        }

        // User mới chưa luyện kỹ năng nào -> giữ catalog gốc.
        if (total == 0) {
            return catalog;
        }

        // Tìm kỹ năng yếu nhất (share thấp nhất trong các skill có gợi ý ở catalog).
        String weakest = null;
        double weakestShare = Double.MAX_VALUE;
        for (String skill : SCORED_SKILLS) {
            boolean inCatalog = catalog.stream().anyMatch(r -> skill.equals(r.type()));
            if (!inCatalog) {
                continue;
            }
            double share = skillXp.getOrDefault(skill, 0) / (double) total;
            if (share < weakestShare) {
                weakestShare = share;
                weakest = skill;
            }
        }

        // Không tìm thấy skill yếu rõ rệt -> giữ catalog gốc.
        if (weakest == null || weakestShare > WEAK_SKILL_SHARE_THRESHOLD) {
            return catalog;
        }

        // Đẩy gợi ý nhắm kỹ năng yếu nhất lên đầu, kèm lý do hiển thị.
        int sharePct = (int) Math.round(weakestShare * 100);
        String reason = "Bạn dành ít thời gian cho " + skillLabel(weakest)
                + " nhất (" + sharePct + "% XP) — luyện thêm nhé";

        List<HomeDashboardResponse.Recommendation> ordered = new ArrayList<>();
        for (HomeDashboardResponse.Recommendation r : catalog) {
            if (weakest.equals(r.type())) {
                ordered.add(0, new HomeDashboardResponse.Recommendation(
                        r.type(), r.title(), r.description(), r.actionUrl(), reason));
            } else {
                ordered.add(r);
            }
        }
        return ordered;
    }

    private List<HomeDashboardResponse.Recommendation> recommendationCatalog(String level) {
        String l = level.toUpperCase();
        return switch (l) {
            case "A1", "A2" -> List.of(
                    new HomeDashboardResponse.Recommendation("vocabulary", "Học từ vựng cơ bản", "Ôn bộ thẻ Flashcard cấp A1–A2", "/api/desks", null),
                    new HomeDashboardResponse.Recommendation("grammar", "Ngữ pháp căn bản", "Thì hiện tại đơn và động từ to be", "/api/grammar/topics", null),
                    new HomeDashboardResponse.Recommendation("pronunciation", "Luyện phát âm", "Bắt đầu với các âm dễ", "/api/pronunciation/exercises", null)
            );
            case "B1", "B2" -> List.of(
                    new HomeDashboardResponse.Recommendation("vocabulary", "Mở rộng từ vựng", "Ôn bộ thẻ Flashcard cấp B1–B2", "/api/desks", null),
                    new HomeDashboardResponse.Recommendation("grammar", "Ngữ pháp trung cấp", "Thì hoàn thành và câu điều kiện", "/api/grammar/topics", null),
                    new HomeDashboardResponse.Recommendation("pronunciation", "Luyện phát âm", "Cải thiện trọng âm và ngữ điệu", "/api/pronunciation/exercises", null)
            );
            case "C1", "C2" -> List.of(
                    new HomeDashboardResponse.Recommendation("vocabulary", "Từ vựng học thuật", "Ôn bộ thẻ Flashcard cấp C1–C2", "/api/desks", null),
                    new HomeDashboardResponse.Recommendation("grammar", "Ngữ pháp nâng cao", "Inversion và mệnh đề phức tạp", "/api/grammar/topics", null),
                    new HomeDashboardResponse.Recommendation("pronunciation", "Luyện phát âm", "Hoàn thiện phát âm tự nhiên", "/api/pronunciation/exercises", null)
            );
            default -> Collections.emptyList();
        };
    }

    private String skillLabel(String skill) {
        return switch (skill) {
            case "vocabulary" -> "từ vựng";
            case "grammar" -> "ngữ pháp";
            case "pronunciation" -> "phát âm";
            default -> skill;
        };
    }

    private String normalizeLevel(String raw) {
        if (raw == null || raw.isBlank()) {
            return DEFAULT_LEVEL;
        }
        return raw.trim().toUpperCase();
    }
}
