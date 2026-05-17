package com.kiovant.englishme.controller;

import com.google.firebase.auth.FirebaseToken;
import com.kiovant.englishme.dto.HomeDashboardResponse;
import com.kiovant.englishme.service.FirebaseAuthHelper;
import com.kiovant.englishme.service.HomeDashboardService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/home")
public class HomeApiController {

    private final HomeDashboardService homeDashboardService;
    private final FirebaseAuthHelper authHelper;

    public HomeApiController(HomeDashboardService homeDashboardService, FirebaseAuthHelper authHelper) {
        this.homeDashboardService = homeDashboardService;
        this.authHelper = authHelper;
    }

    @GetMapping("/dashboard")
    public HomeDashboardResponse getDashboard(
            @RequestHeader(value = "Authorization", required = false) String authorization
    ) {
        FirebaseToken token = authHelper.verifyBearer(authorization);
        return homeDashboardService.getDashboard(token.getUid());
    }
}
