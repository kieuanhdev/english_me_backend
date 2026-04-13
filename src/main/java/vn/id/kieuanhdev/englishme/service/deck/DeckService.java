package vn.id.kieuanhdev.englishme.service.deck;

import java.time.Instant;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import vn.id.kieuanhdev.englishme.dto.deck.AddWordToDeckRequest;
import vn.id.kieuanhdev.englishme.dto.deck.AddWordToDeckResponse;
import vn.id.kieuanhdev.englishme.dto.deck.CreateDeckRequest;
import vn.id.kieuanhdev.englishme.dto.deck.CreateDeckResponse;
import vn.id.kieuanhdev.englishme.dto.deck.DeckWordCountResponse;
import vn.id.kieuanhdev.englishme.dto.deck.SubscribeDeckResponse;
import vn.id.kieuanhdev.englishme.dto.deck.SystemDeckSummaryResponse;
import vn.id.kieuanhdev.englishme.entity.auth.CefrLevel;
import vn.id.kieuanhdev.englishme.entity.deck.Deck;
import vn.id.kieuanhdev.englishme.entity.deck.DeckSubscription;
import vn.id.kieuanhdev.englishme.entity.deck.Flashcard;
import vn.id.kieuanhdev.englishme.entity.review.FlashcardProgress;
import vn.id.kieuanhdev.englishme.entity.vocabulary.Vocabulary;
import vn.id.kieuanhdev.englishme.repository.auth.UserRepository;
import vn.id.kieuanhdev.englishme.repository.deck.DeckRepository;
import vn.id.kieuanhdev.englishme.repository.deck.DeckSubscriptionRepository;
import vn.id.kieuanhdev.englishme.repository.deck.FlashcardRepository;
import vn.id.kieuanhdev.englishme.repository.review.FlashcardProgressRepository;
import vn.id.kieuanhdev.englishme.repository.vocabulary.VocabularyRepository;

@Service
@RequiredArgsConstructor
public class DeckService {
	private static final String CLONE_TITLE_SUFFIX = " (bản sao)";

	private final DeckRepository deckRepository;
	private final FlashcardRepository flashcardRepository;
	private final VocabularyRepository vocabularyRepository;
	private final DeckSubscriptionRepository deckSubscriptionRepository;
	private final FlashcardProgressRepository flashcardProgressRepository;
	private final UserRepository userRepository;

	@Transactional
	public CreateDeckResponse createUserDeck(UUID userId, CreateDeckRequest req) {
		var owner = userRepository.getReferenceById(userId);
		var deck = new Deck();
		deck.setOwner(owner);
		deck.setTitle(req.name().trim());
		deck.setDescription(blankToNull(req.description()));
		deck.setTopic(blankToNull(req.topic()));
		deck.setSystem(false);
		deck.setWordCount(0);
		deckRepository.save(deck);
		return new CreateDeckResponse(deck.getId(), deck.getTitle(), deck.getDescription(), deck.getWordCount());
	}

	@Transactional
	public AddWordToDeckResponse addWordFromVocabulary(UUID userId, UUID deckId, AddWordToDeckRequest req) {
		var deck = deckRepository.findByIdAndOwner_IdAndDeletedAtIsNullAndIsSystemFalse(deckId, userId)
			.orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Deck not found"));
		if (flashcardRepository.existsByDeck_IdAndVocabulary_IdAndDeletedAtIsNull(deckId, req.vocabularyId())) {
			throw new ResponseStatusException(HttpStatus.CONFLICT, "Word already in deck");
		}
		var vocabulary = vocabularyRepository.findByIdAndDeletedAtIsNull(req.vocabularyId())
			.orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vocabulary not found"));
		var flashcard = copyVocabularyToFlashcard(deck, vocabulary);
		flashcardRepository.save(flashcard);

		var userRef = userRepository.getReferenceById(userId);
		var progress = new FlashcardProgress();
		progress.setUser(userRef);
		progress.setFlashcard(flashcard);
		progress.setActive(true);
		flashcardProgressRepository.save(progress);

		deck.setWordCount(deck.getWordCount() + 1);
		deckRepository.save(deck);

		return new AddWordToDeckResponse(flashcard.getId(), vocabulary.getId(), deck.getWordCount());
	}

	@Transactional(readOnly = true)
	public List<SystemDeckSummaryResponse> listSystemDecks(String topic, String level) {
		CefrLevel cefr = parseLevelOrNull(level);
		String topicFilter = blankToNull(topic);
		var decks = deckRepository.findSystemDecksVisible(topicFilter, cefr);
		var ids = decks.stream().map(Deck::getId).toList();
		var counts = countActiveFlashcardsByDeck(ids);
		return decks.stream()
			.map(d -> new SystemDeckSummaryResponse(
				d.getId(),
				d.getTitle(),
				d.getDescription(),
				counts.getOrDefault(d.getId(), 0L),
				d.getTopic(),
				d.getCefrLevel() != null ? d.getCefrLevel().name() : null
			))
			.toList();
	}

