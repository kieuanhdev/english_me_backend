package vn.id.kieuanhdev.englishme.dto.deck;

import java.util.UUID;

public record CreateDeckResponse(UUID deckId, String name, String description, int wordCount) {
}
