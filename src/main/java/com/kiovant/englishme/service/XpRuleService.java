package com.kiovant.englishme.service;

import com.kiovant.englishme.entity.XpRule;
import com.kiovant.englishme.repository.XpRuleRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.Instant;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Đọc cấu hình XP từ table {@code xp_rules} với cache in-memory TTL 60s.
 *
 * <p>Khi admin chỉnh rule qua endpoint hoặc SQL, hiệu ứng có hiệu lực trong vòng tối đa
 * 60 giây (hoặc gọi {@link #invalidate()} để áp dụng tức thì).
 */
@Service
public class XpRuleService {

    private static final Duration CACHE_TTL = Duration.ofSeconds(60);

    private final XpRuleRepository repository;
    private final Map<String, XpRule> cache = new ConcurrentHashMap<>();
    private volatile Instant cacheLoadedAt = Instant.EPOCH;

    public XpRuleService(XpRuleRepository repository) {
        this.repository = repository;
    }

    /**
     * Tính XP cho test/exercise từ rule + (correct, total).
     * Công thức: {@code base + perCorrect*correct + (accuracy >= threshold ? accuracyBonus : 0)}.
     * Trả 0 nếu rule không enabled hoặc total <= 0.
     */
    public int computeAccuracyBased(String sourceType, int correct, int total) {
        if (total <= 0 || correct < 0) return 0;
        XpRule rule = get(sourceType).orElse(null);
        if (rule == null || !Boolean.TRUE.equals(rule.getEnabled())) return 0;

        int xp = nz(rule.getBaseAmount()) + nz(rule.getPerCorrect()) * correct;
        int threshold = rule.getAccuracyThresholdPct() == null ? 0 : rule.getAccuracyThresholdPct();
        int accuracy = (int) Math.round((correct * 100.0) / total);
        if (accuracy >= threshold && nz(rule.getAccuracyBonus()) > 0) {
            xp += rule.getAccuracyBonus();
        }
        return Math.max(0, xp);
    }

    /**
     * Lấy base XP cho các bonus đơn giản (daily_goal_bonus, path_bonus, level_bonus, streak_bonus, ...).
     * Trả về {@code fallback} nếu rule không tồn tại hoặc bị disable.
     */
    public int baseAmount(String sourceType, int fallback) {
        return get(sourceType)
                .filter(r -> Boolean.TRUE.equals(r.getEnabled()))
                .map(r -> nz(r.getBaseAmount()))
                .orElse(fallback);
    }

    public Optional<XpRule> get(String sourceType) {
        refreshIfStale();
        return Optional.ofNullable(cache.get(sourceType));
    }

    /** Snapshot toàn bộ rules — dùng cho admin endpoint. */
    @Transactional(readOnly = true)
    public Map<String, XpRule> findAll() {
        refreshIfStale();
        return Map.copyOf(cache);
    }

    /** Upsert 1 rule và invalidate cache để có hiệu lực ngay. */
    @Transactional
    public XpRule upsert(XpRule rule) {
        XpRule saved = repository.save(rule);
        invalidate();
        return saved;
    }

    /** Buộc reload lần gọi tiếp theo. */
    public void invalidate() {
        cacheLoadedAt = Instant.EPOCH;
    }

    private void refreshIfStale() {
        if (Duration.between(cacheLoadedAt, Instant.now()).compareTo(CACHE_TTL) < 0) {
            return;
        }
        synchronized (this) {
            if (Duration.between(cacheLoadedAt, Instant.now()).compareTo(CACHE_TTL) < 0) {
                return;
            }
            Map<String, XpRule> snapshot = new ConcurrentHashMap<>();
            for (XpRule r : repository.findAll()) {
                snapshot.put(r.getSourceType(), r);
            }
            cache.clear();
            cache.putAll(snapshot);
            cacheLoadedAt = Instant.now();
        }
    }

    private static int nz(Integer v) {
        return v == null ? 0 : v;
    }
}
