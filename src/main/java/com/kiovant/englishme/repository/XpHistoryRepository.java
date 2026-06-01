package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.XpHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface XpHistoryRepository extends JpaRepository<XpHistory, UUID> {

    Optional<XpHistory> findByUser_IdAndActivityDate(UUID userId, LocalDate date);

    List<XpHistory> findByUser_IdAndActivityDateBetweenOrderByActivityDateAsc(UUID userId, LocalDate from, LocalDate to);

    @Query("SELECT COALESCE(SUM(x.xp), 0) FROM XpHistory x WHERE x.user.id = :userId AND x.activityDate BETWEEN :from AND :to")
    int sumXpBetween(@Param("userId") UUID userId, @Param("from") LocalDate from, @Param("to") LocalDate to);

    @Query("SELECT COUNT(x) FROM XpHistory x WHERE x.user.id = :userId AND x.activityDate BETWEEN :from AND :to AND x.xp > 0")
    int countActiveDaysBetween(@Param("userId") UUID userId, @Param("from") LocalDate from, @Param("to") LocalDate to);

    @Query("SELECT COALESCE(SUM(x.xp), 0) FROM XpHistory x WHERE x.activityDate = :date")
    long sumXpOnDate(@Param("date") LocalDate date);

    @Query("SELECT COUNT(DISTINCT x.user.id) FROM XpHistory x WHERE x.activityDate >= :from AND x.activityDate <= :to AND x.xp > 0")
    long countActiveUsersBetween(@Param("from") LocalDate from, @Param("to") LocalDate to);
}
