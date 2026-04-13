package vn.id.kieuanhdev.englishme.controller.admin;

import jakarta.validation.Valid;
import java.nio.charset.StandardCharsets;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import vn.id.kieuanhdev.englishme.dto.admin.question.AdminQuestionRequest;
import vn.id.kieuanhdev.englishme.dto.admin.question.AdminQuestionResponse;
import vn.id.kieuanhdev.englishme.dto.admin.question.QuestionBankWarningResponse;
import vn.id.kieuanhdev.englishme.security.WebAuth;
import vn.id.kieuanhdev.englishme.service.admin.AdminQuestionService;

@RestController
@RequestMapping("/api/admin/questions")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminQuestionController {
	private final AdminQuestionService adminQuestionService;

	@GetMapping
	public Page<AdminQuestionResponse> list(
		@RequestParam(required = false) String cefr,
		@RequestParam(required = false) String skill,
		@RequestParam(defaultValue = "false") boolean includeDeleted,
		@PageableDefault(size = 20, sort = "updatedAt", direction = Sort.Direction.DESC) Pageable pageable
	) {
		return adminQuestionService.list(cefr, skill, includeDeleted, pageable);
	}

	@GetMapping("/{id}")
	public AdminQuestionResponse getById(@PathVariable UUID id) {
		return adminQuestionService.getById(id);
	}

	@PostMapping
	@ResponseStatus(HttpStatus.CREATED)
	public AdminQuestionResponse create(Authentication authentication, @Valid @RequestBody AdminQuestionRequest req) {
		var userId = WebAuth.requireUserId(authentication);
		return adminQuestionService.create(userId, req);
	}

	@PutMapping("/{id}")
	public AdminQuestionResponse update(@PathVariable UUID id, @Valid @RequestBody AdminQuestionRequest req) {
		return adminQuestionService.update(id, req);
	}

	@DeleteMapping("/{id}")
	public ResponseEntity<?> delete(@PathVariable UUID id) {
		var body = adminQuestionService.delete(id);
		return ResponseEntity.ok(body == null ? java.util.Map.of("deleted", true, "mode", "HARD") : java.util.Map.of("deleted", true, "mode", "SOFT", "question", body));
	}

	@GetMapping("/warnings")
	public QuestionBankWarningResponse warnings() {
		return adminQuestionService.warning();
	}

	@GetMapping(value = "/export", produces = "text/csv")
	public ResponseEntity<String> export(
		@RequestParam(defaultValue = "false") boolean includeDeleted
	) {
		var csv = adminQuestionService.exportCsv(includeDeleted);
		return ResponseEntity.ok()
			.contentType(new MediaType("text", "csv", StandardCharsets.UTF_8))
			.header(HttpHeaders.CONTENT_DISPOSITION, ContentDisposition.attachment().filename("cefr_questions.csv").build().toString())
			.body(csv);
	}
}
