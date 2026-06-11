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

    List<Desk> findAllByOwnerIsNullOrderBySortOrderAsc();

    @Query("SELECT d FROM Desk d WHERE d.owner.id = :ownerId OR d.owner IS NULL ORDER BY d.sortOrder ASC")
    List<Desk> findAllAccessibleByOwner(UUID ownerId);

    @Query("SELECT COALESCE(MAX(d.sortOrder), 0) FROM Desk d WHERE d.owner.id = :ownerId")
    int findMaxSortOrderByOwnerId(UUID ownerId);

    @Query("SELECT COALESCE(MAX(d.sortOrder), 0) FROM Desk d WHERE d.owner IS NULL")
    int findMaxSortOrderWhereOwnerIsNull();

    /** Check trùng desk hệ thống (CEFR + title, không phân biệt hoa thường) — khớp uq_desk_global_cefr_title. */
    @Query("""
            SELECT COUNT(d) > 0 FROM Desk d
            WHERE d.owner IS NULL
              AND UPPER(d.cefrLevel) = UPPER(:cefrLevel)
              AND UPPER(d.title) = UPPER(:title)
            """)
    boolean existsSystemDeskByCefrAndTitle(String cefrLevel, String title);
}
