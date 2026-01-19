# API Contracts: 탭 기반 메인 네비게이션

**Feature**: 002-main-tab-navigation
**Date**: 2026-01-08
**Status**: 향후 구현 예정 (현재 더미 데이터 사용)

## Overview

본 문서는 탭 기반 메인 화면에서 사용될 API 엔드포인트를 정의합니다.
현재는 더미 데이터로 UI가 구현되어 있으며, 향후 백엔드 API 연동 시 참조됩니다.

---

## Explore Tab APIs

### GET /api/v1/recommendations

오늘의 추천 장소 목록 조회

**Response**
```json
{
  "recommendations": [
    {
      "id": "string",
      "name": "string",
      "imageUrl": "string",
      "rating": 4.5,
      "reviewCount": 150
    }
  ]
}
```

### GET /api/v1/places/popular

인기 장소 목록 조회

**Query Parameters**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| page | int | No | 페이지 번호 (default: 1) |
| limit | int | No | 페이지 당 항목 수 (default: 20) |

**Response**
```json
{
  "places": [
    {
      "id": "string",
      "name": "string",
      "location": "string",
      "imageUrl": "string",
      "rating": 4.8,
      "reviewCount": 200
    }
  ],
  "pagination": {
    "currentPage": 1,
    "totalPages": 10,
    "totalItems": 200
  }
}
```

---

## Search Tab APIs

### GET /api/v1/search

장소 검색

**Query Parameters**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| q | string | Yes | 검색어 |
| category | string | No | 카테고리 필터 (all, restaurants, hotels, attractions, activities) |
| page | int | No | 페이지 번호 |
| limit | int | No | 페이지 당 항목 수 |

**Response**
```json
{
  "results": [
    {
      "id": "string",
      "name": "string",
      "description": "string",
      "category": "restaurants",
      "imageUrl": "string"
    }
  ],
  "pagination": {
    "currentPage": 1,
    "totalPages": 5,
    "totalItems": 100
  }
}
```

### GET /api/v1/search/recent

최근 검색어 목록 조회

**Response**
```json
{
  "recentSearches": [
    {
      "query": "string",
      "timestamp": "2026-01-08T12:00:00Z"
    }
  ]
}
```

### DELETE /api/v1/search/recent

최근 검색어 전체 삭제

**Response**
```json
{
  "success": true
}
```

---

## Saved Tab APIs

### GET /api/v1/saved/places

저장된 장소 목록 조회

**Response**
```json
{
  "places": [
    {
      "id": "string",
      "name": "string",
      "location": "string",
      "imageUrl": "string",
      "rating": 4.7,
      "savedAt": "2026-01-08T12:00:00Z"
    }
  ]
}
```

### GET /api/v1/trips

여행 계획 목록 조회

**Response**
```json
{
  "trips": [
    {
      "id": "string",
      "title": "string",
      "imageUrl": "string",
      "startDate": "2026-02-01",
      "endDate": "2026-02-05",
      "placeCount": 5
    }
  ]
}
```

### GET /api/v1/collections

컬렉션 목록 조회

**Response**
```json
{
  "collections": [
    {
      "id": "string",
      "name": "string",
      "thumbnailUrl": "string",
      "itemCount": 10
    }
  ]
}
```

---

## Notifications Tab APIs

### GET /api/v1/notifications

알림 목록 조회

**Response**
```json
{
  "notifications": [
    {
      "id": "string",
      "type": "review",
      "title": "string",
      "message": "string",
      "createdAt": "2026-01-08T12:00:00Z",
      "isRead": false
    }
  ],
  "unreadCount": 3
}
```

### PUT /api/v1/notifications/read-all

모든 알림 읽음 처리

**Response**
```json
{
  "success": true,
  "updatedCount": 5
}
```

### DELETE /api/v1/notifications/{id}

개별 알림 삭제

**Response**
```json
{
  "success": true
}
```

---

## Profile Tab APIs

### GET /api/v1/users/me/stats

사용자 통계 조회

**Response**
```json
{
  "reviewCount": 12,
  "savedCount": 48,
  "tripCount": 5
}
```

---

## Error Responses

모든 API는 다음 형식의 에러 응답을 반환합니다:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable error message"
  }
}
```

| HTTP Status | Error Code | Description |
|-------------|------------|-------------|
| 400 | INVALID_REQUEST | 잘못된 요청 파라미터 |
| 401 | UNAUTHORIZED | 인증 필요 |
| 403 | FORBIDDEN | 권한 없음 |
| 404 | NOT_FOUND | 리소스를 찾을 수 없음 |
| 429 | TOO_MANY_REQUESTS | 요청 제한 초과 |
| 500 | INTERNAL_ERROR | 서버 내부 오류 |
