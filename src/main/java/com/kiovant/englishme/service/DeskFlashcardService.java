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
import java.util.UUID;

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

    @Transactional(readOnly = true)
    public List<DeskResponse> listDesks(String firebaseUid) {
        User owner = getUserByFirebaseUidOrThrow(firebaseUid);
        return deskRepository.findAll().stream()
                .filter(d -> d.getOwner() == null || d.getOwner().getId().equals(owner.getId()))
                .sorted((a, b) -> Integer.compare(a.getSortOrder(), b.getSortOrder()))
                .map(this::toDeskResponse)
                .toList();
    }

    /**
     * Legacy admin scope: desks not bound to a specific owner.
     */
    @Transactional(readOnly = true)
    public List<DeskResponse> listDesks() {
        return deskRepository.findAll().stream()
                .filter(d -> d.getOwner() == null)
                .sorted((a, b) -> Integer.compare(a.getSortOrder(), b.getSortOrder()))
                .map(this::toDeskResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public Desk getDeskOrThrow(UUID id, UUID ownerId) {
        return deskRepository.findByIdAndOwner_Id(id, ownerId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Desk not found"));
    }

    /**
     * Legacy admin scope: desk without owner.
     */
    @Transactional(readOnly = true)
    public Desk getDeskOrThrow(UUID id) {
        Desk desk = deskRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Desk not found"));
        if (desk.getOwner() != null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Desk not found");
        }
        return desk;
    }

    @Transactional(readOnly = true)
    public Page<FlashcardResponse> listFlashcardsPage(String firebaseUid, UUID deskId, int page, int size) {
        getDeskReadableOrThrow(firebaseUid, deskId);
        return flashcardRepository
                .findByDesk_Id(deskId, PageRequest.of(page, size, Sort.by("word")))
                .map(fc -> toFlashcardResponse(fc, deskId));
    }

    /**
     * Legacy admin scope: desk without owner.
     */
    @Transactional(readOnly = true)
    public Page<FlashcardResponse> listFlashcardsPage(UUID deskId, int page, int size) {
        getDeskOrThrow(deskId);
        return flashcardRepository
                .findByDesk_Id(deskId, PageRequest.of(page, size, Sort.by("word")))
                .map(fc -> toFlashcardResponse(fc, deskId));
    }

    private DeskResponse toDeskResponse(Desk d) {
        long n = flashcardRepository.countByDesk_Id(d.getId());
        return new DeskResponse(
                d.getId(),
                d.getCefrLevel(),
                d.getTitle(),
                d.getSortOrder(),
                d.getCreatedAt(),
                n);
    }

    @Transactional
    public DeskResponse createDesk(String firebaseUid, CreateDeskRequest req) {
        User owner = getUserByFirebaseUidOrThrow(firebaseUid);

        if (req.getCefrLevel() == null || req.getCefrLevel().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "cefrLevel is required");
        }
        String cefr = req.getCefrLevel().trim().toUpperCase();
        if (deskRepository.findByOwner_IdAndCefrLevel(owner.getId(), cefr).isPresent()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Desk already exists for CEFR " + cefr + " on your account");
        }

        Desk desk = new Desk();
        desk.setOwner(owner);
        desk.setCefrLevel(cefr);
        String title = req.getTitle();
        if (title == null || title.isBlank()) {
            title = "Desk " + cefr;
        }
        desk.setTitle(title.trim());
        if (req.getSortOrder() != null && req.getSortOrder() < 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "sortOrder must be >= 0");
        }
        int order = req.getSortOrder() != null ? req.getSortOrder() : deskRepository.findMaxSortOrderByOwnerId(owner.getId()) + 1;
        desk.setSortOrder(order);

        desk = deskRepository.save(desk);
        return toDeskResponse(desk);
    }

    /**
     * Legacy admin scope: create desk without owner.
     */
    @Transactional
    public DeskResponse createDesk(CreateDeskRequest req) {
        if (req.getCefrLevel() == null || req.getCefrLevel().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "cefrLevel is required");
        }
        String cefr = req.getCefrLevel().trim().toUpperCase();
        if (deskRepository.findAll().stream().anyMatch(d -> d.getOwner() == null && cefr.equalsIgnoreCase(d.getCefrLevel()))) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Desk already exists for CEFR " + cefr);
        }
        Desk desk = new Desk();
        desk.setCefrLevel(cefr);
        String title = req.getTitle();
        if (title == null || title.isBlank()) {
            title = "Desk " + cefr;
        }
        desk.setTitle(title.trim());
        if (req.getSortOrder() != null && req.getSortOrder() < 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "sortOrder must be >= 0");
        }
        int order = req.getSortOrder() != null ? req.getSortOrder() : listDesks().stream().map(DeskResponse::getSortOrder).max(Integer::compareTo).orElse(0) + 1;
        desk.setSortOrder(order);
        desk = deskRepository.save(desk);
        return toDeskResponse(desk);
    }

    @Transactional
    public DeskResponse updateDesk(String firebaseUid, UUID deskId, UpdateDeskRequest req) {
        User owner = getUserByFirebaseUidOrThrow(firebaseUid);
        Desk desk = getDeskOrThrow(deskId, owner.getId());

        if (req.getCefrLevel() != null && !req.getCefrLevel().isBlank()) {
            String cefr = req.getCefrLevel().trim().toUpperCase();
            deskRepository.findByOwner_IdAndCefrLevel(owner.getId(), cefr)
                    .filter(existing -> !existing.getId().equals(deskId))
                    .ifPresent(existing -> {
                        throw new ResponseStatusException(HttpStatus.CONFLICT, "Desk already exists for CEFR " + cefr + " on your account");
                    });
            desk.setCefrLevel(cefr);
        }

        if (req.getTitle() != null) {
            String title = req.getTitle().trim();
            if (title.isEmpty()) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "title must not be blank");
            }
            desk.setTitle(title);
        }

        if (req.getSortOrder() != null) {
            if (req.getSortOrder() < 0) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "sortOrder must be >= 0");
            }
            desk.setSortOrder(req.getSortOrder());
        }

        return toDeskResponse(deskRepository.save(desk));
    }

    @Transactional
    public void deleteDesk(String firebaseUid, UUID deskId) {
        User owner = getUserByFirebaseUidOrThrow(firebaseUid);
        Desk desk = getDeskOrThrow(deskId, owner.getId());
        deskRepository.delete(desk);
    }

    @Transactional
    public FlashcardResponse createFlashcard(String firebaseUid, UUID deskId, CreateFlashcardRequest req) {
        User owner = getUserByFirebaseUidOrThrow(firebaseUid);

        if (req.getWord() == null || req.getWord().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "word is required");
        }
        if (req.getCefr() == null || req.getCefr().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "cefr is required");
        }

        Desk desk = getDeskOrThrow(deskId, owner.getId());

        String word = req.getWord().trim();
        if (flashcardRepository.existsByDesk_IdAndWord(deskId, word)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Flashcard already exists for this word on this desk");
        }

        Flashcard fc = new Flashcard();
        fc.setDesk(desk);
        fc.setWord(word);
        fc.setCefr(req.getCefr().trim().toUpperCase());
        fc.setPosJson(emptyToNull(req.getPos()));
        fc.setAllLevelsJson(emptyToNull(req.getAllLevels()));
        fc.setIpa(trimToNull(req.getIpa()));
        fc.setAudioUrl(trimToNull(req.getAudioUrl()));
        fc.setDefinition(trimToNull(req.getDefinition()));
        fc.setExample(trimToNull(req.getExample()));
        fc.setTopic(trimToNull(req.getTopic()));
        fc.setVietnamese(trimToNull(req.getVietnamese()));
        fc.setViDefinition(trimToNull(req.getViDefinition()));
        fc.setViExample(trimToNull(req.getViExample()));

        fc = flashcardRepository.save(fc);
        return toFlashcardResponse(fc, deskId);
    }

    /**
     * Legacy admin scope: desk without owner.
     */
    @Transactional
    public FlashcardResponse createFlashcard(UUID deskId, CreateFlashcardRequest req) {
        if (req.getWord() == null || req.getWord().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "word is required");
        }
        if (req.getCefr() == null || req.getCefr().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "cefr is required");
        }
        Desk desk = getDeskOrThrow(deskId);
        String word = req.getWord().trim();
        if (flashcardRepository.existsByDesk_IdAndWord(deskId, word)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Flashcard already exists for this word on this desk");
        }
        Flashcard fc = new Flashcard();
        fc.setDesk(desk);
        fc.setWord(word);
        fc.setCefr(req.getCefr().trim().toUpperCase());
        fc.setPosJson(emptyToNull(req.getPos()));
        fc.setAllLevelsJson(emptyToNull(req.getAllLevels()));
        fc.setIpa(trimToNull(req.getIpa()));
        fc.setAudioUrl(trimToNull(req.getAudioUrl()));
        fc.setDefinition(trimToNull(req.getDefinition()));
        fc.setExample(trimToNull(req.getExample()));
        fc.setTopic(trimToNull(req.getTopic()));
        fc.setVietnamese(trimToNull(req.getVietnamese()));
        fc.setViDefinition(trimToNull(req.getViDefinition()));
        fc.setViExample(trimToNull(req.getViExample()));
        fc = flashcardRepository.save(fc);
        return toFlashcardResponse(fc, deskId);
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
