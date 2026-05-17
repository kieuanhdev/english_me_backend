package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.BadgeResponse;
import com.kiovant.englishme.dto.UpdateProfileRequest;
import com.kiovant.englishme.dto.UserProfileResponse;
import com.kiovant.englishme.entity.User;
import com.kiovant.englishme.entity.UserBadge;
import com.kiovant.englishme.repository.UserBadgeRepository;
import com.kiovant.englishme.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Set;

@Service
public class ProfileService {

    private static final Set<String> ALLOWED_CEFR = Set.of("A1", "A2", "B1", "B2", "C1", "C2");

    private final UserRepository userRepository;
    private final UserBadgeRepository userBadgeRepository;

    public ProfileService(UserRepository userRepository, UserBadgeRepository userBadgeRepository) {
        this.userRepository = userRepository;
        this.userBadgeRepository = userBadgeRepository;
    }

    @Transactional(readOnly = true)
    public UserProfileResponse getProfile(String firebaseUid) {
        User user = loadUser(firebaseUid);
        return toResponse(user, loadBadges(user));
    }

    @Transactional
    public UserProfileResponse updateProfile(String firebaseUid, UpdateProfileRequest req) {
        if (req == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Body is required");
        }
        User user = loadUser(firebaseUid);

        if (req.displayName() != null) {
            String name = req.displayName().trim();
            if (name.isEmpty()) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "displayName must not be blank");
            }
            user.setFullName(name);
        }

        if (req.cefrLevel() != null) {
            String level = req.cefrLevel().trim().toUpperCase();
            if (!ALLOWED_CEFR.contains(level)) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "cefrLevel must be one of A1, A2, B1, B2, C1, C2");
            }
            user.setCefrLevel(level);
        }

        User saved = userRepository.save(user);
        return toResponse(saved, loadBadges(saved));
    }

    private User loadUser(String firebaseUid) {
        return userRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
    }

    private List<BadgeResponse> loadBadges(User user) {
        return userBadgeRepository.findByUser_Id(user.getId()).stream()
                .map(this::toBadgeResponse)
                .toList();
    }

    private BadgeResponse toBadgeResponse(UserBadge ub) {
        return new BadgeResponse(
                ub.getBadge().getId(),
                ub.getBadge().getName(),
                ub.getBadge().getDescription(),
                ub.getBadge().getIconUrl(),
                ub.getBadge().getConditionType(),
                ub.getEarnedAt()
        );
    }

    private UserProfileResponse toResponse(User user, List<BadgeResponse> badges) {
        return new UserProfileResponse(
                user.getId(),
                user.getEmail(),
                user.getFullName(),
                user.getAvatarUrl(),
                user.getCefrLevel(),
                user.getIsOnboarded(),
                user.getTotalXp(),
                user.getCurrentStreak(),
                user.getLongestStreak(),
                user.getLastActiveDate(),
                user.getCreatedAt(),
                badges
        );
    }
}
