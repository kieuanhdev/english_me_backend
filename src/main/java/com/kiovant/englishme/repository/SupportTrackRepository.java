package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.SupportTrack;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SupportTrackRepository extends JpaRepository<SupportTrack, String> {
    List<SupportTrack> findAllByEnabledTrueOrderByDisplayOrderAsc();
}
