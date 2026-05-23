package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.*;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class LearningService {

    private static final Set<String> VALID_LEVELS = Set.of("A1", "A2", "B1", "B2", "C1", "C2");
    private static final Set<String> VALID_SKILLS = Set.of("listening", "speaking", "reading", "writing");
    private static final String DEFAULT_LEVEL = "A1";

    // ─── GET /api/learning/hub ────────────────────────────────────────

    public LearningHubResponse getHub(String level) {
        String resolved = (level != null && VALID_LEVELS.contains(level)) ? level : DEFAULT_LEVEL;

        return new LearningHubResponse(
                DEFAULT_LEVEL,
                resolved,
                "speaking",
                new LearningHubResponse.DailyGoal(30, 12, 2),
                levels(),
                skillTracks(resolved),
                units(resolved),
                supportTracks()
        );
    }

    // ─── GET /api/learning/levels/{level} ─────────────────────────────

    public LevelDetailResponse getLevel(String level) {
        validateLevel(level);

        return new LevelDetailResponse(
                new LevelDetailResponse.LevelInfo(
                        level,
                        levelTitle(level),
                        levelDescription(level),
                        levelProgress(level),
                        levelStatus(level),
                        "A1".equals(level)
                ),
                levelOutcomes(level),
                units(level),
                skillTracks(level)
        );
    }

    // ─── GET /api/learning/levels/{level}/skills/{skill}/lessons ──────

    public SkillLessonsResponse getSkillLessons(String level, String skill) {
        validateLevel(level);
        validateSkill(skill);

        return new SkillLessonsResponse(
                level,
                skill,
                skillTitleVi(skill) + " " + level,
                skillDescription(level, skill),
                lessons(level, skill)
        );
    }

    // ─── GET /api/learning/lessons/{lessonId} ─────────────────────────

    public LessonDetailResponse getLessonDetail(String lessonId) {
        String[] parts = lessonId.split("-");
        if (parts.length < 3)
            throw new IllegalArgumentException("Invalid lessonId format. Expected: {level}-{skill}-{number}");

        String level = parts[0].toUpperCase();
        String skill = parts[1].toLowerCase();
        int num = Integer.parseInt(parts[2]);

        validateLevel(level);
        validateSkill(skill);

        return buildLessonDetail(level, skill, num, lessonId);
    }

    // ─── POST /api/learning/lessons/{lessonId}/complete ───────────────

    public LessonCompleteResponse completeLesson(String lessonId, LessonCompleteRequest request) {
        String[] parts = lessonId.split("-");
        String level = parts.length >= 1 ? parts[0].toUpperCase() : "A1";
        String skill = parts.length >= 2 ? parts[1].toLowerCase() : "listening";
        int num = Integer.parseInt(parts.length >= 3 ? parts[2] : "1");

        int nextNum = num + 1;
        String nextLessonId = level.toLowerCase() + "-" + skill + "-" + String.format("%03d", nextNum);

        return new LessonCompleteResponse(
                lessonId,
                true,
                request.score(),
                12,
                0.38,
                0.28,
                nextLessonId,
                true
        );
    }

    // ─── GET /api/learning/recommendations ────────────────────────────

    public RecommendationsResponse getRecommendations() {
        return new RecommendationsResponse(List.of(
                new RecommendationsResponse.Recommendation(
                        "continue",
                        "Tiếp tục Nói A1",
                        "Bạn còn 1 bài trong unit Greetings.",
                        "A1",
                        "speaking",
                        "a1-speaking-005",
                        1
                ),
                new RecommendationsResponse.Recommendation(
                        "weak_skill",
                        "Củng cố Nghe A1",
                        "Điểm nghe đang thấp hơn các kỹ năng khác.",
                        "A1",
                        "listening",
                        "a1-listening-003",
                        2
                )
        ));
    }

    // ═══════════════════════════════════════════════════════════════════
    // Mock data builders
    // ═══════════════════════════════════════════════════════════════════

    private List<LearningHubResponse.LevelSummary> levels() {
        return List.of(
                new LearningHubResponse.LevelSummary("A1", "Beginner", "Làm quen câu đơn, từ vựng hằng ngày và phản xạ cơ bản.", 0.35, "in_progress", false),
                new LearningHubResponse.LevelSummary("A2", "Elementary", "Mở rộng giao tiếp thường ngày và mô tả trải nghiệm đơn giản.", 0.0, "locked", true),
                new LearningHubResponse.LevelSummary("B1", "Intermediate", "Xử lý hầu hết tình huống khi du lịch. Diễn đạt ý kiến và kể chuyện.", 0.0, "locked", true),
                new LearningHubResponse.LevelSummary("B2", "Upper Intermediate", "Tương tác trôi chảy với người bản xứ. Trình bày quan điểm chi tiết.", 0.0, "locked", true),
                new LearningHubResponse.LevelSummary("C1", "Advanced", "Diễn đạt linh hoạt trong xã hội, học thuật và công việc.", 0.0, "locked", true),
                new LearningHubResponse.LevelSummary("C2", "Proficient", "Hiểu hầu hết mọi thứ nghe/đọc. Tóm tắt thông tin từ nhiều nguồn.", 0.0, "locked", true)
        );
    }

    private List<LearningHubResponse.SkillTrackSummary> skillTracks(String level) {
        String l = level.toLowerCase();
        return List.of(
                new LearningHubResponse.SkillTrackSummary(
                        "listening", "Nghe", "Nghe ý chính, chi tiết và phản xạ tình huống.",
                        "headphones", "#E53935", skillProgress("listening", level), 12, 2,
                        l + "-listening-001", !"C1".equals(level) && !"C2".equals(level)
                ),
                new LearningHubResponse.SkillTrackSummary(
                        "speaking", "Nói", "Phát âm, câu mẫu và trả lời theo ngữ cảnh.",
                        "record_voice_over", "#E67E22", skillProgress("speaking", level), 10, 4,
                        l + "-speaking-001", true
                ),
                new LearningHubResponse.SkillTrackSummary(
                        "reading", "Đọc", "Đọc hiểu đoạn văn và trả lời câu hỏi.",
                        "menu_book", "#43A047", skillProgress("reading", level), 8, 1,
                        l + "-reading-001", !"C1".equals(level) && !"C2".equals(level)
                ),
                new LearningHubResponse.SkillTrackSummary(
                        "writing", "Viết", "Viết câu và đoạn theo chủ đề.",
                        "edit", "#1E88E5", skillProgress("writing", level), 6, 0,
                        l + "-writing-001", !"C2".equals(level)
                )
        );
    }

    private List<LearningHubResponse.UnitSummary> units(String level) {
        String l = level.toLowerCase();
        return switch (level) {
            case "A1" -> List.of(
                    new LearningHubResponse.UnitSummary(
                            l + "-unit-001", level, "Greetings", "Chào hỏi và giới thiệu bản thân",
                            8, 3, "in_progress", List.of("listening", "speaking", "reading", "writing")
                    ),
                    new LearningHubResponse.UnitSummary(
                            l + "-unit-002", level, "Daily Life", "Mô tả hoạt động hằng ngày",
                            6, 0, "available", List.of("listening", "speaking", "reading")
                    )
            );
            case "A2" -> List.of(
                    new LearningHubResponse.UnitSummary(
                            l + "-unit-001", level, "Plans", "Lịch trình, dự định và lời mời",
                            9, 1, "in_progress", List.of("listening", "speaking", "reading", "writing")
                    ),
                    new LearningHubResponse.UnitSummary(
                            l + "-unit-002", level, "Travel", "Hỏi đường, đặt phòng, mua vé",
                            7, 0, "locked", List.of("listening", "speaking", "writing")
                    )
            );
            default -> List.of(
                    new LearningHubResponse.UnitSummary(
                            l + "-unit-001", level, "Opinions", "Bày tỏ quan điểm và thảo luận",
                            10, 0, "locked", List.of("listening", "speaking", "reading", "writing")
                    ),
                    new LearningHubResponse.UnitSummary(
                            l + "-unit-002", level, "Work", "Giao tiếp nơi làm việc và email",
                            8, 0, "locked", List.of("reading", "writing")
                    )
            );
        };
    }

    private List<LearningHubResponse.SupportTrackSummary> supportTracks() {
        return List.of(
                new LearningHubResponse.SupportTrackSummary(
                        "grammar", "Ngữ pháp theo level",
                        "Mẫu câu và quy tắc cần cho từng chặng học.",
                        "/learn/grammar", 0.3, true
                ),
                new LearningHubResponse.SupportTrackSummary(
                        "vocabulary", "Từ vựng theo chủ đề",
                        "Từ nền tảng cho nghe, nói, đọc và viết.",
                        "/vocabulary", 0.25, true
                ),
                new LearningHubResponse.SupportTrackSummary(
                        "flashcard", "Flashcard ôn tập",
                        "Ôn lại từ và cụm từ đã học bằng spaced repetition.",
                        "/learn/flashcards", 0.1, true
                )
        );
    }

    private List<SkillLessonsResponse.LessonSummary> lessons(String level, String skill) {
        String l = level.toLowerCase();
        String s = skill;
        return switch (skill) {
            case "listening" -> List.of(
                    lesson(l + "-" + s + "-001", l + "-unit-001", "Hello and goodbye", "Nhận diện lời chào và lời tạm biệt", "lesson", 6, 10, "completed", 1),
                    lesson(l + "-" + s + "-002", l + "-unit-001", "What is your name?", "Nghe và chọn thông tin cá nhân", "quiz", 8, 12, "available", 2),
                    lesson(l + "-" + s + "-003", l + "-unit-001", "How are you?", "Nghe hội thoại hỏi thăm sức khỏe", "lesson", 5, 10, "available", 3),
                    lesson(l + "-" + s + "-004", l + "-unit-002", "Morning routine", "Nghe mô tả thói quen buổi sáng", "pronunciation", 7, 12, "available", 4),
                    lesson(l + "-" + s + "-005", l + "-unit-002", "At the cafe", "Nghe đoạn hội thoại tại quán cà phê", "review", 10, 15, "locked", 5)
            );
            case "speaking" -> List.of(
                    lesson(l + "-" + s + "-001", l + "-unit-001", "Introduce yourself", "Luyện nói câu giới thiệu bản thân", "pronunciation", 7, 12, "completed", 1),
                    lesson(l + "-" + s + "-002", l + "-unit-001", "Say hello", "Luyện phát âm lời chào", "pronunciation", 5, 10, "completed", 2),
                    lesson(l + "-" + s + "-003", l + "-unit-001", "Ask a question", "Luyện đặt câu hỏi đơn giản", "quiz", 8, 12, "in_progress", 3),
                    lesson(l + "-" + s + "-004", l + "-unit-002", "Describe your day", "Nói về một ngày của bạn", "review", 9, 15, "available", 4),
                    lesson(l + "-" + s + "-005", l + "-unit-002", "Order food", "Luyện gọi món trong nhà hàng", "lesson", 6, 12, "available", 5)
            );
            case "reading" -> List.of(
                    lesson(l + "-" + s + "-001", l + "-unit-001", "A short profile", "Đọc hồ sơ cá nhân ngắn", "lesson", 8, 10, "completed", 1),
                    lesson(l + "-" + s + "-002", l + "-unit-001", "Signs and notices", "Đọc biển báo và thông báo", "quiz", 6, 10, "available", 2),
                    lesson(l + "-" + s + "-003", l + "-unit-002", "A simple email", "Đọc email ngắn", "lesson", 7, 12, "available", 3),
                    lesson(l + "-" + s + "-004", l + "-unit-002", "Weather forecast", "Đọc dự báo thời tiết", "review", 5, 8, "locked", 4)
            );
            case "writing" -> List.of(
                    lesson(l + "-" + s + "-001", l + "-unit-001", "Write your name and country", "Viết câu giới thiệu cơ bản", "lesson", 8, 12, "available", 1),
                    lesson(l + "-" + s + "-002", l + "-unit-001", "Fill a form", "Điền mẫu đơn cơ bản", "quiz", 7, 10, "available", 2),
                    lesson(l + "-" + s + "-003", l + "-unit-002", "Write about your day", "Viết đoạn ngắn về ngày của bạn", "review", 10, 15, "locked", 3)
            );
            default -> List.of();
        };
    }

    private LessonDetailResponse buildLessonDetail(String level, String skill, int num, String lessonId) {
        int lessonIndex = (num - 1) % 4;
        String unitId = level.toLowerCase() + "-unit-001";
        List<String> titles = List.of(
                skillTitle(skill, "A", num), skillTitle(skill, "B", num),
                skillTitle(skill, "C", num), skillTitle(skill, "D", num)
        );
        String title = lessonIndex < titles.size() ? titles.get(lessonIndex) : "Lesson " + num;
        int[] durations = {6, 8, 7, 10};
        int[] xps = {10, 12, 12, 15};
        String[] statuses = {"completed", "available", "available", "locked"};

        return new LessonDetailResponse(
                lessonId, level, skill, unitId,
                title, "Bài học " + skill + " cấp độ " + level,
                durations[lessonIndex], xps[lessonIndex],
                lessonIndex == 0 ? "completed" : (num <= 3 ? "available" : "locked"),
                buildContent(skill, num),
                buildActivities(skill, num)
        );
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> buildContent(String skill, int num) {
        Map<String, Object> content = new LinkedHashMap<>();
        switch (skill) {
            case "listening" -> {
                content.put("instruction", "Nghe đoạn hội thoại và chọn đáp án đúng.");
                content.put("audioUrl", "https://cdn.example.com/a1/listening/what-is-your-name.mp3");
                content.put("transcript", "Hello. My name is Anna. What is your name?");
                content.put("translationVi", "Xin chào. Tên tôi là Anna. Bạn tên là gì?");
            }
            case "speaking" -> {
                content.put("instruction", "Nghe mẫu, sau đó ghi âm lại câu của bạn.");
                content.put("sampleText", "Hello, my name is Linh.");
                content.put("phonetic", "həˈloʊ, maɪ neɪm ɪz lɪn");
                content.put("translationVi", "Xin chào, tên tôi là Linh.");
                content.put("audioUrl", "https://cdn.example.com/a1/speaking/introduce-yourself.mp3");
            }
            case "reading" -> {
                content.put("instruction", "Đọc đoạn văn và trả lời câu hỏi.");
                content.put("passage", "My name is Ben. I am from Canada. I am a student.");
                content.put("translationVi", "Tên tôi là Ben. Tôi đến từ Canada. Tôi là học sinh.");
            }
            case "writing" -> {
                content.put("instruction", "Viết 2 câu giới thiệu tên và quốc gia của bạn.");
                content.put("prompt", "Write your name and where you are from.");
                content.put("exampleAnswer", "My name is Mai. I am from Vietnam.");
                content.put("minWords", 6);
                content.put("maxWords", 30);
            }
        }
        return content;
    }

    private List<LessonDetailResponse.Activity> buildActivities(String skill, int num) {
        return switch (skill) {
            case "listening" -> List.of(
                    activityMultipleChoice("act-001", "What is the speaker's name?",
                            List.of(option("A", "Anna"), option("B", "Emma"), option("C", "Lana")),
                            "A", "Người nói nói: My name is Anna.")
            );
            case "speaking" -> List.of(
                    activityPronunciation("act-001", "Hello, my name is Linh.", 70)
            );
            case "reading" -> List.of(
                    activityMultipleChoice("act-001", "Where is Ben from?",
                            List.of(option("A", "Canada"), option("B", "Japan"), option("C", "Vietnam")),
                            "A", "Trong bài có câu: I am from Canada.")
            );
            case "writing" -> List.of(
                    activityWriting("act-001", "Write your name and where you are from.",
                            List.of("Có câu giới thiệu tên.", "Có câu giới thiệu quốc gia.", "Dùng đúng cấu trúc: My name is... / I am from..."))
            );
            default -> List.of();
        };
    }

    // ─── Helper methods ──────────────────────────────────────────────

    private static SkillLessonsResponse.LessonSummary lesson(String id, String unitId, String title, String subtitle,
                                                              String activityType, int mins, int xp, String status, int order) {
        return new SkillLessonsResponse.LessonSummary(id, unitId, title, subtitle, activityType, mins, xp, status, order);
    }

    private static LessonDetailResponse.Activity.Option option(String id, String text) {
        return new LessonDetailResponse.Activity.Option(id, text);
    }

    private static LessonDetailResponse.Activity activityMultipleChoice(String id, String question,
                                                                         List<LessonDetailResponse.Activity.Option> options,
                                                                         String correctId, String explanation) {
        return new LessonDetailResponse.Activity(id, "multiple_choice", question, options, correctId, explanation, null, null, null, null, null);
    }

    private static LessonDetailResponse.Activity activityPronunciation(String id, String expectedText, int minScore) {
        return new LessonDetailResponse.Activity(id, "pronunciation", null, null, null, null, expectedText, minScore, null, null, null);
    }

    private static LessonDetailResponse.Activity activityWriting(String id, String prompt, List<String> rubric) {
        return new LessonDetailResponse.Activity(id, "writing_prompt", null, null, null, null, null, null, prompt, rubric, null);
    }

    // ─── Level helpers ────────────────────────────────

    private String levelTitle(String level) {
        return switch (level) {
            case "A1" -> "Beginner";
            case "A2" -> "Elementary";
            case "B1" -> "Intermediate";
            case "B2" -> "Upper Intermediate";
            case "C1" -> "Advanced";
            case "C2" -> "Proficient";
            default -> level;
        };
    }

    private String levelDescription(String level) {
        return switch (level) {
            case "A1" -> "Làm quen câu đơn, từ vựng hằng ngày và phản xạ cơ bản.";
            case "A2" -> "Mở rộng giao tiếp thường ngày và mô tả trải nghiệm đơn giản.";
            case "B1" -> "Xử lý hầu hết tình huống khi du lịch. Diễn đạt ý kiến và kể chuyện.";
            case "B2" -> "Tương tác trôi chảy với người bản xứ. Trình bày quan điểm chi tiết.";
            case "C1" -> "Diễn đạt linh hoạt trong xã hội, học thuật và công việc.";
            case "C2" -> "Hiểu hầu hết mọi thứ nghe/đọc. Tóm tắt thông tin từ nhiều nguồn.";
            default -> "";
        };
    }

    private double levelProgress(String level) {
        return "A1".equals(level) ? 0.35 : ("A2".equals(level) ? 0.18 : 0.0);
    }

    private String levelStatus(String level) {
        if ("A1".equals(level)) return "in_progress";
        if ("A2".equals(level)) return "available";
        return "locked";
    }

    private double skillProgress(String skill, String level) {
        if (!"A1".equals(level)) return 0.0;
        return switch (skill) {
            case "listening" -> 0.2;
            case "speaking" -> 0.45;
            case "reading" -> 0.12;
            case "writing" -> 0.05;
            default -> 0.0;
        };
    }

    private List<String> levelOutcomes(String level) {
        return switch (level) {
            case "A1" -> List.of(
                    "Hiểu và dùng các câu đơn giản hằng ngày.",
                    "Giới thiệu bản thân và trả lời câu hỏi cá nhân cơ bản.",
                    "Tương tác đơn giản với người nói chậm và rõ ràng."
            );
            case "A2" -> List.of(
                    "Hiểu câu nói ngắn trong tình huống quen thuộc.",
                    "Viết đoạn ngắn 4-6 câu về bản thân hoặc kế hoạch.",
                    "Trao đổi thông tin đơn giản khi đi học, đi làm hoặc du lịch."
            );
            case "B1" -> List.of(
                    "Xử lý hầu hết tình huống khi du lịch.",
                    "Viết đoạn liên kết về chủ đề quen thuộc.",
                    "Mô tả trải nghiệm, sự kiện và đưa ra lý do ngắn gọn."
            );
            default -> List.of(
                    "Tiếp tục mở rộng vốn từ và mẫu câu.",
                    "Thực hành giao tiếp trong tình huống thực tế.",
                    "Phát triển khả năng đọc hiểu và viết đoạn."
            );
        };
    }

    private String skillTitle(String skill, String prefix, int num) {
        return switch (skill) {
            case "listening" -> prefix + " - Nghe bài " + num;
            case "speaking" -> prefix + " - Nói bài " + num;
            case "reading" -> prefix + " - Đọc bài " + num;
            case "writing" -> prefix + " - Viết bài " + num;
            default -> prefix + " - Bài " + num;
        };
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

    private String skillDescription(String level, String skill) {
        return switch (skill) {
            case "listening" -> "Nghe câu và đoạn hội thoại ngắn trong tình huống quen thuộc.";
            case "speaking" -> "Phát âm, câu mẫu và trả lời theo ngữ cảnh.";
            case "reading" -> "Đọc đoạn văn ngắn và trả lời câu hỏi.";
            case "writing" -> "Viết câu và đoạn theo chủ đề quen thuộc.";
            default -> "";
        };
    }

    // ─── Validation ────────────────────────────────────────────────────

    private void validateLevel(String level) {
        if (level == null || !VALID_LEVELS.contains(level)) {
            throw new IllegalArgumentException("Invalid level: " + level + ". Valid values: " + VALID_LEVELS);
        }
    }

    private void validateSkill(String skill) {
        if (skill == null || !VALID_SKILLS.contains(skill)) {
            throw new IllegalArgumentException("Invalid skill: " + skill + ". Valid values: " + VALID_SKILLS);
        }
    }
}
