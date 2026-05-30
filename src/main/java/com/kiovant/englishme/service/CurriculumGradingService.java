package com.kiovant.englishme.service;

import com.kiovant.englishme.entity.LearningLessonActivity;
import org.springframework.stereotype.Service;

import java.text.Normalizer;
import java.util.List;
import java.util.Map;

/**
 * Chấm bài SERVER-SIDE cho luồng giáo trình. FE gửi đáp án THÔ (không tự chấm),
 * service này chấm theo activity_type rồi trả đúng/sai + đáp án đúng + giải thích.
 *
 * <p>Bám catalog 8 dạng (KE_HOACH_BE_BAI_TAP_VA_DU_LIEU.md §D):
 * <ul>
 *   <li>multiple_choice / listening_choice → so selectedOptionId == correctOptionId</li>
 *   <li>grammar_fill_blank / translation / error_correction → chuẩn hoá text ∈ acceptedAnswers</li>
 *   <li>vocabulary_match → từng cặp pairs[i].right khớp đáp án user</li>
 *   <li>sentence_ordering → mảng order == correctOrder</li>
 *   <li>pronunciation → audio chấm qua PronunciationAssessmentService (endpoint riêng);
 *       ở đây coi như đạt khi user đánh dấu đã ghi âm (không tính mastery)</li>
 *   <li>writing_prompt → chủ quan, không chấm cứng (đạt = đã viết, không tính mastery)</li>
 * </ul>
 *
 * <p>Định dạng "answer thô" (Map từ FE) — chỉ field liên quan tới dạng được đọc:
 * <pre>
 * { "activityId": "...",
 *   "selectedOptionId": "b",        // mcq | listening_choice
 *   "text": "good morning",         // fill_blank | translation | error_correction
 *   "match": {"Hello":"Xin chào"},  // vocabulary_match (left → right user chọn)
 *   "order": [1,0,3,2],             // sentence_ordering
 *   "pronounced": true              // pronunciation
 * }
 * </pre>
 */
@Service
public class CurriculumGradingService {

    /** Kết quả chấm 1 câu. */
    public record Graded(
            String activityId,
            String type,
            boolean correct,
            boolean autoGraded,      // false với pronunciation/writing (không chấm khách quan)
            Object correctAnswer,    // đáp án đúng để FE hiển thị (optionId | text | order | pairs)
            String explanationVi
    ) {}

    @SuppressWarnings("unchecked")
    public Graded grade(LearningLessonActivity activity, Map<String, Object> answer) {
        Map<String, Object> p = activity.getPayload() != null ? activity.getPayload() : Map.of();
        String type = activity.getActivityType();
        String explanation = str(p.get("explanationVi"));

        switch (type) {
            case "multiple_choice", "listening_choice" -> {
                String correctId = str(p.get("correctOptionId"));
                String picked = answer == null ? null : str(answer.get("selectedOptionId"));
                boolean ok = correctId != null && correctId.equals(picked);
                return new Graded(activity.getId(), type, ok, true, correctId, explanation);
            }
            case "grammar_fill_blank", "translation", "error_correction" -> {
                List<String> accepted = asStringList(p.get("acceptedAnswers"));
                String userText = answer == null ? "" : str(answer.get("text"));
                String norm = normalize(userText);
                boolean ok = !norm.isEmpty() && accepted.stream().anyMatch(a -> normalize(a).equals(norm));
                Object correctAns = accepted.isEmpty() ? null : accepted.get(0);
                return new Graded(activity.getId(), type, ok, true, correctAns, explanation);
            }
            case "vocabulary_match" -> {
                List<Map<String, Object>> pairs = asMapList(p.get("pairs"));
                Map<String, Object> userMatch = answer == null ? Map.of()
                        : (Map<String, Object>) answer.getOrDefault("match", Map.of());
                boolean ok = !pairs.isEmpty() && pairs.stream().allMatch(pair -> {
                    String left = str(pair.get("left"));
                    String right = str(pair.get("right"));
                    String chosen = str(userMatch.get(left));
                    return right != null && right.equals(chosen);
                });
                return new Graded(activity.getId(), type, ok, true, pairs, explanation);
            }
            case "sentence_ordering" -> {
                List<Integer> correctOrder = asIntList(p.get("correctOrder"));
                List<Integer> userOrder = answer == null ? List.of() : asIntList(answer.get("order"));
                boolean ok = !correctOrder.isEmpty() && correctOrder.equals(userOrder);
                return new Graded(activity.getId(), type, ok, true, correctOrder, explanation);
            }
            case "pronunciation" -> {
                // Audio chấm qua endpoint /pronunciation riêng (Levenshtein server-side).
                // Trong flow giáo trình: đạt khi đã ghi âm; KHÔNG tính mastery.
                boolean pronounced = answer != null && Boolean.TRUE.equals(answer.get("pronounced"));
                return new Graded(activity.getId(), type, pronounced, false, str(p.get("targetText")), explanation);
            }
            case "writing_prompt" -> {
                String text = answer == null ? "" : str(answer.get("text"));
                boolean written = text != null && !text.isBlank();
                return new Graded(activity.getId(), type, written, false, null, explanation);
            }
            default -> {
                // Dạng chưa biết → không chấm khách quan, coi như đạt để không chặn flow.
                return new Graded(activity.getId(), type, true, false, null, explanation);
            }
        }
    }

    // ── helpers chuẩn hoá ────────────────────────────────────────────────────

    /** trim + lowercase + gộp khoảng trắng + bỏ dấu câu cuối + bỏ dấu unicode thừa. */
    private String normalize(String s) {
        if (s == null) return "";
        String x = Normalizer.normalize(s, Normalizer.Form.NFC).trim().toLowerCase();
        x = x.replaceAll("\\s+", " ");
        x = x.replaceAll("[.!?,;:]+$", ""); // bỏ dấu câu ở cuối để "Good morning." == "Good morning"
        return x.trim();
    }

    private String str(Object o) { return o == null ? null : String.valueOf(o); }

    @SuppressWarnings("unchecked")
    private List<String> asStringList(Object o) {
        if (o instanceof List<?> l) return l.stream().map(String::valueOf).toList();
        return List.of();
    }

    @SuppressWarnings("unchecked")
    private List<Map<String, Object>> asMapList(Object o) {
        if (o instanceof List<?> l) {
            return l.stream().filter(e -> e instanceof Map).map(e -> (Map<String, Object>) e).toList();
        }
        return List.of();
    }

    private List<Integer> asIntList(Object o) {
        if (o instanceof List<?> l) {
            return l.stream().map(e -> {
                if (e instanceof Number n) return n.intValue();
                try { return Integer.parseInt(String.valueOf(e)); } catch (NumberFormatException ex) { return -1; }
            }).toList();
        }
        return List.of();
    }
}
