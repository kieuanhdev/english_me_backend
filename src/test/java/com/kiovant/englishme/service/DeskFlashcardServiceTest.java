package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.CreateDeskRequest;
import com.kiovant.englishme.dto.CreateFlashcardRequest;
import com.kiovant.englishme.dto.FlashcardResponse;
import com.kiovant.englishme.entity.Desk;
import com.kiovant.englishme.entity.Flashcard;
import com.kiovant.englishme.entity.User;
import com.kiovant.englishme.repository.DeskRepository;
import com.kiovant.englishme.repository.FlashcardRepository;
import com.kiovant.englishme.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * Unit test cho DeskFlashcardService — hàng rào ownership (chống IDOR) +
 * ràng buộc nghiệp vụ: trùng từ trong desk = 409, desk hệ thống trùng
 * CEFR+title = 409, desk cá nhân được phép nhiều bộ cùng CEFR (V45).
 */
class DeskFlashcardServiceTest {

    private static final String UID = "uid-1";

    private DeskRepository deskRepository;
    private FlashcardRepository flashcardRepository;
    private UserRepository userRepository;
    private DeskFlashcardService service;

    private User owner;
    private Desk ownDesk;

    @BeforeEach
    void setUp() {
        deskRepository = mock(DeskRepository.class);
        flashcardRepository = mock(FlashcardRepository.class);
        userRepository = mock(UserRepository.class);
        service = new DeskFlashcardService(deskRepository, flashcardRepository, userRepository);

        owner = new User();
        owner.setId(UUID.randomUUID());
        owner.setFirebaseUid(UID);

        ownDesk = new Desk();
        ownDesk.setId(UUID.randomUUID());
        ownDesk.setOwner(owner);
        ownDesk.setCefrLevel("A1");
        ownDesk.setTitle("My desk");

        when(userRepository.findByFirebaseUid(UID)).thenReturn(Optional.of(owner));
        when(deskRepository.findByIdAndOwner_Id(ownDesk.getId(), owner.getId()))
                .thenReturn(Optional.of(ownDesk));
        when(deskRepository.save(any(Desk.class))).thenAnswer(inv -> {
            Desk d = inv.getArgument(0);
            if (d.getId() == null) d.setId(UUID.randomUUID());
            return d;
        });
        when(flashcardRepository.save(any(Flashcard.class))).thenAnswer(inv -> {
            Flashcard fc = inv.getArgument(0);
            if (fc.getId() == null) fc.setId(UUID.randomUUID());
            return fc;
        });
        when(flashcardRepository.countByDeskIdsAsMap(any(Set.class))).thenReturn(Map.of());
    }

    private CreateFlashcardRequest cardReq(String word) {
        return new CreateFlashcardRequest(word, "A1", null, null,
                null, null, null, null, null, null, null, null);
    }

    // ── Ownership (chống IDOR) ────────────────────────────────────────────

