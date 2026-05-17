package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.AdminBannerRow;
import com.kiovant.englishme.dto.AdminRecommendationRow;
import com.kiovant.englishme.dto.AdminWordOfDayRow;
import com.kiovant.englishme.entity.HomeBanner;
import com.kiovant.englishme.entity.HomeRecommendation;
import com.kiovant.englishme.entity.HomeWordOfDay;
import com.kiovant.englishme.entity.VocabularyWord;
import com.kiovant.englishme.repository.HomeBannerRepository;
import com.kiovant.englishme.repository.HomeRecommendationRepository;
import com.kiovant.englishme.repository.HomeWordOfDayRepository;
import com.kiovant.englishme.repository.VocabularyWordRepository;
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
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;

@Service
public class AdminHomeContentService {

    public static final Set<String> ALLOWED_LEVELS = Set.of("A1", "A2", "B1", "B2", "C1", "C2");
    public static final Set<String> ALLOWED_REC_TYPES =
            Set.of("vocabulary", "grammar", "pronunciation", "exercise", "test");

    private static final Set<String> ALLOWED_IMG_EXTS = Set.of("png", "jpg", "jpeg", "webp", "gif");
    private static final long MAX_BANNER_BYTES = 3L * 1024L * 1024L; // 3 MB
    private static final Path BANNER_DIR = Paths.get("uploads", "banners");

    private final HomeWordOfDayRepository wodRepo;
    private final HomeRecommendationRepository recRepo;
    private final HomeBannerRepository bannerRepo;
    private final VocabularyWordRepository wordRepo;

    public AdminHomeContentService(HomeWordOfDayRepository wodRepo,
                                   HomeRecommendationRepository recRepo,
                                   HomeBannerRepository bannerRepo,
                                   VocabularyWordRepository wordRepo) {
        this.wodRepo = wodRepo;
        this.recRepo = recRepo;
        this.bannerRepo = bannerRepo;
        this.wordRepo = wordRepo;
    }

