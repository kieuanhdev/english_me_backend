package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.*;
import com.kiovant.englishme.entity.Desk;
import com.kiovant.englishme.entity.Flashcard;
import com.kiovant.englishme.repository.DeskRepository;
import com.kiovant.englishme.repository.FlashcardRepository;
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

    public DeskFlashcardService(DeskRepository deskRepository, FlashcardRepository flashcardRepository) {
        this.deskRepository = deskRepository;
        this.flashcardRepository = flashcardRepository;
    }

    @Transactional(readOnly = true)
    public List<DeskResponse> listDesks() {
        return deskRepository.findAllByOrderBySortOrderAsc().stream()
                .map(this::toDeskResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public Desk getDeskOrThrow(UUID id) {
        return deskRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Desk not found"));
    }

    @Transactional(readOnly = true)
    public Page<FlashcardResponse> listFlashcardsPage(UUID deskId, int page, int size) {
        if (!deskRepository.existsById(deskId)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Desk not found");
        }
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
    public DeskResponse createDesk(CreateDeskRequest req) {
        if (req.getCefrLevel() == null || req.getCefrLevel().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "cefrLevel is required");
        }
        String cefr = req.getCefrLevel().trim().toUpperCase();
        if (deskRepository.findByCefrLevel(cefr).isPresent()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Desk already exists for CEFR " + cefr);
        }

        Desk desk = new Desk();
        desk.setCefrLevel(cefr);
        String title = req.getTitle();
        if (title == null || title.isBlank()) {
            title = "Desk " + cefr;
        }
        desk.setTitle(title.trim());
        int order = req.getSortOrder() != null ? req.getSortOrder() : deskRepository.findMaxSortOrder() + 1;
        desk.setSortOrder(order);

        desk = deskRepository.save(desk);
        return toDeskResponse(desk);
    }

    @Transactional
    public FlashcardResponse createFlashcard(UUID deskId, CreateFlashcardRequest req) {
        if (req.getWord() == null || req.getWord().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "word is required");
        }
        if (req.getCefr() == null || req.getCefr().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "cefr is required");
        }

        Desk desk = deskRepository.findById(deskId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Desk not found"));

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
