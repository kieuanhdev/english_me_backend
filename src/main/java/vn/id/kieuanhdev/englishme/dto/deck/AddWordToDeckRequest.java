package vn.id.kieuanhdev.englishme.dto.deck;

import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public record AddWordToDeckRequest(@NotNull UUID vocabularyId) {
}
