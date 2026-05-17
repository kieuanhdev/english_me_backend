package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.AdminPronunciationExerciseRow;
import com.kiovant.englishme.dto.CreatePronunciationExerciseRequest;
import com.kiovant.englishme.dto.PronunciationAnalytics;
import com.kiovant.englishme.dto.UpdatePronunciationExerciseRequest;
import com.kiovant.englishme.entity.PronunciationExercise;
import com.kiovant.englishme.repository.PronunciationAttemptRepository;
import com.kiovant.englishme.repository.PronunciationExerciseRepository;
import com.kiovant.englishme.repository.PronunciationWordFeedbackRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

@Service
public class AdminPronunciationExerciseService {

    private static final Set<String> ALLOWED_LEVELS = Set.of("A1", "A2", "B1", "B2", "C1", "C2");
    private static final Set<String> ALLOWED_DIFFICULTIES = Set.of("easy", "medium", "hard");
    private static final Set<String> ALLOWED_AUDIO_EXTS = Set.of("mp3", "wav", "ogg", "m4a", "webm");
    private static final long MAX_AUDIO_BYTES = 5L * 1024L * 1024L; // 5 MB
    private static final Path AUDIO_DIR = Paths.get("uploads", "pronunciation");

    private final PronunciationExerciseRepository exerciseRepository;
    private final PronunciationAttemptRepository attemptRepository;
    private final PronunciationWordFeedbackRepository wordFeedbackRepository;

    public AdminPronunciationExerciseService(PronunciationExerciseRepository exerciseRepository,
                                             PronunciationAttemptRepository attemptRepository,
                                             PronunciationWordFeedbackRepository wordFeedbackRepository) {
        this.exerciseRepository = exerciseRepository;
        this.attemptRepository = attemptRepository;
        this.wordFeedbackRepository = wordFeedbackRepository;
    }

    // ── List + filter ───────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public List<AdminPronunciationExerciseRow> list(String level, String difficulty, String keyword) {
        List<PronunciationExercise> rows = exerciseRepository.searchForAdmin(
                level == null ? "" : level.trim(),
                difficulty == null ? "" : difficulty.trim(),
                keyword == null ? "" : keyword.trim());
        if (rows.isEmpty()) return List.of();

        Map<UUID, long[]> attempts = new HashMap<>();
        Map<UUID, Double> avgs = new HashMap<>();
        for (Object[] r : attemptRepository.aggregateStatsByExercise()) {
            UUID exId = (UUID) r[0];
            long count = ((Number) r[1]).longValue();
            Double avg = r[2] == null ? null : ((Number) r[2]).doubleValue();
            attempts.put(exId, new long[]{count});
            avgs.put(exId, avg);
        }

