# Implementation Plan: 탭 기반 메인 네비게이션

**Branch**: `002-main-tab-navigation` | **Date**: 2026-01-08 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/002-main-tab-navigation/spec.md`

## Summary

TripAdvisor 스타일의 5개 탭(탐색, 검색, 저장됨, 알림, 프로필) 기반 메인 화면을 SwiftUI TabView로 구현합니다. 각 탭은 독립적인 NavigationStack을 가지며, 클린 아키텍처 원칙에 따라 Presentation Layer에 위치합니다.

## Technical Context

**Language/Version**: Swift 5.9+
**Primary Dependencies**: SwiftUI, Foundation
**Storage**: UserDefaults (최근 검색), Keychain (인증 토큰 - 기존)
**Testing**: XCTest
**Target Platform**: iOS 15+
**Project Type**: Mobile (iOS)
**Performance Goals**: 탭 전환 0.3초 이내, 콘텐츠 로딩 2초 이내
**Constraints**: 60fps UI 렌더링, 다크모드 지원, VoiceOver 접근성
**Scale/Scope**: 5개 탭, 6개 주요 화면

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| 원칙 | 상태 | 검증 내용 |
|------|------|----------|
| I. SwiftUI 우선 | ✅ 통과 | 모든 탭 뷰는 SwiftUI View 프로토콜 준수, TabView와 NavigationStack 사용 |
| II. 클린 아키텍처 | ✅ 통과 | Presentation Layer에 View만 배치, ViewModel은 UseCase에만 의존 |
| III. 테스트 주도 개발 | ⚠️ 보류 | 현재 더미 데이터로 UI 구현, 실제 데이터 연동 시 테스트 작성 필요 |
| IV. 상태 관리 일관성 | ✅ 통과 | @State로 탭 선택 관리, @Observable ViewModel 패턴 준비 |
| V. 접근성 필수 | ✅ 통과 | 모든 탭에 accessibilityLabel, 인터랙티브 요소에 적절한 힌트 제공 |
| VI. 단순성 우선 | ✅ 통과 | SwiftUI 기본 컴포넌트 활용, 외부 라이브러리 미사용 |
| VII. 보안 최우선 | ✅ 통과 | 프로필 탭에서 기존 로그아웃 로직 재사용, Keychain 통한 토큰 관리 |

**Gate 결과**: ✅ 통과 (테스트는 데이터 레이어 연동 시 작성)

## Project Structure

### Documentation (this feature)

```text
specs/002-main-tab-navigation/
├── spec.md              # Feature specification
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (API contracts)
└── checklists/
    └── requirements.md  # Quality checklist
```

### Source Code (repository root)

```text
LoginDemo/
├── Presentation/
│   └── Main/
│       ├── MainView.swift                    # TabView 기반 메인 컨테이너
│       └── Tabs/
│           ├── ExploreTab/
│           │   └── ExploreView.swift         # 탐색 탭
│           ├── SearchTab/
│           │   └── SearchView.swift          # 검색 탭
│           ├── SavedTab/
│           │   └── SavedView.swift           # 저장됨 탭
│           ├── NotificationsTab/
│           │   └── NotificationsView.swift   # 알림 탭
│           └── ProfileTab/
│               └── ProfileView.swift         # 프로필 탭
│
├── Domain/
│   ├── Entities/
│   │   ├── Place.swift                       # 장소 엔티티 (향후)
│   │   ├── Trip.swift                        # 여행 엔티티 (향후)
│   │   └── Notification.swift                # 알림 엔티티 (향후)
│   └── UseCases/
│       ├── Places/                           # 장소 관련 UseCase (향후)
│       ├── Search/                           # 검색 관련 UseCase (향후)
│       └── Notifications/                    # 알림 관련 UseCase (향후)
│
└── Data/
    ├── Repositories/                         # 탭별 Repository (향후)
    └── DataSources/
        └── Local/
            └── RecentSearchDataSource.swift  # 최근 검색 저장 (향후)
```

**Structure Decision**: Mobile (iOS) 구조 선택. 기존 클린 아키텍처 구조를 유지하면서 Presentation/Main/Tabs/ 하위에 각 탭별 폴더를 생성하여 관리합니다.

## Complexity Tracking

> 본 기능은 Constitution Check에서 모든 원칙을 준수하므로 별도의 위반 정당화가 필요하지 않습니다.

| 항목 | 결정 | 근거 |
|------|------|------|
| 탭별 폴더 분리 | 채택 | 5개 탭이 독립적으로 발전할 수 있도록 모듈화 |
| 더미 데이터 사용 | 채택 | UI 우선 구현 후 데이터 레이어 연동 (점진적 개발) |
| ViewModel 없이 View만 | 채택 | 현재 더미 데이터이므로, 실제 API 연동 시 ViewModel 추가 |
