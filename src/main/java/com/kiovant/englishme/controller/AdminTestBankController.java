package com.kiovant.englishme.controller;

import com.kiovant.englishme.dto.CreateTestBankQuestionRequest;
import com.kiovant.englishme.dto.TestBankImportResult;
import com.kiovant.englishme.dto.UpdateTestBankQuestionRequest;
import com.kiovant.englishme.service.AdminTestBankService;
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
@RequestMapping("/admin/test-bank")
public class AdminTestBankController {

    private final AdminTestBankService adminTestBankService;

    public AdminTestBankController(AdminTestBankService adminTestBankService) {
        this.adminTestBankService = adminTestBankService;
    }

    // ── List + filter ───────────────────────────────────────────────────────

    @GetMapping
    public String list(
            @RequestParam(required = false, defaultValue = "") String level,
            @RequestParam(required = false, defaultValue = "") String skill,
            @RequestParam(required = false, defaultValue = "") String q,
            Model model
    ) {
        model.addAttribute("questions", adminTestBankService.listQuestions(level, skill, q));
        model.addAttribute("selectedLevel", level);
        model.addAttribute("selectedSkill", skill);
        model.addAttribute("selectedKeyword", q);
        return "admin/test-bank";
    }

    // ── CRUD ────────────────────────────────────────────────────────────────

    @PostMapping
    public String create(
            @RequestParam String cefrLevel,
            @RequestParam String skillCategory,
            @RequestParam String question,
            @RequestParam String optionsJson,
            @RequestParam String correctAnswer,
            @RequestParam(required = false, defaultValue = "") String explanation,
            @RequestParam(required = false, defaultValue = "") String audioUrl,
            @RequestParam(required = false, defaultValue = "") String passage,
            RedirectAttributes ra
    ) {
        try {
            adminTestBankService.createQuestion(new CreateTestBankQuestionRequest(
                    cefrLevel, skillCategory, question, optionsJson, correctAnswer,
                    blankToNull(explanation), blankToNull(audioUrl), blankToNull(passage)));
            ra.addFlashAttribute("successMessage", "Đã tạo câu hỏi test bank.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể tạo câu hỏi."));
        }
        return "redirect:/admin/test-bank";
    }

    @PostMapping("/{id}/update")
    public String update(
            @PathVariable UUID id,
            @RequestParam String cefrLevel,
            @RequestParam String skillCategory,
            @RequestParam String question,
            @RequestParam String optionsJson,
            @RequestParam String correctAnswer,
            @RequestParam(required = false, defaultValue = "") String explanation,
            @RequestParam(required = false, defaultValue = "") String audioUrl,
            @RequestParam(required = false, defaultValue = "") String passage,
            RedirectAttributes ra
    ) {
        try {
            adminTestBankService.updateQuestion(id, new UpdateTestBankQuestionRequest(
                    cefrLevel, skillCategory, question, optionsJson, correctAnswer,
                    blankToNull(explanation), blankToNull(audioUrl), blankToNull(passage)));
            ra.addFlashAttribute("successMessage", "Đã cập nhật câu hỏi.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể cập nhật câu hỏi."));
        }
        return "redirect:/admin/test-bank";
    }

    @PostMapping("/{id}/delete")
    public String delete(@PathVariable UUID id, RedirectAttributes ra) {
        try {
            adminTestBankService.deleteQuestion(id);
            ra.addFlashAttribute("successMessage", "Đã xóa câu hỏi.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể xóa câu hỏi."));
        }
        return "redirect:/admin/test-bank";
    }

    // ── Bulk import / export ────────────────────────────────────────────────

    @PostMapping("/import")
    public String importQuestions(
            @RequestParam(required = false, defaultValue = "") String jsonPayload,
            RedirectAttributes ra
    ) {
        try {
            TestBankImportResult result = adminTestBankService.importQuestions(jsonPayload);
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
        return "redirect:/admin/test-bank";
    }

    @GetMapping("/export")
    public ResponseEntity<byte[]> export(
            @RequestParam(required = false, defaultValue = "") String level,
            @RequestParam(required = false, defaultValue = "") String skill,
            @RequestParam(required = false, defaultValue = "") String q
    ) {
        String csv = adminTestBankService.exportQuestionsAsCsv(level, skill, q);
        byte[] body = csv.getBytes(StandardCharsets.UTF_8);
        byte[] bom = new byte[]{(byte) 0xEF, (byte) 0xBB, (byte) 0xBF};
        byte[] out = new byte[bom.length + body.length];
        System.arraycopy(bom, 0, out, 0, bom.length);
        System.arraycopy(body, 0, out, bom.length, body.length);
        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType("text/csv; charset=UTF-8"))
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"test-bank.csv\"")
                .body(out);
    }

    // ── Stats ──────────────────────────────────────────────────────────────

    @GetMapping("/stats")
    public String stats(Model model) {
        model.addAttribute("stats", adminTestBankService.getStats());
        return "admin/test-bank-stats";
    }

    // ── Helpers ─────────────────────────────────────────────────────────────

    private static String blankToNull(String s) {
        return s == null || s.isBlank() ? null : s.trim();
    }

    private static String reasonOr(ResponseStatusException ex, String fallback) {
        return ex.getReason() == null ? fallback : ex.getReason();
    }
}
