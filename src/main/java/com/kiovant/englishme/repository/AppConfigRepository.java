package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.AppConfig;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AppConfigRepository extends JpaRepository<AppConfig, String> {

    List<AppConfig> findAllByOrderByConfigKeyAsc();
}
