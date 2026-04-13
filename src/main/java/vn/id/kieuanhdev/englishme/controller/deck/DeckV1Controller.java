package vn.id.kieuanhdev.englishme.controller.deck;

import jakarta.validation.Valid;
import java.net.URI;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import vn.id.kieuanhdev.englishme.dto.deck.AddWordToDeckRequest;
import vn.id.kieuanhdev.englishme.dto.deck.AddWordToDeckResponse;
import vn.id.kieuanhdev.englishme.dto.deck.CreateDeckRequest;
import vn.id.kieuanhdev.englishme.dto.deck.CreateDeckResponse;
import vn.id.kieuanhdev.englishme.dto.deck.DeckWordCountResponse;
import vn.id.kieuanhdev.englishme.dto.deck.SubscribeDeckResponse;
import vn.id.kieuanhdev.englishme.dto.deck.SystemDeckSummaryResponse;
import vn.id.kieuanhdev.englishme.security.WebAuth;
import vn.id.kieuanhdev.englishme.service.deck.DeckService;

@RestController
@RequestMapping("/api/v1/decks")
@RequiredArgsConstructor
public class DeckV1Controller {
	private final DeckService deckService;

	@PostMapping
	public ResponseEntity<CreateDeckResponse> createDeck(Authentication authentication, @Valid @RequestBody CreateDeckRequest request) {
		var userId = WebAuth.requireUserId(authentication);
		var body = deckService.createUserDeck(userId, request);
		var location = URI.create("/api/v1/decks/" + body.deckId());
		return ResponseEntity.created(location).body(body);
	}

	@GetMapping("/system")
	public List<SystemDeckSummaryResponse> listSystemDecks(
		Authentication authentication,
		@RequestParam(required = false) String topic,
		@RequestParam(required = false) String level
	) {
		WebAuth.requireUserId(authentication);
		return deckService.listSystemDecks(topic, level);
	}

	@PostMapping("/system/{deckId}/subscribe")
	@ResponseStatus(HttpStatus.CREATED)
	public SubscribeDeckResponse subscribeSystemDeck(Authentication authentication, @PathVariable UUID deckId) {
		var userId = WebAuth.requireUserId(authentication);
		return deckService.subscribeSystemDeck(userId, deckId);
	}

	@PostMapping("/system/{deckId}/clone")
	@ResponseStatus(HttpStatus.CREATED)
	public ResponseEntity<CreateDeckResponse> cloneSystemDeck(Authentication authentication, @PathVariable UUID deckId) {
		var userId = WebAuth.requireUserId(authentication);
		var body = deckService.cloneSystemDeck(userId, deckId);
		var location = URI.create("/api/v1/decks/" + body.deckId());
		return ResponseEntity.created(location).body(body);
	}

	@PostMapping("/{deckId}/words")
	@ResponseStatus(HttpStatus.CREATED)
	public ResponseEntity<AddWordToDeckResponse> addWord(
		Authentication authentication,
		@PathVariable UUID deckId,
		@Valid @RequestBody AddWordToDeckRequest request
	) {
		var userId = WebAuth.requireUserId(authentication);
		var body = deckService.addWordFromVocabulary(userId, deckId, request);
		var location = URI.create(String.format("/api/v1/decks/%s/words/%s", deckId, body.flashcardId()));
		return ResponseEntity.created(location).body(body);
	}

	@DeleteMapping("/{deckId}/words/{vocabularyId}")
	public DeckWordCountResponse removeWord(
		Authentication authentication,
		@PathVariable UUID deckId,
		@PathVariable UUID vocabularyId
	) {
		var userId = WebAuth.requireUserId(authentication);
		return deckService.removeWordFromUserDeck(userId, deckId, vocabularyId);
	}
}
