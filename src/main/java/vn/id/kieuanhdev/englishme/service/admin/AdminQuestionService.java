package vn.id.kieuanhdev.englishme.service.admin;

import java.io.IOException;
import java.io.StringWriter;
import java.time.Instant;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVPrinter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import vn.id.kieuanhdev.englishme.dto.admin.question.AdminQuestionRequest;
import vn.id.kieuanhdev.englishme.dto.admin.question.AdminQuestionResponse;
import vn.id.kieuanhdev.englishme.dto.admin.question.QuestionBankWarningResponse;
import vn.id.kieuanhdev.englishme.entity.auth.CefrLevel;
import vn.id.kieuanhdev.englishme.entity.placement.CefrQuestion;
import vn.id.kieuanhdev.englishme.entity.placement.PlacementSkillType;
import vn.id.kieuanhdev.englishme.repository.auth.UserRepository;
import vn.id.kieuanhdev.englishme.repository.placement.CefrQuestionRepository;
import vn.id.kieuanhdev.englishme.repository.placement.CefrQuestionSpecs;
import vn.id.kieuanhdev.englishme.repository.placement.PlacementAnswerRepository;

@Service
@RequiredArgsConstructor
public class AdminQuestionService {
	private final CefrQuestionRepository questionRepository;
	private final PlacementAnswerRepository answerRepository;
	private final UserRepository userRepository;

	@Value("${app.placement.min-questions-per-band:10}")
	private int minQuestionsPerBand;

	@Transactional(readOnly = true)
	public Page<AdminQuestionResponse> list(String cefr, String skill, boolean includeDeleted, Pageable pageable) {
		var band = parseBandOrNull(cefr);
		var skillType = parseSkillOrNull(skill);
		int safeSize = Math.min(Math.max(pageable.getPageSize(), 1), 100);
		var safeSort = pageable.getSort().stream()
			.filter(o -> List.of("updatedAt", "createdAt", "difficultyScore", "cefrBand", "skillType").contains(o.getProperty()))
			.toList();
		var normalizedPageable = safeSort.isEmpty()
			? PageRequest.of(Math.max(pageable.getPageNumber(), 0), safeSize)
			: PageRequest.of(Math.max(pageable.getPageNumber(), 0), safeSize, org.springframework.data.domain.Sort.by(safeSort));
		return questionRepository.findAll(CefrQuestionSpecs.filter(band, skillType, includeDeleted), normalizedPageable)
			.map(this::toResponse);
	}

	@Transactional(readOnly = true)
	public AdminQuestionResponse getById(UUID id) {
		return toResponse(findQuestion(id));
	}

	@Transactional
	public AdminQuestionResponse create(UUID adminId, AdminQuestionRequest req) {
		validatePayload(req);
		var q = new CefrQuestion();
		applyPayload(q, req);
		if (adminId != null) {
			q.setCreatedBy(userRepository.getReferenceById(adminId));
		}
		questionRepository.save(q);
		return toResponse(q);
	}

	@Transactional
	public AdminQuestionResponse update(UUID id, AdminQuestionRequest req) {
		validatePayload(req);
		var q = findQuestion(id);
		applyPayload(q, req);
		questionRepository.save(q);
		return toResponse(q);
	}

	@Transactional
	public AdminQuestionResponse delete(UUID id) {
		var q = findQuestion(id);
		if (answerRepository.countByQuestion_Id(id) > 0) {
			q.setActive(false);
			q.setDeletedAt(Instant.now());
			questionRepository.save(q);
			return toResponse(q);
		}
		questionRepository.delete(q);
		return null;
	}

	@Transactional(readOnly = true)
	public QuestionBankWarningResponse warning() {
		Map<String, Long> current = new LinkedHashMap<>();
		Map<String, Long> missing = new LinkedHashMap<>();
		for (CefrLevel band : CefrLevel.values()) {
			long c = questionRepository.countByCefrBandAndDeletedAtIsNullAndActiveTrue(band);
			current.put(band.name(), c);
			if (c < minQuestionsPerBand) {
				missing.put(band.name(), minQuestionsPerBand - c);
			}
		}
		return new QuestionBankWarningResponse(minQuestionsPerBand, current, missing);
	}

