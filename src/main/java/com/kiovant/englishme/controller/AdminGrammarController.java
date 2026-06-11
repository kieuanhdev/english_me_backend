package com.kiovant.englishme.controller;

import com.kiovant.englishme.dto.CreateGrammarExerciseRequest;
import com.kiovant.englishme.dto.CreateGrammarLessonRequest;
import com.kiovant.englishme.dto.CreateGrammarTopicRequest;
import com.kiovant.englishme.dto.GrammarImportResult;
import com.kiovant.englishme.dto.UpdateGrammarExerciseRequest;
import com.kiovant.englishme.dto.UpdateGrammarLessonRequest;
import com.kiovant.englishme.dto.UpdateGrammarTopicRequest;
import com.kiovant.englishme.entity.GrammarLesson;
import com.kiovant.englishme.service.AdminGrammarService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.UUID;

@Controller
@RequestMapping("/admin/grammar")
public class AdminGrammarController {

    private final AdminGrammarService adminGrammarService;

    public AdminGrammarController(AdminGrammarService adminGrammarService) {
        this.adminGrammarService = adminGrammarService;
    }

    // ── Topic list / create / update / delete ───────────────────────────────

    @GetMapping
    public String list(
            @RequestParam(required = false, defaultValue = "") String level,
            @RequestParam(required = false, defaultValue = "") String q,
            Model model
    ) {
        model.addAttribute("topics", adminGrammarService.listTopics(level, q));
        model.addAttribute("selectedLevel", level);
        model.addAttribute("selectedKeyword", q);
        return "admin/grammar";
    }

