package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.HomeBanner;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface HomeBannerRepository extends JpaRepository<HomeBanner, UUID> {

    List<HomeBanner> findAllByOrderBySortOrderAscStartAtDesc();
}
