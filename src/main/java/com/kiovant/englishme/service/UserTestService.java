package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.AnswerSubmit;
import com.kiovant.englishme.dto.TestHistoryItem;
import com.kiovant.englishme.dto.TestQuestionResponse;
import com.kiovant.englishme.dto.UserTestStartResponse;
import com.kiovant.englishme.dto.UserTestSubmitResponse;
import com.kiovant.englishme.dto.XpGrantResult;
import com.kiovant.englishme.entity.Question;
import com.kiovant.englishme.entity.User;
import com.kiovant.englishme.entity.UserTestSession;
import com.kiovant.englishme.repository.QuestionRepository;
import com.kiovant.englishme.repository.UserRepository;
import com.kiovant.englishme.repository.UserTestSessionRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

@Service
public class UserTestService {

    private static final int DEFAULT_QUESTION_COUNT = 10;
    private static final int DEFAULT_DURATION_SECONDS = 900; // 15 min
    private static final Set<String> ALLOWED_TOPICS = Set.of("grammar", "vocabulary");
    private static final Set<String> ALLOWED_LEVELS = Set.of("a1", "a2", "b1", "b2", "c1", "c2");

    private final UserRepository userRepository;
    private final QuestionRepository questionRepository;
    private final UserTestSessionRepository sessionRepository;
    private final XpService xpService;
    private final XpRuleService xpRuleService;

    public UserTestService(UserRepository userRepository,
                           QuestionRepository questionRepository,
                           UserTestSessionRepository sessionRepository,
                           XpService xpService,
                           XpRuleService xpRuleService) {
        this.userRepository = userRepository;
        this.questionRepository = questionRepository;
        this.sessionRepository = sessionRepository;
        this.xpService = xpService;
        this.xpRuleService = xpRuleService;
    }

    @Transactional
    public UserTestStartResponse createSession(String firebaseUid, String topic, String level) {
        String normTopic = normalizeTopic(topic);
        String normLevel = normalizeLevel(level);
        User user = loadUser(firebaseUid);

        String skillCategory = normTopic.substring(0, 1).toUpperCase() + normTopic.substring(1); // grammar -> Grammar
        String cefrUpper = normLevel.toUpperCase();

        List<Question> picked = questionRepository.findRandomByCefrLevelAndSkillCategory(
                cefrUpper, skillCategory, DEFAULT_QUESTION_COUNT);
        if (picked.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND,
                    "No questions available for topic '" + normTopic + "' at level " + cefrUpper);
        }

        UserTestSession session = new UserTestSession();
        session.setUser(user);
        session.setTopic(normTopic);
        session.setLevel(normLevel);
        session.setStatus("active");
        session.setQuestionIds(picked.stream().map(Question::getId).toList());
        session.setDurationSeconds(DEFAULT_DURATION_SECONDS);
        session.setTotal(picked.size());
        session = sessionRepository.save(session);

        List<TestQuestionResponse> questions = picked.stream()
                .map(q -> new TestQuestionResponse(
                        q.getId(),
                        q.getCefrLevel(),
                        q.getSkillCategory(),
                        q.getQuestion(),
                        q.getOptions()))
                .toList();

