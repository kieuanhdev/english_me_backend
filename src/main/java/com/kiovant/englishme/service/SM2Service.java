package com.kiovant.englishme.service;

import com.kiovant.englishme.entity.FlashcardProgress;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

/**
 * SM-2 spaced repetition algorithm (SuperMemo 2).
 *
 * Quality scale 0-5:
 *   0-2 = lapse (Again)
 *   3   = Hard
 *   4   = Good
 *   5   = Easy
 */
@Service
public class SM2Service {

    private static final double MIN_EF = 1.3;

    public FlashcardProgress applyReview(FlashcardProgress progress, int quality) {
        int q = Math.max(0, Math.min(5, quality));

        double ef = progress.getEasinessFactor() == null ? 2.5 : progress.getEasinessFactor();
        int reps = progress.getRepetitions() == null ? 0 : progress.getRepetitions();
        int interval;

        if (q < 3) {
            // Lapse: reset repetitions, repeat tomorrow
            reps = 0;
            interval = 1;
        } else {
            reps += 1;
            if (reps == 1) {
                interval = 1;
            } else if (reps == 2) {
                interval = 6;
            } else {
                int prev = progress.getIntervalDays() == null ? 1 : Math.max(1, progress.getIntervalDays());
                interval = (int) Math.round(prev * ef);
            }
        }

        // Update EF (always, even on lapse — only affects next correct review)
        ef = ef + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
        if (ef < MIN_EF) {
            ef = MIN_EF;
        }

        LocalDateTime now = LocalDateTime.now();
        progress.setEasinessFactor(ef);
        progress.setRepetitions(reps);
        progress.setIntervalDays(interval);
        progress.setLastReviewedAt(now);
        progress.setNextReviewAt(now.plusDays(interval));
        return progress;
    }

    /**
     * XP reward per card: quality>=3 = 2 XP, quality==5 = 3 XP, quality<3 = 0 XP.
     */
    public int xpForQuality(int quality) {
        if (quality >= 5) return 3;
        if (quality >= 3) return 2;
        return 0;
    }
}
