package com.kiovant.englishme.controller;

import com.kiovant.englishme.service.AppConfigService;
import com.kiovant.englishme.service.LlmClient;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Map;

@Controller
@RequestMapping("/admin/config")
public class AdminConfigController {

    private final AppConfigService appConfigService;
    private final LlmClient llmClient;

    public AdminConfigController(AppConfigService appConfigService, LlmClient llmClient) {
        this.appConfigService = appConfigService;
        this.llmClient = llmClient;
    }

    @GetMapping
    public String configPage(Model model) {
        model.addAttribute("configs", appConfigService.findAll());
        return "admin/config";
    }

    @PostMapping
    public String updateConfig(
            @RequestParam String key,
            @RequestParam String value,
            HttpSession session,
            RedirectAttributes ra
    ) {
        try {
            String adminEmail = (String) session.getAttribute("ADMIN_EMAIL");
            appConfigService.setValue(key, value, adminEmail);
            ra.addFlashAttribute("successMessage", "Đã cập nhật cấu hình.");
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/admin/config";
    }

    /**
     * Test kết nối LLM. Nhận giá trị admin đang nhập (chưa cần lưu): nếu để trống
     * thì dùng giá trị đã lưu trong DB. Trả JSON {success, message} cho JS hiển thị.
     */
    @PostMapping("/test-llm")
    @ResponseBody
    public Map<String, Object> testLlm(
            @RequestParam(required = false) String baseUrl,
            @RequestParam(required = false) String apiKey,
            @RequestParam(required = false) String model
    ) {
        String b = blankToSaved(baseUrl, LlmClient.KEY_BASE_URL);
        String k = blankToSaved(apiKey, LlmClient.KEY_API_KEY);
        String m = blankToSaved(model, LlmClient.KEY_MODEL);

        LlmClient.TestResult result = llmClient.testConnection(b, k, m);
        return Map.of("success", result.success(), "message", result.message());
    }

    /** Giá trị nhập rỗng -> lấy giá trị đã lưu trong app_config. */
    private String blankToSaved(String input, String key) {
        if (input != null && !input.isBlank()) {
            return input.trim();
        }
        return appConfigService.getValue(key);
    }
}
