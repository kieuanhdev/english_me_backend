package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.HomeRecommendation;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface HomeRecommendationRepository extends JpaRepository<HomeRecommendation, UUID> {

    List<HomeRecommendation> findAllByOrderByLevelAscSortOrderAsc();

    List<HomeRecommendation> findByLevelIgnoreCaseAndIsActiveTrueOrderBySortOrderAsc(String level);
}
