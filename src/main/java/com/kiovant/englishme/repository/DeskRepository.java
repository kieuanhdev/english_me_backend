package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.Desk;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface DeskRepository extends JpaRepository<Desk, UUID> {

    Optional<Desk> findByIdAndOwner_Id(UUID id, UUID ownerId);

    Optional<Desk> findByOwner_IdAndCefrLevel(UUID ownerId, String cefrLevel);

    List<Desk> findAllByOwner_IdOrderBySortOrderAsc(UUID ownerId);

    @Query("SELECT COALESCE(MAX(d.sortOrder), 0) FROM Desk d WHERE d.owner.id = :ownerId")
    int findMaxSortOrderByOwnerId(UUID ownerId);
}