    @PostMapping("/topics")
    public String createTopic(
            @RequestParam String slug,
            @RequestParam String category,
            @RequestParam String level,
            @RequestParam String title,
            @RequestParam(required = false, defaultValue = "") String sortOrderRaw,
            RedirectAttributes ra
    ) {
        Integer sortOrder = parseSortOrder(sortOrderRaw, ra);
        if (sortOrder == null && !sortOrderRaw.isBlank()) return "redirect:/admin/grammar";

        try {
            adminGrammarService.createTopic(new CreateGrammarTopicRequest(
                    slug, category, level, title, sortOrder));
            ra.addFlashAttribute("successMessage", "Đã tạo chủ đề ngữ pháp.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể tạo chủ đề."));
        }
        return "redirect:/admin/grammar";
    }

    @PostMapping("/topics/{id}/update")
    public String updateTopic(
            @PathVariable UUID id,
            @RequestParam String slug,
            @RequestParam String category,
            @RequestParam String level,
            @RequestParam String title,
            @RequestParam(required = false, defaultValue = "") String sortOrderRaw,
            RedirectAttributes ra
    ) {
        Integer sortOrder = parseSortOrder(sortOrderRaw, ra);
        if (sortOrder == null && !sortOrderRaw.isBlank()) return "redirect:/admin/grammar";

        try {
            adminGrammarService.updateTopic(id, new UpdateGrammarTopicRequest(
                    slug, category, level, title, sortOrder));
            ra.addFlashAttribute("successMessage", "Đã cập nhật chủ đề.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể cập nhật chủ đề."));
        }
        return "redirect:/admin/grammar";
    }

    @PostMapping("/topics/{id}/delete")
    public String deleteTopic(@PathVariable UUID id, RedirectAttributes ra) {
        try {
            adminGrammarService.deleteTopic(id);
            ra.addFlashAttribute("successMessage", "Đã xóa chủ đề và toàn bộ bài học / bài tập.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể xóa chủ đề."));
        }
        return "redirect:/admin/grammar";
    }

    // ── Topic detail: lessons list / create / update / delete ───────────────

    @GetMapping("/topics/{id}")
    public String topicDetail(@PathVariable UUID id, Model model, RedirectAttributes ra) {
        try {
            model.addAttribute("topic", adminGrammarService.getTopicOrThrow(id));
            model.addAttribute("lessons", adminGrammarService.listLessonsByTopic(id));
            model.addAttribute("topicId", id.toString());
            return "admin/grammar-lessons";
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", "Không tìm thấy chủ đề ngữ pháp.");
            return "redirect:/admin/grammar";
        }
    }

    @PostMapping("/topics/{id}/lessons")
    public String createLesson(
            @PathVariable UUID id,
            @RequestParam String sourceId,
            @RequestParam String title,
            @RequestParam(required = false, defaultValue = "") String sortOrderRaw,
            @RequestParam(required = false, defaultValue = "") String explanationVi,
            @RequestParam(required = false, defaultValue = "") String whenToUseVi,
            @RequestParam(required = false, defaultValue = "") String tipsVi,
            @RequestParam(required = false, defaultValue = "") String formulasJson,
            @RequestParam(required = false, defaultValue = "") String keyWordsJson,
            @RequestParam(required = false, defaultValue = "") String examplesJson,
            @RequestParam(required = false, defaultValue = "") String commonMistakesJson,
            RedirectAttributes ra
    ) {
        Integer sortOrder = parseSortOrder(sortOrderRaw, ra);
        if (sortOrder == null && !sortOrderRaw.isBlank()) return "redirect:/admin/grammar/topics/" + id;

        try {
            adminGrammarService.createLesson(id, new CreateGrammarLessonRequest(
                    sourceId, title, sortOrder,
                    blankToNull(explanationVi),
                    blankToNull(whenToUseVi),
                    blankToNull(tipsVi),
                    blankToNull(formulasJson),
                    blankToNull(keyWordsJson),
                    blankToNull(examplesJson),
                    blankToNull(commonMistakesJson)));
            ra.addFlashAttribute("successMessage", "Đã thêm bài học.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể thêm bài học."));
        }
        return "redirect:/admin/grammar/topics/" + id;
    }

    @PostMapping("/lessons/{id}/update")
    public String updateLesson(
            @PathVariable UUID id,
            @RequestParam String sourceId,
            @RequestParam String title,
            @RequestParam(required = false, defaultValue = "") String sortOrderRaw,
            @RequestParam(required = false, defaultValue = "") String explanationVi,
            @RequestParam(required = false, defaultValue = "") String whenToUseVi,
            @RequestParam(required = false, defaultValue = "") String tipsVi,
            @RequestParam(required = false, defaultValue = "") String formulasJson,
            @RequestParam(required = false, defaultValue = "") String keyWordsJson,
            @RequestParam(required = false, defaultValue = "") String examplesJson,
            @RequestParam(required = false, defaultValue = "") String commonMistakesJson,
            RedirectAttributes ra
    ) {
        Integer sortOrder = parseSortOrder(sortOrderRaw, ra);
        if (sortOrder == null && !sortOrderRaw.isBlank()) return "redirect:/admin/grammar/lessons/" + id;

        UUID topicId = null;
        try {
            GrammarLesson updated = adminGrammarService.updateLesson(id, new UpdateGrammarLessonRequest(
                    sourceId, title, sortOrder,
                    blankToNull(explanationVi),
                    blankToNull(whenToUseVi),
                    blankToNull(tipsVi),
                    blankToNull(formulasJson),
                    blankToNull(keyWordsJson),
                    blankToNull(examplesJson),
                    blankToNull(commonMistakesJson)));
            topicId = updated.getTopic().getId();
            ra.addFlashAttribute("successMessage", "Đã cập nhật bài học.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể cập nhật bài học."));
            try {
                topicId = adminGrammarService.getLessonOrThrow(id).getTopic().getId();
            } catch (ResponseStatusException ignored) {
                return "redirect:/admin/grammar";
            }
        }
        return "redirect:/admin/grammar/topics/" + topicId;
    }

    @PostMapping("/lessons/{id}/delete")
    public String deleteLesson(@PathVariable UUID id, RedirectAttributes ra) {
        UUID topicId;
        try {
            topicId = adminGrammarService.getLessonOrThrow(id).getTopic().getId();
            adminGrammarService.deleteLesson(id);
            ra.addFlashAttribute("successMessage", "Đã xóa bài học.");
            return "redirect:/admin/grammar/topics/" + topicId;
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể xóa bài học."));
            return "redirect:/admin/grammar";
        }
    }

    // ── Lesson detail + exercises ───────────────────────────────────────────

    @GetMapping("/lessons/{id}")
    public String lessonDetail(@PathVariable UUID id, Model model, RedirectAttributes ra) {
        try {
            model.addAttribute("lesson", adminGrammarService.getLessonDetail(id));
            return "admin/grammar-lesson-detail";
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", "Không tìm thấy bài học.");
            return "redirect:/admin/grammar";
        }
    }

    @PostMapping("/lessons/{id}/exercises")
    public String createExercise(
            @PathVariable UUID id,
            @RequestParam(required = false, defaultValue = "") String exerciseOrderRaw,
            @RequestParam(required = false, defaultValue = "") String exerciseType,
            @RequestParam(required = false, defaultValue = "") String contentJson,
            RedirectAttributes ra
    ) {
        Integer order = parseSortOrder(exerciseOrderRaw, ra);
        if (order == null && !exerciseOrderRaw.isBlank()) return "redirect:/admin/grammar/lessons/" + id;

        try {
            adminGrammarService.createExercise(id, new CreateGrammarExerciseRequest(
                    order, blankToNull(exerciseType), contentJson));
            ra.addFlashAttribute("successMessage", "Đã thêm bài tập.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể thêm bài tập."));
        }
        return "redirect:/admin/grammar/lessons/" + id;
    }

    @PostMapping("/exercises/{id}/update")
    public String updateExercise(
            @PathVariable UUID id,
            @RequestParam UUID lessonId,
            @RequestParam(required = false, defaultValue = "") String exerciseOrderRaw,
            @RequestParam(required = false, defaultValue = "") String exerciseType,
            @RequestParam(required = false, defaultValue = "") String contentJson,
            RedirectAttributes ra
    ) {
        Integer order = parseSortOrder(exerciseOrderRaw, ra);
        if (order == null && !exerciseOrderRaw.isBlank()) return "redirect:/admin/grammar/lessons/" + lessonId;

        try {
            adminGrammarService.updateExercise(id, new UpdateGrammarExerciseRequest(
                    order, blankToNull(exerciseType), contentJson));
            ra.addFlashAttribute("successMessage", "Đã cập nhật bài tập.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể cập nhật bài tập."));
        }
        return "redirect:/admin/grammar/lessons/" + lessonId;
    }

    @PostMapping("/exercises/{id}/delete")
    public String deleteExercise(@PathVariable UUID id, RedirectAttributes ra) {
        try {
            UUID lessonId = adminGrammarService.deleteExercise(id);
            ra.addFlashAttribute("successMessage", "Đã xóa bài tập.");
            return "redirect:/admin/grammar/lessons/" + lessonId;
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể xóa bài tập."));
            return "redirect:/admin/grammar";
        }
    }

    // ── Bulk import ─────────────────────────────────────────────────────────

    @PostMapping("/import")
    public String importGrammar(
            @RequestParam(required = false, defaultValue = "") String jsonPayload,
            RedirectAttributes ra
    ) {
        // Chặn payload quá khổ trước khi đưa vào ObjectMapper (tránh OOM).
        if (jsonPayload.length() > 1_048_576) {
            ra.addFlashAttribute("errorMessage", "Payload vượt quá 1MB — chia nhỏ file import.");
            return "redirect:/admin/grammar";
        }
        try {
            GrammarImportResult result = adminGrammarService.importGrammar(jsonPayload);
            StringBuilder msg = new StringBuilder();
            msg.append("Topics: ").append(result.topicsInserted())
                    .append(" mới / ").append(result.totalTopics())
                    .append(" (bỏ qua ").append(result.topicsSkipped()).append("). ");
            msg.append("Lessons: ").append(result.lessonsInserted())
                    .append(" mới / ").append(result.totalLessons())
                    .append(" (bỏ qua ").append(result.lessonsSkipped()).append("). ");
            msg.append("Exercises: ").append(result.exercisesInserted())
                    .append(" mới / ").append(result.totalExercises()).append(".");
            if (!result.errors().isEmpty()) {
                msg.append(" Lỗi: ");
                int limit = Math.min(result.errors().size(), 5);
                for (int i = 0; i < limit; i++) msg.append(result.errors().get(i)).append(" | ");
                if (result.errors().size() > 5) {
                    msg.append("... (+").append(result.errors().size() - 5).append(" lỗi khác)");
                }
            }
            if (result.topicsInserted() + result.lessonsInserted() + result.exercisesInserted() > 0) {
                ra.addFlashAttribute("successMessage", msg.toString());
            } else {
                ra.addFlashAttribute("errorMessage", msg.toString());
            }
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể import."));
        }
        return "redirect:/admin/grammar";
    }

    // ── Helpers ─────────────────────────────────────────────────────────────

    private static Integer parseSortOrder(String raw, RedirectAttributes ra) {
        if (raw == null || raw.isBlank()) return null;
        try {
            return Integer.parseInt(raw.trim());
        } catch (NumberFormatException ex) {
            ra.addFlashAttribute("errorMessage", "Thứ tự hiển thị phải là số nguyên.");
            return null;
        }
    }

    private static String blankToNull(String s) {
        return s == null || s.isBlank() ? null : s.trim();
    }

    private static String reasonOr(ResponseStatusException ex, String fallback) {
        return ex.getReason() == null ? fallback : ex.getReason();
    }
}
