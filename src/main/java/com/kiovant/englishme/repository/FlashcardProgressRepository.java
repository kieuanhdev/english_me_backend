package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.FlashcardProgress;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface FlashcardProgressRepository extends JpaRepository<FlashcardProgress, UUID> {
}
