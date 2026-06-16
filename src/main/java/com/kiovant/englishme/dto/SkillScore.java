package com.kiovant.englishme.dto;

/**
 * Điểm 1 kỹ năng cho màn Tiến độ / widget "Kỹ năng của bạn".
 *
 * <p>{@code score} = số lesson skill này user ĐÃ HOÀN THÀNH ở level hiện tại;
 * {@code maxScore} = TỔNG số lesson active của skill ở level đó. % hiển thị =
 * score / maxScore — phản ánh tiến độ học thật, không skill nào tự nhảy 100%
 * khi mới học vài bài. {@code maxScore == 0} (hoặc null) = skill không gắn
 * lesson (vd phát âm thuần STT) → client ẩn bar.
 */
public record SkillScore(
        String name,
        Integer score,
        Integer maxScore
) {}
