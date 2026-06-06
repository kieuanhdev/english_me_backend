package com.kiovant.englishme.entity;

import java.io.Serializable;
import java.util.Objects;
import java.util.UUID;

/** Khóa kép cho {@link UserSkillXp}: (user_id, skill). */
public class UserSkillXpId implements Serializable {

    private UUID userId;
    private String skill;

    public UserSkillXpId() {
    }

    public UserSkillXpId(UUID userId, String skill) {
        this.userId = userId;
        this.skill = skill;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof UserSkillXpId that)) return false;
        return Objects.equals(userId, that.userId) && Objects.equals(skill, that.skill);
    }

    @Override
    public int hashCode() {
        return Objects.hash(userId, skill);
    }
}
