package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.*;
import com.kiovant.englishme.entity.*;
import com.kiovant.englishme.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Placement Test theo mô hình CAT (Computerized Adaptive Testing) + IRT 1PL (Rasch).
 *
 * <p>Câu kế tiếp phụ thuộc câu trước: đúng → câu khó hơn, sai → câu dễ hơn. Dừng sau
 * {@code maxQuestions} câu. Ability estimate θ cập nhật sau mỗi câu, map → CEFR (A1–C1).
 * Xem docs/placement-test-cat-upgrade.md.
 */
@Service
public class PlacementTestService {

    // ── IRT 1PL constants ────────────────────────────────────────────────────
    private static final double THETA_START = 0.0;   // khởi đầu ~B1
    private static final double THETA_MIN = -3.0;
    private static final double THETA_MAX = 3.0;
    private static final double LEARNING_RATE = 0.3; // constant step-size MLE (Newton–Raphson bước đầu)
    private static final int DEFAULT_MAX_QUESTIONS = 15;

    private static final List<String> CEFR_ORDER = List.of("A1", "A2", "B1", "B2", "C1", "C2");

    // Ngưỡng phát hiện "có thể cao hơn C1" (kịch trần): θ cuối rất cao.
    private static final double GO_HIGHER_THETA = 2.2;

    // Thông báo cho người dùng.
    private static final String NOTICE_INTRO =
            "Bài kiểm tra đầu vào này điều chỉnh độ khó theo từng câu trả lời của bạn (tối đa 15 câu, "
            + "ngữ pháp + từ vựng) và xác định trình độ của bạn theo chuẩn CEFR từ A1 đến C1. Câu càng về "
            + "sau càng phản ánh đúng năng lực thật của bạn, nên hãy cố gắng trả lời thật chính xác nhé!";
    private static final String MESSAGE_ABOVE_C1 =
            "Bạn đã đạt C1 — mức cao nhất của bài kiểm tra đầu vào! Trình độ thực tế của bạn có thể còn "
            + "cao hơn. Hãy học và hoàn thành các bài kiểm tra lên cấp trong lộ trình để xác định chính "
            + "xác trình độ C2 của mình.";

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

        TestSession session = new TestSession();
        session.setUser(user);
        session.setStatus(TestSession.TestStatus.IN_PROGRESS);
        session.setTheta(THETA_START);
        session.setMaxQuestions(DEFAULT_MAX_QUESTIONS);

        // Câu đầu: chọn theo θ khởi đầu (0.0) — câu gần B1 nhất.
        Question first = selectNextQuestion(THETA_START, List.of(), Map.of());
        if (first == null) {
            throw new IllegalStateException("No placement questions available");
        }
        session.setQuestionIds(new ArrayList<>(List.of(first.getId())));
        testSessionRepository.save(session);

