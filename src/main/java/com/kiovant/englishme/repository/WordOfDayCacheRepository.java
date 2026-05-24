package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.WordOfDayCache;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;

public interface WordOfDayCacheRepository extends JpaRepository<WordOfDayCache, UUID> {

    Optional<WordOfDayCache> findByCacheDateAndCefrLevelIgnoreCase(LocalDate cacheDate, String cefrLevel);
}