	@Transactional
	public SubscribeDeckResponse subscribeSystemDeck(UUID userId, UUID deckId) {
		var deck = deckRepository.findByIdAndIsSystemTrueAndDeletedAtIsNull(deckId)
			.orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "System deck not found"));
		var userRef = userRepository.getReferenceById(userId);
		if (!deckSubscriptionRepository.existsByUser_IdAndDeck_Id(userId, deckId)) {
			var sub = new DeckSubscription();
			sub.setUser(userRef);
			sub.setDeck(deck);
			deckSubscriptionRepository.save(sub);
		}
		var flashcards = flashcardRepository.findAllByDeck_IdAndDeletedAtIsNull(deckId);
		int created = 0;
		for (var f : flashcards) {
			if (flashcardProgressRepository.findByUser_IdAndFlashcard_Id(userId, f.getId()).isEmpty()) {
				var p = new FlashcardProgress();
				p.setUser(userRef);
				p.setFlashcard(f);
				p.setActive(true);
				flashcardProgressRepository.save(p);
				created++;
			}
		}
		return new SubscribeDeckResponse(deckId, created);
	}

	@Transactional
	public CreateDeckResponse cloneSystemDeck(UUID userId, UUID sourceDeckId) {
		var source = deckRepository.findByIdAndIsSystemTrueAndDeletedAtIsNull(sourceDeckId)
			.orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "System deck not found"));
		var owner = userRepository.getReferenceById(userId);
		var copy = new Deck();
		copy.setOwner(owner);
		copy.setTitle(cloneTitle(source.getTitle()));
		copy.setDescription(source.getDescription());
		copy.setTopic(source.getTopic());
		copy.setPublic(false);
		copy.setCefrLevel(source.getCefrLevel());
		copy.setSystem(false);
		copy.setClonedFrom(source);
		copy.setWordCount(0);
		deckRepository.save(copy);

		var sourceCards = flashcardRepository.findAllByDeck_IdAndDeletedAtIsNull(sourceDeckId);
		for (var s : sourceCards) {
			var fc = cloneFlashcardToDeck(s, copy);
			flashcardRepository.save(fc);
			var p = new FlashcardProgress();
			p.setUser(owner);
			p.setFlashcard(fc);
			p.setActive(true);
			flashcardProgressRepository.save(p);
		}
		int n = sourceCards.size();
		copy.setWordCount(n);
		deckRepository.save(copy);
		return new CreateDeckResponse(copy.getId(), copy.getTitle(), copy.getDescription(), n);
	}

	@Transactional
	public DeckWordCountResponse removeWordFromUserDeck(UUID userId, UUID deckId, UUID vocabularyOrCardId) {
		var deck = deckRepository.findByIdAndOwner_IdAndDeletedAtIsNullAndIsSystemFalse(deckId, userId)
			.orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Deck not found"));
		var flashcard = flashcardRepository.findActiveByDeckIdAndVocabularyId(deckId, vocabularyOrCardId)
			.or(() -> flashcardRepository.findByDeck_IdAndIdAndDeletedAtIsNull(deckId, vocabularyOrCardId))
			.orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Word not found in deck"));
		flashcard.setDeletedAt(Instant.now());
		flashcardRepository.save(flashcard);

		flashcardProgressRepository.findByUser_IdAndFlashcard_Id(userId, flashcard.getId()).ifPresent(p -> {
			p.setActive(false);
			flashcardProgressRepository.save(p);
		});

		int wc = (int) flashcardRepository.countByDeck_IdAndDeletedAtIsNull(deckId);
		deck.setWordCount(wc);
		deckRepository.save(deck);
		return new DeckWordCountResponse(wc);
	}

	private static Flashcard copyVocabularyToFlashcard(Deck deck, Vocabulary v) {
		var f = new Flashcard();
		f.setDeck(deck);
		f.setVocabulary(v);
		f.setWord(v.getWord());
		f.setPhonetic(v.getPhonetic());
		f.setPartOfSpeech(v.getPartOfSpeech());
		f.setMeaningVi(v.getMeaningVi());
		f.setExampleSentence(v.getExampleSentence());
		f.setAudioUrl(v.getAudioUrl());
		f.setImageUrl(v.getImageUrl());
		f.setCefrLevel(v.getCefrLevel());
		return f;
	}

	private static Flashcard cloneFlashcardToDeck(Flashcard source, Deck targetDeck) {
		var f = new Flashcard();
		f.setDeck(targetDeck);
		f.setVocabulary(source.getVocabulary());
		f.setWord(source.getWord());
		f.setPhonetic(source.getPhonetic());
		f.setPartOfSpeech(source.getPartOfSpeech());
		f.setMeaningVi(source.getMeaningVi());
		f.setExampleSentence(source.getExampleSentence());
		f.setAudioUrl(source.getAudioUrl());
		f.setImageUrl(source.getImageUrl());
		f.setCefrLevel(source.getCefrLevel());
		return f;
	}

	private static String cloneTitle(String title) {
		String base = (title == null || title.isBlank()) ? "Deck" : title.trim();
		if (base.length() + CLONE_TITLE_SUFFIX.length() > 200) {
			base = base.substring(0, 200 - CLONE_TITLE_SUFFIX.length()).trim();
			if (base.isEmpty()) {
				base = "Deck";
			}
		}
		return base + CLONE_TITLE_SUFFIX;
	}

	private static String blankToNull(String s) {
		if (s == null || s.isBlank()) {
			return null;
		}
		return s.trim();
	}

	private static CefrLevel parseLevelOrNull(String level) {
		if (level == null || level.isBlank()) {
			return null;
		}
		try {
			return CefrLevel.valueOf(level.trim().toUpperCase());
		} catch (IllegalArgumentException ex) {
			throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid CEFR level");
		}
	}

	private Map<UUID, Long> countActiveFlashcardsByDeck(List<UUID> deckIds) {
		if (deckIds.isEmpty()) {
			return Map.of();
		}
		var rows = flashcardRepository.countActiveByDeckIds(deckIds);
		var map = new HashMap<UUID, Long>();
		for (Object[] row : rows) {
			map.put((UUID) row[0], ((Number) row[1]).longValue());
		}
		return map;
	}
}
