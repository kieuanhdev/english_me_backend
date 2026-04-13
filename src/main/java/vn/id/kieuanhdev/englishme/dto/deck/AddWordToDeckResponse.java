package vn.id.kieuanhdev.englishme.dto.deck;

import java.util.UUID;

public record AddWordToDeckResponse(UUID flashcardId, UUID vocabularyId, int wordCount) {
}