        List<AdminPronunciationExerciseRow> out = new ArrayList<>(rows.size());
        for (PronunciationExercise e : rows) {
            long count = attempts.getOrDefault(e.getId(), new long[]{0L})[0];
            Double avg = avgs.get(e.getId());
            Double rounded = avg == null ? null : Math.round(avg * 100.0) / 100.0;
            out.add(new AdminPronunciationExerciseRow(
                    e.getId(),
                    e.getText(),
                    e.getPhonetic(),
                    e.getMeaning(),
                    e.getLevel(),
                    e.getDifficulty(),
                    e.getAudioUrl(),
                    e.getTips(),
                    count,
                    rounded));
        }
        return out;
    }

    @Transactional(readOnly = true)
    public PronunciationExercise getOrThrow(UUID id) {
        return exerciseRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Bài tập phát âm không tồn tại."));
    }

    // ── CRUD ────────────────────────────────────────────────────────────────

    @Transactional
    public PronunciationExercise create(CreatePronunciationExerciseRequest req) {
        validate(req.text(), req.difficulty(), req.level());
        PronunciationExercise e = new PronunciationExercise();
        applyFields(e, req.text(), req.expectedPhonetic(), req.meaning(), req.level(),
                req.difficulty(), req.referenceAudioUrl(), req.tips());
        return exerciseRepository.save(e);
    }

    @Transactional
    public PronunciationExercise update(UUID id, UpdatePronunciationExerciseRequest req) {
        validate(req.text(), req.difficulty(), req.level());
        PronunciationExercise e = getOrThrow(id);
        applyFields(e, req.text(), req.expectedPhonetic(), req.meaning(), req.level(),
                req.difficulty(), req.referenceAudioUrl(), req.tips());
        return exerciseRepository.save(e);
    }

    @Transactional
    public void delete(UUID id) {
        PronunciationExercise e = getOrThrow(id);
        exerciseRepository.delete(e);
    }

    // ── Audio upload ────────────────────────────────────────────────────────

    @Transactional
    public String uploadAudio(UUID id, MultipartFile file) {
        PronunciationExercise e = getOrThrow(id);
        if (file == null || file.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Chưa chọn file audio.");
        }
        if (file.getSize() > MAX_AUDIO_BYTES) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Audio tối đa 5 MB.");
        }
        String original = file.getOriginalFilename();
        String ext = original == null ? "" : extOf(original);
        if (!ALLOWED_AUDIO_EXTS.contains(ext)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Định dạng audio không hỗ trợ. Cho phép: " + ALLOWED_AUDIO_EXTS);
        }
        try {
            Files.createDirectories(AUDIO_DIR);
            String filename = id + "_" + System.currentTimeMillis() + "." + ext;
            Path target = AUDIO_DIR.resolve(filename);
            Files.copy(file.getInputStream(), target, StandardCopyOption.REPLACE_EXISTING);
            String publicUrl = "/uploads/pronunciation/" + filename;
            e.setAudioUrl(publicUrl);
            exerciseRepository.save(e);
            return publicUrl;
        } catch (IOException ex) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR,
                    "Không thể lưu audio: " + ex.getMessage());
        }
    }

    // ── Analytics ───────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public PronunciationAnalytics getAnalytics() {
        long total = attemptRepository.countAll();
        Double avg = attemptRepository.averageOverallScore();
        Double avgRounded = avg == null ? null : Math.round(avg * 100.0) / 100.0;

        // Score buckets 0–9 ... 90–100 (gộp 100 vào bucket 9)
        long[] bucket = new long[10];
        for (Object[] r : attemptRepository.scoreDistributionBuckets()) {
            int idx = ((Number) r[0]).intValue();
            if (idx < 0) idx = 0;
            if (idx > 9) idx = 9;
            bucket[idx] += ((Number) r[1]).longValue();
        }
        List<PronunciationAnalytics.ScoreBucket> bucketList = new ArrayList<>();
        for (int i = 0; i < 10; i++) {
            String label = i == 9 ? "90–100" : (i * 10) + "–" + (i * 10 + 9);
            bucketList.add(new PronunciationAnalytics.ScoreBucket(label, bucket[i]));
        }

        List<PronunciationAnalytics.WeakWord> weakest = new ArrayList<>();
        for (Object[] r : wordFeedbackRepository.findWeakestWords(PageRequest.of(0, 20))) {
            String word = (String) r[0];
            long count = ((Number) r[1]).longValue();
            Double s = r[2] == null ? null : ((Number) r[2]).doubleValue();
            Double sRounded = s == null ? null : Math.round(s * 100.0) / 100.0;
            weakest.add(new PronunciationAnalytics.WeakWord(word, count, sRounded));
        }

        List<PronunciationAnalytics.IssueType> issues = new ArrayList<>();
        for (Object[] r : wordFeedbackRepository.countByIssueType()) {
            issues.add(new PronunciationAnalytics.IssueType(
                    (String) r[0], ((Number) r[1]).longValue()));
        }

        List<PronunciationAnalytics.ProviderStat> providers = new ArrayList<>();
        for (Object[] r : attemptRepository.providerComparison()) {
            providers.add(new PronunciationAnalytics.ProviderStat(
                    (String) r[0],
                    ((Number) r[1]).longValue(),
                    r[2] == null ? null : Math.round(((Number) r[2]).doubleValue() * 100.0) / 100.0,
                    r[3] == null ? null : Math.round(((Number) r[3]).doubleValue() * 100.0) / 100.0,
                    r[4] == null ? null : Math.round(((Number) r[4]).doubleValue() * 100.0) / 100.0));
        }

        return new PronunciationAnalytics(total, avgRounded, bucketList, weakest, issues, providers);
    }

    // ── Helpers ─────────────────────────────────────────────────────────────

    private void validate(String text, String difficulty, String level) {
        if (text == null || text.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Text không được trống.");
        }
        if (difficulty == null || !ALLOWED_DIFFICULTIES.contains(difficulty.trim().toLowerCase(Locale.ROOT))) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Difficulty phải là 'easy' | 'medium' | 'hard'.");
        }
        if (level != null && !level.isBlank()
                && !ALLOWED_LEVELS.contains(level.trim().toUpperCase(Locale.ROOT))) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "CEFR level phải thuộc A1–C2.");
        }
    }

    private void applyFields(PronunciationExercise e, String text, String phonetic, String meaning,
                             String level, String difficulty, String audioUrl, String tips) {
        e.setText(text.trim());
        e.setPhonetic(blankToNull(phonetic));
        e.setMeaning(blankToNull(meaning));
        e.setLevel(level == null || level.isBlank() ? null : level.trim().toUpperCase(Locale.ROOT));
        e.setDifficulty(difficulty.trim().toLowerCase(Locale.ROOT));
        e.setAudioUrl(blankToNull(audioUrl));
        e.setTips(blankToNull(tips));
    }

    private static String blankToNull(String s) {
        return s == null || s.isBlank() ? null : s.trim();
    }

    private static String extOf(String filename) {
        int dot = filename.lastIndexOf('.');
        if (dot < 0 || dot == filename.length() - 1) return "";
        return filename.substring(dot + 1).toLowerCase(Locale.ROOT);
    }
}
