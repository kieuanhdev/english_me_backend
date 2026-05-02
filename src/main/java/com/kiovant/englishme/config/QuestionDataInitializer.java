package com.kiovant.englishme.config;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.kiovant.englishme.entity.Question;
import com.kiovant.englishme.repository.QuestionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;

import java.io.InputStream;
import java.util.List;
import java.util.Map;

@Component
public class QuestionDataInitializer implements ApplicationRunner {

    @Autowired
    private QuestionRepository questionRepository;

    @Autowired
    private ObjectMapper objectMapper;

    @Override
    public void run(ApplicationArguments args) throws Exception {
        ClassPathResource resource = new ClassPathResource("dauvaotest.json");
        if (!resource.exists()) return;

        try (InputStream is = resource.getInputStream()) {
            List<Map<String, Object>> rawList = objectMapper.readValue(is, new TypeReference<>() {});

            int imported = 0;
            for (Map<String, Object> raw : rawList) {
                String cefrLevel = (String) raw.get("cefr_level");
                String skillCategory = (String) raw.get("skill_category");
                String questionText = (String) raw.get("question");

                // Bỏ qua nếu câu hỏi đã tồn tại (idempotent)
                if (questionRepository.existsByCefrLevelAndSkillCategoryAndQuestion(cefrLevel, skillCategory, questionText)) {
                    continue;
                }

                Question q = new Question();
                q.setCefrLevel(cefrLevel);
                q.setSkillCategory(skillCategory);
                q.setQuestion(questionText);
                q.setOptions((Map<String, String>) raw.get("options"));
                q.setCorrectAnswer((String) raw.get("correct_answer"));
                q.setExplanation((String) raw.get("explanation"));

                questionRepository.save(q);
                imported++;
            }

            if (imported > 0) {
                System.out.printf("[QuestionDataInitializer] Imported %d new questions.%n", imported);
            }
        }
    }
}
