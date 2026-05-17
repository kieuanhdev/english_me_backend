# API Spec: Luyện phát âm AI

## Base URL

```
{host}/api/pronunciation
```

## Authentication

Tất cả request cần kèm Firebase ID Token trong header:

```
Authorization: Bearer <firebase_id_token>
```

---

## 1. Lấy danh sách bài tập phát âm

```
GET /api/pronunciation/exercises
```

### Response `200 OK`

```json
{
  "exercises": [
    {
      "id": "ex_001",
      "text": "Hello, how are you?",
      "phonetic": "həˈloʊ, haʊ ɑːr juː",
      "meaning": "Xin chào, bạn khỏe không?",
      "audioUrl": "https://cdn.example.com/audio/hello.mp3",
      "difficulty": "beginner"
    }
  ]
}
```

| Field | Type | Required | Mô tả |
|-------|------|----------|-------|
| `id` | string | yes | Mã định danh bài tập |
| `text` | string | yes | Câu/từ cần luyện đọc |
| `phonetic` | string | no | Phiên âm IPA |
| `meaning` | string | no | Nghĩa tiếng Việt |
| `audioUrl` | string | no | Link audio giọng đọc mẫu |
| `difficulty` | string | no | Độ khó: `beginner`, `intermediate`, `advanced` |

---

## 2. Phân tích phát âm

```
POST /api/pronunciation/assess
Content-Type: multipart/form-data
```

### Request Body

| Field | Type | Required | Mô tả |
|-------|------|----------|-------|
| `audio` | file | yes | File ghi âm (`.m4a`, AAC-LC, 128kbps, 44100Hz) |
| `exerciseId` | string | yes | ID bài tập đang luyện |
| `expectedText` | string | yes | Text mẫu mà học viên cần đọc |

### Response `200 OK`

```json
{
  "score": 78.5,
  "accuracy": 82.0,
  "fluency": 75.0,
  "completeness": 90.0,
  "transcription": "Hello how are you",
  "errors": [
    {
      "word": "how",
      "position": 1,
      "expected": "haʊ",
      "actual": "ho",
      "suggestion": "Chú ý nguyên âm đôi /aʊ/, mở miệng rộng hơn khi phát âm."
    }
  ],
  "overallComment": "Phát âm khá tốt. Cần cải thiện nguyên âm đôi /aʊ/."
}
```

| Field | Type | Mô tả |
|-------|------|-------|
| `score` | number | Điểm tổng (0-100) |
| `accuracy` | number | Độ chính xác phát âm từng âm (0-100) |
| `fluency` | number | Độ trôi chảy, ngữ điệu (0-100) |
| `completeness` | number | Mức độ đọc đủ/thiếu từ so với mẫu (0-100) |
| `transcription` | string | Kết quả nhận dạng giọng nói (speech-to-text) |
| `errors` | array | Danh sách lỗi phát âm |
| `overallComment` | string | Nhận xét tổng quan |

### Error Object

| Field | Type | Mô tả |
|-------|------|-------|
| `word` | string | Từ bị phát âm sai |
| `position` | number | Vị trí từ trong câu (0-indexed) |
| `expected` | string | Phiên âm IPA đúng |
| `actual` | string | Phiên âm IPA thực tế học viên đọc |
| `suggestion` | string | Gợi ý sửa lỗi bằng tiếng Việt |

### Error Response

```json
{
  "message": "Không thể nhận dạng giọng nói. Vui lòng thử lại trong môi trường yên tĩnh hơn."
}
```

---

## Luồng xử lý phía Backend

1. Nhận file audio + `expectedText`
2. Chạy Speech-to-Text (Whisper / Google STT / Azure Speech) để lấy `transcription`
3. So sánh `transcription` với `expectedText`:
   - Căn chỉnh từ (word alignment)
   - Đánh giá từng âm tiết bằng phonetic comparison
4. Tính điểm thành phần và điểm tổng
5. Với mỗi từ sai → sinh `suggestion` hướng dẫn sửa
6. Trả về kết quả

### Gợi ý công nghệ

| Thành phần | Công nghệ gợi ý |
|------------|-----------------|
| Speech-to-Text | OpenAI Whisper, Google Cloud STT, Azure Speech |
| Phonetic Alignment | Montreal Forced Aligner, Gentle, hoặc tự build với DTW |
| Pronunciation Scoring | Goodness of Pronunciation (GOP), hoặc fine-tune Wav2Vec2 |
| Text-to-Speech mẫu | Google TTS, Amazon Polly (cho `audioUrl`) |
