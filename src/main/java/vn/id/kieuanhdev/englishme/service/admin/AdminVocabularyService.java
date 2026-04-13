package vn.id.kieuanhdev.englishme.service.admin;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;
import vn.id.kieuanhdev.englishme.dto.admin.vocabulary.ImportRowError;
import vn.id.kieuanhdev.englishme.dto.admin.vocabulary.VocabularyAdminResponse;
import vn.id.kieuanhdev.englishme.dto.admin.vocabulary.VocabularyCreateRequest;
import vn.id.kieuanhdev.englishme.dto.admin.vocabulary.VocabularyImportResponse;
import vn.id.kieuanhdev.englishme.dto.admin.vocabulary.VocabularyUpdateRequest;
import vn.id.kieuanhdev.englishme.entity.auth.CefrLevel;
import vn.id.kieuanhdev.englishme.entity.vocabulary.Vocabulary;
import vn.id.kieuanhdev.englishme.repository.vocabulary.VocabularyRepository;
import vn.id.kieuanhdev.englishme.repository.vocabulary.VocabularySpecs;
import vn.id.kieuanhdev.englishme.util.VocabularySpreadsheetParser;
import vn.id.kieuanhdev.englishme.util.VocabularySpreadsheetParser.ParsedRow;

@Service
@RequiredArgsConstructor
public class AdminVocabularyService {
	private static final int IMPORT_BATCH_SIZE = 50;
	private static final int DB_IN_CHUNK = 500;

	private final VocabularyRepository vocabularyRepository;
	private final TransactionTemplate transactionTemplate;

	@Transactional(readOnly = true)
	public Page<VocabularyAdminResponse> list(String q, boolean includeDeleted, Pageable pageable) {
		Specification<Vocabulary> spec = VocabularySpecs.adminList(q, includeDeleted);
		return vocabularyRepository.findAll(spec, pageable).map(AdminVocabularyService::toResponse);
	}

	@Transactional(readOnly = true)
	public VocabularyAdminResponse getById(UUID id, boolean includeDeleted) {
		var v = vocabularyRepository.findById(id)
			.orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vocabulary not found"));
		if (v.getDeletedAt() != null && !includeDeleted) {
			throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Vocabulary not found");
		}
		return toResponse(v);
	}

	@Transactional
	public VocabularyAdminResponse create(VocabularyCreateRequest req) {
		var word = req.word().trim();
		if (vocabularyRepository.existsByWordIgnoreCaseAndDeletedAtIsNull(word)) {
			throw new ResponseStatusException(HttpStatus.CONFLICT, "Từ vựng đã tồn tại (chưa xóa mềm)");
		}
		var v = new Vocabulary();
		v.setWord(word);
		v.setPhonetic(blankToNull(req.phonetic()));
		v.setPartOfSpeech(blankToNull(req.partOfSpeech()));
		v.setMeaningVi(req.meaningVi().trim());
		v.setExampleSentence(blankToNull(req.exampleSentence()));
		v.setAudioUrl(blankToNull(req.audioUrl()));
		v.setImageUrl(blankToNull(req.imageUrl()));
		v.setCefrLevel(parseCefrOrNull(req.cefrLevel()));
		vocabularyRepository.save(v);
		return toResponse(v);
	}

