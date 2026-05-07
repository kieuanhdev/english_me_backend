package com.kiovant.englishme.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.kiovant.englishme.dto.PronunciationAssessResponse;
import com.kiovant.englishme.dto.PronunciationWordFeedbackDto;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

@Component
public class PronunciationScoringMapper {

    public PronunciationAssessResponse mapSpeechace(UUID attemptId, JsonNode root, String provider) {
        JsonNode textScore = root.path("text_score");

        int overall = clampScore(textScore.path("quality_score").asInt(0));
        int accuracy = clampScore(textScore.path("pronunciation").path("score").asInt(0));
        int fluency = clampScore(textScore.path("fluency").path("score").asInt(0));

        List<PronunciationWordFeedbackDto> words = new ArrayList<>();
        for (JsonNode word : textScore.path("word_score_list")) {
            String token = word.path("word").asText("").trim();
            if (token.isEmpty()) {
                continue;
            }
            int score = clampScore(word.path("quality_score").asInt(0));
            int startMs = (int) Math.round(word.path("start").asDouble(0) * 1000);
            int endMs = (int) Math.round(word.path("end").asDouble(0) * 1000);
            String issueType = score >= 80 ? "good" : (score >= 60 ? "minor" : "critical");
            String suggestion = buildSuggestion(token, score);
            words.add(new PronunciationWordFeedbackDto(token, score, startMs, endMs, issueType, suggestion));
        }

        words.sort(Comparator.comparingInt(PronunciationWordFeedbackDto::startMs));
        List<String> tips = buildTips(words);
        String retryAdvice = buildRetryAdvice(words);
        return new PronunciationAssessResponse(attemptId, overall, accuracy, fluency, words, tips, retryAdvice, provider);
    }

    private static int clampScore(int score) {
        return Math.min(Math.max(score, 0), 100);
    }

    private static String buildSuggestion(String word, int score) {
        if (score >= 80) {
            return "Phat am tot, giu nhip noi on dinh.";
        }
        if (score >= 60) {
            return "Luyen lai tu \"" + word + "\" cham hon va nhan ro trong am.";
        }
        return "Can luyen lai tu \"" + word + "\". Doc tach am tiet, mo khau hinh ro hon.";
    }

    private static List<String> buildTips(List<PronunciationWordFeedbackDto> words) {
        List<PronunciationWordFeedbackDto> weakWords = words.stream()
                .filter(w -> w.score() < 80)
                .limit(3)
                .toList();
        if (weakWords.isEmpty()) {
            return List.of("Ban phat am kha on. Hay giu toc do noi va ngu dieu hien tai.");
        }
        List<String> tips = new ArrayList<>();
        tips.add("Tap trung luyen cac tu: " + weakWords.stream().map(PronunciationWordFeedbackDto::word).reduce((a, b) -> a + ", " + b).orElse(""));
        tips.add("Doc cham theo tung cum 3-5 tu, sau do tang toc do dan.");
        tips.add("Nghe lai cau mau va bat chuoc trong am cua tu khoa.");
        return tips;
    }

    private static String buildRetryAdvice(List<PronunciationWordFeedbackDto> words) {
        long critical = words.stream().filter(w -> w.score() < 60).count();
        if (critical == 0) {
            return "Ban da dat muc tot. Thu doc lai nhanh hon de cai thien do troi chay.";
        }
        if (critical <= 2) {
            return "Luyen lai tung tu sai, sau do doc lai ca cau 2-3 lan.";
        }
        return "Nen chia cau thanh nhieu doan ngan va luyen tung doan truoc khi doc toan bo.";
    }
}
