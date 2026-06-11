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

    // Bài kiểm tra ĐẦU VÀO chấm tối đa B2 (cap cứng) → đề chỉ rút câu A1–B2.
    // Xem HE_THONG_KIEM_TRA_TRINH_DO.md §A.4.
    private static final int TOTAL_QUESTIONS = 16;

    // 16 câu: A1×4, A2×4, B1×4, B2×4 (mỗi cấp 2 grammar + 2 vocabulary). Bỏ C1/C2.
    private static final Map<String, Integer> LEVEL_DISTRIBUTION = new LinkedHashMap<>();

    static {
        LEVEL_DISTRIBUTION.put("A1", 4);
        LEVEL_DISTRIBUTION.put("A2", 4);
        LEVEL_DISTRIBUTION.put("B1", 4);
        LEVEL_DISTRIBUTION.put("B2", 4);
    }

    private static final List<String> CEFR_ORDER = List.of("A1", "A2", "B1", "B2", "C1", "C2");

    // Trọng số độ khó theo cấp — dùng cho Weighted Difficulty Scoring (§A.1).
    private static final Map<String, Integer> WEIGHTS = Map.of("A1", 1, "A2", 2, "B1", 3, "B2", 4);

    // Cutoff R → band CEFR (§A.1 Bước 3).
    private static final double CUTOFF_A2 = 0.25;
    private static final double CUTOFF_B1 = 0.45;
    private static final double CUTOFF_B2 = 0.68;

    // Ngưỡng phát hiện "có thể cao hơn B2" (§A.3).
    private static final double GO_HIGHER_MIN_R = 0.90;
    private static final double GO_HIGHER_B2_SMOOTHED = 0.83;

    // Index của B2 trong CEFR_ORDER (cap cứng).
    private static final int B2_INDEX = 3;

    // Thông báo cho người dùng (§A.7).
    private static final String NOTICE_INTRO =
            "Bài kiểm tra đầu vào này gồm 16 câu (ngữ pháp + từ vựng) và chỉ xác định trình độ của bạn "
            + "tối đa tới mức B2 theo chuẩn CEFR. Nếu trình độ của bạn cao hơn B2, hệ thống sẽ gợi ý bạn "
            + "học và làm các bài kiểm tra lên cấp để xác định chính xác. Câu bỏ trống được tính là sai, "
            + "nên hãy cố gắng trả lời tất cả các câu nhé!";
    private static final String MESSAGE_ABOVE_B2 =
            "Bạn đã đạt B2 — mức cao nhất của bài kiểm tra đầu vào! Trình độ thực tế của bạn có thể còn "
            + "cao hơn B2. Hãy học và hoàn thành các bài kiểm tra lên cấp trong lộ trình để xác định chính "
            + "xác trình độ C1/C2 của mình.";

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
        return new StartTestResponse(session.getId(), questions, questions.size(), NOTICE_INTRO);
    }

    @Transactional
    public AnswerQuestionResponse answerQuestion(String firebaseUid, UUID sessionId, AnswerQuestionRequest request) {
        // Load theo (sessionId, firebaseUid) — user khác đoán được UUID cũng chỉ nhận "not found".
        TestSession session = testSessionRepository.findByIdAndUser_FirebaseUid(sessionId, firebaseUid)
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

        // Map questionId -> đáp án, để tính điểm trên TOÀN BỘ đề (câu bỏ trống vẫn vào mẫu số).
        Map<UUID, TestAnswer> answerByQid = answers.stream()
                .collect(Collectors.toMap(a -> a.getQuestion().getId(), a -> a, (x, y) -> x));

        // Weighted Difficulty Scoring (§A.1): R = earned / max, cap cứng B2.
        ScoreResult sr = score(questions, answerByQid);
        String resultLevel = sr.resultLevel();

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

        return buildResult(session, questions, answers, sr.canGoHigherThanB2());
    }

    /** Kết quả chấm: band CEFR (cap B2) + cờ có thể cao hơn B2. */
    private record ScoreResult(String resultLevel, boolean canGoHigherThanB2) {}

    /**
     * Weighted Difficulty Scoring with CEFR Cutoffs (cap cứng B2).
     * Xem HE_THONG_KIEM_TRA_TRINH_DO.md §A.1 + §A.3.
     *
     * <p>R = Σ w(câu đúng) / Σ w(MỌI câu trong đề). Mẫu số ĐỘNG lấy từ toàn bộ đề
     * (câu bỏ trống không cộng earned nhưng vẫn vào max → tính là sai).
     */
    private ScoreResult score(List<Question> questions, Map<UUID, TestAnswer> answerByQid) {
        int earned = 0, max = 0;
        int b2Correct = 0, b2Total = 0;
        for (Question q : questions) {
            int w = WEIGHTS.getOrDefault(q.getCefrLevel(), 0);
            if (w == 0) continue; // bỏ câu C1/C2 lỡ lọt vào (an toàn)
            max += w;
            boolean correct = isCorrect(answerByQid.get(q.getId()));
            if (correct) earned += w;
            if ("B2".equals(q.getCefrLevel())) {
                b2Total++;
                if (correct) b2Correct++;
            }
        }

        if (max == 0) return new ScoreResult("A1", false); // chống chia 0

        double r = (double) earned / max;
        String band;
        if (r < CUTOFF_A2) band = "A1";
        else if (r < CUTOFF_B1) band = "A2";
        else if (r < CUTOFF_B2) band = "B1";
        else band = "B2";

        // Cap cứng B2 (lưới an toàn tường minh).
        String resultLevel = CEFR_ORDER.indexOf(band) > B2_INDEX ? "B2" : band;

        boolean canGoHigher = detectAboveB2(resultLevel, r, b2Correct, b2Total);
        return new ScoreResult(resultLevel, canGoHigher);
    }

    /**
     * Phát hiện "có thể cao hơn B2" — thỏa đồng thời cả 3 điều kiện (§A.3):
     *   (1) resultLevel == B2, (2) Laplace-smoothed B2 accuracy ≥ 0.83, (3) R ≥ 0.90.
     * Dùng Laplace add-1 (Beta(1,1) prior) cho B2 vì chỉ 4 câu B2 → accuracy thô rất nhiễu.
     */
    private boolean detectAboveB2(String resultLevel, double r, int b2Correct, int b2Total) {
        if (!"B2".equals(resultLevel)) return false;
        if (r < GO_HIGHER_MIN_R) return false;
        double b2Smoothed = (double) (b2Correct + 1) / (b2Total + 2);
        return b2Smoothed >= GO_HIGHER_B2_SMOOTHED;
    }

    private boolean isCorrect(TestAnswer a) {
        return a != null && Boolean.TRUE.equals(a.getIsCorrect());
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

    private TestResultResponse buildResult(TestSession session, List<Question> questions,
                                           List<TestAnswer> answers, boolean canGoHigherThanB2) {
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
                canGoHigherThanB2,
                canGoHigherThanB2 ? MESSAGE_ABOVE_B2 : "",
                reviews
        );
    }
}
