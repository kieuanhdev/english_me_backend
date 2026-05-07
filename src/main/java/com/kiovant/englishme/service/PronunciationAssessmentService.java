package com.kiovant.englishme.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.kiovant.englishme.dto.PronunciationAssessResponse;
import com.kiovant.englishme.dto.AdminPronunciationAttemptRow;
import com.kiovant.englishme.dto.PronunciationAttemptHistoryItemResponse;
import com.kiovant.englishme.dto.PronunciationWordFeedbackDto;
import com.kiovant.englishme.entity.PronunciationAttempt;
import com.kiovant.englishme.entity.PronunciationWordFeedback;
import com.kiovant.englishme.entity.User;
import com.kiovant.englishme.repository.PronunciationAttemptRepository;
import com.kiovant.englishme.repository.PronunciationWordFeedbackRepository;
import com.kiovant.englishme.repository.UserRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

@Service
public class PronunciationAssessmentService {
    private static final Logger log = LoggerFactory.getLogger(PronunciationAssessmentService.class);

    private static final int MAX_AUDIO_BYTES = 3 * 1024 * 1024;
    private static final int MAX_REFERENCE_LENGTH = 300;

    private final UserRepository userRepository;
    private final PronunciationAttemptRepository attemptRepository;
    private final PronunciationWordFeedbackRepository wordFeedbackRepository;
    private final CloudPronunciationClient cloudPronunciationClient;
    private final PronunciationScoringMapper pronunciationScoringMapper;
    private final PronunciationRateLimiter pronunciationRateLimiter;

    public PronunciationAssessmentService(
            UserRepository userRepository,
            PronunciationAttemptRepository attemptRepository,
            PronunciationWordFeedbackRepository wordFeedbackRepository,
            CloudPronunciationClient cloudPronunciationClient,
            PronunciationScoringMapper pronunciationScoringMapper,
            PronunciationRateLimiter pronunciationRateLimiter
    ) {
        this.userRepository = userRepository;
        this.attemptRepository = attemptRepository;
        this.wordFeedbackRepository = wordFeedbackRepository;
        this.cloudPronunciationClient = cloudPronunciationClient;
        this.pronunciationScoringMapper = pronunciationScoringMapper;
        this.pronunciationRateLimiter = pronunciationRateLimiter;
    }

    @Transactional
    public PronunciationAssessResponse assess(
            String firebaseUid,
            MultipartFile audio,
            String referenceText,
            String language,
            UUID lessonItemId
    ) {
        if (audio == null || audio.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "audio is required");
        }
        if (audio.getSize() > MAX_AUDIO_BYTES) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "audio is too large (max 3MB)");
        }
        String contentType = audio.getContentType();
        if (contentType == null || (!contentType.contains("audio") && !contentType.contains("octet-stream"))) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "unsupported audio content type");
        }
        if (referenceText == null || referenceText.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "referenceText is required");
        }
        String safeReference = referenceText.trim();
        if (safeReference.length() > MAX_REFERENCE_LENGTH) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "referenceText is too long");
        }

        pronunciationRateLimiter.checkOrThrow(firebaseUid);
        User user = userRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));

        byte[] bytes;
        try {
            bytes = audio.getBytes();
        } catch (IOException ex) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Cannot read audio payload");
        }

        JsonNode providerResult = cloudPronunciationClient.assess(bytes, safeReference, language);

        UUID attemptId = UUID.randomUUID();
        PronunciationAssessResponse response = pronunciationScoringMapper
                .mapSpeechace(attemptId, providerResult, cloudPronunciationClient.providerName());

        PronunciationAttempt attempt = new PronunciationAttempt();
        attempt.setId(attemptId);
        attempt.setUser(user);
        attempt.setLessonItemId(lessonItemId);
        attempt.setReferenceText(safeReference);
        attempt.setProvider(cloudPronunciationClient.providerName());
        attempt.setOverallScore(response.overallScore());
        attempt.setAccuracyScore(response.accuracyScore());
        attempt.setFluencyScore(response.fluencyScore());
        attempt = attemptRepository.save(attempt);
        log.info("pronunciation_attempt_saved attemptId={} overall={} accuracy={} fluency={}",
                attempt.getId(), response.overallScore(), response.accuracyScore(), response.fluencyScore());

        final PronunciationAttempt savedAttempt = attempt;
        List<PronunciationWordFeedback> feedbackEntities = response.wordFeedback().stream().map(word -> {
            PronunciationWordFeedback item = new PronunciationWordFeedback();
            item.setAttempt(savedAttempt);
            item.setWord(word.word());
            item.setScore(word.score());
            item.setStartMs(word.startMs());
            item.setEndMs(word.endMs());
            item.setIssueType(word.issueType());
            item.setSuggestion(word.suggestion());
            return item;
        }).toList();
        wordFeedbackRepository.saveAll(feedbackEntities);
        return response;
    }

    @Transactional(readOnly = true)
    public List<PronunciationAttemptHistoryItemResponse> history(String firebaseUid, UUID lessonItemId, int limit) {
        int safeLimit = Math.min(Math.max(limit, 1), 50);
        List<PronunciationAttempt> attempts = lessonItemId == null
                ? attemptRepository.findByUser_FirebaseUidOrderByCreatedAtDesc(firebaseUid, PageRequest.of(0, safeLimit))
                : attemptRepository.findByUser_FirebaseUidAndLessonItemIdOrderByCreatedAtDesc(firebaseUid, lessonItemId, PageRequest.of(0, safeLimit));

        return attempts.stream().map(item -> new PronunciationAttemptHistoryItemResponse(
                item.getId(),
                item.getLessonItemId(),
                item.getReferenceText(),
                item.getOverallScore(),
                item.getAccuracyScore(),
                item.getFluencyScore(),
                item.getProvider(),
                item.getCreatedAt()
        )).toList();
    }

    @Transactional(readOnly = true)
    public Page<AdminPronunciationAttemptRow> adminList(String provider, int minScore, String keyword, int page, int size) {
        int safePage = Math.max(page, 0);
        int safeSize = Math.min(Math.max(size, 1), 100);
        int safeMinScore = Math.min(Math.max(minScore, 0), 100);
        String safeProvider = provider == null ? "" : provider.trim();
        String safeKeyword = keyword == null ? "" : keyword.trim();

        return attemptRepository.findForAdmin(safeProvider, safeMinScore, safeKeyword, PageRequest.of(safePage, safeSize))
                .map(item -> new AdminPronunciationAttemptRow(
                        item.getId(),
                        item.getUser().getEmail(),
                        item.getUser().getFullName(),
                        item.getUser().getFirebaseUid(),
                        item.getLessonItemId(),
                        item.getReferenceText(),
                        item.getOverallScore(),
                        item.getAccuracyScore(),
                        item.getFluencyScore(),
                        item.getProvider(),
                        item.getCreatedAt()
                ));
    }
}
