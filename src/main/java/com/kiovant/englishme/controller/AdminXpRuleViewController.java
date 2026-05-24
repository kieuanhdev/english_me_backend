package com.kiovant.englishme.controller;

import com.kiovant.englishme.entity.XpRule;
import com.kiovant.englishme.service.XpRuleService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Comparator;
import java.util.List;

/**
 * Trang admin chỉnh xp_rules — chỉ tập trung vào test/exercise (accuracy-based)
 * và 5 bonus types (daily_goal_bonus, path_bonus, level_bonus, streak_bonus, pronunciation).
 *
 * <p>Lesson XP cố ý KHÔNG hiển thị ở đây vì:
 * - Lesson XP đọc từ {@code learning_lessons.xp_reward} (master data, mỗi lesson 1 giá trị riêng).
 * - sm2_review XP cố định trong code (rating-based) — không khớp schema xp_rules.
 *
 * <p>Sau khi POST cập nhật, cache xp_rules tự invalidate qua {@link XpRuleService#upsert}
 * → có hiệu lực ngay cho lượt grant XP tiếp theo.
 */
@Controller
@RequestMapping("/admin/xp-rules")
public class AdminXpRuleViewController {

    private final XpRuleService xpRuleService;

    public AdminXpRuleViewController(XpRuleService xpRuleService) {
        this.xpRuleService = xpRuleService;
    }

    @GetMapping
    public String page(Model model) {
        List<XpRule> rules = xpRuleService.findAll().values().stream()
                .sorted(Comparator.comparing(XpRule::getSourceType))
                .toList();
        model.addAttribute("rules", rules);
        return "admin/xp-rules";
    }

    @PostMapping
    public String update(
            @RequestParam String sourceType,
            @RequestParam(required = false, defaultValue = "0") int baseAmount,
            @RequestParam(required = false, defaultValue = "0") int perCorrect,
            @RequestParam(required = false, defaultValue = "0") int accuracyBonus,
            @RequestParam(required = false, defaultValue = "0") int accuracyThresholdPct,
            @RequestParam(required = false) String dailyCapRaw,
            @RequestParam(required = false) String enabled,
            RedirectAttributes ra
    ) {
        try {
            if (sourceType == null || sourceType.isBlank()) {
                throw new IllegalArgumentException("Thiếu sourceType.");
            }
            if (baseAmount < 0 || perCorrect < 0 || accuracyBonus < 0) {
                throw new IllegalArgumentException("Các giá trị XP phải >= 0.");
            }
            if (accuracyThresholdPct < 0 || accuracyThresholdPct > 100) {
                throw new IllegalArgumentException("Ngưỡng accuracy phải trong [0, 100].");
            }

            Integer dailyCap = null;
            if (dailyCapRaw != null && !dailyCapRaw.isBlank()) {
                try {
                    dailyCap = Integer.parseInt(dailyCapRaw.trim());
                    if (dailyCap < 0) {
                        throw new IllegalArgumentException("Daily cap phải >= 0 hoặc để trống.");
                    }
                } catch (NumberFormatException ex) {
                    throw new IllegalArgumentException("Daily cap phải là số nguyên.");
                }
            }

            XpRule existing = xpRuleService.get(sourceType).orElseGet(() -> {
                XpRule r = new XpRule();
                r.setSourceType(sourceType);
                return r;
            });

            existing.setBaseAmount(baseAmount);
            existing.setPerCorrect(perCorrect);
            existing.setAccuracyBonus(accuracyBonus);
            existing.setAccuracyThresholdPct((short) accuracyThresholdPct);
            existing.setDailyCap(dailyCap);
            existing.setEnabled("on".equalsIgnoreCase(enabled) || "true".equalsIgnoreCase(enabled));

            xpRuleService.upsert(existing);
            ra.addFlashAttribute("successMessage", "Đã cập nhật rule '" + sourceType + "'.");
        } catch (IllegalArgumentException ex) {
            ra.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/admin/xp-rules";
    }
}
