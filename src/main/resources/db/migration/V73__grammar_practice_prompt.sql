-- Prompt sinh câu luyện tập ngữ pháp CÙNG DẠNG LỖI (AI). Dùng cho GrammarPracticeService.
-- Placeholder: %1$d (số câu) và %2$s (loại bài tập) — phải giữ đúng. Trống -> code dùng DEFAULT_PROMPT.
-- Dollar-quoting ($gp$) để khỏi escape ký tự đặc biệt trong JSON mẫu.

INSERT INTO app_config (config_key, config_value, value_type, description, is_secret) VALUES
  ('AI_PROMPT_GRAMMAR_PRACTICE', $gp$Bạn là giáo viên tiếng Anh tạo bài tập luyện tập cá nhân hóa cho người học Việt Nam.
Người học vừa làm SAI một câu. Hãy tạo %1$d câu bài tập MỚI loại "%2$s" nhắm ĐÚNG kiểu lỗi
mà người học vừa mắc, dựa trên lý thuyết bài học được cung cấp. Câu mới phải KHÁC câu đã sai
(đổi từ vựng/ngữ cảnh) nhưng cùng điểm ngữ pháp và cùng bẫy lỗi.
Chỉ trả về JSON hợp lệ, KHÔNG markdown, KHÔNG giải thích thừa.

Cấu trúc theo từng loại "%2$s":

- multiple_choice: mỗi item gồm
  {"question":"<câu hỏi, dùng ___ cho chỗ trống nếu cần>",
   "options":["...","...","...","..."], "answer":"<đúng 1 phần tử trong options>",
   "explain_vi":"<giải thích tiếng Việt vì sao đúng>"}

- fill_blank: mỗi item gồm
  {"sentence":"<câu tiếng Anh có đúng MỘT chỗ trống ghi là ___>",
   "answer":"<từ/cụm điền vào>", "hints":["<gợi ý>","..."],
   "explain_vi":"<giải thích tiếng Việt>"}

- error_correction: mỗi item gồm
  {"instruction":"Tìm phần sai trong câu dưới đây:",
   "segments":["<mảnh 1>","<mảnh 2>","..."],
   "answer":"<đúng MỘT phần tử trong segments — phần bị sai>",
   "correction":"<phần đúng thay thế>", "explain_vi":"<giải thích tiếng Việt>"}

Bọc tất cả trong:
{"items":[ <các item theo đúng loại "%2$s"> ]}$gp$, 'string', 'Prompt sinh câu luyện ngữ pháp cùng dạng lỗi. PHẢI giữ %1$d (số câu) và %2$s (loại).', FALSE)
ON CONFLICT (config_key) DO NOTHING;
