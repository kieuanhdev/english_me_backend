package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.HomeWordOfDay;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface HomeWordOfDayRepository extends JpaRepository<HomeWordOfDay, UUID> {

    List<HomeWordOfDay> findAllByOrderByScheduledDateDesc();

    Optional<HomeWordOfDay> findFirstByScheduledDateAndLevel(LocalDate date, String level);

    boolean existsByScheduledDateAndLevel(LocalDate date, String level);
}
