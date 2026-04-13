package vn.id.kieuanhdev.englishme.controller.admin;

import jakarta.validation.Valid;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import vn.id.kieuanhdev.englishme.dto.admin.vocabulary.VocabularyAdminResponse;
import vn.id.kieuanhdev.englishme.dto.admin.vocabulary.VocabularyCreateRequest;
import vn.id.kieuanhdev.englishme.dto.admin.vocabulary.VocabularyImportResponse;
import vn.id.kieuanhdev.englishme.dto.admin.vocabulary.VocabularyUpdateRequest;
import vn.id.kieuanhdev.englishme.service.admin.AdminVocabularyService;

@RestController
@RequestMapping("/api/admin/vocabularies")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminVocabularyController {
	private final AdminVocabularyService adminVocabularyService;

	@GetMapping
	public Page<VocabularyAdminResponse> list(
		@RequestParam(required = false) String q,
		@RequestParam(defaultValue = "false") boolean includeDeleted,
		@PageableDefault(size = 20, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable
	) {
		return adminVocabularyService.list(q, includeDeleted, pageable);
	}

	@GetMapping("/{id}")
	public VocabularyAdminResponse get(
		@PathVariable UUID id,
		@RequestParam(defaultValue = "false") boolean includeDeleted
	) {
		return adminVocabularyService.getById(id, includeDeleted);
	}

	@PostMapping
	@ResponseStatus(HttpStatus.CREATED)
	public VocabularyAdminResponse create(@Valid @RequestBody VocabularyCreateRequest request) {
		return adminVocabularyService.create(request);
	}

	@PatchMapping("/{id}")
	public VocabularyAdminResponse update(@PathVariable UUID id, @Valid @RequestBody VocabularyUpdateRequest request) {
		return adminVocabularyService.update(id, request);
	}

	@DeleteMapping("/{id}")
	public ResponseEntity<Void> softDelete(@PathVariable UUID id) {
		adminVocabularyService.softDelete(id);
		return ResponseEntity.noContent().build();
	}

	@PostMapping(value = "/import", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
	@ResponseStatus(HttpStatus.OK)
	public VocabularyImportResponse importFile(@RequestPart("file") MultipartFile file) {
		return adminVocabularyService.importFile(file);
	}
}
