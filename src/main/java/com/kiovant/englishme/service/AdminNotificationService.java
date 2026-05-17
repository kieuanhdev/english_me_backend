package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.AdminAnnouncementRow;
import com.kiovant.englishme.dto.AdminNotificationRow;
import com.kiovant.englishme.dto.PushSendResult;
import com.kiovant.englishme.entity.AdminNotification;
import com.kiovant.englishme.entity.AppAnnouncement;
import com.kiovant.englishme.entity.User;
import com.kiovant.englishme.entity.UserDeviceToken;
import com.kiovant.englishme.repository.AdminNotificationRepository;
import com.kiovant.englishme.repository.AppAnnouncementRepository;
import com.kiovant.englishme.repository.UserDeviceTokenRepository;
import com.kiovant.englishme.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;

@Service
public class AdminNotificationService {

    public static final Set<String> ALLOWED_SEVERITY = Set.of("info", "warning", "success");
    public static final Set<String> ALLOWED_SEGMENT_TYPES = Set.of("broadcast", "cefr", "inactive", "custom");
    private static final Set<String> ALLOWED_CEFR = Set.of("A1", "A2", "B1", "B2", "C1", "C2");

    private final AdminNotificationRepository notifRepo;
    private final AppAnnouncementRepository annRepo;
    private final UserDeviceTokenRepository tokenRepo;
    private final UserRepository userRepo;
    private final FcmPushService fcm;

    public AdminNotificationService(AdminNotificationRepository notifRepo,
                                    AppAnnouncementRepository annRepo,
                                    UserDeviceTokenRepository tokenRepo,
                                    UserRepository userRepo,
                                    FcmPushService fcm) {
        this.notifRepo = notifRepo;
        this.annRepo = annRepo;
        this.tokenRepo = tokenRepo;
        this.userRepo = userRepo;
        this.fcm = fcm;
    }

