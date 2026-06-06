package com.kiovant.englishme.service;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.util.ArrayDeque;
import java.util.Deque;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class PronunciationRateLimiter {

    private final Map<String, Deque<Long>> userWindowMap = new ConcurrentHashMap<>();
    private static final int MAX_TRACKED_USERS = 10000;

    /** Default khi app_config trống — giữ giá trị cũ. */
    private static final int DEFAULT_MAX_REQUESTS = 20;
    private static final int DEFAULT_WINDOW_SECONDS = 3600;

    private final AppConfigService appConfigService;

    public PronunciationRateLimiter(AppConfigService appConfigService) {
        this.appConfigService = appConfigService;
    }

    public void checkOrThrow(String firebaseUid) {
        int maxRequestsPerWindow = appConfigService.getIntOr(AiConfigKeys.RATELIMIT_MAX, DEFAULT_MAX_REQUESTS);
        int windowSeconds = appConfigService.getIntOr(AiConfigKeys.RATELIMIT_WINDOW_SEC, DEFAULT_WINDOW_SECONDS);

        long now = Instant.now().getEpochSecond();
        long from = now - Math.max(windowSeconds, 60);
        if (userWindowMap.size() > MAX_TRACKED_USERS && !userWindowMap.containsKey(firebaseUid)) {
            throw new ResponseStatusException(HttpStatus.TOO_MANY_REQUESTS, "Rate limiter is busy. Please retry later.");
        }
        Deque<Long> queue = userWindowMap.computeIfAbsent(firebaseUid, key -> new ArrayDeque<>());
        synchronized (queue) {
            while (!queue.isEmpty() && queue.peekFirst() < from) {
                queue.pollFirst();
            }
            if (queue.size() >= Math.max(maxRequestsPerWindow, 1)) {
                throw new ResponseStatusException(HttpStatus.TOO_MANY_REQUESTS, "Too many pronunciation attempts. Please try again later.");
            }
            queue.addLast(now);
            if (queue.isEmpty()) {
                userWindowMap.remove(firebaseUid, queue);
            }
        }
    }
}
