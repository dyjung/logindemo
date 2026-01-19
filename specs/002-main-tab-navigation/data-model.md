# Data Model: 탭 기반 메인 네비게이션

**Feature**: 002-main-tab-navigation
**Date**: 2026-01-08

## Overview

본 문서는 탭 기반 메인 화면에서 사용되는 데이터 모델을 정의합니다.

---

## Presentation Layer Entities

### MainTab (Enum)

탭 종류를 나타내는 열거형

| Case | Title | Icon | Selected Icon |
|------|-------|------|---------------|
| explore | 탐색 | safari | safari.fill |
| search | 검색 | magnifyingglass | magnifyingglass |
| saved | 저장됨 | heart | heart.fill |
| notifications | 알림 | bell | bell.fill |
| profile | 프로필 | person | person.fill |

```swift
enum MainTab: Int, CaseIterable {
    case explore = 0
    case search
    case saved
    case notifications
    case profile
}
```

---

### SearchCategory (Enum)

검색 카테고리 필터

| Case | Title | Icon |
|------|-------|------|
| all | 전체 | square.grid.2x2 |
| restaurants | 레스토랑 | fork.knife |
| hotels | 호텔 | bed.double |
| attractions | 명소 | camera |
| activities | 즐길거리 | figure.hiking |

---

### NotificationItem (Struct)

알림 정보 모델

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | 고유 식별자 |
| type | NotificationType | 알림 종류 |
| title | String | 알림 제목 |
| message | String | 알림 메시지 |
| timeAgo | String | 경과 시간 표시 |
| isRead | Bool | 읽음 여부 |

#### NotificationType (Enum)

| Case | Icon | Color |
|------|------|-------|
| review | star.fill | yellow |
| recommendation | heart.fill | red |
| trip | airplane | blue |
| promo | tag.fill | green |

---

## Domain Layer Entities (향후 구현)

### Place (Entity)

장소 정보 엔티티

| Field | Type | Description |
|-------|------|-------------|
| id | String | 고유 식별자 |
| name | String | 장소 이름 |
| location | String | 위치 정보 |
| rating | Double | 평점 (0.0-5.0) |
| reviewCount | Int | 리뷰 수 |
| imageURL | URL? | 대표 이미지 URL |
| category | PlaceCategory | 장소 카테고리 |

---

### Trip (Entity)

여행 계획 엔티티

| Field | Type | Description |
|-------|------|-------------|
| id | String | 고유 식별자 |
| title | String | 여행 제목 |
| startDate | Date? | 시작일 |
| endDate | Date? | 종료일 |
| places | [Place] | 포함된 장소 목록 |
| imageURL | URL? | 대표 이미지 URL |

---

### Collection (Entity)

컬렉션 엔티티

| Field | Type | Description |
|-------|------|-------------|
| id | String | 고유 식별자 |
| name | String | 컬렉션 이름 |
| itemCount | Int | 항목 수 |
| thumbnailURL | URL? | 썸네일 이미지 URL |

---

### Notification (Entity)

알림 엔티티 (Domain Layer)

| Field | Type | Description |
|-------|------|-------------|
| id | String | 고유 식별자 |
| type | NotificationType | 알림 종류 |
| title | String | 알림 제목 |
| body | String | 알림 본문 |
| createdAt | Date | 생성 시간 |
| isRead | Bool | 읽음 여부 |
| metadata | [String: Any]? | 추가 데이터 |

---

## State Models

### SavedSegment (Enum)

저장됨 탭의 세그먼트 상태

| Case | Value |
|------|-------|
| places | 0 |
| trips | 1 |
| collections | 2 |

---

## Relationships

```
┌─────────────┐     ┌─────────────┐
│    User     │────<│   Trip      │
└─────────────┘     └─────────────┘
                          │
                          │ contains
                          ▼
                    ┌─────────────┐
                    │   Place     │
                    └─────────────┘
                          │
                          │ belongs to
                          ▼
                    ┌─────────────┐
                    │ Collection  │
                    └─────────────┘

┌─────────────┐
│    User     │────<│ Notification │
└─────────────┘     └──────────────┘
```

---

## Validation Rules

| Entity | Field | Rule |
|--------|-------|------|
| Place | rating | 0.0 ≤ value ≤ 5.0 |
| Place | reviewCount | value ≥ 0 |
| Trip | title | length > 0 |
| Collection | name | length > 0 |
| Notification | title | length > 0 |
