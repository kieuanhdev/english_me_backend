package com.kiovant.englishme.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.kiovant.englishme.dto.PronunciationAssessResponse;
import com.kiovant.englishme.dto.PronunciationErrorDto;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

import org.springframework.stereotype.Component;

@Component
public class PronunciationScoringMapper {

    public PronunciationAssessResponse mapSpeechace(JsonNode root, String referenceText) {
        JsonNode textScore = root.path("text_score");

        double score = clamp(textScore.path("quality_score").asDouble(0));
        double accuracy = clamp(textScore.path("pronunciation").path("score").asDouble(0));
        double fluency = clamp(textScore.path("fluency").path("score").asDouble(0));

        List<WordResult> wordResults = new ArrayList<>();
        int pos = 0;
        for (JsonNode word : textScore.path("word_score_list")) {
            String token = word.path("word").asText("").trim();
            if (token.isEmpty()) {
                continue;
            }
            double wordScore = clamp(word.path("quality_score").asDouble(0));
            double startSec = word.path("start").asDouble(0);
            wordResults.add(new WordResult(token, wordScore, pos, startSec));
            pos++;
        }
        wordResults.sort(Comparator.comparingDouble(WordResult::startSec));

        // Nếu provider trả transcription thật (vd Gemini "heard" — lời thực nghe được),
        // ưu tiên dùng. Speechace không có -> ghép từ word_score_list như cũ.
        String heard = root.path("transcription").asText("");
        String transcription;
        if (!heard.isBlank()) {
            transcription = heard.trim();
        } else {
            StringBuilder sb = new StringBuilder();
            for (WordResult wr : wordResults) {
                if (!sb.isEmpty()) {
                    sb.append(' ');
                }
                sb.append(wr.word);
            }
            transcription = sb.toString();
        }

        String[] refWords = referenceText.toLowerCase().split("\\s+");
        double completeness = refWords.length == 0 ? 0
                : Math.min(100.0, Math.round((double) wordResults.size() / refWords.length * 100.0));

        List<PronunciationErrorDto> errors = new ArrayList<>();
        for (int i = 0; i < wordResults.size(); i++) {
            WordResult wr = wordResults.get(i);
            if (wr.score >= 80) {
                continue;
            }
            String expectedPhonetic = i < refWords.length ? refWords[i] : "";
            errors.add(new PronunciationErrorDto(
                    wr.word,
                    i,
                    expectedPhonetic,
                    wr.word,
                    buildSuggestion(wr.word, wr.score)
            ));
        }

        String overallComment = buildOverallComment(errors.size(), wordResults.size());
        return new PronunciationAssessResponse(score, accuracy, fluency, completeness, transcription, errors, overallComment);
    }

    private record WordResult(String word, double score, int index, double startSec) {
    }

    private static double clamp(double value) {
        return Math.min(Math.max(value, 0), 100);
    }

    private static String buildSuggestion(String word, double score) {
        if (score >= 80) {
            return "Phát âm tốt, giữ nhịp nói ổn định.";
        }
        if (score >= 60) {
            return "Luyện lại từ \"" + word + "\" chậm hơn và nhấn rõ trọng âm.";
        }
        return "Cần luyện lại từ \"" + word + "\". Đọc tách âm tiết, mở khẩu hình rõ hơn.";
    }

    private static String buildOverallComment(int errorCount, int totalWords) {
        if (errorCount == 0) {
            return "Phát âm rất tốt. Tiếp tục luyện tập để duy trì phong độ.";
        }
        double errorRate = totalWords == 0 ? 0 : (double) errorCount / totalWords;
        if (errorRate <= 0.2) {
            return "Phát âm khá tốt. Cần cải thiện một vài từ nhỏ.";
        }
        if (errorRate <= 0.5) {
            return "Phát âm ở mức trung bình. Nên luyện lại các từ bị sai và đọc cả câu 2-3 lần.";
        }
        return "Cần luyện tập thêm. Chia câu thành các đoạn ngắn và luyện từng đoạn trước khi đọc toàn bộ.";
    }
}
