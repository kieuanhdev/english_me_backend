package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.AppAnnouncement;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface AppAnnouncementRepository extends JpaRepository<AppAnnouncement, UUID> {

    List<AppAnnouncement> findAllByOrderByCreatedAtDesc();
}
