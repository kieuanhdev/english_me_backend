package com.kiovant.englishme.service;

import com.kiovant.englishme.entity.LearningLesson;
import com.kiovant.englishme.repository.LearningLessonRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * Nguồn nội dung "xoay quanh bài giáo trình" cho 4 kỹ năng (Nghe/Nói/Đọc/Viết).
 *
 * <p>Thay vì 4 engine luyện nội dung ngẫu nhiên theo level, helper này trích
 * nguyên liệu (câu mẫu, từ vựng, chủ đề) từ {@code theory_content} của các bài
 * học (LearningLesson) mà user ĐÃ/ĐANG học — để luyện tập = ôn lại đúng cái vừa
 * học. Một nơi parse JSON duy nhất → 4 engine không lặp lại logic (SOLID/DRY).
 *
 * <p>Hai chế độ:
 * <ul>
 *   <li>Theo level (mặc định, vào từ Home): gom mọi bài đã học cùng level.</li>
 *   <li>Theo lessonId (vào từ trong 1 lesson): chỉ nội dung của lesson đó.</li>
 * </ul>
 *
 * <p>Thiếu nội dung (user mới, chưa học bài nào) → trả rỗng; caller tự fallback
 * sang seed sẵn để engine không bao giờ rỗng.
 */
@Service
public class LessonContentSource {

    private final LearningLessonRepository lessonRepository;

    public LessonContentSource(LearningLessonRepository lessonRepository) {
        this.lessonRepository = lessonRepository;
    }

    /** Một câu mẫu en + nghĩa vi trích từ theory.examples của bài học. */
    public record SentenceItem(String en, String vi) {}

    /** Một mục từ vựng trích từ theory.vocabBlock của bài học. */
    public record VocabItem(String word, String ipa, String meaningVi, String example) {}

    /** Bộ nguyên liệu gom được; rỗng nghĩa là user chưa có bài học làm nguồn. */
    public record LessonMaterial(
            List<SentenceItem> sentences,
            List<VocabItem> vocab,
            List<String> topics // tiêu đề bài học → gợi ý chủ đề cho Nói/Viết
    ) {
        public boolean isEmpty() {
            return sentences.isEmpty() && vocab.isEmpty() && topics.isEmpty();
        }
    }

    /**
     * Gom nguyên liệu cho user theo level — mọi bài đã/đang học (bài gần nhất
     * trước). Dùng khi vào kỹ năng từ Home (không gắn lesson cụ thể).
     */
    @Transactional(readOnly = true)
    public LessonMaterial forLevel(UUID userId, String level) {
        if (level == null || level.isBlank()) return empty();
        List<LearningLesson> lessons =
                lessonRepository.findStudiedByUserAndLevel(userId, level.trim().toUpperCase());
        return extract(lessons);
    }

    /**
     * Gom nguyên liệu của đúng 1 lesson — dùng khi vào kỹ năng từ trong lesson đó
     * ("Luyện nghe câu trong bài"). Không kiểm tra ownership/progress: chỉ đọc nội
     * dung công khai của lesson, an toàn.
     */
    @Transactional(readOnly = true)
    public LessonMaterial forLesson(String lessonId) {
        if (lessonId == null || lessonId.isBlank()) return empty();
        return lessonRepository.findById(lessonId)
                .map(l -> extract(List.of(l)))
                .orElseGet(this::empty);
    }

    // ── Parse theory_content JSON → nguyên liệu ──────────────────────────────
    @SuppressWarnings("unchecked")
    private LessonMaterial extract(List<LearningLesson> lessons) {
        List<SentenceItem> sentences = new ArrayList<>();
        List<VocabItem> vocab = new ArrayList<>();
        List<String> topics = new ArrayList<>();

        for (LearningLesson l : lessons) {
            if (l.getTitle() != null && !l.getTitle().isBlank()) topics.add(l.getTitle());

            Map<String, Object> theory = l.getTheoryContent();
            if (theory == null) continue;

            Object examples = theory.get("examples");
            if (examples instanceof List<?> list) {
                for (Object o : list) {
                    if (o instanceof Map<?, ?> m) {
                        String en = str(m.get("en"));
                        if (!en.isBlank()) sentences.add(new SentenceItem(en, str(m.get("vi"))));
                    }
                }
            }

            Object vocabBlock = theory.get("vocabBlock");
            if (vocabBlock instanceof List<?> list) {
                for (Object o : list) {
                    if (o instanceof Map<?, ?> m) {
                        String word = str(m.get("word"));
                        if (!word.isBlank()) {
                            vocab.add(new VocabItem(
                                    word, str(m.get("ipa")),
                                    str(m.get("meaningVi")), str(m.get("example"))));
                        }
                        // Câu ví dụ trong vocab cũng là câu chép chính tả tốt.
                        String ex = str(m.get("example"));
                        if (!ex.isBlank()) sentences.add(new SentenceItem(ex, str(m.get("meaningVi"))));
                    }
                }
            }
        }
        return new LessonMaterial(sentences, vocab, topics);
    }

    private static String str(Object o) {
        return o == null ? "" : o.toString().trim();
    }

    private LessonMaterial empty() {
        return new LessonMaterial(List.of(), List.of(), List.of());
    }
}
