package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.*;
import com.kiovant.englishme.entity.*;
import com.kiovant.englishme.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class PlacementTestService {

    private static final int TOTAL_QUESTIONS = 20;

    // Tổng 20 câu trải đều A1..C2 (theo LEARNING_PATH_BACKEND_SPEC mục 3.1).
    private static final Map<String, Integer> LEVEL_DISTRIBUTION = new LinkedHashMap<>();

    static {
        LEVEL_DISTRIBUTION.put("A1", 4);
        LEVEL_DISTRIBUTION.put("A2", 4);
        LEVEL_DISTRIBUTION.put("B1", 4);
        LEVEL_DISTRIBUTION.put("B2", 4);
        LEVEL_DISTRIBUTION.put("C1", 2);
        LEVEL_DISTRIBUTION.put("C2", 2);
    }

    private static final List<String> CEFR_ORDER = List.of("A1", "A2", "B1", "B2", "C1", "C2");

    private final QuestionRepository questionRepository;
    private final TestSessionRepository testSessionRepository;
    private final TestAnswerRepository testAnswerRepository;
    private final UserRepository userRepository;
    private final UserService userService;

    public PlacementTestService(
            QuestionRepository questionRepository,
            TestSessionRepository testSessionRepository,
            TestAnswerRepository testAnswerRepository,
            UserRepository userRepository,
            UserService userService
    ) {
        this.questionRepository = questionRepository;
        this.testSessionRepository = testSessionRepository;
        this.testAnswerRepository = testAnswerRepository;
        this.userRepository = userRepository;
        this.userService = userService;
    }

    @Transactional
    public StartTestResponse startTest(String firebaseUid) {
        User user = userRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        userService.requireAccountNotLocked(user);

        List<Question> selected = selectQuestions();

        TestSession session = new TestSession();
        session.setUser(user);
        session.setStatus(TestSession.TestStatus.IN_PROGRESS);
        session.setQuestionIds(selected.stream().map(Question::getId).toList());
        testSessionRepository.save(session);

        var questions = selected.stream().map(this::toDto).toList();
        return new StartTestResponse(session.getId(), questions, questions.size());
    }

    @Transactional
    public AnswerQuestionResponse answerQuestion(UUID sessionId, AnswerQuestionRequest request) {
        TestSession session = testSessionRepository.findById(sessionId)
                .orElseThrow(() -> new IllegalArgumentException("Test session not found"));
        userService.requireAccountNotLocked(session.getUser());

        if (session.getStatus() == TestSession.TestStatus.COMPLETED) {
            throw new IllegalStateException("Test session already completed");
        }

        UUID questionId = request.questionId();

        // Kiểm tra câu hỏi có thuộc session này không
        if (session.getQuestionIds() == null || !session.getQuestionIds().contains(questionId)) {
            throw new IllegalArgumentException("Question does not belong to this session");
        }

        Question question = questionRepository.findById(questionId)
                .orElseThrow(() -> new IllegalArgumentException("Question not found"));

        // Kiểm tra đã trả lời câu này chưa (không cho trả lời lại)
        if (testAnswerRepository.findByTestSessionAndQuestion(session, question).isPresent()) {
            throw new IllegalStateException("Question already answered");
        }

        String selected = request.selectedAnswer();
        boolean correct = question.getCorrectAnswer().equals(selected);

        TestAnswer answer = new TestAnswer();
        answer.setTestSession(session);
        answer.setQuestion(question);
        answer.setSelectedAnswer(selected);
        answer.setIsCorrect(correct);
        testAnswerRepository.save(answer);

        long answeredCount = testAnswerRepository.countByTestSession(session);

        return new AnswerQuestionResponse(
                questionId,
                selected,
                question.getCorrectAnswer(),
                correct,
                question.getExplanation(),
                (int) answeredCount,
                session.getQuestionIds().size()
        );
    }

    @Transactional
    public TestResultResponse completeTest(UUID sessionId) {
        TestSession session = testSessionRepository.findById(sessionId)
                .orElseThrow(() -> new IllegalArgumentException("Test session not found"));
        userService.requireAccountNotLocked(session.getUser());

        if (session.getStatus() == TestSession.TestStatus.COMPLETED) {
            throw new IllegalStateException("Test session already completed");
        }

        List<TestAnswer> answers = testAnswerRepository.findByTestSession(session);
        List<Question> questions = questionRepository.findAllById(session.getQuestionIds());

        // Tính điểm và phân loại CEFR
        Map<String, int[]> levelStats = new LinkedHashMap<>();
        for (TestAnswer a : answers) {
            String level = a.getQuestion().getCefrLevel();
            levelStats.computeIfAbsent(level, k -> new int[]{0, 0});
            levelStats.get(level)[1]++;
            if (Boolean.TRUE.equals(a.getIsCorrect())) levelStats.get(level)[0]++;
        }

        int totalCorrect = (int) answers.stream().filter(a -> Boolean.TRUE.equals(a.getIsCorrect())).count();
        String resultLevel = calculateCefrLevel(levelStats);

        session.setCompletedAt(LocalDateTime.now());
        session.setStatus(TestSession.TestStatus.COMPLETED);
        session.setScore(totalCorrect);
        session.setResultLevel(resultLevel);
        testSessionRepository.save(session);

        // Cập nhật cefrLevel của user:
        //  - Lần đầu (cefrLevel == null) → set & bật onboarded.
        //  - Re-test: chỉ nâng level khi resultLevel > current_level (theo spec mục 6.4).
        User user = session.getUser();
        if (user.getCefrLevel() == null) {
            user.setCefrLevel(resultLevel);
            user.setIsOnboarded(true);
            userRepository.save(user);
        } else if (compareCefr(resultLevel, user.getCefrLevel()) > 0) {
            user.setCefrLevel(resultLevel);
            userRepository.save(user);
        }

        return buildResult(session, questions, answers);
    }

    /**
     * Spec mục 3.4:
     *   resultLevel = level cao nhất mà user đạt ≥70% câu đúng ở level đó
     *   VÀ ≥50% ở level kế tiếp. Không đạt mức nào → A1.
     */
    private String calculateCefrLevel(Map<String, int[]> levelStats) {
        String highestPassed = "A1";
        for (int i = 0; i < CEFR_ORDER.size(); i++) {
            String level = CEFR_ORDER.get(i);
            double accuracy = accuracyOf(levelStats, level);
            if (accuracy < 0.7) continue;
            // Yêu cầu ≥50% ở level kế tiếp (nếu có); level cao nhất (C2) bỏ qua check kế tiếp.
            if (i + 1 < CEFR_ORDER.size()) {
                double nextAcc = accuracyOf(levelStats, CEFR_ORDER.get(i + 1));
                if (nextAcc < 0.5) continue;
            }
            highestPassed = level;
        }
        return highestPassed;
    }

    private double accuracyOf(Map<String, int[]> levelStats, String level) {
        int[] stats = levelStats.get(level);
        if (stats == null || stats[1] == 0) return 0.0;
        return (double) stats[0] / stats[1];
    }

    private int compareCefr(String a, String b) {
        return Integer.compare(CEFR_ORDER.indexOf(a), CEFR_ORDER.indexOf(b));
    }

    private List<Question> selectQuestions() {
        List<Question> result = new ArrayList<>();

        for (Map.Entry<String, Integer> entry : LEVEL_DISTRIBUTION.entrySet()) {
            String level = entry.getKey();
            int count = entry.getValue();
            int grammarCount = count / 2;
            int vocabCount = count - grammarCount;
            result.addAll(questionRepository.findRandomByCefrLevelAndSkillCategory(level, "grammar", grammarCount));
            result.addAll(questionRepository.findRandomByCefrLevelAndSkillCategory(level, "vocabulary", vocabCount));
        }

        if (result.size() < TOTAL_QUESTIONS) {
            Set<UUID> existingIds = result.stream().map(Question::getId).collect(Collectors.toSet());
            int needed = TOTAL_QUESTIONS - result.size();
            for (Map.Entry<String, Integer> entry : LEVEL_DISTRIBUTION.entrySet()) {
                if (needed <= 0) break;
                List<Question> extra = questionRepository.findRandomByCefrLevel(entry.getKey(), needed * 2);
                for (Question q : extra) {
                    if (!existingIds.contains(q.getId())) {
                        result.add(q);
                        existingIds.add(q.getId());
                        needed--;
                        if (needed <= 0) break;
                    }
                }
            }
        }

        Collections.shuffle(result);
        return result.size() > TOTAL_QUESTIONS ? result.subList(0, TOTAL_QUESTIONS) : result;
    }

    private QuestionDto toDto(Question q) {
        return new QuestionDto(
                q.getId(),
                q.getCefrLevel(),
                q.getSkillCategory(),
                q.getQuestion(),
                q.getOptions()
        );
    }

    private TestResultResponse buildResult(TestSession session, List<Question> questions, List<TestAnswer> answers) {
        Map<UUID, TestAnswer> answerByQuestion = answers.stream()
                .collect(Collectors.toMap(a -> a.getQuestion().getId(), a -> a));

        List<TestResultResponse.AnswerReview> reviews = questions.stream().map(q -> {
            TestAnswer ans = answerByQuestion.get(q.getId());
            return new TestResultResponse.AnswerReview(
                    q.getId(),
                    q.getQuestion(),
                    ans != null ? ans.getSelectedAnswer() : null,
                    q.getCorrectAnswer(),
                    ans != null && Boolean.TRUE.equals(ans.getIsCorrect()),
                    q.getExplanation()
            );
        }).toList();

        return new TestResultResponse(
                session.getId(),
                session.getResultLevel(),
                session.getScore() != null ? session.getScore() : 0,
                questions.size(),
                reviews
        );
    }
}
