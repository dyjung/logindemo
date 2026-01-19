# Tasks: 탭 기반 메인 네비게이션

**Input**: Design documents from `/specs/002-main-tab-navigation/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/

**Tests**: 테스트는 현재 단계에서 요청되지 않음 (데이터 레이어 연동 시 추가 예정)

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

**Status**: UI 구현 완료 ✅ | 향후 데이터 레이어 연동 필요

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Mobile (iOS)**: `LoginDemo/` at repository root
- Presentation Layer: `LoginDemo/Presentation/`
- Domain Layer: `LoginDemo/Domain/`
- Data Layer: `LoginDemo/Data/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Create Main tab folder structure in LoginDemo/Presentation/Main/Tabs/
- [x] T002 Define MainTab enum with icon and label properties in LoginDemo/Presentation/Main/MainView.swift
- [x] T003 [P] Configure tab bar tint color to match primaryColor

**Phase 1 Status**: ✅ 완료

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T004 Verify AppState.currentScreen supports .main state in LoginDemo/Presentation/App/AppState.swift
- [x] T005 [P] Verify RootView renders MainView when currentScreen == .main
- [x] T006 [P] Ensure DIContainer provides required dependencies for ProfileView

**Checkpoint**: Foundation ready - user story implementation can now begin ✅

---

## Phase 3: User Story 1 - 탭 기반 네비게이션 (Priority: P1) 🎯 MVP

**Goal**: 로그인한 사용자가 하단 탭 바를 통해 앱의 주요 기능에 쉽게 접근할 수 있습니다.

**Independent Test**: 로그인 후 하단 탭 바가 표시되고 각 탭을 탭하여 해당 화면으로 이동하는지 검증

### Implementation for User Story 1

- [x] T007 [US1] Implement MainView with TabView in LoginDemo/Presentation/Main/MainView.swift
- [x] T008 [US1] Add 5 tab items (explore, search, saved, notifications, profile)
- [x] T009 [US1] Implement tab selection state with @State private var selectedTab
- [x] T010 [US1] Configure filled/outline icon toggle based on selection
- [x] T011 [US1] Set default tab to .explore on initial load

**Checkpoint**: User Story 1 완료 - TabView 기반 네비게이션 동작 확인 ✅

---

## Phase 4: User Story 2 - 탐색 화면 (Priority: P1)

**Goal**: 사용자가 탐색 탭에서 추천 장소와 인기 장소 목록을 확인할 수 있습니다.

**Independent Test**: 탐색 탭에서 추천 카드와 인기 장소 목록이 표시되고 스크롤할 수 있는지 검증

### Implementation for User Story 2

- [x] T012 [P] [US2] Create ExploreView in LoginDemo/Presentation/Main/Tabs/ExploreTab/ExploreView.swift
- [x] T013 [US2] Implement "오늘의 추천" horizontal scroll section with RecommendationCard
- [x] T014 [US2] Implement "인기 장소" vertical list section with PlaceRow
- [x] T015 [US2] Add NavigationStack with title "탐색"
- [x] T016 [US2] Style cards with image placeholder, name, rating, review count

**Checkpoint**: User Story 2 완료 - 탐색 화면 UI 동작 확인 ✅

---

## Phase 5: User Story 3 - 검색 화면 (Priority: P2)

**Goal**: 사용자가 검색 탭에서 장소를 검색하고 카테고리별로 필터링할 수 있습니다.

**Independent Test**: 검색 탭에서 검색어를 입력하고 카테고리 필터를 선택하여 결과가 표시되는지 검증

### Implementation for User Story 3

- [x] T017 [P] [US3] Create SearchView in LoginDemo/Presentation/Main/Tabs/SearchTab/SearchView.swift
- [x] T018 [US3] Implement search text field with placeholder and clear button
- [x] T019 [US3] Implement SearchCategory enum (all, restaurants, hotels, attractions, activities)
- [x] T020 [US3] Create CategoryChip component for horizontal filter scrollview
- [x] T021 [US3] Implement recent searches view when search text is empty
- [x] T022 [US3] Implement search results view with SearchResultRow

**Checkpoint**: User Story 3 완료 - 검색 화면 UI 동작 확인 ✅

---

## Phase 6: User Story 4 - 저장됨 화면 (Priority: P2)

**Goal**: 사용자가 저장한 장소, 여행 계획, 컬렉션을 관리하고 확인할 수 있습니다.