        return new UserTestStartResponse(
                session.getId(),
                normTopic,
                normLevel,
                picked.size(),
                DEFAULT_DURATION_SECONDS,
                questions
        );
    }

    @Transactional
    public UserTestSubmitResponse submit(String firebaseUid, UUID sessionId,
                                         List<AnswerSubmit> answers, Integer timeTakenSeconds) {
        UserTestSession session = sessionRepository.findByIdAndUser_FirebaseUid(sessionId, firebaseUid)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Test session not found"));

        if ("completed".equalsIgnoreCase(session.getStatus())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Test session is already completed");
        }
        if (answers == null) {
            answers = List.of();
        }

        Set<UUID> sessionQuestionIds = new HashSet<>(session.getQuestionIds());
        Map<UUID, Question> questionsById = new HashMap<>();
        for (Question q : questionRepository.findAllById(session.getQuestionIds())) {
            questionsById.put(q.getId(), q);
        }

        Set<UUID> answeredIds = new HashSet<>();
        int correct = 0;

        for (AnswerSubmit submit : answers) {
            if (submit == null || submit.questionId() == null) {
                continue;
            }
            UUID qid = submit.questionId();
            if (!sessionQuestionIds.contains(qid) || answeredIds.contains(qid)) {
                continue;
            }
            Question q = questionsById.get(qid);
            if (q == null) {
                continue;
            }
            if (q.getCorrectAnswer() != null
                    && submit.selectedAnswer() != null
                    && q.getCorrectAnswer().equalsIgnoreCase(submit.selectedAnswer())) {
                correct++;
            }
            answeredIds.add(qid);
        }

        int total = session.getQuestionIds().size();
        int accuracy = total == 0 ? 0 : (int) Math.round((correct * 100.0) / total);
        int candidateXp = xpRuleService.computeAccuracyBased("test", correct, total);
        String cefrSuggestion = suggestCefr(session.getLevel(), accuracy);

        int safeTime = timeTakenSeconds == null || timeTakenSeconds < 0 ? 0 : timeTakenSeconds;

        session.setStatus("completed");
        session.setCorrect(correct);
        session.setTotal(total);
        session.setTimeTakenSeconds(safeTime);
        session.setCefrSuggestion(cefrSuggestion);
        session.setCompletedAt(LocalDateTime.now());

        // Idempotent grant — 1 session chỉ được cộng XP 1 lần dù retry mạng.
        XpGrantResult xpResult = xpService.grant(
                session.getUser().getId(),
                candidateXp,
                "test",
                session.getId().toString(),
                "test:" + session.getId() + ":submit",
                java.util.Map.of(
                        "topic", session.getTopic(),
                        "level", session.getLevel(),
                        "correct", correct,
                        "total", total,
                        "accuracy", accuracy
                )
        );
        session.setXpEarned(xpResult.xpEarned());
        sessionRepository.save(session);

        return new UserTestSubmitResponse(
                session.getId(),
                session.getTopic(),
                session.getLevel(),
                total,
                correct,
                total - correct,
                accuracy,
                xpResult.xpEarned(),
                xpResult.totalXp(),
                xpResult.dailyEarnedXp(),
                xpResult.streakUpdated(),
                safeTime,
                cefrSuggestion
        );
    }

    @Transactional(readOnly = true)
    public List<TestHistoryItem> getHistory(String firebaseUid) {
        // Verify user exists (throws if not synced)
        loadUser(firebaseUid);

        return sessionRepository.findByUser_FirebaseUidOrderByCreatedAtDesc(firebaseUid).stream()
                .map(s -> {
                    int total = s.getTotal() == null ? 0 : s.getTotal();
                    int correct = s.getCorrect() == null ? 0 : s.getCorrect();
                    int accuracy = total == 0 ? 0 : (int) Math.round((correct * 100.0) / total);
                    return new TestHistoryItem(
                            s.getId(),
                            s.getTopic(),
                            s.getLevel(),
                            s.getStatus(),
                            s.getTotal(),
                            s.getCorrect(),
                            accuracy,
                            s.getXpEarned(),
                            s.getTimeTakenSeconds(),
                            s.getCefrSuggestion(),
                            s.getCreatedAt(),
                            s.getCompletedAt()
                    );
                })
                .toList();
    }

    /** Suggest CEFR upgrade/downgrade based on accuracy at chosen level. */
    private static String suggestCefr(String testedLevel, int accuracy) {
        String upper = testedLevel.toUpperCase();
        List<String> ladder = List.of("A1", "A2", "B1", "B2", "C1", "C2");
        int idx = ladder.indexOf(upper);
        if (idx < 0) return upper;
        if (accuracy >= 85 && idx < ladder.size() - 1) {
            return ladder.get(idx + 1);
        }
        if (accuracy < 50 && idx > 0) {
            return ladder.get(idx - 1);
        }
        return upper;
    }

    private static String normalizeTopic(String raw) {
        if (raw == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "topic is required");
        }
        String t = raw.trim().toLowerCase();
        if (!ALLOWED_TOPICS.contains(t)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "topic must be 'grammar' or 'vocabulary'");
        }
        return t;
    }

    private static String normalizeLevel(String raw) {
        if (raw == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "level is required");
        }
        String l = raw.trim().toLowerCase();
        if (!ALLOWED_LEVELS.contains(l)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "level must be one of a1, a2, b1, b2, c1, c2");
        }
        return l;
    }

    private User loadUser(String firebaseUid) {
        return userRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED,
                        "User profile not found. Please sync account first."));
    }
}
