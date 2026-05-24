package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.AnswerSubmit;
import com.kiovant.englishme.dto.ExerciseAnswerResult;
import com.kiovant.englishme.dto.ExerciseCompleteResponse;
import com.kiovant.englishme.dto.ExerciseQuestionResponse;
import com.kiovant.englishme.dto.ExerciseSessionResponse;
import com.kiovant.englishme.dto.XpGrantResult;
import com.kiovant.englishme.entity.ExerciseAnswer;
import com.kiovant.englishme.entity.ExerciseQuestion;
import com.kiovant.englishme.entity.ExerciseSession;
import com.kiovant.englishme.entity.User;
import com.kiovant.englishme.repository.ExerciseAnswerRepository;
import com.kiovant.englishme.repository.ExerciseQuestionRepository;
import com.kiovant.englishme.repository.ExerciseSessionRepository;
import com.kiovant.englishme.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

@Service
public class ExerciseService {

    private static final int DEFAULT_SIZE = 10;
    private static final int MAX_SIZE = 50;
    private static final Set<String> ALLOWED_CATEGORIES = Set.of("vocabulary", "grammar");

    private final UserRepository userRepository;
    private final ExerciseQuestionRepository questionRepository;
    private final ExerciseSessionRepository sessionRepository;
    private final ExerciseAnswerRepository answerRepository;
    private final XpService xpService;
    private final XpRuleService xpRuleService;

    public ExerciseService(UserRepository userRepository,
                           ExerciseQuestionRepository questionRepository,
                           ExerciseSessionRepository sessionRepository,
                           ExerciseAnswerRepository answerRepository,
                           XpService xpService,
                           XpRuleService xpRuleService) {
        this.userRepository = userRepository;
        this.questionRepository = questionRepository;
        this.sessionRepository = sessionRepository;
        this.answerRepository = answerRepository;
        this.xpService = xpService;
        this.xpRuleService = xpRuleService;
    }

    @Transactional
    public ExerciseSessionResponse createSession(String firebaseUid, String category, int size) {
        String cat = normalizeCategory(category);
        int cap = clampSize(size);

        User user = loadUser(firebaseUid);

        List<ExerciseQuestion> picked = questionRepository.findRandomByCategory(cat, cap);
        if (picked.size() < cap) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Not enough questions available for category: " + cat);
        }

        ExerciseSession session = new ExerciseSession();
        session.setUser(user);
        session.setCategory(cat);
        session.setStatus("active");
        session.setQuestionIds(picked.stream().map(ExerciseQuestion::getId).toList());
        session = sessionRepository.save(session);

        List<ExerciseQuestionResponse> questions = picked.stream()
                .map(q -> new ExerciseQuestionResponse(
                        q.getId().toString(),
                        "multipleChoice",
                        q.getCategory(),
                        q.getDifficulty(),
                        q.getQuestion(),
                        toOptionsMap(q.getOptions()),
                        q.getCorrectAnswer(),
                        q.getExplanation(),
                        q.getHint()))
                .toList();

        return new ExerciseSessionResponse(session.getId(), cat, picked.size(), questions);
    }

    @Transactional
    public ExerciseCompleteResponse completeSession(String firebaseUid, UUID sessionId, List<AnswerSubmit> answers) {
        ExerciseSession session = sessionRepository.findByIdAndUser_FirebaseUid(sessionId, firebaseUid)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Exercise session not found"));

        if ("completed".equalsIgnoreCase(session.getStatus())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Exercise session is already completed");
        }
        if (answers == null) {
            answers = List.of();
        }

        Set<UUID> sessionQuestionIds = new HashSet<>(session.getQuestionIds());
        Map<UUID, ExerciseQuestion> questionsById = new HashMap<>();
        for (ExerciseQuestion q : questionRepository.findAllById(session.getQuestionIds())) {
            questionsById.put(q.getId(), q);
        }

        List<ExerciseAnswerResult> results = new ArrayList<>();
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
            ExerciseQuestion q = questionsById.get(qid);
            if (q == null) {
                continue;
            }
            boolean isCorrect = q.getCorrectAnswer() != null
                    && submit.selectedAnswer() != null
                    && q.getCorrectAnswer().equals(submit.selectedAnswer());
            if (isCorrect) correct++;

            ExerciseAnswer ans = new ExerciseAnswer();
            ans.setSession(session);
            ans.setQuestion(q);
            ans.setSelectedAnswer(submit.selectedAnswer());
            ans.setIsCorrect(isCorrect);
            answerRepository.save(ans);
            answeredIds.add(qid);

            results.add(new ExerciseAnswerResult(
                    qid,
                    submit.selectedAnswer(),
                    q.getCorrectAnswer(),
                    isCorrect,
                    q.getExplanation()
            ));
        }

        int total = session.getQuestionIds().size();
        double accuracy = total == 0 ? 0.0 : Math.round((correct * 1000.0) / total) / 10.0;
        int candidateXp = xpRuleService.computeAccuracyBased("exercise", correct, total);

        session.setStatus("completed");
        session.setCompletedAt(LocalDateTime.now());
        sessionRepository.save(session);

        XpGrantResult xpResult = xpService.grant(
                session.getUser().getId(),
                candidateXp,
                "exercise",
                session.getId().toString(),
                "exercise:" + session.getId() + ":submit",
                java.util.Map.of(
                        "category", session.getCategory(),
                        "correct", correct,
                        "total", total,
                        "accuracy", accuracy
                )
        );

        return new ExerciseCompleteResponse(
                session.getId(),
                session.getCategory(),
                total,
                correct,
                total - correct,
                accuracy,
                xpResult.xpEarned(),
                xpResult.totalXp(),
                xpResult.dailyEarnedXp(),
                xpResult.streakUpdated(),
                results
        );
    }

    private static String normalizeCategory(String raw) {
        if (raw == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "category is required");
        }
        String cat = raw.trim().toLowerCase();
        if (!ALLOWED_CATEGORIES.contains(cat)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "category must be 'vocabulary' or 'grammar'");
        }
        return cat;
    }

    private static int clampSize(int size) {
        if (size <= 0) return DEFAULT_SIZE;
        return Math.min(size, MAX_SIZE);
    }

    private User loadUser(String firebaseUid) {
        return userRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "User profile not found. Please sync account first."));
    }

    private static Map<String, String> toOptionsMap(Map<String, String> options) {
        return options == null ? Map.of() : options;
    }
}