	@Transactional(readOnly = true)
	public String exportCsv(boolean includeDeleted) {
		var spec = CefrQuestionSpecs.filter(null, null, includeDeleted);
		var questions = questionRepository.findAll(spec);
		try (var sw = new StringWriter();
		     var csv = new CSVPrinter(sw, CSVFormat.DEFAULT.builder()
			     .setHeader("id", "content", "options", "correct_answer", "cefr_band", "skill_type", "difficulty_score", "is_active", "created_at", "updated_at", "deleted_at")
			     .build())) {
			for (var q : questions) {
				csv.printRecord(
					q.getId(),
					q.getContent(),
					joinOptions(q.getOptions()),
					q.getCorrectAnswer(),
					q.getCefrBand().name(),
					q.getSkillType().name(),
					q.getDifficultyScore(),
					q.isActive(),
					q.getCreatedAt(),
					q.getUpdatedAt(),
					q.getDeletedAt()
				);
			}
			csv.flush();
			return sw.toString();
		} catch (IOException e) {
			throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Không thể export CSV");
		}
	}

	private void applyPayload(CefrQuestion q, AdminQuestionRequest req) {
		q.setContent(req.content().trim());
		q.setOptions(cleanOptions(req.options()));
		q.setCorrectAnswer(req.correctAnswer().trim().toUpperCase(Locale.ROOT));
		q.setCefrBand(parseBand(req.cefrBand()));
		q.setSkillType(parseSkill(req.skillType()));
		q.setDifficultyScore(req.difficultyScore());
		q.setActive(req.isActive() == null || req.isActive());
		if (q.getDeletedAt() != null && q.isActive()) {
			q.setDeletedAt(null);
		}
	}

	private void validatePayload(AdminQuestionRequest req) {
		if (req.content() == null || req.content().trim().length() < 10) {
			throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Nội dung câu hỏi không được để trống");
		}
		var options = cleanOptions(req.options());
		if (options.size() != 4) {
			throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Câu hỏi phải có đúng 4 lựa chọn khác nhau");
		}
		var ans = req.correctAnswer() == null ? "" : req.correctAnswer().trim().toUpperCase(Locale.ROOT);
		if (!List.of("A", "B", "C", "D").contains(ans)) {
			throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Đáp án đúng phải là một trong các lựa chọn");
		}
		if (req.difficultyScore() == null || req.difficultyScore() < 0 || req.difficultyScore() > 1) {
			throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Điểm độ khó phải trong khoảng 0.0 đến 1.0");
		}
		parseBand(req.cefrBand());
		parseSkill(req.skillType());
	}

	private List<String> cleanOptions(List<String> options) {
		if (options == null) {
			return List.of();
		}
		var out = new ArrayList<String>();
		for (String opt : options) {
			if (opt == null) {
				continue;
			}
			var v = opt.trim();
			if (v.length() > 255) {
				throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Mỗi lựa chọn không được quá 255 ký tự");
			}
			if (!v.isEmpty()) {
				out.add(v);
			}
		}
		var distinct = out.stream().distinct().toList();
		if (distinct.size() != out.size()) {
			throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Câu hỏi phải có đúng 4 lựa chọn khác nhau");
		}
		return distinct;
	}

	private CefrLevel parseBand(String raw) {
		try {
			return CefrLevel.valueOf(raw.trim().toUpperCase(Locale.ROOT));
		} catch (Exception e) {
			throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "CEFR band không hợp lệ");
		}
	}

	private CefrLevel parseBandOrNull(String raw) {
		if (raw == null || raw.isBlank()) {
			return null;
		}
		return parseBand(raw);
	}

	private PlacementSkillType parseSkill(String raw) {
		try {
			return PlacementSkillType.valueOf(raw.trim().toUpperCase(Locale.ROOT));
		} catch (Exception e) {
			throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "skill_type không hợp lệ");
		}
	}

	private PlacementSkillType parseSkillOrNull(String raw) {
		if (raw == null || raw.isBlank()) {
			return null;
		}
		return parseSkill(raw);
	}

	private CefrQuestion findQuestion(UUID id) {
		return questionRepository.findById(id)
			.orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy câu hỏi"));
	}

	private AdminQuestionResponse toResponse(CefrQuestion q) {
		return new AdminQuestionResponse(
			q.getId(),
			q.getContent(),
			q.getOptions(),
			q.getCorrectAnswer(),
			q.getCefrBand().name(),
			q.getSkillType().name(),
			q.getDifficultyScore(),
			q.isActive(),
			q.getCreatedBy() != null ? q.getCreatedBy().getId() : null,
			q.getCreatedAt(),
			q.getUpdatedAt(),
			q.getDeletedAt()
		);
	}

	private static String joinOptions(List<String> options) {
		if (options == null || options.isEmpty()) {
			return "[]";
		}
		return String.join(" | ", options);
	}
}
