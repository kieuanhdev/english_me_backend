package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.Skill;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SkillRepository extends JpaRepository<Skill, String> {
    List<Skill> findAllByOrderByDisplayOrderAsc();
}
