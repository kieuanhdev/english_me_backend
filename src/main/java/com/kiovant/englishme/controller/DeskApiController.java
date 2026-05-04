package com.kiovant.englishme.controller;

import com.google.firebase.auth.FirebaseAuth;
import com.kiovant.englishme.dto.CreateDeskRequest;
import com.kiovant.englishme.dto.CreateFlashcardRequest;
import com.kiovant.englishme.dto.DeskResponse;
import com.kiovant.englishme.dto.FlashcardResponse;
import com.kiovant.englishme.service.DeskFlashcardService;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/desks")
public class DeskApiController {

    private final DeskFlashcardService deskFlashcardService;

    public DeskApiController(DeskFlashcardService deskFlashcardService) {
        this.deskFlashcardService = deskFlashcardService;
    }

    /** Danh sách desk CEFR + số lượng flashcard */
    @GetMapping
    public List<DeskResponse> listDesks() {
        return deskFlashcardService.listDesks();
    }

    /**
     * Danh sách flashcard trong một desk (phân trang). Không cần token — dùng cho màn học / browse.
     * Phản hồi là Spring {@link Page}: {@code content}, {@code totalElements}, {@code totalPages}, {@code number}, {@code size}, ...
     */
    @GetMapping("/{deskId}/flashcards")
    public Page<FlashcardResponse> listFlashcards(
            @PathVariable UUID deskId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        int safeSize = Math.min(Math.max(size, 1), 100);
        int safePage = Math.max(page, 0);
        return deskFlashcardService.listFlashcardsPage(deskId, safePage, safeSize);
    }

    /** Tạo desk mới — yêu cầu Bearer Firebase */
    @PostMapping
    public ResponseEntity<DeskResponse> createDesk(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestBody CreateDeskRequest body
    ) throws Exception {
        verifyBearer(authorization);
        DeskResponse created = deskFlashcardService.createDesk(body);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    /** Thêm flashcard vào desk — yêu cầu Bearer Firebase */
    @PostMapping("/{deskId}/flashcards")
    public ResponseEntity<FlashcardResponse> createFlashcard(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @PathVariable UUID deskId,
            @RequestBody CreateFlashcardRequest body
    ) throws Exception {
        verifyBearer(authorization);
        FlashcardResponse created = deskFlashcardService.createFlashcard(deskId, body);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    private static void verifyBearer(String authorization) throws Exception {
        if (authorization == null || !authorization.startsWith("Bearer ")) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Authorization Bearer token required");
        }
        String idToken = authorization.substring(7).trim();
        if (idToken.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing token");
        }
        FirebaseAuth.getInstance().verifyIdToken(idToken);
    }
}
