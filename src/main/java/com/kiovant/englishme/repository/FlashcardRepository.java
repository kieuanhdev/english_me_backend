package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.Flashcard;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface FlashcardRepository extends JpaRepository<Flashcard, UUID> {

    long countByDesk_Id(UUID deskId);

    boolean existsByDesk_IdAndWord(UUID deskId, String word);

    Page<Flashcard> findByDesk_Id(UUID deskId, Pageable pageable);
}
