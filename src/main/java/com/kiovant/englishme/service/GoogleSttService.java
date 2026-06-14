package com.kiovant.englishme.service;

import com.google.api.gax.core.FixedCredentialsProvider;
import com.google.auth.oauth2.GoogleCredentials;
import com.google.cloud.speech.v1.RecognitionAudio;
import com.google.cloud.speech.v1.RecognitionConfig;
import com.google.cloud.speech.v1.RecognizeResponse;
import com.google.cloud.speech.v1.SpeechClient;
import com.google.cloud.speech.v1.SpeechRecognitionAlternative;
import com.google.cloud.speech.v1.SpeechRecognitionResult;
import com.google.cloud.speech.v1.SpeechSettings;
import com.google.protobuf.ByteString;
import jakarta.annotation.PreDestroy;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.io.ByteArrayInputStream;
import java.nio.charset.StandardCharsets;

/**
 * Google Cloud Speech-to-Text: nhận audio bytes -> trả transcript text.
 *
 * Đáp ứng đề cương MT4 ("Google Speech-to-Text API"). Transcript sau đó được
 * {@link PronunciationAssessmentService} chấm bằng Levenshtein như luồng assess-text.
 *
 * Cấu hình đọc RUNTIME từ app_config (admin bật/tắt + dán key trên /admin/config,
 * không cần build/restart — giống {@link LlmClient}):
 *   STT_ENABLED          — bật/tắt (mặc định false).
 *   STT_CREDENTIALS_JSON — nội dung service account JSON. Trống -> Application Default
 *                          Credentials (env GOOGLE_APPLICATION_CREDENTIALS).
 *   STT_LANGUAGE         — mã ngôn ngữ (mặc định en-US).
 *   STT_SAMPLE_RATE      — sample rate Hz client gửi (mặc định 16000).
 *
 * Thiếu cấu hình / lỗi -> {@link #isConfigured()} = false, controller fallback
 * sang luồng assess-text (mobile gửi transcript on-device).
 */
@Service
public class GoogleSttService {

    private static final Logger log = LoggerFactory.getLogger(GoogleSttService.class);

    public static final String KEY_ENABLED = "STT_ENABLED";
    public static final String KEY_CREDENTIALS_JSON = "STT_CREDENTIALS_JSON";
    public static final String KEY_LANGUAGE = "STT_LANGUAGE";
    public static final String KEY_SAMPLE_RATE = "STT_SAMPLE_RATE";

    private final AppConfigService appConfigService;

    /**
     * SpeechClient tái sử dụng giữa các request (thread-safe theo docs Google).
     * Tạo client = đọc credentials + TLS handshake + auth, đắt -> cache lại.
     * Vì credentials giờ đọc runtime từ DB, admin đổi key thì client cũ phải bỏ:
     * lưu kèm dấu vân tay (fingerprint) của JSON đang dùng; mỗi lần dùng so với
     * giá trị DB hiện tại, khác -> đóng client cũ + build lại.
     */
    private volatile SpeechClient client;
    private volatile String clientFingerprint;

    public GoogleSttService(AppConfigService appConfigService) {
        this.appConfigService = appConfigService;
    }

    /** Bật STT chưa. Controller hỏi trước để quyết fallback assess-text. */
    public boolean isConfigured() {
        return enabled();
    }

    private boolean enabled() {
        return "true".equalsIgnoreCase(appConfigService.getOr(KEY_ENABLED, "false").trim());
    }

    /**
     * Nhận diện audio -> transcript. Trả chuỗi rỗng nếu không nhận ra/lỗi
     * (controller coi rỗng = thất bại, fallback).
     *
     * @param audioBytes nội dung file audio (LINEAR16/WAV PCM mono, sample rate = STT_SAMPLE_RATE).
     */
    public String transcribe(byte[] audioBytes) {
        if (!enabled()) {
            return "";
        }
        if (audioBytes == null || audioBytes.length == 0) {
            return "";
        }
        try {
            SpeechClient client = getOrCreateClient();
            RecognitionConfig config = RecognitionConfig.newBuilder()
                    .setEncoding(RecognitionConfig.AudioEncoding.LINEAR16)
                    .setSampleRateHertz(appConfigService.getIntOr(KEY_SAMPLE_RATE, 16000))
                    .setLanguageCode(appConfigService.getOr(KEY_LANGUAGE, "en-US").trim())
                    .setEnableAutomaticPunctuation(true)
                    .build();
            RecognitionAudio audio = RecognitionAudio.newBuilder()
                    .setContent(ByteString.copyFrom(audioBytes))
                    .build();

            RecognizeResponse response = client.recognize(config, audio);
            StringBuilder sb = new StringBuilder();
            for (SpeechRecognitionResult result : response.getResultsList()) {
                if (result.getAlternativesCount() > 0) {
                    SpeechRecognitionAlternative alt = result.getAlternatives(0);
                    if (sb.length() > 0) {
                        sb.append(' ');
                    }
                    sb.append(alt.getTranscript().trim());
                }
            }
            return sb.toString().trim();
        } catch (Exception ex) {
            // Không log ex.getMessage() vào message chính (có thể chứa chi tiết hạ tầng);
            // full stack ở mức debug cho dev tra cứu.
            log.error("Google STT transcribe failed ({})", ex.getClass().getSimpleName());
            log.debug("Google STT transcribe stack trace", ex);
            return "";
        }
    }

    /**
     * Trả client khớp credentials DB hiện tại. JSON đổi (fingerprint khác) -> đóng
     * client cũ, build lại. Double-checked trên monitor của bean.
     */
    private SpeechClient getOrCreateClient() throws Exception {
        String credentialsJson = appConfigService.getOr(KEY_CREDENTIALS_JSON, "");
        String fingerprint = fingerprint(credentialsJson);

        SpeechClient local = client;
        if (local != null && fingerprint.equals(clientFingerprint)) {
            return local;
        }
        synchronized (this) {
            if (client != null && fingerprint.equals(clientFingerprint)) {
                return client;
            }
            if (client != null) {
                client.close();
                client = null;
            }
            SpeechClient built = buildClient(credentialsJson);
            client = built;
            clientFingerprint = fingerprint;
            return built;
        }
    }

    @PreDestroy
    void closeClient() {
        SpeechClient local = client;
        if (local != null) {
            local.close();
        }
    }

    /**
     * Tạo SpeechClient: có JSON credentials thì nạp từ chuỗi, không thì dùng ADC
     * (env GOOGLE_APPLICATION_CREDENTIALS).
     */
    private SpeechClient buildClient(String credentialsJson) throws Exception {
        if (credentialsJson != null && !credentialsJson.isBlank()) {
            try (ByteArrayInputStream in =
                         new ByteArrayInputStream(credentialsJson.getBytes(StandardCharsets.UTF_8))) {
                GoogleCredentials credentials = GoogleCredentials.fromStream(in);
                SpeechSettings settings = SpeechSettings.newBuilder()
                        .setCredentialsProvider(FixedCredentialsProvider.create(credentials))
                        .build();
                return SpeechClient.create(settings);
            }
        }
        // Application Default Credentials (env GOOGLE_APPLICATION_CREDENTIALS).
        return SpeechClient.create();
    }

    /** Vân tay phân biệt credentials để biết khi nào rebuild client. Không log nội dung. */
    private static String fingerprint(String credentialsJson) {
        String s = credentialsJson == null ? "" : credentialsJson.trim();
        return s.length() + ":" + Integer.toHexString(s.hashCode());
    }
}
