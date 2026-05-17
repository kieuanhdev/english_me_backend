package com.kiovant.englishme.dto;

import java.util.List;

public record UserTestSubmitRequest(
        List<AnswerSubmit> answers,
        Integer timeTakenSeconds
) {
}
