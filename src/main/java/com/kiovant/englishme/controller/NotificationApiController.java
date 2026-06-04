package com.kiovant.englishme.controller;

import com.google.firebase.auth.FirebaseToken;
import com.kiovant.englishme.dto.NotificationResponse;
import com.kiovant.englishme.dto.UnreadCountResponse;
import com.kiovant.englishme.service.FirebaseAuthHelper;
import com.kiovant.englishme.service.NotificationService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/notifications")
public class NotificationApiController {

    private final NotificationService notificationService;
    private final FirebaseAuthHelper authHelper;

    public NotificationApiController(NotificationService notificationService,
                                     FirebaseAuthHelper authHelper) {
        this.notificationService = notificationService;
        this.authHelper = authHelper;
    }

    /** Danh sách thông báo của user (mới nhất trước). */
    @GetMapping
    public List<NotificationResponse> list(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestParam(name = "unreadOnly", defaultValue = "false") boolean unreadOnly,
            @RequestParam(name = "limit", defaultValue = "30") int limit
    ) {
        FirebaseToken token = authHelper.verifyBearer(authorization);
        return notificationService.list(token.getUid(), unreadOnly, limit);
    }

    /** Số thông báo chưa đọc — cho badge trên chuông. */
    @GetMapping("/unread-count")
    public UnreadCountResponse unreadCount(
            @RequestHeader(value = "Authorization", required = false) String authorization
    ) {
        FirebaseToken token = authHelper.verifyBearer(authorization);
        return notificationService.unreadCount(token.getUid());
    }

    /** Đánh dấu 1 thông báo đã đọc. */
    @PutMapping("/{id}/read")
    public ResponseEntity<Void> markRead(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @PathVariable UUID id
    ) {
        FirebaseToken token = authHelper.verifyBearer(authorization);
        notificationService.markRead(token.getUid(), id);
        return ResponseEntity.noContent().build();
    }

    /** Đánh dấu tất cả đã đọc. */
    @PutMapping("/read-all")
    public ResponseEntity<Void> markAllRead(
            @RequestHeader(value = "Authorization", required = false) String authorization
    ) {
        FirebaseToken token = authHelper.verifyBearer(authorization);
        notificationService.markAllRead(token.getUid());
        return ResponseEntity.noContent().build();
    }
}
