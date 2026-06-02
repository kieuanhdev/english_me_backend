package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.HomeDashboardResponse;
import com.kiovant.englishme.dto.VocabularyWordResponse;
import com.kiovant.englishme.entity.GrammarTopic;
import com.kiovant.englishme.entity.User;
import com.kiovant.englishme.entity.XpHistory;
import com.kiovant.englishme.repository.GrammarTopicRepository;
import com.kiovant.englishme.repository.UserDailyGoalRepository;
import com.kiovant.englishme.repository.UserRepository;
import com.kiovant.englishme.repository.XpHistoryRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.TemporalAdjusters;
import java.util.Collections;
import java.util.List;
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

    public HomeDashboardService(UserRepository userRepository,
                                XpHistoryRepository xpHistoryRepository,
                                WordOfDayService wordOfDayService,
                                GrammarTopicRepository grammarTopicRepository,
                                UserDailyGoalRepository userDailyGoalRepository) {
        this.userRepository = userRepository;
        this.xpHistoryRepository = xpHistoryRepository;
        this.wordOfDayService = wordOfDayService;
        this.grammarTopicRepository = grammarTopicRepository;
        this.userDailyGoalRepository = userDailyGoalRepository;
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
                buildContinueLearning(level),
                buildRecommendations(level)
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

        return new HomeDashboardResponse.DailyStats(xpToday, xpWeek, activeDays, user.getCurrentStreak(), xpGoal);
    }

    private HomeDashboardResponse.WordOfDay buildWordOfDay(User user, String level) {
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

    private HomeDashboardResponse.ContinueLearning buildContinueLearning(String level) {
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
                t.getTitle(),
                t.getLevel(),
                t.getSlug()
        );
    }

    private List<HomeDashboardResponse.Recommendation> buildRecommendations(String level) {
        String l = level.toUpperCase();
        return switch (l) {
            case "A1", "A2" -> List.of(
                    new HomeDashboardResponse.Recommendation("vocabulary", "Học từ vựng cơ bản", "Ôn bộ thẻ Flashcard cấp A1–A2", "/api/desks"),
                    new HomeDashboardResponse.Recommendation("grammar", "Ngữ pháp căn bản", "Thì hiện tại đơn và động từ to be", "/api/grammar/topics"),
                    new HomeDashboardResponse.Recommendation("pronunciation", "Luyện phát âm", "Bắt đầu với các âm dễ", "/api/pronunciation/exercises")
            );
            case "B1", "B2" -> List.of(
                    new HomeDashboardResponse.Recommendation("vocabulary", "Mở rộng từ vựng", "Ôn bộ thẻ Flashcard cấp B1–B2", "/api/desks"),
                    new HomeDashboardResponse.Recommendation("grammar", "Ngữ pháp trung cấp", "Thì hoàn thành và câu điều kiện", "/api/grammar/topics"),
                    new HomeDashboardResponse.Recommendation("exercise", "Luyện bài tập", "Làm bài tập mức medium hàng ngày", "/api/exercises/sessions")
            );
            case "C1", "C2" -> List.of(
                    new HomeDashboardResponse.Recommendation("vocabulary", "Từ vựng học thuật", "Ôn bộ thẻ Flashcard cấp C1–C2", "/api/desks"),
                    new HomeDashboardResponse.Recommendation("grammar", "Ngữ pháp nâng cao", "Inversion và mệnh đề phức tạp", "/api/grammar/topics"),
                    new HomeDashboardResponse.Recommendation("test", "Thử sức bài test", "Làm bài test có tính giờ để đo trình độ", "/api/tests/sessions")
            );
            default -> Collections.emptyList();
        };
    }

    private String normalizeLevel(String raw) {
        if (raw == null || raw.isBlank()) {
            return DEFAULT_LEVEL;
        }
        return raw.trim().toUpperCase();
    }
}
