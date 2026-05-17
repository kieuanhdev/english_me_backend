package com.kiovant.englishme.controller;

import com.kiovant.englishme.dto.CreateDeskRequest;
import com.kiovant.englishme.dto.CreateFlashcardRequest;
import com.kiovant.englishme.dto.AdminPronunciationAttemptRow;
import com.kiovant.englishme.dto.DashboardStats;
import com.kiovant.englishme.entity.Desk;
import com.kiovant.englishme.repository.DeskRepository;
import com.kiovant.englishme.repository.FlashcardRepository;
import com.kiovant.englishme.repository.PronunciationAttemptRepository;
import com.kiovant.englishme.repository.TestAnswerRepository;
import com.kiovant.englishme.repository.TestSessionRepository;
import com.kiovant.englishme.repository.UserRepository;
import com.kiovant.englishme.service.DeskFlashcardService;
import com.kiovant.englishme.service.GrammarService;
import com.kiovant.englishme.service.PronunciationAssessmentService;
import com.kiovant.englishme.service.UserService;
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
import org.springframework.data.domain.Page;

import java.time.LocalDate;
import java.util.UUID;

@Controller
@RequestMapping("/admin")
public class AdminViewController {

    private final UserService userService;
    private final DeskFlashcardService deskFlashcardService;
    private final PronunciationAssessmentService pronunciationAssessmentService;
    private final GrammarService grammarService;
    private final UserRepository userRepository;
    private final DeskRepository deskRepository;
    private final FlashcardRepository flashcardRepository;
    private final PronunciationAttemptRepository pronunciationAttemptRepository;
    private final TestSessionRepository testSessionRepository;
    private final TestAnswerRepository testAnswerRepository;

    public AdminViewController(
            UserService userService,
            DeskFlashcardService deskFlashcardService,
            PronunciationAssessmentService pronunciationAssessmentService,
            GrammarService grammarService,
            UserRepository userRepository,
            DeskRepository deskRepository,
            FlashcardRepository flashcardRepository,
            PronunciationAttemptRepository pronunciationAttemptRepository,
            TestSessionRepository testSessionRepository,
            TestAnswerRepository testAnswerRepository
    ) {
        this.userService = userService;
        this.deskFlashcardService = deskFlashcardService;
        this.pronunciationAssessmentService = pronunciationAssessmentService;
        this.grammarService = grammarService;
        this.userRepository = userRepository;
        this.deskRepository = deskRepository;
        this.flashcardRepository = flashcardRepository;
        this.pronunciationAttemptRepository = pronunciationAttemptRepository;
        this.testSessionRepository = testSessionRepository;
        this.testAnswerRepository = testAnswerRepository;
    }

    @GetMapping
    public String dashboard(Model model) {
        var todayStart = LocalDate.now().atStartOfDay();
        long totalUsers = userRepository.count();
        long newUsersToday = userRepository.countCreatedSince(todayStart);
        long activeToday = pronunciationAttemptRepository.countSince(todayStart);
        long totalDesks = deskRepository.count();
        long totalFlashcards = flashcardRepository.count();
        long totalPronunciationAttempts = pronunciationAttemptRepository.count();
        model.addAttribute("stats", new DashboardStats(
                totalUsers, activeToday, newUsersToday, totalDesks, totalFlashcards, totalPronunciationAttempts
        ));
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
        CreateDeskRequest req = new CreateDeskRequest(
                cefrLevel,
                title.isBlank() ? null : title,
                sortOrder
        );
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
        CreateFlashcardRequest req = new CreateFlashcardRequest(
                word, cefr, null, null,
                blankToNull(ipa), blankToNull(audioUrl),
                blankToNull(definition), blankToNull(example),
                blankToNull(topic), blankToNull(vietnamese),
                blankToNull(viDefinition), blankToNull(viExample)
        );
        try {
            deskFlashcardService.createFlashcard(id, req);
            ra.addFlashAttribute("successMessage", "Đã thêm flashcard.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", adminMessageFor(ex, "Không thể thêm flashcard."));
        }
        return "redirect:/admin/desks/" + id;
    }

    @PostMapping("/desks/{deskId}/flashcards/{flashcardId}/delete")
    public String deleteFlashcardAdmin(
            @PathVariable UUID deskId,
            @PathVariable UUID flashcardId,
            RedirectAttributes ra
    ) {
        try {
            deskFlashcardService.deleteFlashcard(deskId, flashcardId);
            ra.addFlashAttribute("successMessage", "Đã xóa flashcard.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", adminMessageFor(ex, "Không thể xóa flashcard."));
        }
        return "redirect:/admin/desks/" + deskId;
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

    @GetMapping("/pronunciation")
    public String pronunciationAttempts(
            @RequestParam(required = false, defaultValue = "") String provider,
            @RequestParam(required = false, defaultValue = "0") int minScore,
            @RequestParam(required = false, defaultValue = "") String q,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "20") int size,
            Model model
    ) {
        Page<AdminPronunciationAttemptRow> attempts = pronunciationAssessmentService.adminList(provider, minScore, q, page, size);
        model.addAttribute("attemptsPage", attempts);
        model.addAttribute("selectedProvider", provider == null ? "" : provider);
        model.addAttribute("selectedMinScore", Math.min(Math.max(minScore, 0), 100));
        model.addAttribute("selectedKeyword", q == null ? "" : q);
        model.addAttribute("currentPage", Math.max(page, 0));
        model.addAttribute("pageSize", Math.min(Math.max(size, 1), 100));
        return "admin/pronunciation";
    }

    @GetMapping("/grammar")
    public String grammarTopics(Model model) {
        model.addAttribute("topics", grammarService.getTopics());
        return "admin/grammar";
    }

    @GetMapping("/grammar/topics/{id}")
    public String grammarLessons(@PathVariable String id, Model model, RedirectAttributes ra) {
        try {
            model.addAttribute("lessons", grammarService.getLessonsByTopicId(id));
            model.addAttribute("topicId", id);
            return "admin/grammar-lessons";
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", "Không tìm thấy chủ đề ngữ pháp.");
            return "redirect:/admin/grammar";
        }
    }

    @GetMapping("/grammar/lessons/{id}")
    public String grammarLessonDetail(@PathVariable String id, Model model, RedirectAttributes ra) {
        try {
            model.addAttribute("lesson", grammarService.getLessonDetail(id));
            return "admin/grammar-lesson-detail";
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", "Không tìm thấy bài học.");
            return "redirect:/admin/grammar";
        }
    }

    @GetMapping("/placement-test")
    public String placementTestSessions(
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "20") int size,
            Model model
    ) {
        int safePage = Math.max(page, 0);
        int safeSize = Math.min(Math.max(size, 1), 100);
        model.addAttribute("sessionsPage", testSessionRepository.findAllWithUser(
                org.springframework.data.domain.PageRequest.of(safePage, safeSize)));
        model.addAttribute("currentPage", safePage);
        model.addAttribute("pageSize", safeSize);
        return "admin/placement-test";
    }

    @GetMapping("/placement-test/{id}")
    public String placementTestDetail(@PathVariable UUID id, Model model, RedirectAttributes ra) {
        var session = testSessionRepository.findByIdWithUser(id);
        if (session.isEmpty()) {
            ra.addFlashAttribute("errorMessage", "Không tìm thấy phiên kiểm tra.");
            return "redirect:/admin/placement-test";
        }
        model.addAttribute("session", session.get());
        model.addAttribute("answers", testAnswerRepository.findByTestSession(session.get()));
        return "admin/placement-test-detail";
    }

}
