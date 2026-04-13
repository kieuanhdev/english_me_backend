package vn.id.kieuanhdev.englishme.util;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;

public final class VocabularySpreadsheetParser {
	public static final List<String> KNOWN_HEADERS = List.of(
		"word",
		"meaning_vi",
		"phonetic",
		"part_of_speech",
		"example_sentence",
		"audio_url",
		"image_url",
		"cefr_level"
	);

	public record ParsedRow(int lineNumber, String word, String phonetic, String partOfSpeech, String meaningVi, String exampleSentence, String audioUrl, String imageUrl, String cefrRaw) {
	}

	private VocabularySpreadsheetParser() {
	}

	public static List<ParsedRow> parseCsv(InputStream in) throws IOException {
		CSVFormat format = CSVFormat.Builder.create(CSVFormat.DEFAULT)
			.setHeader()
			.setSkipHeaderRecord(true)
			.setTrim(true)
			.setIgnoreEmptyLines(true)
			.setIgnoreHeaderCase(true)
			.build();
		try (CSVParser parser = format.parse(new InputStreamReader(in, StandardCharsets.UTF_8))) {
			List<ParsedRow> out = new ArrayList<>();
			for (CSVRecord rec : parser) {
				int line = (int) rec.getRecordNumber() + 1;
				out.add(rowFromRecord(rec, line));
			}
			return out;
		}
	}

	private static ParsedRow rowFromRecord(CSVRecord rec, int line) {
		return new ParsedRow(
			line,
			get(rec, "word"),
			get(rec, "phonetic"),
			get(rec, "part_of_speech"),
			get(rec, "meaning_vi"),
			get(rec, "example_sentence"),
			get(rec, "audio_url"),
			get(rec, "image_url"),
			get(rec, "cefr_level")
		);
	}

	private static String get(CSVRecord rec, String h) {
		try {
			String v = rec.get(h);
			return v == null || v.isBlank() ? null : v.trim();
		} catch (IllegalArgumentException ex) {
			return null;
		}
	}

	public static List<ParsedRow> parseExcel(InputStream in) throws IOException {
		DataFormatter df = new DataFormatter();
		try (Workbook wb = WorkbookFactory.create(in)) {
			Sheet sh = wb.getNumberOfSheets() > 0 ? wb.getSheetAt(0) : null;
			if (sh == null) {
				return List.of();
			}
			Row headerRow = sh.getRow(0);
			if (headerRow == null) {
				return List.of();
			}
			var col = new java.util.HashMap<String, Integer>();
			for (int c = 0; c < headerRow.getLastCellNum(); c++) {
				Cell cell = headerRow.getCell(c);
				if (cell == null) {
					continue;
				}
				String key = df.formatCellValue(cell).trim().toLowerCase(Locale.ROOT);
				if (!key.isEmpty()) {
					col.putIfAbsent(key, c);
				}
			}
			List<ParsedRow> out = new ArrayList<>();
			for (int r = 1; r <= sh.getLastRowNum(); r++) {
				Row row = sh.getRow(r);
				if (row == null) {
					continue;
				}
				int lastCell = row.getLastCellNum();
				if (lastCell < 0) {
					continue;
				}
				boolean empty = true;
				for (int c = 0; c < lastCell; c++) {
					Cell cell = row.getCell(c);
					if (cell != null && !df.formatCellValue(cell).isBlank()) {
						empty = false;
						break;
					}
				}
				if (empty) {
					continue;
				}
				int line = r + 1;
				out.add(new ParsedRow(
					line,
					excelCell(df, row, col, "word"),
					excelCell(df, row, col, "phonetic"),
					excelCell(df, row, col, "part_of_speech"),
					excelCell(df, row, col, "meaning_vi"),
					excelCell(df, row, col, "example_sentence"),
					excelCell(df, row, col, "audio_url"),
					excelCell(df, row, col, "image_url"),
					excelCell(df, row, col, "cefr_level")
				));
			}
			return out;
		}
	}

	private static String excelCell(DataFormatter df, Row row, java.util.Map<String, Integer> col, String key) {
		Integer idx = col.get(key);
		if (idx == null) {
			return null;
		}
		Cell c = row.getCell(idx);
		if (c == null) {
			return null;
		}
		String v = df.formatCellValue(c).trim();
		return v.isEmpty() ? null : v;
	}
}
