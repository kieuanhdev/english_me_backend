package com.kiovant.englishme.dto;

import lombok.Data;

import java.util.List;
import java.util.UUID;

@Data
public class SubmitTestRequest {

    private List<AnswerItem> answers;

    @Data
    public static class AnswerItem {
        private UUID questionId;
        private String selectedAnswer; // "A", "B", "C", "D"
    }
}
