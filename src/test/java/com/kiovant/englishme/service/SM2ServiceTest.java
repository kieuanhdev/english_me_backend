package com.kiovant.englishme.service;

import com.kiovant.englishme.entity.FlashcardProgress;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Test suite cho thuật toán SM-2 (SuperMemo 2).
 * Đây là phần lõi luận văn Trụ 1 — Học từ vựng với spaced repetition.
 *
 * Quality scale 0-5:
 *   0-2 = lapse (Again) -> repetitions reset, interval = 1
 *   3   = Hard
 *   4   = Good
 *   5   = Easy
 */
class SM2ServiceTest {

    private SM2Service sm2;

    @BeforeEach
    void setUp() {
        sm2 = new SM2Service();
    }

    private FlashcardProgress newProgress() {
        FlashcardProgress p = new FlashcardProgress();
        p.setEasinessFactor(2.5);
        p.setIntervalDays(0);
        p.setRepetitions(0);
        return p;
    }

    @Test
    @DisplayName("quality < 3 -> lapse: reset repetitions = 0, interval = 1 day")
    void lapseResetsRepetitionsAndIntervalToOne() {
        FlashcardProgress p = newProgress();
        p.setRepetitions(5);
        p.setIntervalDays(30);

        sm2.applyReview(p, 2);

        assertEquals(0, p.getRepetitions());
        assertEquals(1, p.getIntervalDays());
    }

    @Test
    @DisplayName("quality = 3, repetitions = 0 -> interval = 1, repetitions = 1")
    void firstSuccessfulReviewSetsIntervalToOne() {
        FlashcardProgress p = newProgress();

        sm2.applyReview(p, 3);

        assertEquals(1, p.getRepetitions());
        assertEquals(1, p.getIntervalDays());
    }

    @Test
    @DisplayName("quality = 4, repetitions = 1 -> second review interval = 6")
    void secondSuccessfulReviewSetsIntervalToSix() {
        FlashcardProgress p = newProgress();
        p.setRepetitions(1);
        p.setIntervalDays(1);

        sm2.applyReview(p, 4);

        assertEquals(2, p.getRepetitions());
        assertEquals(6, p.getIntervalDays());
    }

    @Test
    @DisplayName("quality = 5, repetitions = 2, EF = 2.5 -> interval ≈ 15 (6 * 2.5)")
    void thirdReviewMultipliesPreviousIntervalByEf() {
        FlashcardProgress p = newProgress();
        p.setRepetitions(2);
        p.setIntervalDays(6);
        p.setEasinessFactor(2.5);

        sm2.applyReview(p, 5);

        assertEquals(3, p.getRepetitions());
        assertEquals(15, p.getIntervalDays());
    }

    @Test
    @DisplayName("EF không bao giờ nhỏ hơn 1.3 (sàn an toàn)")
    void easinessFactorClampedToMinimum() {
        FlashcardProgress p = newProgress();
        p.setEasinessFactor(1.3);

        // Liên tiếp quality thấp -> EF sẽ giảm xuống dưới 1.3 nếu không có clamp
        for (int i = 0; i < 10; i++) {
            sm2.applyReview(p, 0);
        }

        assertTrue(p.getEasinessFactor() >= 1.3,
                "EF phải >= 1.3, actual = " + p.getEasinessFactor());
    }

    @Test
    @DisplayName("Công thức EF: EF + (0.1 - (5-q)*(0.08 + (5-q)*0.02))")
    void easinessFactorFormulaIsCorrect() {
        // q = 5 -> EF tăng 0.1
        FlashcardProgress p5 = newProgress();
        p5.setEasinessFactor(2.5);
        sm2.applyReview(p5, 5);
        assertEquals(2.6, p5.getEasinessFactor(), 0.0001);

        // q = 4 -> EF không đổi (0.1 - 1*(0.08+0.02) = 0)
        FlashcardProgress p4 = newProgress();
        p4.setEasinessFactor(2.5);
        sm2.applyReview(p4, 4);
        assertEquals(2.5, p4.getEasinessFactor(), 0.0001);

        // q = 3 -> EF giảm 0.14 (0.1 - 2*(0.08+0.04) = -0.14)
        FlashcardProgress p3 = newProgress();
        p3.setEasinessFactor(2.5);
        sm2.applyReview(p3, 3);
        assertEquals(2.36, p3.getEasinessFactor(), 0.0001);
    }

    @Test
    @DisplayName("nextReviewAt = lastReviewedAt + interval days")
    void nextReviewAtMatchesIntervalDays() {
        FlashcardProgress p = newProgress();
        LocalDateTime before = LocalDateTime.now();

        sm2.applyReview(p, 4);

        assertNotNull(p.getLastReviewedAt());
        assertNotNull(p.getNextReviewAt());
        long days = ChronoUnit.DAYS.between(
                p.getLastReviewedAt().toLocalDate(),
                p.getNextReviewAt().toLocalDate()
        );
        assertEquals(p.getIntervalDays().longValue(), days);
        assertFalse(p.getLastReviewedAt().isBefore(before.minusSeconds(1)));
    }

    @Test
    @DisplayName("Card mới (repetitions=0) sau review thành công -> repetitions=1")
    void newCardTransitionsToFirstReviewState() {
        FlashcardProgress p = newProgress();
        assertEquals(0, p.getRepetitions());

        sm2.applyReview(p, 4);

        assertEquals(1, p.getRepetitions());
        assertEquals(1, p.getIntervalDays());
    }

    @Test
    @DisplayName("xpForQuality: q>=5 -> 3 XP, q>=3 -> 2 XP, q<3 -> 0 XP")
    void xpForQualityFollowsRewardTable() {
        assertEquals(3, sm2.xpForQuality(5));
        assertEquals(2, sm2.xpForQuality(4));
        assertEquals(2, sm2.xpForQuality(3));
        assertEquals(0, sm2.xpForQuality(2));
        assertEquals(0, sm2.xpForQuality(1));
        assertEquals(0, sm2.xpForQuality(0));
    }

    @Test
    @DisplayName("quality ngoài khoảng [0,5] bị clamp về [0,5]")
    void qualityOutsideRangeIsClamped() {
        FlashcardProgress pHigh = newProgress();
        sm2.applyReview(pHigh, 10);
        // q clamp = 5 -> EF tăng 0.1
        assertEquals(2.6, pHigh.getEasinessFactor(), 0.0001);

        FlashcardProgress pLow = newProgress();
        sm2.applyReview(pLow, -3);
        // q clamp = 0 -> lapse
        assertEquals(0, pLow.getRepetitions());
        assertEquals(1, pLow.getIntervalDays());
    }
}
