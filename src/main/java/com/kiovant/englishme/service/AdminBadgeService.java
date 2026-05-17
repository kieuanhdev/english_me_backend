package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.AdminBadgeRow;
import com.kiovant.englishme.dto.AdminBadgeUserRow;
import com.kiovant.englishme.dto.CreateBadgeRequest;
import com.kiovant.englishme.dto.UpdateBadgeRequest;
import com.kiovant.englishme.entity.Badge;
import com.kiovant.englishme.entity.User;
import com.kiovant.englishme.entity.UserBadge;
import com.kiovant.englishme.repository.BadgeRepository;
import com.kiovant.englishme.repository.UserBadgeRepository;
import com.kiovant.englishme.repository.UserRepository;
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
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

@Service
public class AdminBadgeService {

    /** Các loại điều kiện hỗ trợ — phải khớp logic evaluate ở ProgressService. */
    private static final Set<String> ALLOWED_CONDITION_TYPES = Set.of(
            "streak_7", "streak_30", "streak_custom",
            "xp_1000", "xp_5000", "xp_custom",
            "first_lesson", "grammar_10", "pronunciation_50"
    );

    private static final Set<String> ALLOWED_ICON_EXTS = Set.of("png", "jpg", "jpeg", "svg", "webp");
    private static final long MAX_ICON_BYTES = 1024L * 1024L; // 1 MB
    private static final Path ICON_DIR = Paths.get("uploads", "badges");

    private final BadgeRepository badgeRepository;
    private final UserBadgeRepository userBadgeRepository;
    private final UserRepository userRepository;

    public AdminBadgeService(BadgeRepository badgeRepository,
                             UserBadgeRepository userBadgeRepository,
                             UserRepository userRepository) {
        this.badgeRepository = badgeRepository;
        this.userBadgeRepository = userBadgeRepository;
        this.userRepository = userRepository;
    }

    // ── List ────────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public List<AdminBadgeRow> listBadges() {
        List<Badge> badges = badgeRepository.findAllByOrderByCreatedAtDesc();
        if (badges.isEmpty()) return List.of();

