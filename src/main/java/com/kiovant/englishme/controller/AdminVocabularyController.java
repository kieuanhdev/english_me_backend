package com.kiovant.englishme.controller;

import com.kiovant.englishme.dto.CreateVocabularyTopicRequest;
import com.kiovant.englishme.dto.CreateVocabularyWordRequest;
import com.kiovant.englishme.dto.UpdateVocabularyTopicRequest;
import com.kiovant.englishme.dto.UpdateVocabularyWordRequest;
import com.kiovant.englishme.dto.VocabularyImportResult;
import com.kiovant.englishme.entity.VocabularyTopic;
import com.kiovant.englishme.entity.VocabularyWord;
import com.kiovant.englishme.service.AdminVocabularyService;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.nio.charset.StandardCharsets;
import java.util.UUID;

@Controller
@RequestMapping("/admin/vocabulary")
public class AdminVocabularyController {

    private final AdminVocabularyService adminVocabularyService;

    public AdminVocabularyController(AdminVocabularyService adminVocabularyService) {
        this.adminVocabularyService = adminVocabularyService;
    }

    // ── Topic list ──────────────────────────────────────────────────────────

    @GetMapping
    public String topics(
            @RequestParam(required = false, defaultValue = "") String level,
            @RequestParam(required = false, defaultValue = "") String q,
            Model model
    ) {
        model.addAttribute("topics", adminVocabularyService.listTopics(level, q));
        model.addAttribute("selectedLevel", level);
        model.addAttribute("selectedKeyword", q);
        return "admin/vocabulary";
    }

