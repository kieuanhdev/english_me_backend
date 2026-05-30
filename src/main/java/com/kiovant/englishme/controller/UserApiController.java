package com.kiovant.englishme.controller;

import com.google.firebase.auth.FirebaseToken;
import com.kiovant.englishme.dto.DailyGoalResponse;
import com.kiovant.englishme.dto.ProgressResponse;
import com.kiovant.englishme.dto.StreakCalendarResponse;
import com.kiovant.englishme.dto.UpdateDailyGoalRequest;
import com.kiovant.englishme.dto.UpdateProfileRequest;
import com.kiovant.englishme.dto.UserProfileResponse;
import com.kiovant.englishme.dto.XpHistoryItem;
import com.kiovant.englishme.dto.XpLedgerPage;
import com.kiovant.englishme.service.FirebaseAuthHelper;
import com.kiovant.englishme.service.ProfileService;
import com.kiovant.englishme.service.ProgressService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/users/me")
public class UserApiController {

    private final ProfileService profileService;
    private final ProgressService progressService;
    private final FirebaseAuthHelper authHelper;

    public UserApiController(ProfileService profileService,
                             ProgressService progressService,
                             FirebaseAuthHelper authHelper) {
        this.profileService = profileService;
        this.progressService = progressService;
        this.authHelper = authHelper;
    }

    @GetMapping
    public UserProfileResponse getProfile(
            @RequestHeader(value = "Authorization", required = false) String authorization
    ) {
        FirebaseToken token = authHelper.verifyBearer(authorization);
        return profileService.getProfile(token.getUid());
    }

    @PutMapping
    public UserProfileResponse updateProfile(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestBody UpdateProfileRequest body
    ) {
        FirebaseToken token = authHelper.verifyBearer(authorization);
        return profileService.updateProfile(token.getUid(), body);
    }

    @GetMapping("/progress")
    public ProgressResponse getProgress(
            @RequestHeader(value = "Authorization", required = false) String authorization
    ) {
        FirebaseToken token = authHelper.verifyBearer(authorization);
        return progressService.getProgress(token.getUid());
    }

    @GetMapping("/daily-goal")
    public DailyGoalResponse getDailyGoal(
            @RequestHeader(value = "Authorization", required = false) String authorization
    ) {
        FirebaseToken token = authHelper.verifyBearer(authorization);
        return progressService.getDailyGoal(token.getUid());
    }

    @PutMapping("/daily-goal")
    public DailyGoalResponse updateDailyGoal(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestBody UpdateDailyGoalRequest body
    ) {
        FirebaseToken token = authHelper.verifyBearer(authorization);
        return progressService.updateDailyGoal(token.getUid(), body.targetXp());
    }

    @GetMapping("/xp-history")
    public List<XpHistoryItem> getXpHistory(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestParam(defaultValue = "14") int days
    ) {
        FirebaseToken token = authHelper.verifyBearer(authorization);
        return progressService.getXpHistory(token.getUid(), days);
    }

    @GetMapping("/streak-calendar")
    public StreakCalendarResponse getStreakCalendar(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestParam(required = false) String month
    ) {
        FirebaseToken token = authHelper.verifyBearer(authorization);
        return progressService.getStreakCalendar(token.getUid(), month);
    }

    /**
     * Lịch sử transaction XP (per-row của xp_ledger), cursor-based pagination.
     *
     * @param cursor id của row cuối cùng trang trước (bỏ qua để lấy trang đầu).
     * @param limit  1..100, default 20.
     */
    @GetMapping("/xp/ledger")
    public XpLedgerPage getXpLedger(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestParam(required = false) String cursor,
            @RequestParam(defaultValue = "20") int limit
    ) {
        FirebaseToken token = authHelper.verifyBearer(authorization);
        return progressService.getXpLedger(token.getUid(), cursor, limit);
    }
}
