package com.kiovant.englishme.controller;

import com.kiovant.englishme.dto.XpRuleDto;
import com.kiovant.englishme.dto.XpRuleUpdateRequest;
import com.kiovant.englishme.entity.XpRule;
import com.kiovant.englishme.service.XpRuleService;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

/**
 * REST API quản lý xp_rules cho admin.
 *
 * <p>Đặt dưới <code>/admin/api/**</code> để tự động được {@code AdminRoleInterceptor}
 * bảo vệ (yêu cầu session admin). Không expose ra <code>/api/**</code> dành cho mobile.
 *
 * <p>Cách dùng nhanh từ Postman:
 * <pre>
 *   GET  /admin/api/xp-rules                  → list all rules
 *   GET  /admin/api/xp-rules/test             → 1 rule
 *   PUT  /admin/api/xp-rules/test             → upsert
 *     body: { "perCorrect": 5, "accuracyBonus": 15, "accuracyThresholdPct": 80 }
 * </pre>
 */
@RestController
@RequestMapping("/admin/api/xp-rules")
public class AdminXpRuleApiController {

    private final XpRuleService xpRuleService;

    public AdminXpRuleApiController(XpRuleService xpRuleService) {
        this.xpRuleService = xpRuleService;
    }

    @GetMapping
    public List<XpRuleDto> listAll() {
        return xpRuleService.findAll().values().stream()
                .sorted((a, b) -> a.getSourceType().compareTo(b.getSourceType()))
                .map(XpRuleDto::from)
                .toList();
    }

    @GetMapping("/{sourceType}")
    public XpRuleDto get(@PathVariable String sourceType) {
        return xpRuleService.get(sourceType)
                .map(XpRuleDto::from)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "xp_rule not found: " + sourceType));
    }

    /**
     * Upsert 1 rule. Tất cả field trong body đều optional — chỉ field được gửi sẽ ghi đè.
     * Nếu rule chưa tồn tại, tạo mới với các field còn lại = default (0 / null / true).
     */
    @PutMapping("/{sourceType}")
    public XpRuleDto upsert(@PathVariable String sourceType,
                            @RequestBody XpRuleUpdateRequest body) {
        if (sourceType == null || sourceType.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "sourceType is required");
        }

        XpRule existing = xpRuleService.get(sourceType).orElseGet(() -> {
            XpRule r = new XpRule();
            r.setSourceType(sourceType);
            return r;
        });

        if (body.baseAmount() != null) existing.setBaseAmount(nonNegative(body.baseAmount(), "baseAmount"));
        if (body.perCorrect() != null) existing.setPerCorrect(nonNegative(body.perCorrect(), "perCorrect"));
        if (body.accuracyBonus() != null) existing.setAccuracyBonus(nonNegative(body.accuracyBonus(), "accuracyBonus"));
        if (body.accuracyThresholdPct() != null) {
            short pct = body.accuracyThresholdPct();
            if (pct < 0 || pct > 100) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "accuracyThresholdPct must be in [0, 100]");
            }
            existing.setAccuracyThresholdPct(pct);
        }
        if (body.dailyCap() != null) {
            if (body.dailyCap() < 0) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "dailyCap must be >= 0 (or omit for unlimited)");
            }
            existing.setDailyCap(body.dailyCap());
        }
        if (body.enabled() != null) existing.setEnabled(body.enabled());
        if (body.description() != null) existing.setDescription(body.description());

        return XpRuleDto.from(xpRuleService.upsert(existing));
    }

    /** Buộc reload cache ngay (không cần đợi TTL 60s). */
    @PostMapping("/invalidate-cache")
    public java.util.Map<String, Object> invalidate() {
        xpRuleService.invalidate();
        return java.util.Map.of("ok", true);
    }

    private static int nonNegative(int v, String field) {
        if (v < 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, field + " must be >= 0");
        }
        return v;
    }
}
