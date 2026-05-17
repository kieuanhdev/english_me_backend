package com.kiovant.englishme.controller;

import com.kiovant.englishme.dto.CreatePronunciationExerciseRequest;
import com.kiovant.englishme.dto.UpdatePronunciationExerciseRequest;
import com.kiovant.englishme.service.AdminPronunciationExerciseService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.UUID;

@Controller
@RequestMapping("/admin/pronunciation/exercises")
public class AdminPronunciationExerciseController {

    private final AdminPronunciationExerciseService service;

    public AdminPronunciationExerciseController(AdminPronunciationExerciseService service) {
        this.service = service;
    }

    // ── List + filter ───────────────────────────────────────────────────────

    @GetMapping
    public String list(
            @RequestParam(required = false, defaultValue = "") String level,
            @RequestParam(required = false, defaultValue = "") String difficulty,
            @RequestParam(required = false, defaultValue = "") String q,
            Model model
    ) {
        model.addAttribute("exercises", service.list(level, difficulty, q));
        model.addAttribute("selectedLevel", level);
        model.addAttribute("selectedDifficulty", difficulty);
        model.addAttribute("selectedKeyword", q);
        return "admin/pronunciation-exercises";
    }

    // ── CRUD ────────────────────────────────────────────────────────────────

    @PostMapping
    public String create(
            @RequestParam String text,
            @RequestParam(required = false, defaultValue = "") String expectedPhonetic,
            @RequestParam(required = false, defaultValue = "") String meaning,
            @RequestParam(required = false, defaultValue = "") String level,
            @RequestParam String difficulty,
            @RequestParam(required = false, defaultValue = "") String referenceAudioUrl,
            @RequestParam(required = false, defaultValue = "") String tips,
            RedirectAttributes ra
    ) {
        try {
            service.create(new CreatePronunciationExerciseRequest(
                    text, blankToNull(expectedPhonetic), blankToNull(meaning),
                    blankToNull(level), difficulty,
                    blankToNull(referenceAudioUrl), blankToNull(tips)));
            ra.addFlashAttribute("successMessage", "Đã tạo bài tập phát âm.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể tạo bài tập."));
        }
        return "redirect:/admin/pronunciation/exercises";
    }

    @PostMapping("/{id}/update")
    public String update(
            @PathVariable UUID id,
            @RequestParam String text,
            @RequestParam(required = false, defaultValue = "") String expectedPhonetic,
            @RequestParam(required = false, defaultValue = "") String meaning,
            @RequestParam(required = false, defaultValue = "") String level,
            @RequestParam String difficulty,
            @RequestParam(required = false, defaultValue = "") String referenceAudioUrl,
            @RequestParam(required = false, defaultValue = "") String tips,
            RedirectAttributes ra
    ) {
        try {
            service.update(id, new UpdatePronunciationExerciseRequest(
                    text, blankToNull(expectedPhonetic), blankToNull(meaning),
                    blankToNull(level), difficulty,
                    blankToNull(referenceAudioUrl), blankToNull(tips)));
            ra.addFlashAttribute("successMessage", "Đã cập nhật bài tập.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể cập nhật bài tập."));
        }
        return "redirect:/admin/pronunciation/exercises";
    }

    @PostMapping("/{id}/delete")
    public String delete(@PathVariable UUID id, RedirectAttributes ra) {
        try {
            service.delete(id);
            ra.addFlashAttribute("successMessage", "Đã xóa bài tập.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể xóa bài tập."));
        }
        return "redirect:/admin/pronunciation/exercises";
    }

    // ── Audio upload ────────────────────────────────────────────────────────

    @PostMapping("/{id}/audio")
    public String uploadAudio(@PathVariable UUID id,
                              @RequestParam("audio") MultipartFile audio,
                              RedirectAttributes ra) {
        try {
            String url = service.uploadAudio(id, audio);
            ra.addFlashAttribute("successMessage", "Đã upload audio mẫu: " + url);
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể upload audio."));
        }
        return "redirect:/admin/pronunciation/exercises";
    }

    // ── Analytics ───────────────────────────────────────────────────────────

    @GetMapping("/analytics")
    public String analytics(Model model) {
        model.addAttribute("analytics", service.getAnalytics());
        return "admin/pronunciation-analytics";
    }

    // ── Helpers ─────────────────────────────────────────────────────────────

    private static String blankToNull(String s) {
        return s == null || s.isBlank() ? null : s.trim();
    }

    private static String reasonOr(ResponseStatusException ex, String fallback) {
        return ex.getReason() == null ? fallback : ex.getReason();
    }
}