    // ── Word of Day ─────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public List<AdminWordOfDayRow> listWordOfDay() {
        List<HomeWordOfDay> all = wodRepo.findAllByOrderByScheduledDateDesc();
        List<AdminWordOfDayRow> rows = new ArrayList<>(all.size());
        for (HomeWordOfDay w : all) {
            VocabularyWord vw = w.getWord();
            rows.add(new AdminWordOfDayRow(
                    w.getId(),
                    w.getScheduledDate(),
                    vw.getId(),
                    vw.getWord(),
                    vw.getPronunciation(),
                    vw.getDefinitionVi(),
                    w.getLevel(),
                    w.getNote()
            ));
        }
        return rows;
    }

    @Transactional
    public HomeWordOfDay createWordOfDay(LocalDate date, UUID wordId, String level, String note) {
        if (date == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Ngày không được trống.");
        }
        if (wordId == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Chọn từ vựng.");
        }
        String normLevel = normalizeLevelOrNull(level);
        if (wodRepo.existsByScheduledDateAndLevel(date, normLevel)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Đã tồn tại Word of Day cho ngày " + date + " (level=" + (normLevel == null ? "ALL" : normLevel) + ").");
        }
        VocabularyWord vw = wordRepo.findById(wordId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Từ vựng không tồn tại."));

        HomeWordOfDay w = new HomeWordOfDay();
        w.setScheduledDate(date);
        w.setWord(vw);
        w.setLevel(normLevel);
        w.setNote(blankToNull(note));
        return wodRepo.save(w);
    }

    @Transactional
    public void deleteWordOfDay(UUID id) {
        HomeWordOfDay w = wodRepo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Word of Day không tồn tại."));
        wodRepo.delete(w);
    }

    // ── Recommendations ─────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public List<AdminRecommendationRow> listRecommendations() {
        List<HomeRecommendation> all = recRepo.findAllByOrderByLevelAscSortOrderAsc();
        List<AdminRecommendationRow> rows = new ArrayList<>(all.size());
        for (HomeRecommendation r : all) {
            rows.add(new AdminRecommendationRow(
                    r.getId(),
                    r.getLevel(),
                    r.getType(),
                    r.getTitle(),
                    r.getDescription(),
                    r.getActionUrl(),
                    r.getSortOrder(),
                    r.getIsActive()
            ));
        }
        return rows;
    }

    @Transactional
    public HomeRecommendation createRecommendation(String level, String type, String title,
                                                   String description, String actionUrl,
                                                   Integer sortOrder, Boolean isActive) {
        HomeRecommendation r = new HomeRecommendation();
        applyRecommendation(r, level, type, title, description, actionUrl, sortOrder, isActive);
        return recRepo.save(r);
    }

    @Transactional
    public HomeRecommendation updateRecommendation(UUID id, String level, String type, String title,
                                                   String description, String actionUrl,
                                                   Integer sortOrder, Boolean isActive) {
        HomeRecommendation r = recRepo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recommendation không tồn tại."));
        applyRecommendation(r, level, type, title, description, actionUrl, sortOrder, isActive);
        return recRepo.save(r);
    }

    @Transactional
    public void deleteRecommendation(UUID id) {
        HomeRecommendation r = recRepo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recommendation không tồn tại."));
        recRepo.delete(r);
    }

    private void applyRecommendation(HomeRecommendation r, String level, String type, String title,
                                     String description, String actionUrl, Integer sortOrder,
                                     Boolean isActive) {
        String normLevel = normalizeLevel(level);
        String normType = normalizeType(type);
        String normTitle = require(title, "Tiêu đề không được trống.");
        r.setLevel(normLevel);
        r.setType(normType);
        r.setTitle(normTitle);
        r.setDescription(blankToNull(description));
        r.setActionUrl(blankToNull(actionUrl));
        r.setSortOrder(sortOrder == null ? 0 : Math.max(sortOrder, 0));
        r.setIsActive(isActive == null ? Boolean.TRUE : isActive);
    }

    // ── Banner ──────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public List<AdminBannerRow> listBanners() {
        List<HomeBanner> all = bannerRepo.findAllByOrderBySortOrderAscStartAtDesc();
        List<AdminBannerRow> rows = new ArrayList<>(all.size());
        for (HomeBanner b : all) {
            rows.add(new AdminBannerRow(
                    b.getId(),
                    b.getTitle(),
                    b.getImageUrl(),
                    b.getActionUrl(),
                    b.getStartAt(),
                    b.getEndAt(),
                    b.getSortOrder(),
                    b.getIsActive()
            ));
        }
        return rows;
    }

    @Transactional
    public HomeBanner createBanner(String title, String imageUrl, String actionUrl,
                                   LocalDateTime startAt, LocalDateTime endAt,
                                   Integer sortOrder, Boolean isActive) {
        HomeBanner b = new HomeBanner();
        applyBanner(b, title, imageUrl, actionUrl, startAt, endAt, sortOrder, isActive);
        return bannerRepo.save(b);
    }

    @Transactional
    public HomeBanner updateBanner(UUID id, String title, String imageUrl, String actionUrl,
                                   LocalDateTime startAt, LocalDateTime endAt,
                                   Integer sortOrder, Boolean isActive) {
        HomeBanner b = bannerRepo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Banner không tồn tại."));
        applyBanner(b, title, imageUrl, actionUrl, startAt, endAt, sortOrder, isActive);
        return bannerRepo.save(b);
    }

    @Transactional
    public void deleteBanner(UUID id) {
        HomeBanner b = bannerRepo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Banner không tồn tại."));
        bannerRepo.delete(b);
    }

    @Transactional
    public String uploadBannerImage(UUID id, MultipartFile file) {
        HomeBanner b = bannerRepo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Banner không tồn tại."));
        if (file == null || file.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Chưa chọn file ảnh.");
        }
        if (file.getSize() > MAX_BANNER_BYTES) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Banner tối đa 3 MB.");
        }
        String original = file.getOriginalFilename();
        String ext = original == null ? "" : extOf(original);
        if (!ALLOWED_IMG_EXTS.contains(ext)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Định dạng ảnh không hỗ trợ. Cho phép: " + ALLOWED_IMG_EXTS);
        }
        try {
            Files.createDirectories(BANNER_DIR);
            String filename = id + "_" + System.currentTimeMillis() + "." + ext;
            Path target = BANNER_DIR.resolve(filename);
            Files.copy(file.getInputStream(), target, StandardCopyOption.REPLACE_EXISTING);
            String publicUrl = "/uploads/banners/" + filename;
            b.setImageUrl(publicUrl);
            bannerRepo.save(b);
            return publicUrl;
        } catch (IOException ex) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR,
                    "Không thể lưu ảnh banner: " + ex.getMessage());
        }
    }

    private void applyBanner(HomeBanner b, String title, String imageUrl, String actionUrl,
                             LocalDateTime startAt, LocalDateTime endAt,
                             Integer sortOrder, Boolean isActive) {
        b.setTitle(require(title, "Tiêu đề banner không được trống."));
        b.setImageUrl(require(imageUrl, "URL ảnh không được trống."));
        b.setActionUrl(blankToNull(actionUrl));
        if (startAt == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Thời gian bắt đầu không được trống.");
        }
        if (endAt != null && endAt.isBefore(startAt)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Thời gian kết thúc phải sau bắt đầu.");
        }
        b.setStartAt(startAt);
        b.setEndAt(endAt);
        b.setSortOrder(sortOrder == null ? 0 : Math.max(sortOrder, 0));
        b.setIsActive(isActive == null ? Boolean.TRUE : isActive);
    }

    // ── Word picker (cho dropdown trong form Word of Day) ───────────────────

    @Transactional(readOnly = true)
    public List<VocabularyWord> wordsForPicker(String level) {
        if (level == null || level.isBlank()) {
            return wordRepo.findAll().stream()
                    .sorted((a, c) -> a.getWord().compareToIgnoreCase(c.getWord()))
                    .toList();
        }
        return wordRepo.findByLevelIgnoreCaseOrderByWordAsc(level.trim().toLowerCase(Locale.ROOT));
    }

    // ── Helpers ─────────────────────────────────────────────────────────────

    private static String require(String s, String error) {
        if (s == null || s.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, error);
        }
        return s.trim();
    }

    private static String blankToNull(String s) {
        return s == null || s.isBlank() ? null : s.trim();
    }

    private static String normalizeLevel(String level) {
        if (level == null || level.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Level không được trống.");
        }
        String upper = level.trim().toUpperCase(Locale.ROOT);
        if (!ALLOWED_LEVELS.contains(upper)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Level không hợp lệ. Cho phép: " + ALLOWED_LEVELS);
        }
        return upper;
    }

    private static String normalizeLevelOrNull(String level) {
        if (level == null || level.isBlank()) return null;
        String upper = level.trim().toUpperCase(Locale.ROOT);
        if (!ALLOWED_LEVELS.contains(upper)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Level không hợp lệ. Cho phép: " + ALLOWED_LEVELS);
        }
        return upper;
    }

    private static String normalizeType(String type) {
        if (type == null || type.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Type không được trống.");
        }
        String lower = type.trim().toLowerCase(Locale.ROOT);
        if (!ALLOWED_REC_TYPES.contains(lower)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Type không hợp lệ. Cho phép: " + ALLOWED_REC_TYPES);
        }
        return lower;
    }

    private static String extOf(String filename) {
        int dot = filename.lastIndexOf('.');
        if (dot < 0 || dot == filename.length() - 1) return "";
        return filename.substring(dot + 1).toLowerCase(Locale.ROOT);
    }
}