**Independent Test**: 저장됨 탭에서 세그먼트(장소, 여행, 컬렉션)를 전환하고 각 콘텐츠가 표시되는지 검증

### Implementation for User Story 4

- [x] T023 [P] [US4] Create SavedView in LoginDemo/Presentation/Main/Tabs/SavedTab/SavedView.swift
- [x] T024 [US4] Implement segmented control (장소, 여행, 컬렉션)
- [x] T025 [US4] Create SavedPlaceRow component for saved places list
- [x] T026 [US4] Create TripCard component for trips list
- [x] T027 [US4] Create CollectionCard component for collections grid
- [x] T028 [US4] Add navigation bar + button for new item

**Checkpoint**: User Story 4 완료 - 저장됨 화면 UI 동작 확인 ✅

---

## Phase 7: User Story 5 - 알림 화면 (Priority: P3)

**Goal**: 사용자가 알림 탭에서 알림을 확인하고 관리할 수 있습니다.

**Independent Test**: 알림 탭에서 알림 목록이 표시되고 읽음/삭제 처리가 되는지 검증

### Implementation for User Story 5

- [x] T029 [P] [US5] Create NotificationsView in LoginDemo/Presentation/Main/Tabs/NotificationsTab/NotificationsView.swift
- [x] T030 [US5] Define NotificationItem struct with type, title, message, timeAgo, isRead
- [x] T031 [US5] Define NotificationType enum (review, recommendation, trip, promo)
- [x] T032 [US5] Create NotificationRow component with icon, content, unread indicator
- [x] T033 [US5] Implement "모두 읽음" button in navigation bar
- [x] T034 [US5] Implement swipe-to-delete for notifications
- [x] T035 [US5] Implement empty state view when no notifications

**Checkpoint**: User Story 5 완료 - 알림 화면 UI 동작 확인 ✅

---

## Phase 8: User Story 6 - 프로필 화면 (Priority: P2)

**Goal**: 사용자가 프로필 탭에서 자신의 정보를 확인하고 로그아웃할 수 있습니다.

**Independent Test**: 프로필 탭에서 사용자 정보가 표시되고 로그아웃 버튼이 동작하는지 검증

### Implementation for User Story 6

- [x] T036 [P] [US6] Create ProfileView in LoginDemo/Presentation/Main/Tabs/ProfileTab/ProfileView.swift
- [x] T037 [US6] Implement profile header with avatar/initials, name, email
- [x] T038 [US6] Create StatItem component for user statistics (리뷰, 저장됨, 여행)
- [x] T039 [US6] Create MenuSection and MenuItem components for menu lists
- [x] T040 [US6] Implement "내 활동" menu section
- [x] T041 [US6] Implement "설정" menu section
- [x] T042 [US6] Implement logout button with existing LogoutUseCase integration
- [x] T043 [US6] Add "프로필 수정" button
- [x] T044 [US6] Add settings icon in navigation bar

**Checkpoint**: User Story 6 완료 - 프로필 화면 UI 동작 확인 ✅

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [x] T045 [P] Add dark mode support with semantic colors across all tab views
- [x] T046 [P] Ensure VoiceOver accessibility labels on all interactive elements ✅ 개선됨 (2026-01-08)
- [x] T047 Add "메인으로" bypass button on LoginView for development testing

### Accessibility Improvements Applied (T046)

- **ExploreView**: RecommendationCard/PlaceRow에 accessibilityLabel, accessibilityHint 추가
- **SearchView**: 검색 TextField, CategoryChip, SearchResultRow에 접근성 속성 추가
- **SavedView**: Picker, SavedPlaceRow, TripCard, CollectionCard에 접근성 속성 추가
- **NotificationsView**: NotificationRow에 accessibilityLabel, accessibilityValue 추가
- **ProfileView**: StatItem, MenuItem, logoutButton에 접근성 속성 추가

### Pending (향후 데이터 레이어 연동 시)

