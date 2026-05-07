package com.kiovant.englishme.controller;

import com.google.firebase.auth.FirebaseToken;
import com.kiovant.englishme.dto.UserSyncResponse;
import com.kiovant.englishme.entity.User;
import com.kiovant.englishme.service.FirebaseAuthHelper;
import com.kiovant.englishme.service.UserService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final UserService userService;
    private final FirebaseAuthHelper authHelper;

    public AuthController(UserService userService, FirebaseAuthHelper authHelper) {
        this.userService = userService;
        this.authHelper = authHelper;
    }

    @PostMapping("/sync")
    public UserSyncResponse sync(@RequestHeader("Authorization") String token) {
        FirebaseToken decodedToken = authHelper.verifyBearer(token);
        User user = userService.syncUser(decodedToken);
        return new UserSyncResponse(
                user.getId(),
                user.getEmail(),
                user.getFullName(),
                user.getAvatarUrl(),
                user.getCefrLevel(),
                user.getIsOnboarded(),
                user.getCreatedAt()
        );
    }
}