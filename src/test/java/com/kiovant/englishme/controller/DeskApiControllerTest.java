package com.kiovant.englishme.controller;

import com.google.firebase.auth.FirebaseToken;
import com.kiovant.englishme.dto.DeskResponse;
import com.kiovant.englishme.service.DeskFlashcardService;
import com.kiovant.englishme.service.FirebaseAuthHelper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.http.HttpStatus;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * MockMvc test chốt AUTH CONTRACT của API mobile: mọi endpoint /api/** phải
 * verifyBearer và fail-closed 401 khi thiếu/hỏng token.
 *
 * Đây là khuôn mẫu — nhân bản sang controller khác để CI bắt được endpoint
 * mới quên gọi verifyBearer (lỗ hổng im lặng nguy hiểm nhất của contract này).
 */
@WebMvcTest(DeskApiController.class)
class DeskApiControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private DeskFlashcardService deskFlashcardService;

    @MockitoBean
    private FirebaseAuthHelper authHelper;

    @Test
    @DisplayName("GET /api/desks không có Authorization header -> 401")
    void listDesksWithoutTokenReturns401() throws Exception {
        when(authHelper.verifyBearer(isNull()))
                .thenThrow(new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Authorization Bearer token required"));

        mockMvc.perform(get("/api/desks"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("GET /api/desks token hỏng -> 401 (không lộ chi tiết)")
    void listDesksWithInvalidTokenReturns401() throws Exception {
        when(authHelper.verifyBearer("Bearer bad-token"))
                .thenThrow(new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid token"));

        mockMvc.perform(get("/api/desks").header("Authorization", "Bearer bad-token"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("GET /api/desks token hợp lệ -> 200, trả desk của đúng uid trong token")
    void listDesksWithValidTokenReturns200() throws Exception {
        FirebaseToken token = mock(FirebaseToken.class);
        when(token.getUid()).thenReturn("uid-1");
        when(authHelper.verifyBearer("Bearer good-token")).thenReturn(token);
        when(deskFlashcardService.listDesks("uid-1")).thenReturn(List.of(
                new DeskResponse(UUID.randomUUID(), "A1", "My desk", 1,
                        LocalDateTime.now(), 5L, false)));

        mockMvc.perform(get("/api/desks").header("Authorization", "Bearer good-token"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].title").value("My desk"));
    }

    @Test
    @DisplayName("GET /api/desks/{id}/flashcards không token -> 401 (path có param cũng phải gác)")
    void listFlashcardsWithoutTokenReturns401() throws Exception {
        when(authHelper.verifyBearer(any()))
                .thenThrow(new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Authorization Bearer token required"));

        mockMvc.perform(get("/api/desks/{id}/flashcards", UUID.randomUUID()))
                .andExpect(status().isUnauthorized());
    }
}