- [ ] T048 Create Place entity in LoginDemo/Domain/Entities/Place.swift
- [ ] T049 Create Trip entity in LoginDemo/Domain/Entities/Trip.swift
- [ ] T050 Create Notification entity in LoginDemo/Domain/Entities/Notification.swift
- [ ] T051 [P] Implement PlaceRepository in LoginDemo/Data/Repositories/
- [ ] T052 [P] Implement SearchRepository in LoginDemo/Data/Repositories/
- [ ] T053 [P] Implement NotificationRepository in LoginDemo/Data/Repositories/
- [ ] T054 Create ExploreViewModel in LoginDemo/Presentation/Main/Tabs/ExploreTab/
- [ ] T055 Create SearchViewModel in LoginDemo/Presentation/Main/Tabs/SearchTab/
- [ ] T056 Create SavedViewModel in LoginDemo/Presentation/Main/Tabs/SavedTab/
- [ ] T057 Create NotificationsViewModel in LoginDemo/Presentation/Main/Tabs/NotificationsTab/
- [ ] T058 Implement RecentSearchDataSource for UserDefaults persistence
- [ ] T059 Write unit tests for ViewModels
- [ ] T060 Run quickstart.md validation

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - ✅ 완료
- **Foundational (Phase 2)**: Depends on Setup completion - ✅ 완료
- **User Stories (Phase 3-8)**: All depend on Foundational phase - ✅ 완료
- **Polish (Phase 9)**: UI 작업 완료, 데이터 레이어 향후 진행

### User Story Dependencies

| User Story | Priority | Status | Dependencies |
|------------|----------|--------|--------------|
| US1 - 탭 네비게이션 | P1 | ✅ 완료 | Phase 2 |
| US2 - 탐색 화면 | P1 | ✅ 완료 | US1 |
| US3 - 검색 화면 | P2 | ✅ 완료 | US1 |
| US4 - 저장됨 화면 | P2 | ✅ 완료 | US1 |
| US5 - 알림 화면 | P3 | ✅ 완료 | US1 |
| US6 - 프로필 화면 | P2 | ✅ 완료 | US1 |

### Parallel Opportunities

- T012, T017, T023, T029, T036: 각 탭 View는 독립적으로 병렬 개발 가능
- T048, T049, T050: 엔티티들은 병렬 생성 가능
- T051, T052, T053: Repository들은 병렬 구현 가능
- T054, T055, T056, T057: ViewModel들은 병렬 구현 가능

---

## Parallel Example: Data Layer Tasks (향후)

```bash
# Launch all entity creation together:
Task: "Create Place entity in LoginDemo/Domain/Entities/Place.swift"
Task: "Create Trip entity in LoginDemo/Domain/Entities/Trip.swift"
Task: "Create Notification entity in LoginDemo/Domain/Entities/Notification.swift"

# Launch all ViewModel creation together:
Task: "Create ExploreViewModel in LoginDemo/Presentation/Main/Tabs/ExploreTab/"
Task: "Create SearchViewModel in LoginDemo/Presentation/Main/Tabs/SearchTab/"
Task: "Create SavedViewModel in LoginDemo/Presentation/Main/Tabs/SavedTab/"
Task: "Create NotificationsViewModel in LoginDemo/Presentation/Main/Tabs/NotificationsTab/"
```

---

## Implementation Strategy

### Current Status: MVP Complete ✅

1. ✅ Phase 1: Setup - 완료
2. ✅ Phase 2: Foundational - 완료
3. ✅ Phase 3-8: All User Stories UI - 완료
4. ⏳ Phase 9: Data Layer - 향후 진행

### Incremental Delivery (향후)

1. ✅ UI MVP 완료 - 더미 데이터로 모든 화면 구현
2. → 탐색 탭 API 연동 (Place 데이터)
3. → 검색 탭 API 연동 (Search + Recent searches)
4. → 저장됨 탭 API 연동 (Saved places, Trips, Collections)
5. → 알림 탭 API 연동 (Notifications)
6. → 프로필 탭 API 연동 (User stats)

---

## Summary

| Category | Count | Status |
|----------|-------|--------|
| Total Tasks | 60 | - |
| Completed | 47 | ✅ |
| Pending (Data Layer) | 13 | ⏳ |
| Parallelizable | 18 | [P] marked |

### Per User Story

| Story | Tasks | Status |
|-------|-------|--------|
| US1 - 탭 네비게이션 | 5 | ✅ 완료 |
| US2 - 탐색 화면 | 5 | ✅ 완료 |
| US3 - 검색 화면 | 6 | ✅ 완료 |
| US4 - 저장됨 화면 | 6 | ✅ 완료 |
| US5 - 알림 화면 | 7 | ✅ 완료 |
| US6 - 프로필 화면 | 9 | ✅ 완료 |

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story is independently testable with dummy data
- UI implementation complete, data layer pending
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