	@Transactional
	public VocabularyAdminResponse update(UUID id, VocabularyUpdateRequest req) {
		var v = vocabularyRepository.findById(id)
			.orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vocabulary not found"));
		if (v.getDeletedAt() != null) {
			throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Vocabulary not found");
		}
		if (req.word() != null) {
			var nw = req.word().trim();
			if (nw.isEmpty()) {
				throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "word không được rỗng");
			}
			if (!nw.equalsIgnoreCase(v.getWord()) && vocabularyRepository.existsByWordIgnoreCaseAndDeletedAtIsNullAndIdNot(nw, id)) {
				throw new ResponseStatusException(HttpStatus.CONFLICT, "Từ vựng trùng với bản ghi khác");
			}
			v.setWord(nw);
		}
		if (req.phonetic() != null) {
			v.setPhonetic(blankToNull(req.phonetic()));
		}
		if (req.partOfSpeech() != null) {
			v.setPartOfSpeech(blankToNull(req.partOfSpeech()));
		}
		if (req.meaningVi() != null) {
			if (req.meaningVi().isBlank()) {
				throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "meaningVi không được rỗng");
			}
			v.setMeaningVi(req.meaningVi().trim());
		}
		if (req.exampleSentence() != null) {
			v.setExampleSentence(blankToNull(req.exampleSentence()));
		}
		if (req.audioUrl() != null) {
			v.setAudioUrl(blankToNull(req.audioUrl()));
		}
		if (req.imageUrl() != null) {
			v.setImageUrl(blankToNull(req.imageUrl()));
		}
		if (req.cefrLevel() != null) {
			v.setCefrLevel(parseCefrOrNull(req.cefrLevel()));
		}
		vocabularyRepository.save(v);
		return toResponse(v);
	}

	@Transactional
	public void softDelete(UUID id) {
		var v = vocabularyRepository.findById(id)
			.orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vocabulary not found"));
		if (v.getDeletedAt() != null) {
			return;
		}
		v.setDeletedAt(java.time.Instant.now());
		vocabularyRepository.save(v);
	}

	/**
	 * Validate từng dòng, loại trùng trong file & trùng DB; insert theo lô, mỗi lô một transaction.
	 */
	public VocabularyImportResponse importFile(MultipartFile file) {
		if (file == null || file.isEmpty()) {
			throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "File trống");
		}
		List<ParsedRow> rows;
		try {
			rows = parseByFilename(file);
		} catch (IOException e) {
			throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Không đọc được file: " + e.getMessage());
		}
		var errors = new ArrayList<ImportRowError>();
		var seenInFile = new HashMap<String, Integer>();
		var staged = new ArrayList<StagedImport>();
		for (ParsedRow row : rows) {
			var lineErr = validateParsedRow(row);
			if (lineErr != null) {
				errors.add(new ImportRowError(row.lineNumber(), lineErr));
				continue;
			}
			String key = normalizeWordKey(row.word());
			Integer firstLine = seenInFile.putIfAbsent(key, row.lineNumber());
			if (firstLine != null) {
				errors.add(new ImportRowError(row.lineNumber(), "Trùng từ trong file (dòng " + firstLine + ")"));
				continue;
			}
			var v = new Vocabulary();
			v.setWord(row.word().trim());
			v.setPhonetic(blankToNull(row.phonetic()));
			v.setPartOfSpeech(blankToNull(row.partOfSpeech()));
			v.setMeaningVi(row.meaningVi().trim());
			v.setExampleSentence(blankToNull(row.exampleSentence()));
			v.setAudioUrl(blankToNull(row.audioUrl()));
			v.setImageUrl(blankToNull(row.imageUrl()));
			v.setCefrLevel(parseCefrForValidatedImport(row.cefrRaw()));
			staged.add(new StagedImport(row.lineNumber(), v));
		}
		var stagedKeys = new HashSet<String>();
		for (var s : staged) {
			stagedKeys.add(normalizeWordKey(s.vocabulary().getWord()));
		}
		var existingDb = loadExistingDbWords(stagedKeys);
		var finalInsert = new ArrayList<Vocabulary>();
		for (var s : staged) {
			if (existingDb.contains(normalizeWordKey(s.vocabulary().getWord()))) {
				errors.add(new ImportRowError(s.line(), "Từ đã tồn tại trong kho (chưa xóa mềm)"));
			} else {
				finalInsert.add(s.vocabulary());
			}
		}
		int success = 0;
		for (int i = 0; i < finalInsert.size(); i += IMPORT_BATCH_SIZE) {
			int end = Math.min(i + IMPORT_BATCH_SIZE, finalInsert.size());
			var chunk = finalInsert.subList(i, end);
			transactionTemplate.executeWithoutResult(status -> vocabularyRepository.saveAll(new ArrayList<>(chunk)));
			success += chunk.size();
		}
		errors.sort(Comparator.comparingInt(ImportRowError::line));
		int total = rows.size();
		int errCount = errors.size();
		return new VocabularyImportResponse(total, success, errCount, List.copyOf(errors));
	}

	private record StagedImport(int line, Vocabulary vocabulary) {
	}

	private List<ParsedRow> parseByFilename(MultipartFile file) throws IOException {
		String n = file.getOriginalFilename() == null ? "" : file.getOriginalFilename().toLowerCase(Locale.ROOT);
		if (n.endsWith(".csv")) {
			return VocabularySpreadsheetParser.parseCsv(file.getInputStream());
		}
		if (n.endsWith(".xlsx") || n.endsWith(".xls")) {
			return VocabularySpreadsheetParser.parseExcel(file.getInputStream());
		}
		throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Chỉ hỗ trợ .csv, .xlsx hoặc .xls");
	}

	private Set<String> loadExistingDbWords(Set<String> lowerTrimmedKeys) {
		var out = new HashSet<String>();
		var list = new ArrayList<>(lowerTrimmedKeys);
		for (int i = 0; i < list.size(); i += DB_IN_CHUNK) {
			var sub = list.subList(i, Math.min(i + DB_IN_CHUNK, list.size()));
			out.addAll(vocabularyRepository.findActiveWordsLowerTrimmedIn(sub));
		}
		return out;
	}

	private static String normalizeWordKey(String word) {
		return word.trim().toLowerCase(Locale.ROOT);
	}

	private static String validateParsedRow(ParsedRow row) {
		if (row.word() == null || row.word().isBlank()) {
			return "Thiếu word";
		}
		if (row.word().length() > 200) {
			return "word vượt quá 200 ký tự";
		}
		if (row.meaningVi() == null || row.meaningVi().isBlank()) {
			return "Thiếu meaning_vi";
		}
		if (row.cefrRaw() != null && !row.cefrRaw().isBlank()) {
			try {
				CefrLevel.valueOf(row.cefrRaw().trim().toUpperCase(Locale.ROOT));
			} catch (IllegalArgumentException ex) {
				return "cefr_level không hợp lệ: " + row.cefrRaw();
			}
		}
		return null;
	}

	private static String blankToNull(String s) {
		if (s == null || s.isBlank()) {
			return null;
		}
		return s.trim();
	}

	private static CefrLevel parseCefrOrNull(String s) {
		if (s == null || s.isBlank()) {
			return null;
		}
		try {
			return CefrLevel.valueOf(s.trim().toUpperCase(Locale.ROOT));
		} catch (IllegalArgumentException ex) {
			throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "cefr_level không hợp lệ: " + s);
		}
	}

	/** Sau {@link #validateParsedRow}; không ném ngoại lệ. */
	private static CefrLevel parseCefrForValidatedImport(String s) {
		if (s == null || s.isBlank()) {
			return null;
		}
		return CefrLevel.valueOf(s.trim().toUpperCase(Locale.ROOT));
	}

	private static VocabularyAdminResponse toResponse(Vocabulary v) {
		return new VocabularyAdminResponse(
			v.getId(),
			v.getWord(),
			v.getPhonetic(),
			v.getPartOfSpeech(),
			v.getMeaningVi(),
			v.getExampleSentence(),
			v.getAudioUrl(),
			v.getImageUrl(),
			v.getCefrLevel() != null ? v.getCefrLevel().name() : null,
			v.getCreatedAt(),
			v.getUpdatedAt(),
			v.getDeletedAt()
		);
	}
}
