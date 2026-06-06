package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.UserSkillXp;
import com.kiovant.englishme.entity.UserSkillXpId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.UUID;

public interface UserSkillXpRepository extends JpaRepository<UserSkillXp, UserSkillXpId> {

    List<UserSkillXp> findByUserId(UUID userId);

    /**
     * Upsert atomic: cộng dồn XP cho (user, skill). Tạo row nếu chưa có.
     * Gọi sau khi insert xp_ledger thành công -> idempotency đã đảm bảo ở tầng ledger.
     */
    @Modifying
    @Query(value = """
            INSERT INTO user_skill_xp (user_id, skill, xp, updated_at)
            VALUES (:userId, :skill, :amount, NOW())
            ON CONFLICT (user_id, skill)
            DO UPDATE SET xp = user_skill_xp.xp + EXCLUDED.xp, updated_at = NOW()
            """, nativeQuery = true)
    void upsertAdd(@Param("userId") UUID userId,
                   @Param("skill") String skill,
                   @Param("amount") int amount);
}
