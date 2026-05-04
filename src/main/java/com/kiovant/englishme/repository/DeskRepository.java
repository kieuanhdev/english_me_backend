package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.Desk;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface DeskRepository extends JpaRepository<Desk, UUID> {

    Optional<Desk> findByCefrLevel(String cefrLevel);

    List<Desk> findAllByOrderBySortOrderAsc();

    @Query("SELECT COALESCE(MAX(d.sortOrder), 0) FROM Desk d")
    int findMaxSortOrder();
}