    // ── History ─────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public List<AdminNotificationRow> listHistory() {
        List<AdminNotification> all = notifRepo.findAllByOrderBySentAtDesc();
        List<AdminNotificationRow> rows = new ArrayList<>(all.size());
        for (AdminNotification n : all) {
            rows.add(new AdminNotificationRow(
                    n.getId(), n.getTitle(), n.getBody(),
                    n.getSegmentType(), n.getSegmentValue(),
                    n.getTargetCount(), n.getSuccessCount(), n.getFailureCount(),
                    n.getSentByEmail(), n.getSentAt()
            ));
        }
        return rows;
    }

    @Transactional(readOnly = true)
    public AdminNotification getOrThrow(UUID id) {
        return notifRepo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Push không tồn tại."));
    }

    // ── Broadcast ───────────────────────────────────────────────────────────

    @Transactional
    public AdminNotification broadcast(String title, String body, String imageUrl, String actionUrl,
                                       String sentByEmail) {
        String t = require(title, "Tiêu đề không được trống.");
        String b = require(body, "Nội dung không được trống.");
        List<String> tokens = tokenRepo.findAllActiveTokens();
        PushSendResult res = fcm.sendToTokens(tokens, t, b, blankToNull(imageUrl), blankToNull(actionUrl));
        return persist(t, b, imageUrl, actionUrl, "broadcast", null, sentByEmail, res);
    }

    // ── Targeted (CEFR / inactive / custom) ─────────────────────────────────

    @Transactional
    public AdminNotification targeted(String segmentType, String segmentValue,
                                      String title, String body, String imageUrl, String actionUrl,
                                      String sentByEmail) {
        String type = normalizeSegmentType(segmentType);
        String t = require(title, "Tiêu đề không được trống.");
        String b = require(body, "Nội dung không được trống.");
        String value = blankToNull(segmentValue);

        List<String> tokens = resolveSegmentTokens(type, value);
        PushSendResult res = fcm.sendToTokens(tokens, t, b, blankToNull(imageUrl), blankToNull(actionUrl));
        return persist(t, b, imageUrl, actionUrl, type, value, sentByEmail, res);
    }

    private List<String> resolveSegmentTokens(String type, String value) {
        return switch (type) {
            case "broadcast" -> tokenRepo.findAllActiveTokens();
            case "cefr" -> {
                if (value == null) {
                    throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                            "Segment CEFR yêu cầu giá trị level (A1..C2).");
                }
                String upper = value.toUpperCase(Locale.ROOT);
                if (!ALLOWED_CEFR.contains(upper)) {
                    throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                            "CEFR không hợp lệ. Cho phép: " + ALLOWED_CEFR);
                }
                yield tokenRepo.findTokensByCefr(upper);
            }
            case "inactive" -> {
                int days = parsePositiveInt(value, 7);
                LocalDate threshold = LocalDate.now().minusDays(days);
                yield tokenRepo.findTokensInactiveSince(threshold);
            }
            case "custom" -> throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Segment custom chưa hỗ trợ — cần truyền danh sách userIds.");
            default -> List.of();
        };
    }

    private AdminNotification persist(String title, String body, String imageUrl, String actionUrl,
                                      String segmentType, String segmentValue,
                                      String sentByEmail, PushSendResult res) {
        AdminNotification n = new AdminNotification();
        n.setTitle(title);
        n.setBody(body);
        n.setImageUrl(blankToNull(imageUrl));
        n.setActionUrl(blankToNull(actionUrl));
        n.setSegmentType(segmentType);
        n.setSegmentValue(segmentValue);
        n.setTargetCount(res.targetCount());
        n.setSuccessCount(res.successCount());
        n.setFailureCount(res.failureCount());
        n.setSentByEmail(blankToNull(sentByEmail));
        return notifRepo.save(n);
    }

    // ── Device token (gọi từ mobile API) ────────────────────────────────────

    @Transactional
    public void registerDeviceToken(User user, String token, String platform) {
        if (user == null || token == null || token.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Thiếu user hoặc token.");
        }
        String normPlat = normalizePlatform(platform);
        UserDeviceToken existing = tokenRepo.findByToken(token).orElse(null);
        if (existing != null) {
            existing.setUser(user);
            existing.setPlatform(normPlat);
            existing.setLastUsedAt(LocalDateTime.now());
            tokenRepo.save(existing);
            return;
        }
        UserDeviceToken t = new UserDeviceToken();
        t.setUser(user);
        t.setToken(token);
        t.setPlatform(normPlat);
        t.setLastUsedAt(LocalDateTime.now());
        tokenRepo.save(t);
    }

    @Transactional
    public void unregisterDeviceToken(String token) {
        if (token == null || token.isBlank()) return;
        tokenRepo.deleteByToken(token);
    }

    // ── Announcement ────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public List<AdminAnnouncementRow> listAnnouncements() {
        List<AppAnnouncement> all = annRepo.findAllByOrderByCreatedAtDesc();
        List<AdminAnnouncementRow> rows = new ArrayList<>(all.size());
        for (AppAnnouncement a : all) {
            rows.add(new AdminAnnouncementRow(
                    a.getId(), a.getTitle(), a.getBody(), a.getSeverity(),
                    a.getStartAt(), a.getEndAt(), a.getIsActive(), a.getCreatedByEmail()
            ));
        }
        return rows;
    }

    @Transactional
    public AppAnnouncement createAnnouncement(String title, String body, String severity,
                                              LocalDateTime startAt, LocalDateTime endAt,
                                              Boolean isActive, String createdByEmail) {
        AppAnnouncement a = new AppAnnouncement();
        applyAnnouncement(a, title, body, severity, startAt, endAt, isActive);
        a.setCreatedByEmail(blankToNull(createdByEmail));
        return annRepo.save(a);
    }

    @Transactional
    public AppAnnouncement updateAnnouncement(UUID id, String title, String body, String severity,
                                              LocalDateTime startAt, LocalDateTime endAt,
                                              Boolean isActive) {
        AppAnnouncement a = annRepo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Announcement không tồn tại."));
        applyAnnouncement(a, title, body, severity, startAt, endAt, isActive);
        return annRepo.save(a);
    }

    @Transactional
    public void deleteAnnouncement(UUID id) {
        AppAnnouncement a = annRepo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Announcement không tồn tại."));
        annRepo.delete(a);
    }

    private void applyAnnouncement(AppAnnouncement a, String title, String body, String severity,
                                   LocalDateTime startAt, LocalDateTime endAt, Boolean isActive) {
        a.setTitle(require(title, "Tiêu đề không được trống."));
        a.setBody(require(body, "Nội dung không được trống."));
        a.setSeverity(normalizeSeverity(severity));
        if (startAt == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Thời gian bắt đầu không được trống.");
        }
        if (endAt != null && endAt.isBefore(startAt)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Thời gian kết thúc phải sau bắt đầu.");
        }
        a.setStartAt(startAt);
        a.setEndAt(endAt);
        a.setIsActive(isActive == null ? Boolean.TRUE : isActive);
    }

    // ── Helpers ─────────────────────────────────────────────────────────────

    @SuppressWarnings("unused")
    private User userOrThrow(UUID id) {
        return userRepo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User không tồn tại."));
    }

    private static String require(String s, String error) {
        if (s == null || s.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, error);
        }
        return s.trim();
    }

    private static String blankToNull(String s) {
        return s == null || s.isBlank() ? null : s.trim();
    }

    private static String normalizeSegmentType(String t) {
        if (t == null || t.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Segment type không được trống.");
        }
        String lower = t.trim().toLowerCase(Locale.ROOT);
        if (!ALLOWED_SEGMENT_TYPES.contains(lower)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Segment type không hợp lệ. Cho phép: " + ALLOWED_SEGMENT_TYPES);
        }
        return lower;
    }

    private static String normalizeSeverity(String s) {
        if (s == null || s.isBlank()) return "info";
        String lower = s.trim().toLowerCase(Locale.ROOT);
        if (!ALLOWED_SEVERITY.contains(lower)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Severity không hợp lệ. Cho phép: " + ALLOWED_SEVERITY);
        }
        return lower;
    }

    private static String normalizePlatform(String p) {
        if (p == null || p.isBlank()) return "unknown";
        String lower = p.trim().toLowerCase(Locale.ROOT);
        return switch (lower) {
            case "android", "ios", "web" -> lower;
            default -> "unknown";
        };
    }

    private static int parsePositiveInt(String s, int fallback) {
        if (s == null || s.isBlank()) return fallback;
        try {
            int v = Integer.parseInt(s.trim());
            return v <= 0 ? fallback : v;
        } catch (NumberFormatException ex) {
            return fallback;
        }
    }
}
