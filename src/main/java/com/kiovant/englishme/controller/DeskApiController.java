package com.kiovant.englishme.controller;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import com.kiovant.englishme.dto.CreateDeskRequest;
import com.kiovant.englishme.dto.CreateFlashcardRequest;
import com.kiovant.englishme.dto.DeskResponse;
import com.kiovant.englishme.dto.FlashcardResponse;
import com.kiovant.englishme.dto.UpdateDeskRequest;
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

    /** Danh sách desk của user đã đăng nhập */
    @GetMapping
    public List<DeskResponse> listDesks(
            @RequestHeader(value = "Authorization", required = false) String authorization
    ) throws Exception {
        FirebaseToken token = verifyBearer(authorization);
        return deskFlashcardService.listDesks(token.getUid());
    }

    /**
     * Danh sách flashcard trong desk của chính user (phân trang).
     * Phản hồi là Spring {@link Page}: {@code content}, {@code totalElements}, {@code totalPages}, {@code number}, {@code size}, ...
     */
    @GetMapping("/{deskId}/flashcards")
    public Page<FlashcardResponse> listFlashcards(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @PathVariable UUID deskId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) throws Exception {
        FirebaseToken token = verifyBearer(authorization);
        int safeSize = Math.min(Math.max(size, 1), 100);
        int safePage = Math.max(page, 0);
        return deskFlashcardService.listFlashcardsPage(token.getUid(), deskId, safePage, safeSize);
    }

    /** Tạo desk mới — yêu cầu Bearer Firebase */
    @PostMapping
    public ResponseEntity<DeskResponse> createDesk(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestBody CreateDeskRequest body
    ) throws Exception {
        FirebaseToken token = verifyBearer(authorization);
        DeskResponse created = deskFlashcardService.createDesk(token.getUid(), body);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    /** Sửa desk của chính user */
    @PutMapping("/{deskId}")
    public DeskResponse updateDesk(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @PathVariable UUID deskId,
            @RequestBody UpdateDeskRequest body
    ) throws Exception {
        FirebaseToken token = verifyBearer(authorization);
        return deskFlashcardService.updateDesk(token.getUid(), deskId, body);
    }

    /** Xóa desk của chính user */
    @DeleteMapping("/{deskId}")
    public ResponseEntity<Void> deleteDesk(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @PathVariable UUID deskId
    ) throws Exception {
        FirebaseToken token = verifyBearer(authorization);
        deskFlashcardService.deleteDesk(token.getUid(), deskId);
        return ResponseEntity.noContent().build();
    }

    /** Thêm flashcard vào desk — yêu cầu Bearer Firebase */
    @PostMapping("/{deskId}/flashcards")
    public ResponseEntity<FlashcardResponse> createFlashcard(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @PathVariable UUID deskId,
            @RequestBody CreateFlashcardRequest body
    ) throws Exception {
        FirebaseToken token = verifyBearer(authorization);
        FlashcardResponse created = deskFlashcardService.createFlashcard(token.getUid(), deskId, body);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    private static FirebaseToken verifyBearer(String authorization) throws Exception {
        if (authorization == null || !authorization.startsWith("Bearer ")) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Authorization Bearer token required");
        }
        String idToken = authorization.substring(7).trim();
        if (idToken.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing token");
        }
        try {
            return FirebaseAuth.getInstance().verifyIdToken(idToken);
        } catch (FirebaseAuthException ex) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid token");
        }
    }
}
