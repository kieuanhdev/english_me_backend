package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.Flashcard;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

public interface FlashcardRepository extends JpaRepository<Flashcard, UUID> {

    long countByDesk_Id(UUID deskId);

    boolean existsByDesk_IdAndWord(UUID deskId, String word);

    Page<Flashcard> findByDesk_Id(UUID deskId, Pageable pageable);

    @Query("SELECT f.desk.id, COUNT(f) FROM Flashcard f WHERE f.desk.id IN :deskIds GROUP BY f.desk.id")
    List<Object[]> countByDeskIds(Set<UUID> deskIds);

    default Map<UUID, Long> countByDeskIdsAsMap(Set<UUID> deskIds) {
        return countByDeskIds(deskIds).stream()
                .collect(Collectors.toMap(
                        row -> (UUID) row[0],
                        row -> (Long) row[1]
                ));
    }
}
