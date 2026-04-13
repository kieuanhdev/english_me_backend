package vn.id.kieuanhdev.englishme.controller.admin;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/admin")
public class AdminViewController {

	@GetMapping({ "", "/" })
	public String index() {
		return "redirect:/admin/login";
	}

	@GetMapping("/login")
	public String login() {
		return "admin/login";
	}

	@GetMapping("/dashboard")
	public String dashboard() {
		return "admin/dashboard";
	}

	@GetMapping("/vocabularies")
	public String vocabularies() {
		return "admin/vocabularies";
	}

	@GetMapping("/decks")
	public String decks() {
		return "admin/decks";
	}

	@GetMapping("/questions")
	public String questions() {
		return "admin/questions";
	}
}
