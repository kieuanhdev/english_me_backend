package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.*;
import com.kiovant.englishme.entity.*;
import com.kiovant.englishme.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class PlacementTestService {

    private static final int TOTAL_QUESTIONS = 12;

    private static final Map<String, Integer> LEVEL_DISTRIBUTION = new LinkedHashMap<>();

    static {
        LEVEL_DISTRIBUTION.put("A1", 4);
        LEVEL_DISTRIBUTION.put("A2", 4);
        // Mở rộng sau: B1 -> 2, B2 -> 2
    }

    @Autowired
    private QuestionRepository questionRepository;

    @Autowired
    private TestSessionRepository testSessionRepository;

    @Autowired
    private TestAnswerRepository testAnswerRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private UserService userService;

    @Transactional
    public StartTestResponse startTest(String firebaseUid) {
        User user = userRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        userService.requireAccountNotLocked(user);

        List<Question> selected = selectQuestions();

        TestSession session = new TestSession();
        session.setUser(user);
        session.setStatus(TestSession.TestStatus.IN_PROGRESS);
        session.setQuestionIds(selected.stream().map(Question::getId).collect(Collectors.toList()));
        testSessionRepository.save(session);

        StartTestResponse response = new StartTestResponse();
        response.setSessionId(session.getId());
        response.setTotalQuestions(selected.size());
        response.setQuestions(selected.stream().map(this::toDto).collect(Collectors.toList()));
        return response;
    }

    @Transactional
    public AnswerQuestionResponse answerQuestion(UUID sessionId, AnswerQuestionRequest request) {
        TestSession session = testSessionRepository.findById(sessionId)
                .orElseThrow(() -> new IllegalArgumentException("Test session not found"));
        userService.requireAccountNotLocked(session.getUser());

        if (session.getStatus() == TestSession.TestStatus.COMPLETED) {
            throw new IllegalStateException("Test session already completed");
        }

        UUID questionId = request.getQuestionId();

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

        String selected = request.getSelectedAnswer();
        boolean correct = question.getCorrectAnswer().equals(selected);

        TestAnswer answer = new TestAnswer();
        answer.setTestSession(session);
        answer.setQuestion(question);
        answer.setSelectedAnswer(selected);
        answer.setIsCorrect(correct);
        testAnswerRepository.save(answer);

        long answeredCount = testAnswerRepository.countByTestSession(session);

        AnswerQuestionResponse response = new AnswerQuestionResponse();
        response.setQuestionId(questionId);
        response.setSelectedAnswer(selected);
        response.setCorrectAnswer(question.getCorrectAnswer());
        response.setCorrect(correct);
        response.setExplanation(question.getExplanation());
        response.setAnsweredCount((int) answeredCount);
        response.setTotalQuestions(session.getQuestionIds().size());
        return response;
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

        // Cập nhật cefrLevel của user nếu chưa có
        User user = session.getUser();
        if (user.getCefrLevel() == null) {
            user.setCefrLevel(resultLevel);
            user.setIsOnboarded(true);
            userRepository.save(user);
        }

        return buildResult(session, questions, answers);
    }

    private String calculateCefrLevel(Map<String, int[]> levelStats) {
        List<String> orderedLevels = List.of("A1", "A2", "B1", "B2", "C1", "C2");
        String highestPassed = "A1";
        for (String level : orderedLevels) {
            int[] stats = levelStats.get(level);
            if (stats == null) continue;
            double accuracy = (double) stats[0] / stats[1];
            if (accuracy >= 0.5) highestPassed = level;
        }
        return highestPassed;
    }

    private List<Question> selectQuestions() {
        List<Question> result = new ArrayList<>();

        for (Map.Entry<String, Integer> entry : LEVEL_DISTRIBUTION.entrySet()) {
            String level = entry.getKey();
            int count = entry.getValue();
            int grammarCount = count / 2;
            int vocabCount = count - grammarCount;
            result.addAll(questionRepository.findRandomByCefrLevelAndSkillCategory(level, "Grammar", grammarCount));
            result.addAll(questionRepository.findRandomByCefrLevelAndSkillCategory(level, "Vocabulary", vocabCount));
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
        QuestionDto dto = new QuestionDto();
        dto.setId(q.getId());
        dto.setCefrLevel(q.getCefrLevel());
        dto.setSkillCategory(q.getSkillCategory());
        dto.setQuestion(q.getQuestion());
        dto.setOptions(q.getOptions());
        return dto;
    }

    private TestResultResponse buildResult(TestSession session, List<Question> questions, List<TestAnswer> answers) {
        Map<UUID, TestAnswer> answerByQuestion = answers.stream()
                .collect(Collectors.toMap(a -> a.getQuestion().getId(), a -> a));

        List<TestResultResponse.AnswerReview> reviews = questions.stream().map(q -> {
            TestResultResponse.AnswerReview review = new TestResultResponse.AnswerReview();
            review.setQuestionId(q.getId());
            review.setQuestion(q.getQuestion());
            review.setCorrectAnswer(q.getCorrectAnswer());
            review.setExplanation(q.getExplanation());
            TestAnswer ans = answerByQuestion.get(q.getId());
            if (ans != null) {
                review.setSelectedAnswer(ans.getSelectedAnswer());
                review.setCorrect(Boolean.TRUE.equals(ans.getIsCorrect()));
            }
            return review;
        }).collect(Collectors.toList());

        TestResultResponse response = new TestResultResponse();
        response.setSessionId(session.getId());
        response.setResultLevel(session.getResultLevel());
        response.setScore(session.getScore());
        response.setTotalQuestions(questions.size());
        response.setReview(reviews);
        return response;
    }
}
