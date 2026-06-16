package com.kiovant.englishme.dto;

import java.util.List;
import java.util.Map;

/** DTO cho Level Checkpoint Test (Pha 4 — lên cấp CEFR). */
public final class CheckpointDtos {

    private CheckpointDtos() {}

    /**
     * GET /levels/{level}/checkpoint — trạng thái + đề (nếu đã mở khoá).
     * Khoá khi unitProgress < requiredUnitProgress: trả unlocked=false, questions rỗng.
     */
    public record CheckpointState(
            String level,
            String nextLevel,
            String title,
            boolean unlocked,
            double unitProgress,          // 0..1
            double requiredUnitProgress,  // 0..1
            int passScore,
            boolean alreadyPassed,
            List<Map<String, Object>> questions   // payload + meta (id,type), KHÔNG kèm đáp án đúng
    ) {}

    /**
     * POST /levels/{level}/checkpoint/submit — kết quả nộp.
     * leveledUp=true ⇒ current_level đã nâng lên nextLevel (+100 XP).
     */
    public record CheckpointResult(
            boolean passed,
            int score,
            int passScore,
            boolean leveledUp,
            String fromLevel,
            String toLevel,
            int xpEarned,
            java.util.List<XpGrantResult.BadgeAward> newBadges
    ) {}
}