        return new StartTestResponse(session.getId(), toDto(first), DEFAULT_MAX_QUESTIONS, NOTICE_INTRO);
    }

    @Transactional
    public CatAnswerResponse answerQuestion(String firebaseUid, UUID sessionId, AnswerQuestionRequest request) {
        // Load theo (sessionId, firebaseUid) — user khác đoán được UUID cũng chỉ nhận "not found".
        TestSession session = testSessionRepository.findByIdAndUser_FirebaseUid(sessionId, firebaseUid)
                .orElseThrow(() -> new IllegalArgumentException("Test session not found"));
        userService.requireAccountNotLocked(session.getUser());

        if (session.getStatus() == TestSession.TestStatus.COMPLETED) {
            throw new IllegalStateException("Test session already completed");
        }

        UUID questionId = request.questionId();

        // Câu hỏi phải thuộc session này (CAT chỉ append câu hệ thống chọn).
        if (session.getQuestionIds() == null || !session.getQuestionIds().contains(questionId)) {
            throw new IllegalArgumentException("Question does not belong to this session");
        }

        Question question = questionRepository.findById(questionId)
                .orElseThrow(() -> new IllegalArgumentException("Question not found"));

        // Không cho trả lời lại 1 câu.
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

        // ── IRT 1PL: cập nhật θ ───────────────────────────────────────────────
        double theta = session.getTheta() == null ? THETA_START : session.getTheta();
        double b = question.getDifficulty() == null ? 0.0 : question.getDifficulty();
        double p = probabilityCorrect(theta, b);
        theta += correct ? LEARNING_RATE * (1 - p) : -LEARNING_RATE * p;
        theta = clamp(theta, THETA_MIN, THETA_MAX);
        session.setTheta(theta);

        int answeredCount = (int) testAnswerRepository.countByTestSession(session);
        int maxQuestions = session.getMaxQuestions() == null ? DEFAULT_MAX_QUESTIONS : session.getMaxQuestions();
        boolean isDone = answeredCount >= maxQuestions;

        QuestionDto nextDto = null;
        if (!isDone) {
            Map<String, Integer> skillCounts = countSkills(session);
            Question next = selectNextQuestion(theta, session.getQuestionIds(), skillCounts);
            if (next != null) {
                session.getQuestionIds().add(next.getId());
                nextDto = toDto(next);
            } else {
                // Hết câu trong pool → dừng sớm.
                isDone = true;
            }
        }

        testSessionRepository.save(session);

        return new CatAnswerResponse(
                questionId,
                selected,
                question.getCorrectAnswer(),
                correct,
                question.getExplanation(),
                answeredCount,
                maxQuestions,
                isDone,
                nextDto
        );
    }

    /**
     * Học viên tự chọn trình độ CEFR mà không làm bài kiểm tra đầu vào.
     * Set cefrLevel + bật onboarded. Vẫn cho re-test sau để nâng level (mục 6.4).
     */
    @Transactional
    public UserSyncResponse selfSelectLevel(String firebaseUid, SelfSelectLevelRequest request) {
        User user = userRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        userService.requireAccountNotLocked(user);

        String level = request.level() == null ? "" : request.level().trim().toUpperCase();
        if (!CEFR_ORDER.contains(level)) {
            throw new IllegalArgumentException("Invalid CEFR level: " + request.level());
        }

        user.setCefrLevel(level);
        user.setIsOnboarded(true);
        userRepository.save(user);

        return new UserSyncResponse(
                user.getId(),
                user.getEmail(),
                user.getFullName(),
                user.getAvatarUrl(),
                user.getCefrLevel(),
                user.getIsOnboarded(),
                user.getCreatedAt()
        );
    }

    @Transactional
    public TestResultResponse completeTest(String firebaseUid, UUID sessionId) {
        TestSession session = testSessionRepository.findByIdAndUser_FirebaseUid(sessionId, firebaseUid)
                .orElseThrow(() -> new IllegalArgumentException("Test session not found"));
        userService.requireAccountNotLocked(session.getUser());

        if (session.getStatus() == TestSession.TestStatus.COMPLETED) {
            throw new IllegalStateException("Test session already completed");
        }

        List<TestAnswer> answers = testAnswerRepository.findByTestSession(session);
        List<Question> questions = questionRepository.findAllById(session.getQuestionIds());

        double finalTheta = session.getTheta() == null ? THETA_START : session.getTheta();
        String resultLevel = mapThetaToCefr(finalTheta);
        boolean canGoHigherThanC1 = "C1".equals(resultLevel) && finalTheta >= GO_HIGHER_THETA;

        int totalCorrect = (int) answers.stream().filter(a -> Boolean.TRUE.equals(a.getIsCorrect())).count();

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

        return buildResult(session, questions, answers, finalTheta, canGoHigherThanC1);
    }

    // ── IRT 1PL helpers ────────────────────────────────────────────────────────

    /** P(đúng | θ, b) = 1 / (1 + exp(-(θ - b))). */
    private double probabilityCorrect(double theta, double b) {
        return 1.0 / (1.0 + Math.exp(-(theta - b)));
    }

    // Các kỹ năng đánh giá trong placement (cân đều). Listening bỏ — chưa có audio host.
    private static final List<String> CAT_SKILLS = List.of("grammar", "vocabulary", "reading");

    /**
     * Chọn câu kế tiếp: trong pool (loại câu đã hỏi) lấy câu có |b_i - θ| nhỏ nhất.
     * Tiebreak: ưu tiên skill đang bị hỏi ÍT NHẤT để cân đều grammar/vocabulary/reading.
     */
    private Question selectNextQuestion(double theta, List<UUID> askedIds, Map<String, Integer> skillCounts) {
        List<Question> pool = (askedIds == null || askedIds.isEmpty())
                ? questionRepository.findAllForCat()
                : questionRepository.findForCat(askedIds);
        if (pool.isEmpty()) return null;

        // Skill đang ít câu nhất được ưu tiên khi |b_i - θ| hoà.
        String preferredSkill = CAT_SKILLS.stream()
                .min(Comparator.comparingInt(s -> skillCounts.getOrDefault(s, 0)))
                .orElse("grammar");

        Question best = null;
        double bestDist = Double.MAX_VALUE;
        boolean bestPreferred = false;
        for (Question q : pool) {
            double b = q.getDifficulty() == null ? 0.0 : q.getDifficulty();
            double dist = Math.abs(b - theta);
            boolean preferred = preferredSkill.equals(q.getSkillCategory());
            if (dist < bestDist - 1e-9
                    || (Math.abs(dist - bestDist) <= 1e-9 && preferred && !bestPreferred)) {
                best = q;
                bestDist = dist;
                bestPreferred = preferred;
            }
        }
        return best;
    }

    /** Map θ → band CEFR (A1–C1). Xem docs/placement-test-cat-upgrade.md. */
    private String mapThetaToCefr(double theta) {
        if (theta < -1.5) return "A1";
        if (theta < -0.5) return "A2";
        if (theta < 0.5) return "B1";
        if (theta < 1.5) return "B2";
        return "C1";
    }

    /** Đếm số câu grammar/vocabulary ĐÃ hỏi trong session (để balance skill). */
    private Map<String, Integer> countSkills(TestSession session) {
        List<UUID> ids = session.getQuestionIds();
        if (ids == null || ids.isEmpty()) return Map.of();
        Map<String, Integer> counts = new HashMap<>();
        for (Question q : questionRepository.findAllById(ids)) {
            counts.merge(q.getSkillCategory(), 1, Integer::sum);
        }
        return counts;
    }

    private double clamp(double v, double min, double max) {
        return Math.max(min, Math.min(max, v));
    }

    private int compareCefr(String a, String b) {
        return Integer.compare(CEFR_ORDER.indexOf(a), CEFR_ORDER.indexOf(b));
    }

    private QuestionDto toDto(Question q) {
        return new QuestionDto(
                q.getId(),
                q.getCefrLevel(),
                q.getSkillCategory(),
                q.getQuestion(),
                q.getOptions(),
                q.getPassage()
        );
    }

    private TestResultResponse buildResult(TestSession session, List<Question> questions,
                                           List<TestAnswer> answers, double finalTheta,
                                           boolean canGoHigherThanC1) {
        Map<UUID, TestAnswer> answerByQuestion = answers.stream()
                .collect(Collectors.toMap(a -> a.getQuestion().getId(), a -> a, (x, y) -> x));

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
                finalTheta,
                canGoHigherThanC1,
                canGoHigherThanC1 ? MESSAGE_ABOVE_C1 : "",
                reviews
        );
    }
}
