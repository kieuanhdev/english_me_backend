package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.PronunciationWordFeedback;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface PronunciationWordFeedbackRepository extends JpaRepository<PronunciationWordFeedback, UUID> {
}
