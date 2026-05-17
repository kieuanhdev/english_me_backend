# Desk API Documentation

Base path: `/api/desks`

All endpoints require Firebase bearer token:

```http
Authorization: Bearer <firebase_id_token>
```

If token is missing/invalid, API returns `401 Unauthorized`.

## Permission model

- User can view:
  - system/admin desks (`owner = null`)
  - their own desks
- User cannot view desks of other users.
- Create/update/delete desk and add flashcard are only allowed on user's own desks.

## 1) List desks

`GET /api/desks`

### Request

- Headers:
  - `Authorization: Bearer <firebase_id_token>`

### Response `200 OK`

```json
[
  {
    "id": "6a6a8f7c-7ab3-4f98-b5f4-3a6f9f9ef123",
    "cefrLevel": "A1",
    "title": "Desk A1",
    "sortOrder": 1,
    "createdAt": "2026-05-04T22:10:00",
    "flashcardCount": 120
  }
]
```

## 2) List flashcards by desk (paged)

`GET /api/desks/{deskId}/flashcards?page=0&size=20`

### Request

- Path params:
  - `deskId` (UUID)
- Query params:
  - `page` (default `0`)
  - `size` (default `20`, clamped to `1..100`)
- Headers:
  - `Authorization: Bearer <firebase_id_token>`

### Response `200 OK`

```json
{
  "content": [
    {
      "id": "5f18f2b6-2fa0-4fa7-bffa-4569d967f001",
      "deskId": "6a6a8f7c-7ab3-4f98-b5f4-3a6f9f9ef123",
      "word": "ability",
      "cefr": "A2",
      "pos": ["noun"],
      "allLevels": [],
      "ipa": "/əˈbɪləti/",
      "audioUrl": "https://example.com/audio/ability.mp3",
      "definition": "the power to do something",
      "example": "She has the ability to learn quickly.",
      "topic": "education",
      "vietnamese": "khả năng",
      "viDefinition": "năng lực làm điều gì đó",
      "viExample": "Cô ấy có khả năng học nhanh."
    }
  ],
  "totalElements": 1,
  "totalPages": 1,
  "number": 0,
  "size": 20
}
```

### Error responses

- `404 Not Found`: desk does not exist or user has no read access

## 3) Create desk

`POST /api/desks`

### Request

- Headers:
  - `Authorization: Bearer <firebase_id_token>`
  - `Content-Type: application/json`
- Body (`CreateDeskRequest`):

```json
{
  "cefrLevel": "B1",
  "title": "My B1 Desk",
  "sortOrder": 3
}
```

Field notes:

- `cefrLevel`: required
- `title`: optional, defaults to `Desk {CEFR}`
- `sortOrder`: optional, backend auto-assigns if null

### Response `201 Created`

```json
{
  "id": "f87fdf13-b6cc-4429-9bdd-8f305df95555",
  "cefrLevel": "B1",
  "title": "My B1 Desk",
  "sortOrder": 3,
  "createdAt": "2026-05-04T22:11:00",
  "flashcardCount": 0
}
```

### Error responses

- `400 Bad Request`: missing `cefrLevel`, invalid payload, negative `sortOrder`
- `409 Conflict`: desk CEFR already exists for current user

## 4) Update desk

`PUT /api/desks/{deskId}`

### Request

- Headers:
  - `Authorization: Bearer <firebase_id_token>`
  - `Content-Type: application/json`
- Path params:
  - `deskId` (UUID)
- Body (`UpdateDeskRequest`):

```json
{
  "cefrLevel": "B2",
  "title": "Desk B2 Updated",
  "sortOrder": 2
}
```

All fields are optional; only provided fields are updated.

### Response `200 OK`

```json
{
  "id": "f87fdf13-b6cc-4429-9bdd-8f305df95555",
  "cefrLevel": "B2",
  "title": "Desk B2 Updated",
  "sortOrder": 2,
  "createdAt": "2026-05-04T22:11:00",
  "flashcardCount": 25
}
```

### Error responses

- `400 Bad Request`: blank title, negative `sortOrder`
- `404 Not Found`: desk does not exist or user is not owner
- `409 Conflict`: updated CEFR already exists for current user

## 5) Delete desk

`DELETE /api/desks/{deskId}`

### Request

- Headers:
  - `Authorization: Bearer <firebase_id_token>`
- Path params:
  - `deskId` (UUID)

### Response `204 No Content`

No response body.

### Error responses

- `404 Not Found`: desk does not exist or user is not owner

## 6) Create flashcard in desk

`POST /api/desks/{deskId}/flashcards`

### Request

- Headers:
  - `Authorization: Bearer <firebase_id_token>`
  - `Content-Type: application/json`
- Path params:
  - `deskId` (UUID)
- Body (`CreateFlashcardRequest`):

```json
{
  "word": "ability",
  "cefr": "A2",
  "pos": ["noun"],
  "allLevels": [],
  "ipa": "/əˈbɪləti/",
  "audioUrl": "https://example.com/audio/ability.mp3",
  "definition": "the power to do something",
  "example": "She has the ability to learn quickly.",
  "topic": "education",
  "vietnamese": "khả năng",
  "viDefinition": "năng lực làm điều gì đó",
  "viExample": "Cô ấy có khả năng học nhanh."
}
```

### Response `201 Created`

```json
{
  "id": "5f18f2b6-2fa0-4fa7-bffa-4569d967f001",
  "deskId": "f87fdf13-b6cc-4429-9bdd-8f305df95555",
  "word": "ability",
  "cefr": "A2",
  "pos": ["noun"],
  "allLevels": [],
  "ipa": "/əˈbɪləti/",
  "audioUrl": "https://example.com/audio/ability.mp3",
  "definition": "the power to do something",
  "example": "She has the ability to learn quickly.",
  "topic": "education",
  "vietnamese": "khả năng",
  "viDefinition": "năng lực làm điều gì đó",
  "viExample": "Cô ấy có khả năng học nhanh."
}
```

### Error responses

- `400 Bad Request`: missing `word` or `cefr`
- `404 Not Found`: desk does not exist or user is not owner
- `409 Conflict`: duplicate `word` in the same desk
