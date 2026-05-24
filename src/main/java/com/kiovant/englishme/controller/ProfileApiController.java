package com.kiovant.englishme.controller;

import com.google.firebase.auth.FirebaseToken;
import com.kiovant.englishme.dto.UserProfileResponse;
import com.kiovant.englishme.service.FirebaseAuthHelper;
import com.kiovant.englishme.service.ProfileService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/profile")
public class ProfileApiController {

    private final ProfileService profileService;
    private final FirebaseAuthHelper authHelper;

    public ProfileApiController(ProfileService profileService, FirebaseAuthHelper authHelper) {
        this.profileService = profileService;
        this.authHelper = authHelper;
    }

    @GetMapping("/me")
    public UserProfileResponse getProfile(
            @RequestHeader(value = "Authorization", required = false) String authorization
    ) {
        FirebaseToken token = authHelper.verifyBearer(authorization);
        return profileService.getProfile(token.getUid());
    }
}
