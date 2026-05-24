package com.kiovant.englishme.controller;

import com.kiovant.englishme.entity.LearningLesson;
import com.kiovant.englishme.repository.LearningLessonRepository;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.List;

/**
 * Trang admin chỉnh XP từng learning_lessons.xp_reward.
 *
 * <p>Chỉ ảnh hưởng cột XP của bài học — không sửa content/activities/title.
 * Cho phép filter theo level/skill và search theo title hoặc id.
 */
@Controller
@RequestMapping("/admin/lessons")
public class AdminLessonController {

    private static final int MAX_XP_REWARD = 999;

    private final LearningLessonRepository lessonRepository;

    public AdminLessonController(LearningLessonRepository lessonRepository) {
        this.lessonRepository = lessonRepository;
    }

    @GetMapping
    public String page(
            @RequestParam(required = false, defaultValue = "") String level,
            @RequestParam(required = false, defaultValue = "") String skill,
            @RequestParam(required = false, defaultValue = "") String q,
            Model model
    ) {
        String safeLevel = level == null || level.isBlank() ? null : level.trim();
        String safeSkill = skill == null || skill.isBlank() ? null : skill.trim();
        // Pre-build LIKE pattern ở Java để tránh LOWER(:keyword) với param NULL
        // (Postgres không có lower(bytea) → query fail trên JDBC).
        String keywordPattern = q == null || q.isBlank()
                ? null
                : "%" + q.trim().toLowerCase() + "%";

        List<LearningLesson> lessons = lessonRepository.adminSearch(safeLevel, safeSkill, keywordPattern);

        model.addAttribute("lessons", lessons);
        model.addAttribute("selectedLevel", level == null ? "" : level);
        model.addAttribute("selectedSkill", skill == null ? "" : skill);
        model.addAttribute("selectedKeyword", q == null ? "" : q);
        model.addAttribute("totalCount", lessons.size());
        return "admin/lessons";
    }

    @PostMapping("/{id}/xp")
    public String updateXp(
            @PathVariable String id,
            @RequestParam int xpReward,
            @RequestParam(required = false, defaultValue = "") String level,
            @RequestParam(required = false, defaultValue = "") String skill,
            @RequestParam(required = false, defaultValue = "") String q,
            RedirectAttributes ra
    ) {
        if (xpReward < 0 || xpReward > MAX_XP_REWARD) {
            ra.addFlashAttribute("errorMessage",
                    "XP phải trong khoảng 0–" + MAX_XP_REWARD + ".");
            return redirect(level, skill, q);
        }
        lessonRepository.findById(id).ifPresentOrElse(lesson -> {
            lesson.setXpReward((short) xpReward);
            lessonRepository.save(lesson);
            ra.addFlashAttribute("successMessage",
                    "Đã cập nhật XP cho '" + lesson.getTitle() + "' (" + lesson.getId() + ") = " + xpReward + " XP.");
        }, () -> ra.addFlashAttribute("errorMessage", "Không tìm thấy lesson: " + id));
        return redirect(level, skill, q);
    }

    private static String redirect(String level, String skill, String q) {
        return "redirect:" + UriComponentsBuilder.fromPath("/admin/lessons")
                .queryParam("level", level == null ? "" : level)
                .queryParam("skill", skill == null ? "" : skill)
                .queryParam("q", q == null ? "" : q)
                .build()
                .encode()
                .toUriString();
    }
}
