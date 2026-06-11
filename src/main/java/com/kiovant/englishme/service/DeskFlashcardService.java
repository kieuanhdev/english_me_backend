package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.*;
import com.kiovant.englishme.entity.Desk;
import com.kiovant.englishme.entity.Flashcard;
import com.kiovant.englishme.entity.User;
import com.kiovant.englishme.repository.DeskRepository;
import com.kiovant.englishme.repository.FlashcardRepository;
import com.kiovant.englishme.repository.UserRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class DeskFlashcardService {

    private final DeskRepository deskRepository;
    private final FlashcardRepository flashcardRepository;
    private final UserRepository userRepository;

    public DeskFlashcardService(
            DeskRepository deskRepository,
            FlashcardRepository flashcardRepository,
            UserRepository userRepository
    ) {
        this.deskRepository = deskRepository;
        this.flashcardRepository = flashcardRepository;
        this.userRepository = userRepository;
    }

    // ── Desk listing ──────────────────────────────────────────────

    @Transactional(readOnly = true)
    public List<DeskResponse> listDesks(String firebaseUid) {
        User owner = getUserByFirebaseUidOrThrow(firebaseUid);
        List<Desk> desks = deskRepository.findAllAccessibleByOwner(owner.getId());
        return toDeskResponses(desks);
    }

    @Transactional(readOnly = true)
    public List<DeskResponse> listDesks() {
        List<Desk> desks = deskRepository.findAllByOwnerIsNullOrderBySortOrderAsc();
        return toDeskResponses(desks);
    }

    // ── Desk lookup ───────────────────────────────────────────────

    @Transactional(readOnly = true)
    public Desk getDeskOrThrow(UUID id, UUID ownerId) {
        return deskRepository.findByIdAndOwner_Id(id, ownerId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Desk not found"));
    }

    @Transactional(readOnly = true)
    public Desk getDeskOrThrow(UUID id) {
        Desk desk = deskRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Desk not found"));
        if (desk.getOwner() != null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Desk not found");
        }
        return desk;
    }

    // ── Flashcard listing ─────────────────────────────────────────

    @Transactional(readOnly = true)
    public Page<FlashcardResponse> listFlashcardsPage(String firebaseUid, UUID deskId, int page, int size) {
        getDeskReadableOrThrow(firebaseUid, deskId);
        return listFlashcardsForDesk(deskId, page, size);
    }

    @Transactional(readOnly = true)
    public Page<FlashcardResponse> listFlashcardsPage(UUID deskId, int page, int size) {
        getDeskOrThrow(deskId);
        return listFlashcardsForDesk(deskId, page, size);
    }

    private Page<FlashcardResponse> listFlashcardsForDesk(UUID deskId, int page, int size) {
        return flashcardRepository
                .findByDesk_Id(deskId, PageRequest.of(page, size, Sort.by("word")))
                .map(fc -> toFlashcardResponse(fc, deskId));
    }

    // ── Desk CRUD ─────────────────────────────────────────────────

    @Transactional
    public DeskResponse createDesk(String firebaseUid, CreateDeskRequest req) {
        User owner = getUserByFirebaseUidOrThrow(firebaseUid);
        requireNonNegativeSortOrder(req);
        // Desk cá nhân không còn ràng buộc theo CEFR (V45 drop uq_desk_owner_cefr).
        // Cột cefr_level vẫn NOT NULL → gán mặc định khi client không gửi.
        String cefr = normalizeCefrOrDefault(req.cefrLevel());
        int defaultOrder = deskRepository.findMaxSortOrderByOwnerId(owner.getId()) + 1;
        return buildAndSaveDesk(req, owner, cefr, defaultOrder);
    }

    @Transactional
    public DeskResponse createDesk(CreateDeskRequest req) {
        requireCefrLevel(req);
        requireNonNegativeSortOrder(req);
        String cefr = req.cefrLevel().trim().toUpperCase();
        // Desk hệ thống (owner NULL) cho phép nhiều bộ cùng CEFR, miễn khác title
        // (khớp uq_desk_global_cefr_title từ V33). Title rỗng -> default "Desk <cefr>".
        String title = (req.title() == null || req.title().isBlank())
                ? "Desk " + cefr
                : req.title().trim();
        if (deskRepository.existsSystemDeskByCefrAndTitle(cefr, title)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Desk already exists for CEFR " + cefr + " with title \"" + title + "\"");
        }
        int defaultOrder = deskRepository.findMaxSortOrderWhereOwnerIsNull() + 1;
        return buildAndSaveDesk(req, null, cefr, defaultOrder);
    }

    @Transactional
    public DeskResponse updateDesk(String firebaseUid, UUID deskId, UpdateDeskRequest req) {
        User owner = getUserByFirebaseUidOrThrow(firebaseUid);
        Desk desk = getDeskOrThrow(deskId, owner.getId());

        // CEFR cá nhân không còn ràng buộc duy nhất (V45) → chỉ cập nhật nếu client gửi.
        if (req.cefrLevel() != null && !req.cefrLevel().isBlank()) {
            desk.setCefrLevel(req.cefrLevel().trim().toUpperCase());
        }

        if (req.title() != null) {
            String title = req.title().trim();
            if (title.isEmpty()) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "title must not be blank");
            }
            desk.setTitle(title);
        }

        if (req.sortOrder() != null) {
            if (req.sortOrder() < 0) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "sortOrder must be >= 0");
            }
            desk.setSortOrder(req.sortOrder());
        }

        return toDeskResponses(List.of(deskRepository.save(desk))).get(0);
    }

    @Transactional
    public void deleteDesk(String firebaseUid, UUID deskId) {
        User owner = getUserByFirebaseUidOrThrow(firebaseUid);
        Desk desk = getDeskOrThrow(deskId, owner.getId());
        deskRepository.delete(desk);
    }

    // ── Flashcard CRUD ────────────────────────────────────────────

    @Transactional
    public FlashcardResponse createFlashcard(String firebaseUid, UUID deskId, CreateFlashcardRequest req) {
        User owner = getUserByFirebaseUidOrThrow(firebaseUid);
        Desk desk = getDeskOrThrow(deskId, owner.getId());
        return buildAndSaveFlashcard(desk, req, deskId);
    }

    @Transactional
    public FlashcardResponse createFlashcard(UUID deskId, CreateFlashcardRequest req) {
        Desk desk = getDeskOrThrow(deskId);
        return buildAndSaveFlashcard(desk, req, deskId);
    }

    @Transactional
    public FlashcardResponse updateFlashcard(String firebaseUid, UUID deskId, UUID flashcardId, CreateFlashcardRequest req) {
        User owner = getUserByFirebaseUidOrThrow(firebaseUid);
        getDeskOrThrow(deskId, owner.getId());
        Flashcard fc = flashcardRepository.findByIdAndDesk_Id(flashcardId, deskId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Flashcard not found"));

        if (req.word() == null || req.word().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "word is required");
        }
        if (req.cefr() == null || req.cefr().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "cefr is required");
        }
        String newWord = req.word().trim();
        if (!newWord.equals(fc.getWord()) && flashcardRepository.existsByDesk_IdAndWord(deskId, newWord)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Flashcard already exists for this word on this desk");
        }

        fc.setWord(newWord);
        fc.setCefr(req.cefr().trim().toUpperCase());
        fc.setPosJson(emptyToNull(req.pos()));
        fc.setAllLevelsJson(emptyToNull(req.allLevels()));
        fc.setIpa(trimToNull(req.ipa()));
        fc.setAudioUrl(trimToNull(req.audioUrl()));
        fc.setDefinition(trimToNull(req.definition()));
        fc.setExample(trimToNull(req.example()));
        fc.setTopic(trimToNull(req.topic()));
        fc.setVietnamese(trimToNull(req.vietnamese()));
        fc.setViDefinition(trimToNull(req.viDefinition()));
        fc.setViExample(trimToNull(req.viExample()));

        fc = flashcardRepository.save(fc);
        return toFlashcardResponse(fc, deskId);
    }

    @Transactional
    public void deleteFlashcard(String firebaseUid, UUID deskId, UUID flashcardId) {
        User owner = getUserByFirebaseUidOrThrow(firebaseUid);
        getDeskOrThrow(deskId, owner.getId());
        Flashcard fc = flashcardRepository.findByIdAndDesk_Id(flashcardId, deskId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Flashcard not found"));
        flashcardRepository.delete(fc);
    }

    @Transactional
    public void deleteFlashcard(UUID deskId, UUID flashcardId) {
        getDeskOrThrow(deskId);
        Flashcard fc = flashcardRepository.findById(flashcardId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Flashcard not found"));
        if (!fc.getDesk().getId().equals(deskId)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Flashcard not found in this desk");
        }
        flashcardRepository.delete(fc);
    }

    // ── Private helpers ───────────────────────────────────────────

    private List<DeskResponse> toDeskResponses(List<Desk> desks) {
        if (desks.isEmpty()) {
            return List.of();
        }
        Set<UUID> deskIds = desks.stream().map(Desk::getId).collect(Collectors.toSet());
        Map<UUID, Long> counts = flashcardRepository.countByDeskIdsAsMap(deskIds);
        return desks.stream()
                .map(d -> new DeskResponse(
                        d.getId(),
                        d.getCefrLevel(),
                        d.getTitle(),
                        d.getSortOrder(),
                        d.getCreatedAt(),
                        counts.getOrDefault(d.getId(), 0L),
                        d.getOwner() == null))
                .toList();
    }

    private DeskResponse buildAndSaveDesk(CreateDeskRequest req, User owner, String cefr, int defaultSortOrder) {
        Desk desk = new Desk();
        desk.setOwner(owner);
        desk.setCefrLevel(cefr);
        String title = req.title();
        if (title == null || title.isBlank()) {
            title = "Desk " + cefr;
        }
        desk.setTitle(title.trim());
        int order = req.sortOrder() != null ? req.sortOrder() : defaultSortOrder;
        desk.setSortOrder(order);
        return toDeskResponses(List.of(deskRepository.save(desk))).get(0);
    }

    private FlashcardResponse buildAndSaveFlashcard(Desk desk, CreateFlashcardRequest req, UUID deskId) {
        if (req.word() == null || req.word().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "word is required");
        }
        if (req.cefr() == null || req.cefr().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "cefr is required");
        }
        String word = req.word().trim();
        if (flashcardRepository.existsByDesk_IdAndWord(deskId, word)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Flashcard already exists for this word on this desk");
        }

        Flashcard fc = new Flashcard();
        fc.setDesk(desk);
        fc.setWord(word);
        fc.setCefr(req.cefr().trim().toUpperCase());
        fc.setPosJson(emptyToNull(req.pos()));
        fc.setAllLevelsJson(emptyToNull(req.allLevels()));
        fc.setIpa(trimToNull(req.ipa()));
        fc.setAudioUrl(trimToNull(req.audioUrl()));
        fc.setDefinition(trimToNull(req.definition()));
        fc.setExample(trimToNull(req.example()));
        fc.setTopic(trimToNull(req.topic()));
        fc.setVietnamese(trimToNull(req.vietnamese()));
        fc.setViDefinition(trimToNull(req.viDefinition()));
        fc.setViExample(trimToNull(req.viExample()));

        fc = flashcardRepository.save(fc);
        return toFlashcardResponse(fc, deskId);
    }

    private static void requireCefrLevel(CreateDeskRequest req) {
        if (req.cefrLevel() == null || req.cefrLevel().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "cefrLevel is required");
        }
    }

    /// Chuẩn hoá CEFR client gửi; rỗng/null -> mặc định "A1" (chỉ để thoả cột NOT NULL).
    private static String normalizeCefrOrDefault(String cefrLevel) {
        if (cefrLevel == null || cefrLevel.isBlank()) {
            return "A1";
        }
        return cefrLevel.trim().toUpperCase();
    }

    private static void requireNonNegativeSortOrder(CreateDeskRequest req) {
        if (req.sortOrder() != null && req.sortOrder() < 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "sortOrder must be >= 0");
        }
    }

    private User getUserByFirebaseUidOrThrow(String firebaseUid) {
        return userRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "User profile not found. Please sync account first."));
    }

    private Desk getDeskReadableOrThrow(String firebaseUid, UUID deskId) {
        User user = getUserByFirebaseUidOrThrow(firebaseUid);
        Desk desk = deskRepository.findById(deskId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Desk not found"));
        if (desk.getOwner() == null || desk.getOwner().getId().equals(user.getId())) {
            return desk;
        }
        throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Desk not found");
    }

    private static FlashcardResponse toFlashcardResponse(Flashcard fc, UUID deskId) {
        return new FlashcardResponse(
                fc.getId(),
                deskId,
                fc.getWord(),
                fc.getCefr(),
                fc.getPosJson(),
                fc.getAllLevelsJson(),
                fc.getIpa(),
                fc.getAudioUrl(),
                fc.getDefinition(),
                fc.getExample(),
                fc.getTopic(),
                fc.getVietnamese(),
                fc.getViDefinition(),
                fc.getViExample());
    }

    private static <T> List<T> emptyToNull(List<T> list) {
        if (list == null || list.isEmpty()) {
            return null;
        }
        return list;
    }

    private static String trimToNull(String s) {
        if (s == null) {
            return null;
        }
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }
}
