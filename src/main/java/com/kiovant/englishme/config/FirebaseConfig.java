package com.kiovant.englishme.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Configuration;

import jakarta.annotation.PostConstruct;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

// Credentials nạp từ đường dẫn file ngoài classpath (env FIREBASE_CREDENTIALS_PATH)
// để key không bị đóng gói vào JAR. Tắt toàn bộ Firebase bằng
// englishme.firebase.enabled=false (dùng cho test/CI không có key).
@Configuration
@ConditionalOnProperty(name = "englishme.firebase.enabled", havingValue = "true", matchIfMissing = true)
public class FirebaseConfig {

    @Value("${englishme.firebase.credentials-path:}")
    private String credentialsPath;

    @PostConstruct
    public void initFirebase() throws IOException {
        if (!FirebaseApp.getApps().isEmpty()) {
            return;
        }
        if (credentialsPath == null || credentialsPath.isBlank()) {
            throw new IllegalStateException(
                    "Thiếu FIREBASE_CREDENTIALS_PATH — set env trỏ tới file service account JSON "
                            + "(xem docs/dev-setup.md). Không đặt file key trong src/main/resources.");
        }
        try (InputStream serviceAccount = new FileInputStream(credentialsPath)) {
            FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                    .build();
            FirebaseApp.initializeApp(options);
        }
    }
}
