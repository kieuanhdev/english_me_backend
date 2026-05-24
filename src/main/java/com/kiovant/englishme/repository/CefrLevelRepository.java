package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.CefrLevel;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CefrLevelRepository extends JpaRepository<CefrLevel, String> {
    List<CefrLevel> findAllByIsActiveTrueOrderByDisplayOrderAsc();
}
