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
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.ByteArrayInputStream;
import java.io.InputStream;

/**
 * Google Cloud Speech-to-Text: nhận audio bytes -> trả transcript text.
 *
 * Đáp ứng đề cương MT4 ("Google Speech-to-Text API"). Transcript sau đó được
 * {@link PronunciationAssessmentService} chấm bằng Levenshtein như luồng assess-text.
 *
 * Cấu hình (application.properties / env):
 *   englishme.ai.stt.enabled        — bật/tắt (mặc định false).
 *   englishme.ai.stt.credentials    — đường dẫn service account JSON (hoặc để trống
 *                                      và dùng env GOOGLE_APPLICATION_CREDENTIALS).
 *   englishme.ai.stt.language       — mã ngôn ngữ (mặc định en-US).
 *   englishme.ai.stt.sample-rate    — sample rate Hz client gửi (mặc định 16000).
 *
 * Thiếu cấu hình / lỗi -> {@link #isConfigured()} = false, controller fallback
 * sang luồng assess-text (mobile gửi transcript on-device).
 */
@Service
public class GoogleSttService {

    private static final Logger log = LoggerFactory.getLogger(GoogleSttService.class);

    private final boolean enabled;
    private final String credentialsPath;
    private final String languageCode;
    private final int sampleRateHz;

    /**
     * SpeechClient tái sử dụng giữa các request (thread-safe theo docs Google).
     * Trước đây mỗi lần transcribe tạo client mới = đọc lại credentials file +
     * TLS handshake + auth — chậm và lãng phí. Lazy init double-checked; init
     * fail thì để null, lần gọi sau thử lại.
     */
    private volatile SpeechClient client;

    public GoogleSttService(
            @Value("${englishme.ai.stt.enabled:false}") boolean enabled,
            @Value("${englishme.ai.stt.credentials:}") String credentialsPath,
            @Value("${englishme.ai.stt.language:en-US}") String languageCode,
            @Value("${englishme.ai.stt.sample-rate:16000}") int sampleRateHz
    ) {
        this.enabled = enabled;
        this.credentialsPath = credentialsPath;
        this.languageCode = languageCode;
        this.sampleRateHz = sampleRateHz;
    }

    /** Bật STT chưa. Controller hỏi trước để quyết fallback assess-text. */
    public boolean isConfigured() {
        return enabled;
    }

    /**
     * Nhận diện audio -> transcript. Trả chuỗi rỗng nếu không nhận ra/lỗi
     * (controller coi rỗng = thất bại, fallback).
     *
     * @param audioBytes nội dung file audio (LINEAR16/WAV PCM mono, sample rate = sample-rate).
     */
    public String transcribe(byte[] audioBytes) {
        if (!enabled) {
            return "";
        }
        if (audioBytes == null || audioBytes.length == 0) {
            return "";
        }
        try {
            SpeechClient client = getOrCreateClient();
            RecognitionConfig config = RecognitionConfig.newBuilder()
                    .setEncoding(RecognitionConfig.AudioEncoding.LINEAR16)
                    .setSampleRateHertz(sampleRateHz)
                    .setLanguageCode(languageCode)
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

    private SpeechClient getOrCreateClient() throws Exception {
        SpeechClient local = client;
        if (local == null) {
            synchronized (this) {
                local = client;
                if (local == null) {
                    local = buildClient();
                    client = local;
                }
            }
        }
        return local;
    }

    @PreDestroy
    void closeClient() {
        SpeechClient local = client;
        if (local != null) {
            local.close();
        }
    }

    /** Tạo SpeechClient: nếu có credentials path thì nạp, không thì dùng ADC (env). */
    private SpeechClient buildClient() throws Exception {
        if (credentialsPath != null && !credentialsPath.isBlank()) {
            try (InputStream in = new ByteArrayInputStream(java.nio.file.Files.readAllBytes(
                    java.nio.file.Path.of(credentialsPath.trim())))) {
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
}
