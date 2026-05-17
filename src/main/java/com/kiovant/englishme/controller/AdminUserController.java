package com.kiovant.englishme.controller;

import com.kiovant.englishme.dto.UserDetailDto;
import com.kiovant.englishme.service.AdminUserService;
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
import java.util.List;
import java.util.UUID;

@Controller
@RequestMapping("/admin/users")
public class AdminUserController {

    private final AdminUserService adminUserService;

    public AdminUserController(AdminUserService adminUserService) {
        this.adminUserService = adminUserService;
    }

    // ── Detail page ─────────────────────────────────────────────────────────

    @GetMapping("/{id}")
    public String detail(@PathVariable UUID id, Model model, RedirectAttributes ra) {
        try {
            UserDetailDto detail = adminUserService.getDetail(id);
            model.addAttribute("detail", detail);
            return "admin/user-detail";
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không tìm thấy người dùng."));
            return "redirect:/admin/users";
        }
    }

    // ── Subpages (cùng dữ liệu detail, hiển thị section khác nhau) ──────────

    @GetMapping("/{id}/activity")
    public String activity(@PathVariable UUID id, Model model, RedirectAttributes ra) {
        return detail(id, model, ra);
    }

    @GetMapping("/{id}/sessions")
    public String sessions(@PathVariable UUID id, Model model, RedirectAttributes ra) {
        return detail(id, model, ra);
    }

    @GetMapping("/{id}/xp-history")
    public String xpHistory(@PathVariable UUID id, Model model, RedirectAttributes ra) {
        return detail(id, model, ra);
    }

    @GetMapping("/{id}/desks")
    public String desks(@PathVariable UUID id, Model model, RedirectAttributes ra) {
        return detail(id, model, ra);
    }

    // ── Mutations ───────────────────────────────────────────────────────────

    @PostMapping("/{id}/delete")
    public String softDelete(@PathVariable UUID id, RedirectAttributes ra) {
        try {
            adminUserService.softDelete(id);
            ra.addFlashAttribute("successMessage", "Đã soft-delete tài khoản (deleted_at đã set).");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể xóa user."));
        }
        return "redirect:/admin/users";
    }

    // ── Export CSV ──────────────────────────────────────────────────────────

    @GetMapping("/export")
    public ResponseEntity<byte[]> export(
            @RequestParam(required = false, defaultValue = "") String cefr,
            @RequestParam(required = false, defaultValue = "all") String status,
            @RequestParam(required = false, defaultValue = "") String q
    ) {
        String csv = adminUserService.exportUsersAsCsv(cefr, status, q);
        byte[] body = csv.getBytes(StandardCharsets.UTF_8);
        byte[] bom = new byte[]{(byte) 0xEF, (byte) 0xBB, (byte) 0xBF};
        byte[] out = new byte[bom.length + body.length];
        System.arraycopy(bom, 0, out, 0, bom.length);
        System.arraycopy(body, 0, out, bom.length, body.length);
        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType("text/csv; charset=UTF-8"))
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"users.csv\"")
                .body(out);
    }

    private static String reasonOr(ResponseStatusException ex, String fallback) {
        return ex.getReason() == null ? fallback : ex.getReason();
    }
}
