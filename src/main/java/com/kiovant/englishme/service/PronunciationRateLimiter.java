package com.kiovant.englishme.service;

import org.springframework.beans.factory.annotation.Value;
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

    @Value("${englishme.ai.pronunciation.rate-limit.max-requests:20}")
    private int maxRequestsPerWindow;

    @Value("${englishme.ai.pronunciation.rate-limit.window-seconds:3600}")
    private int windowSeconds;

    public void checkOrThrow(String firebaseUid) {
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