    @PostMapping("/topics")
    public String createTopic(
            @RequestParam String name,
            @RequestParam String nameEn,
            @RequestParam(required = false, defaultValue = "") String icon,
            @RequestParam(required = false, defaultValue = "") String level,
            @RequestParam(required = false, defaultValue = "") String colorHex,
            @RequestParam(required = false, defaultValue = "") String sortOrderRaw,
            RedirectAttributes ra
    ) {
        Integer sortOrder = parseSortOrder(sortOrderRaw, ra);
        if (sortOrder == null && !sortOrderRaw.isBlank()) return "redirect:/admin/vocabulary";

        CreateVocabularyTopicRequest req = new CreateVocabularyTopicRequest(
                name, nameEn,
                blankToNull(icon),
                blankToNull(level),
                blankToNull(colorHex),
                sortOrder
        );
        try {
            adminVocabularyService.createTopic(req);
            ra.addFlashAttribute("successMessage", "Đã tạo chủ đề từ vựng.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể tạo chủ đề."));
        }
        return "redirect:/admin/vocabulary";
    }

    @PostMapping("/topics/{id}/update")
    public String updateTopic(
            @PathVariable UUID id,
            @RequestParam String name,
            @RequestParam String nameEn,
            @RequestParam(required = false, defaultValue = "") String icon,
            @RequestParam(required = false, defaultValue = "") String level,
            @RequestParam(required = false, defaultValue = "") String colorHex,
            @RequestParam(required = false, defaultValue = "") String sortOrderRaw,
            RedirectAttributes ra
    ) {
        Integer sortOrder = parseSortOrder(sortOrderRaw, ra);
        if (sortOrder == null && !sortOrderRaw.isBlank()) return "redirect:/admin/vocabulary";

        UpdateVocabularyTopicRequest req = new UpdateVocabularyTopicRequest(
                name, nameEn,
                blankToNull(icon),
                blankToNull(level),
                blankToNull(colorHex),
                sortOrder
        );
        try {
            adminVocabularyService.updateTopic(id, req);
            ra.addFlashAttribute("successMessage", "Đã cập nhật chủ đề.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể cập nhật chủ đề."));
        }
        return "redirect:/admin/vocabulary";
    }

    @PostMapping("/topics/{id}/delete")
    public String deleteTopic(@PathVariable UUID id, RedirectAttributes ra) {
        try {
            adminVocabularyService.deleteTopic(id);
            ra.addFlashAttribute("successMessage", "Đã xóa chủ đề và toàn bộ từ trong chủ đề.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể xóa chủ đề."));
        }
        return "redirect:/admin/vocabulary";
    }

    // ── Topic detail (words) ────────────────────────────────────────────────

    @GetMapping("/topics/{id}")
    public String topicDetail(
            @PathVariable UUID id,
            @RequestParam(required = false, defaultValue = "") String q,
            Model model,
            RedirectAttributes ra
    ) {
        try {
            VocabularyTopic topic = adminVocabularyService.getTopicOrThrow(id);
            model.addAttribute("topic", topic);
            model.addAttribute("words", adminVocabularyService.listWords(id, q));
            model.addAttribute("selectedKeyword", q);
            return "admin/vocabulary-topic";
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", "Không tìm thấy chủ đề từ vựng.");
            return "redirect:/admin/vocabulary";
        }
    }

    @PostMapping("/topics/{id}/words")
    public String createWord(
            @PathVariable UUID id,
            @RequestParam String word,
            @RequestParam(required = false, defaultValue = "") String pronunciation,
            @RequestParam(required = false, defaultValue = "") String partOfSpeech,
            @RequestParam(required = false, defaultValue = "") String definitionVi,
            @RequestParam(required = false, defaultValue = "") String definitionEn,
            @RequestParam(required = false, defaultValue = "") String exampleSentence,
            @RequestParam(required = false, defaultValue = "") String exampleTranslation,
            @RequestParam String level,
            @RequestParam(required = false, defaultValue = "") String audioUrl,
            RedirectAttributes ra
    ) {
        CreateVocabularyWordRequest req = new CreateVocabularyWordRequest(
                word,
                blankToNull(pronunciation),
                blankToNull(partOfSpeech),
                blankToNull(definitionVi),
                blankToNull(definitionEn),
                blankToNull(exampleSentence),
                blankToNull(exampleTranslation),
                level,
                blankToNull(audioUrl)
        );
        try {
            adminVocabularyService.createWord(id, req);
            ra.addFlashAttribute("successMessage", "Đã thêm từ vào chủ đề.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể thêm từ."));
        }
        return "redirect:/admin/vocabulary/topics/" + id;
    }

    @PostMapping("/words/{id}/update")
    public String updateWord(
            @PathVariable UUID id,
            @RequestParam String word,
            @RequestParam(required = false, defaultValue = "") String pronunciation,
            @RequestParam(required = false, defaultValue = "") String partOfSpeech,
            @RequestParam(required = false, defaultValue = "") String definitionVi,
            @RequestParam(required = false, defaultValue = "") String definitionEn,
            @RequestParam(required = false, defaultValue = "") String exampleSentence,
            @RequestParam(required = false, defaultValue = "") String exampleTranslation,
            @RequestParam String level,
            @RequestParam(required = false, defaultValue = "") String audioUrl,
            RedirectAttributes ra
    ) {
        UpdateVocabularyWordRequest req = new UpdateVocabularyWordRequest(
                word,
                blankToNull(pronunciation),
                blankToNull(partOfSpeech),
                blankToNull(definitionVi),
                blankToNull(definitionEn),
                blankToNull(exampleSentence),
                blankToNull(exampleTranslation),
                level,
                blankToNull(audioUrl)
        );
        UUID topicId;
        try {
            VocabularyWord updated = adminVocabularyService.updateWord(id, req);
            topicId = updated.getTopic().getId();
            ra.addFlashAttribute("successMessage", "Đã cập nhật từ.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể cập nhật từ."));
            // Cố gắng đưa user về topic detail
            try {
                topicId = adminVocabularyService.getWordOrThrow(id).getTopic().getId();
            } catch (ResponseStatusException ignored) {
                return "redirect:/admin/vocabulary";
            }
        }
        return "redirect:/admin/vocabulary/topics/" + topicId;
    }

    @PostMapping("/words/{id}/delete")
    public String deleteWord(@PathVariable UUID id, RedirectAttributes ra) {
        UUID topicId;
        try {
            topicId = adminVocabularyService.getWordOrThrow(id).getTopic().getId();
            adminVocabularyService.deleteWord(id);
            ra.addFlashAttribute("successMessage", "Đã xóa từ.");
            return "redirect:/admin/vocabulary/topics/" + topicId;
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể xóa từ."));
            return "redirect:/admin/vocabulary";
        }
    }

    // ── Bulk import / export ────────────────────────────────────────────────

    @PostMapping("/topics/{id}/import")
    public String importWords(
            @PathVariable UUID id,
            @RequestParam(required = false, defaultValue = "") String jsonPayload,
            RedirectAttributes ra
    ) {
        try {
            VocabularyImportResult result = adminVocabularyService.importWords(id, jsonPayload);
            StringBuilder msg = new StringBuilder();
            msg.append("Đã import: ").append(result.inserted())
                    .append(" / ").append(result.totalRows())
                    .append(" (bỏ qua ").append(result.skipped()).append(").");
            if (!result.errors().isEmpty()) {
                msg.append(" Một số lỗi: ");
                int limit = Math.min(result.errors().size(), 5);
                for (int i = 0; i < limit; i++) {
                    msg.append(result.errors().get(i)).append(" | ");
                }
                if (result.errors().size() > 5) {
                    msg.append("... (+").append(result.errors().size() - 5).append(" lỗi khác)");
                }
            }
            if (result.inserted() > 0) {
                ra.addFlashAttribute("successMessage", msg.toString());
            } else {
                ra.addFlashAttribute("errorMessage", msg.toString());
            }
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể import."));
        }
        return "redirect:/admin/vocabulary/topics/" + id;
    }

    @GetMapping("/topics/{id}/export")
    public ResponseEntity<byte[]> exportTopic(@PathVariable UUID id) {
        try {
            String csv = adminVocabularyService.exportTopicAsCsv(id);
            byte[] body = csv.getBytes(StandardCharsets.UTF_8);
            // BOM for Excel UTF-8 friendliness
            byte[] bom = new byte[]{(byte) 0xEF, (byte) 0xBB, (byte) 0xBF};
            byte[] out = new byte[bom.length + body.length];
            System.arraycopy(bom, 0, out, 0, bom.length);
            System.arraycopy(body, 0, out, bom.length, body.length);
            return ResponseEntity.ok()
                    .contentType(MediaType.parseMediaType("text/csv; charset=UTF-8"))
                    .header(HttpHeaders.CONTENT_DISPOSITION,
                            "attachment; filename=\"vocabulary-topic-" + id + ".csv\"")
                    .body(out);
        } catch (ResponseStatusException ex) {
            throw ex;
        }
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
