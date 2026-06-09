package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.PronunciationAssessResponse;
import com.kiovant.englishme.dto.PronunciationErrorDto;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

/**
 * Chấm phát âm dựa trên transcript (text người dùng nói được từ STT) so với câu mẫu.
 *
 * Thuật toán chấm: Levenshtein Distance theo từ (theo đề cương DATN).
 * Tính số phép sửa tối thiểu (thêm/xóa/thay) để biến chuỗi từ người học nói được
 * thành câu mẫu, từ đó suy ra độ chính xác và điểm phát âm.
 */
@Service
public class LevenshteinPronunciationScorer {

    public PronunciationAssessResponse score(String referenceText, String spokenText) {
        // Thuật toán chấm chính: Levenshtein Distance theo từ (theo đề cương DATN).
        // So transcript người học nói được (STT) với câu mẫu để tính điểm phát âm.
        return levenshteinScore(referenceText, spokenText);
    }

    // ── Chấm điểm: Levenshtein Distance theo từ ──────────────────────────────

    private PronunciationAssessResponse levenshteinScore(String referenceText, String spokenText) {
        List<String> ref = tokenize(referenceText);
        List<String> spoken = tokenize(spokenText);

        int distance = wordLevenshtein(ref, spoken);
        int maxLen = Math.max(ref.size(), spoken.size());
        double similarity = maxLen == 0 ? 1.0 : 1.0 - ((double) distance / maxLen);
        double accuracy = clamp(similarity * 100);

        long matched = ref.stream().filter(spoken::contains).count();
        double completeness = ref.isEmpty() ? 0 : clamp((double) matched / ref.size() * 100);
        double score = (accuracy * 0.7) + (completeness * 0.3);

        List<PronunciationErrorDto> errors = new ArrayList<>();
        for (int i = 0; i < ref.size(); i++) {
            String word = ref.get(i);
            if (!spoken.contains(word)) {
                errors.add(new PronunciationErrorDto(
                        word, i, word,
                        i < spoken.size() ? spoken.get(i) : "",
                        "Cần luyện lại từ \"" + word + "\". Đọc chậm, nhấn rõ trọng âm."
                ));
            }
        }
        String comment = buildComment(errors.size(), ref.size());
        return new PronunciationAssessResponse(score, accuracy, accuracy, completeness, spokenText, errors, comment);
    }

    private static List<String> tokenize(String text) {
        if (text == null) {
            return List.of();
        }
        List<String> out = new ArrayList<>();
        for (String w : text.toLowerCase().replaceAll("[^a-z0-9'\\s]", " ").split("\\s+")) {
            if (!w.isBlank()) {
                out.add(w);
            }
        }
        return out;
    }

    /**
     * Levenshtein Distance giữa hai chuỗi từ (mỗi từ là một "ký tự" trong thuật toán).
     * Trả số phép sửa tối thiểu (thêm/xóa/thay từ) để biến danh sách a thành b.
     * Dùng quy hoạch động hai hàng (O(n) bộ nhớ).
     */
    private static int wordLevenshtein(List<String> a, List<String> b) {
        if (a.isEmpty()) return b.size();
        if (b.isEmpty()) return a.size();
        int[] prev = new int[b.size() + 1];
        int[] curr = new int[b.size() + 1];
        for (int j = 0; j <= b.size(); j++) prev[j] = j;
        for (int i = 1; i <= a.size(); i++) {
            curr[0] = i;
            for (int j = 1; j <= b.size(); j++) {
                int cost = a.get(i - 1).equals(b.get(j - 1)) ? 0 : 1;
                curr[j] = Math.min(Math.min(prev[j] + 1, curr[j - 1] + 1), prev[j - 1] + cost);
            }
            int[] tmp = prev;
            prev = curr;
            curr = tmp;
        }
        return prev[b.size()];
    }

    private static String buildComment(int errorCount, int totalWords) {
        if (errorCount == 0) {
            return "Đọc rất khớp với câu mẫu. Tiếp tục luyện tập để duy trì phong độ.";
        }
        double rate = totalWords == 0 ? 0 : (double) errorCount / totalWords;
        if (rate <= 0.2) {
            return "Khá tốt. Cần cải thiện một vài từ nhỏ.";
        }
        if (rate <= 0.5) {
            return "Mức trung bình. Nên luyện lại các từ bị sai và đọc cả câu 2-3 lần.";
        }
        return "Cần luyện thêm. Chia câu thành đoạn ngắn và luyện từng đoạn.";
    }

    private static double clamp(double value) {
        return Math.min(Math.max(value, 0), 100);
    }
}