        Map<UUID, Long> awardedMap = new HashMap<>();
        for (Object[] row : badgeRepository.countAwardedGroupByBadge()) {
            awardedMap.put((UUID) row[0], ((Number) row[1]).longValue());
        }
        List<AdminBadgeRow> rows = new ArrayList<>(badges.size());
        for (Badge b : badges) {
            long count = awardedMap.getOrDefault(b.getId(), 0L);
            rows.add(new AdminBadgeRow(
                    b.getId(),
                    b.getName(),
                    b.getDescription(),
                    b.getIconUrl(),
                    b.getConditionType(),
                    b.getConditionValue(),
                    b.getIsActive() != null ? b.getIsActive() : Boolean.FALSE,
                    count,
                    b.getCreatedAt()));
        }
        return rows;
    }

    @Transactional(readOnly = true)
    public Badge getOrThrow(UUID id) {
        return badgeRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Badge không tồn tại."));
    }

    // ── CRUD ────────────────────────────────────────────────────────────────

    @Transactional
    public Badge create(CreateBadgeRequest req) {
        String name = require(req.name(), "Tên badge không được trống.");
        String conditionType = normalizeCondition(req.conditionType());
        if (badgeRepository.existsByNameIgnoreCase(name)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Tên badge đã tồn tại.");
        }
        Badge b = new Badge();
        b.setName(name);
        b.setDescription(blankToNull(req.description()));
        b.setIconUrl(blankToNull(req.iconUrl()));
        b.setConditionType(conditionType);
        b.setConditionValue(req.conditionValue());
        b.setIsActive(req.isActive() == null ? Boolean.TRUE : req.isActive());
        return badgeRepository.save(b);
    }

    @Transactional
    public Badge update(UUID id, UpdateBadgeRequest req) {
        Badge b = getOrThrow(id);
        String name = require(req.name(), "Tên badge không được trống.");
        if (!b.getName().equalsIgnoreCase(name) && badgeRepository.existsByNameIgnoreCase(name)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Tên badge đã tồn tại.");
        }
        b.setName(name);
        b.setDescription(blankToNull(req.description()));
        b.setIconUrl(blankToNull(req.iconUrl()));
        b.setConditionType(normalizeCondition(req.conditionType()));
        b.setConditionValue(req.conditionValue());
        b.setIsActive(req.isActive() == null ? Boolean.TRUE : req.isActive());
        return badgeRepository.save(b);
    }

    @Transactional
    public void delete(UUID id) {
        Badge b = getOrThrow(id);
        userBadgeRepository.deleteByBadge_Id(id);
        badgeRepository.delete(b);
    }

    // ── Icon upload ─────────────────────────────────────────────────────────

    @Transactional
    public String uploadIcon(UUID id, MultipartFile file) {
        Badge b = getOrThrow(id);
        if (file == null || file.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Chưa chọn file icon.");
        }
        if (file.getSize() > MAX_ICON_BYTES) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Icon tối đa 1 MB.");
        }
        String original = file.getOriginalFilename();
        String ext = original == null ? "" : extOf(original);
        if (!ALLOWED_ICON_EXTS.contains(ext)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Định dạng icon không hỗ trợ. Cho phép: " + ALLOWED_ICON_EXTS);
        }
        try {
            Files.createDirectories(ICON_DIR);
            String filename = id + "_" + System.currentTimeMillis() + "." + ext;
            Path target = ICON_DIR.resolve(filename);
            Files.copy(file.getInputStream(), target, StandardCopyOption.REPLACE_EXISTING);
            String publicUrl = "/uploads/badges/" + filename;
            b.setIconUrl(publicUrl);
            badgeRepository.save(b);
            return publicUrl;
        } catch (IOException ex) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR,
                    "Không thể lưu icon: " + ex.getMessage());
        }
    }

    // ── Users đã đạt badge ─────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public List<AdminBadgeUserRow> listUsersForBadge(UUID badgeId) {
        getOrThrow(badgeId);
        List<UserBadge> awards = userBadgeRepository.findByBadge_IdOrderByEarnedAtDesc(badgeId);
        List<AdminBadgeUserRow> rows = new ArrayList<>(awards.size());
        for (UserBadge ub : awards) {
            User u = ub.getUser();
            rows.add(new AdminBadgeUserRow(
                    u.getId(),
                    u.getFullName(),
                    u.getEmail(),
                    u.getTotalXp(),
                    u.getCurrentStreak(),
                    ub.getEarnedAt()));
        }
        return rows;
    }

    // ── Đánh giá lại điều kiện cho badge mới tạo / sửa ──────────────────────

    /**
     * Quét toàn bộ user chưa nhận badge và gắn badge nếu thỏa điều kiện.
     * Trả về số user vừa được gắn.
     */
    @Transactional
    public int reevaluateBadge(UUID badgeId) {
        Badge badge = getOrThrow(badgeId);
        if (!Boolean.TRUE.equals(badge.getIsActive())) return 0;

        int awarded = 0;
        List<User> users = userRepository.findAll();
        for (User u : users) {
            if (u.getDeletedAt() != null) continue;
            if (userBadgeRepository.existsByUser_IdAndBadge_Id(u.getId(), badge.getId())) continue;
            if (!matchesCondition(u, badge)) continue;
            UserBadge ub = new UserBadge();
            ub.setUser(u);
            ub.setBadge(badge);
            ub.setEarnedAt(LocalDateTime.now());
            userBadgeRepository.save(ub);
            awarded++;
        }
        return awarded;
    }

    private boolean matchesCondition(User u, Badge b) {
        String type = b.getConditionType();
        Integer value = b.getConditionValue();
        int streak = u.getCurrentStreak() == null ? 0 : u.getCurrentStreak();
        int longestStreak = u.getLongestStreak() == null ? 0 : u.getLongestStreak();
        int xp = u.getTotalXp() == null ? 0 : u.getTotalXp();
        return switch (type) {
            case "streak_7" -> streak >= 7 || longestStreak >= 7;
            case "streak_30" -> streak >= 30 || longestStreak >= 30;
            case "streak_custom" -> value != null && (streak >= value || longestStreak >= value);
            case "xp_1000" -> xp >= 1000;
            case "xp_5000" -> xp >= 5000;
            case "xp_custom" -> value != null && xp >= value;
            // Các điều kiện sau cần dữ liệu nguồn chính xác hơn (hooks ở activity service),
            // hiện ưu tiên backfill khi user đã đạt mốc XP / streak.
            case "first_lesson" -> xp > 0;
            case "grammar_10", "pronunciation_50" -> false;
            default -> false;
        };
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

    private static String normalizeCondition(String type) {
        if (type == null || type.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Condition type không được trống.");
        }
        String lower = type.trim().toLowerCase(Locale.ROOT);
        if (!ALLOWED_CONDITION_TYPES.contains(lower)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Condition type không hợp lệ. Cho phép: " + ALLOWED_CONDITION_TYPES);
        }
        return lower;
    }

    private static String extOf(String filename) {
        int dot = filename.lastIndexOf('.');
        if (dot < 0 || dot == filename.length() - 1) return "";
        return filename.substring(dot + 1).toLowerCase(Locale.ROOT);
    }
}