    @Test
    @DisplayName("getDeskOrThrow(id, ownerId): desk của user khác -> 404, không lộ tồn tại")
    void getDeskRejectsNonOwner() {
        UUID otherUsersDeskId = UUID.randomUUID();
        when(deskRepository.findByIdAndOwner_Id(otherUsersDeskId, owner.getId()))
                .thenReturn(Optional.empty()); // query theo (id, owner) -> user khác không thấy

        ResponseStatusException ex = assertThrows(ResponseStatusException.class,
                () -> service.getDeskOrThrow(otherUsersDeskId, owner.getId()));
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    @Test
    @DisplayName("createFlashcard vào desk hệ thống (overload có uid) -> 404 (chỉ ghi desk của mình)")
    void createFlashcardIntoSystemDeskRejected() {
        UUID systemDeskId = UUID.randomUUID();
        when(deskRepository.findByIdAndOwner_Id(systemDeskId, owner.getId()))
                .thenReturn(Optional.empty()); // desk hệ thống owner=null -> không match owner query

        assertThrows(ResponseStatusException.class,
                () -> service.createFlashcard(UID, systemDeskId, cardReq("apple")));
        verify(flashcardRepository, never()).save(any());
    }

    // ── Trùng từ trong desk ───────────────────────────────────────────────

    @Test
    @DisplayName("createFlashcard từ trùng trong cùng desk -> 409 CONFLICT")
    void createFlashcardDuplicateWordConflicts() {
        when(flashcardRepository.existsByDesk_IdAndWord(ownDesk.getId(), "apple")).thenReturn(true);

        ResponseStatusException ex = assertThrows(ResponseStatusException.class,
                () -> service.createFlashcard(UID, ownDesk.getId(), cardReq("apple")));
        assertEquals(HttpStatus.CONFLICT, ex.getStatusCode());
        verify(flashcardRepository, never()).save(any());
    }

    @Test
    @DisplayName("createFlashcard từ mới -> lưu, word được trim")
    void createFlashcardSavesTrimmedWord() {
        when(flashcardRepository.existsByDesk_IdAndWord(ownDesk.getId(), "apple")).thenReturn(false);

        FlashcardResponse res = service.createFlashcard(UID, ownDesk.getId(), cardReq("  apple  "));

        assertNotNull(res);
        verify(flashcardRepository).save(argThat(fc -> "apple".equals(fc.getWord())));
    }

    @Test
    @DisplayName("updateFlashcard giữ nguyên từ cũ -> KHÔNG check trùng, vẫn update được")
    void updateFlashcardSameWordAllowed() {
        Flashcard fc = new Flashcard();
        fc.setId(UUID.randomUUID());
        fc.setDesk(ownDesk);
        fc.setWord("apple");
        when(flashcardRepository.findByIdAndDesk_Id(fc.getId(), ownDesk.getId()))
                .thenReturn(Optional.of(fc));

        assertDoesNotThrow(() ->
                service.updateFlashcard(UID, ownDesk.getId(), fc.getId(), cardReq("apple")));
        // Không đổi từ -> không gọi exists check.
        verify(flashcardRepository, never()).existsByDesk_IdAndWord(any(), any());
    }

    @Test
    @DisplayName("updateFlashcard đổi sang từ đã tồn tại trong desk -> 409")
    void updateFlashcardToExistingWordConflicts() {
        Flashcard fc = new Flashcard();
        fc.setId(UUID.randomUUID());
        fc.setDesk(ownDesk);
        fc.setWord("apple");
        when(flashcardRepository.findByIdAndDesk_Id(fc.getId(), ownDesk.getId()))
                .thenReturn(Optional.of(fc));
        when(flashcardRepository.existsByDesk_IdAndWord(ownDesk.getId(), "orange")).thenReturn(true);

        ResponseStatusException ex = assertThrows(ResponseStatusException.class,
                () -> service.updateFlashcard(UID, ownDesk.getId(), fc.getId(), cardReq("orange")));
        assertEquals(HttpStatus.CONFLICT, ex.getStatusCode());
    }

    // ── Desk hệ thống vs desk cá nhân ────────────────────────────────────

    @Test
    @DisplayName("createDesk hệ thống trùng CEFR+title -> 409 (uq_desk_global_cefr_title)")
    void createSystemDeskDuplicateCefrTitleConflicts() {
        when(deskRepository.existsSystemDeskByCefrAndTitle("A1", "Numbers")).thenReturn(true);

        ResponseStatusException ex = assertThrows(ResponseStatusException.class,
                () -> service.createDesk(new CreateDeskRequest("A1", "Numbers", null)));
        assertEquals(HttpStatus.CONFLICT, ex.getStatusCode());
        verify(deskRepository, never()).save(any());
    }

    @Test
    @DisplayName("createDesk cá nhân: nhiều desk cùng CEFR được phép (V45 bỏ ràng buộc)")
    void createPersonalDeskAllowsMultipleSameCefr() {
        when(deskRepository.findMaxSortOrderByOwnerId(owner.getId())).thenReturn(2);

        // Hai desk A1 liên tiếp — không có check trùng CEFR nào chặn.
        assertDoesNotThrow(() ->
                service.createDesk(UID, new CreateDeskRequest("A1", "Vocab 1", null)));
        assertDoesNotThrow(() ->
                service.createDesk(UID, new CreateDeskRequest("A1", "Vocab 2", null)));
        verify(deskRepository, times(2)).save(any(Desk.class));
    }
}
