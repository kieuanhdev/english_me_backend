package com.kiovant.englishme.controller;

import com.kiovant.englishme.dto.CreateDeskRequest;
import com.kiovant.englishme.dto.CreateFlashcardRequest;
import com.kiovant.englishme.entity.Desk;
import com.kiovant.englishme.service.DeskFlashcardService;
import com.kiovant.englishme.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.UUID;

@Controller
@RequestMapping("/admin")
public class AdminViewController {

    @Autowired
    private UserService userService;

    @Autowired
    private DeskFlashcardService deskFlashcardService;

    @GetMapping
    public String dashboard() {
        return "admin/dashboard";
    }

    @GetMapping("/desks")
    public String desks(Model model) {
        model.addAttribute("desks", deskFlashcardService.listDesks());
        return "admin/desks";
    }

    @PostMapping("/desks")
    public String createDesk(
            @RequestParam String cefrLevel,
            @RequestParam(required = false, defaultValue = "") String title,
            @RequestParam(required = false, defaultValue = "") String sortOrderRaw,
            RedirectAttributes ra
    ) {
        Integer sortOrder = null;
        if (sortOrderRaw != null && !sortOrderRaw.isBlank()) {
            try {
                sortOrder = Integer.parseInt(sortOrderRaw.trim());
            } catch (NumberFormatException ex) {
                ra.addFlashAttribute("errorMessage", "Thứ tự hiển thị phải là số nguyên.");
                return "redirect:/admin/desks";
            }
        }
        CreateDeskRequest req = new CreateDeskRequest();
        req.setCefrLevel(cefrLevel);
        req.setTitle(title.isBlank() ? null : title);
        req.setSortOrder(sortOrder);
        try {
            deskFlashcardService.createDesk(req);
            ra.addFlashAttribute("successMessage", "Đã tạo desk thành công.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", adminMessageFor(ex, "Không thể tạo desk."));
        }
        return "redirect:/admin/desks";
    }

    @GetMapping("/desks/{id}")
    public String deskDetail(
            @PathVariable UUID id,
            @RequestParam(required = false, defaultValue = "0") int page,
            Model model,
            RedirectAttributes ra
    ) {
        try {
            Desk desk = deskFlashcardService.getDeskOrThrow(id);
            model.addAttribute("desk", desk);
            model.addAttribute("flashcardsPage", deskFlashcardService.listFlashcardsPage(id, page, 40));
            model.addAttribute("currentPage", page);
            return "admin/desk-detail";
        } catch (ResponseStatusException ex) {
            if (ex.getStatusCode().equals(HttpStatus.NOT_FOUND)) {
                ra.addFlashAttribute("errorMessage", "Không tìm thấy desk.");
                return "redirect:/admin/desks";
            }
            throw ex;
        }
    }

    @PostMapping("/desks/{id}/flashcards")
    public String createFlashcardAdmin(
            @PathVariable UUID id,
            @RequestParam String word,
            @RequestParam String cefr,
            @RequestParam(required = false, defaultValue = "") String ipa,
            @RequestParam(required = false, defaultValue = "") String audioUrl,
            @RequestParam(required = false, defaultValue = "") String definition,
            @RequestParam(required = false, defaultValue = "") String example,
            @RequestParam(required = false, defaultValue = "") String topic,
            @RequestParam(required = false, defaultValue = "") String vietnamese,
            @RequestParam(required = false, defaultValue = "") String viDefinition,
            @RequestParam(required = false, defaultValue = "") String viExample,
            RedirectAttributes ra
    ) {
        CreateFlashcardRequest req = new CreateFlashcardRequest();
        req.setWord(word);
        req.setCefr(cefr);
        req.setIpa(blankToNull(ipa));
        req.setAudioUrl(blankToNull(audioUrl));
        req.setDefinition(blankToNull(definition));
        req.setExample(blankToNull(example));
        req.setTopic(blankToNull(topic));
        req.setVietnamese(blankToNull(vietnamese));
        req.setViDefinition(blankToNull(viDefinition));
        req.setViExample(blankToNull(viExample));
        try {
            deskFlashcardService.createFlashcard(id, req);
            ra.addFlashAttribute("successMessage", "Đã thêm flashcard.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", adminMessageFor(ex, "Không thể thêm flashcard."));
        }
        return "redirect:/admin/desks/" + id;
    }

    private static String blankToNull(String s) {
        return s == null || s.isBlank() ? null : s.trim();
    }

    private static String adminMessageFor(ResponseStatusException ex, String fallback) {
        if (ex.getStatusCode().equals(HttpStatus.CONFLICT)) {
            String r = ex.getReason();
            if (r != null && r.contains("Flashcard")) {
                return "Từ này đã có trong desk.";
            }
            if (r != null && r.contains("Desk")) {
                return "Đã có desk cho mức CEFR này.";
            }
            return r != null ? r : fallback;
        }
        if (ex.getStatusCode().equals(HttpStatus.BAD_REQUEST) && ex.getReason() != null) {
            return ex.getReason();
        }
        return ex.getReason() != null ? ex.getReason() : fallback;
    }

    @GetMapping("/users")
    public String users(
            @RequestParam(required = false, defaultValue = "") String cefr,
            @RequestParam(required = false, defaultValue = "all") String status,
            @RequestParam(required = false, defaultValue = "") String q,
            Model model
    ) {
        model.addAttribute("users", userService.findUsersByFilter(cefr, status, q));
        model.addAttribute("selectedCefr", cefr);
        model.addAttribute("selectedStatus", status);
        model.addAttribute("selectedKeyword", q);
        return "admin/users";
    }

    @PostMapping("/users/{id}/unlock")
    public String unlockUser(
            @PathVariable UUID id,
            @RequestParam(required = false, defaultValue = "") String cefr,
            @RequestParam(required = false, defaultValue = "all") String status,
            @RequestParam(required = false, defaultValue = "") String q
    ) {
        userService.unlockUser(id);
        return redirectToUsers(cefr, status, q);
    }

    @PostMapping("/users/{id}/lock")
    public String lockUser(
            @PathVariable UUID id,
            @RequestParam(required = false, defaultValue = "") String cefr,
            @RequestParam(required = false, defaultValue = "all") String status,
            @RequestParam(required = false, defaultValue = "") String q
    ) {
        userService.lockUser(id);
        return redirectToUsers(cefr, status, q);
    }

    private static String redirectToUsers(String cefr, String status, String q) {
        String target = UriComponentsBuilder.fromPath("/admin/users")
                .queryParam("cefr", cefr == null ? "" : cefr)
                .queryParam("status", status == null ? "all" : status)
                .queryParam("q", q == null ? "" : q)
                .build()
                .encode()
                .toUriString();
        return "redirect:" + target;
    }

}
