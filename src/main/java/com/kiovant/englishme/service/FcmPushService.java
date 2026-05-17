package com.kiovant.englishme.service;

import com.google.firebase.messaging.BatchResponse;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.MulticastMessage;
import com.google.firebase.messaging.Notification;
import com.google.firebase.messaging.SendResponse;
import com.kiovant.englishme.dto.PushSendResult;
import com.kiovant.englishme.repository.UserDeviceTokenRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class FcmPushService {

    private static final Logger log = LoggerFactory.getLogger(FcmPushService.class);

    /** FCM giới hạn 500 token/batch cho sendEachForMulticast. */
    private static final int FCM_BATCH_LIMIT = 500;

    private final UserDeviceTokenRepository tokenRepository;

    public FcmPushService(UserDeviceTokenRepository tokenRepository) {
        this.tokenRepository = tokenRepository;
    }

    /**
     * Gửi push tới danh sách token. Tự chia batch 500. Dọn token invalid khỏi DB.
     */
    @Transactional
    public PushSendResult sendToTokens(List<String> tokens, String title, String body,
                                       String imageUrl, String actionUrl) {
        if (tokens == null || tokens.isEmpty()) {
            return new PushSendResult(0, 0, 0);
        }
        int target = tokens.size();
        int success = 0;
        int failure = 0;
        List<String> invalidTokens = new ArrayList<>();

        for (int i = 0; i < tokens.size(); i += FCM_BATCH_LIMIT) {
            int end = Math.min(i + FCM_BATCH_LIMIT, tokens.size());
            List<String> batch = tokens.subList(i, end);

            Notification.Builder notif = Notification.builder()
                    .setTitle(title)
                    .setBody(body);
            if (imageUrl != null && !imageUrl.isBlank()) {
                notif.setImage(imageUrl);
            }
            MulticastMessage.Builder msg = MulticastMessage.builder()
                    .setNotification(notif.build())
                    .addAllTokens(batch);
            Map<String, String> data = new HashMap<>();
            if (actionUrl != null && !actionUrl.isBlank()) {
                data.put("action_url", actionUrl);
            }
            if (!data.isEmpty()) {
                msg.putAllData(data);
            }

            try {
                BatchResponse res = FirebaseMessaging.getInstance().sendEachForMulticast(msg.build());
                success += res.getSuccessCount();
                failure += res.getFailureCount();

                List<SendResponse> responses = res.getResponses();
                for (int k = 0; k < responses.size(); k++) {
                    SendResponse sr = responses.get(k);
                    if (!sr.isSuccessful() && sr.getException() != null) {
                        String code = sr.getException().getMessagingErrorCode() == null
                                ? "" : sr.getException().getMessagingErrorCode().name();
                        if ("UNREGISTERED".equals(code) || "INVALID_ARGUMENT".equals(code)) {
                            invalidTokens.add(batch.get(k));
                        }
                    }
                }
            } catch (FirebaseMessagingException ex) {
                log.warn("FCM batch send failed: {}", ex.getMessage());
                failure += batch.size();
            }
        }

        for (String t : invalidTokens) {
            try {
                tokenRepository.deleteByToken(t);
            } catch (Exception ignored) {
            }
        }
        if (!invalidTokens.isEmpty()) {
            log.info("FCM: removed {} invalid tokens", invalidTokens.size());
        }
        return new PushSendResult(target, success, failure);
    }
}
