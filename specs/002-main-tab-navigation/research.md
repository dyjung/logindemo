# Research: 탭 기반 메인 네비게이션

**Feature**: 002-main-tab-navigation
**Date**: 2026-01-08

## Overview

본 문서는 TripAdvisor 스타일 탭 기반 메인 화면 구현을 위한 기술 조사 결과입니다.

---

## R1: SwiftUI TabView 구현 패턴

### Decision
SwiftUI의 `TabView`와 `tabItem` modifier를 사용하여 5개 탭 구현

### Rationale
- SwiftUI 네이티브 컴포넌트로 iOS 시스템과의 일관성 보장
- 선언적 구문으로 탭 구성이 간결하고 명확
- `@State` 바인딩으로 프로그래매틱 탭 전환 가능
- iOS 15+ 타겟에서 안정적으로 동작

### Alternatives Considered
| 대안 | 기각 이유 |
|------|----------|
| UITabBarController + UIViewControllerRepresentable | 불필요한 복잡성, UIKit 의존성 추가 |
| Custom TabBar 구현 | YAGNI 원칙 위반, SwiftUI 기본 기능으로 충분 |

### Implementation Notes
```swift
TabView(selection: $selectedTab) {
    ExploreView()
        .tabItem { Label("탐색", systemImage: "safari") }
        .tag(MainTab.explore)
    // ... 다른 탭들
}
.tint(.primaryColor)
```

---

## R2: 탭별 독립 NavigationStack

### Decision
각 탭 내부에 독립적인 `NavigationStack`을 배치

### Rationale
- 탭 전환 시 네비게이션 상태가 보존됨
- 각 탭의 네비게이션 히스토리가 독립적으로 관리
- TripAdvisor 등 주요 앱들의 표준 패턴
- iOS Human Interface Guidelines 권장 사항

### Alternatives Considered
| 대안 | 기각 이유 |
|------|----------|
| 단일 NavigationStack | 탭 전환 시 네비게이션 스택 손실 |
| NavigationView (deprecated) | iOS 16+에서 deprecated |

---

## R3: 선택 상태 아이콘 변경

### Decision
선택된 탭은 filled 아이콘, 비선택 탭은 outline 아이콘 사용

### Rationale
- 시각적으로 현재 위치를 명확히 표시
- SF Symbols의 기본 제공 아이콘 활용
- 접근성 향상 (색상에만 의존하지 않음)

### Implementation Notes
```swift
enum MainTab {
    var icon: String {
        switch self {
        case .explore: return "safari"
        // ...
        }
    }
    var selectedIcon: String {
        switch self {
        case .explore: return "safari.fill"
        // ...
        }
    }
}
```

---

## R4: 검색 카테고리 필터 UI

### Decision
가로 스크롤 Chip/Pill 버튼으로 카테고리 필터 구현

### Rationale
- TripAdvisor, Airbnb 등 여행 앱의 표준 패턴
- 작은 화면에서도 모든 카테고리 접근 가능
- 터치 영역이 충분히 크고 직관적

### Implementation Notes
- `ScrollView(.horizontal)` 사용
- 선택된 카테고리는 `primaryColor` 배경
- 비선택 카테고리는 `systemGray6` 배경

---

## R5: 알림 읽음/안읽음 상태 표시

### Decision
읽지 않은 알림은 강조 배경색 + 파란색 점 표시

### Rationale
- 두 가지 시각적 신호로 접근성 향상
- 이메일 앱들의 표준 UX 패턴
- 색상만으로 구분하지 않음 (색각 이상 사용자 고려)

---

## R6: 프로필 탭 로그아웃 연동

### Decision
기존 `LogoutUseCase`와 `AppState.handleLogout()` 재사용

### Rationale
- 기존 인증 로직과의 일관성 유지
- 중복 코드 방지
- 클린 아키텍처 원칙 준수 (UseCase 통한 비즈니스 로직 실행)

---

## R7: 더미 데이터 전략

### Decision
현재 UI 구현 단계에서는 하드코딩된 더미 데이터 사용

### Rationale
- UI/UX 검증을 위한 빠른 프로토타이핑
- 백엔드 API 완성 전 프론트엔드 개발 진행 가능
- 향후 실제 데이터 연동 시 ViewModel + UseCase 패턴으로 교체

### Migration Path
1. 현재: View 내부 더미 데이터
2. 향후: ViewModel 생성 → UseCase 연동 → Repository → API

---

## Summary

| 조사 항목 | 결정 | 상태 |
|----------|------|------|
| TabView 패턴 | SwiftUI 네이티브 TabView | ✅ 구현됨 |
| 네비게이션 | 탭별 독립 NavigationStack | ✅ 구현됨 |
| 아이콘 상태 | filled/outline 토글 | ✅ 구현됨 |
| 검색 필터 | 가로 스크롤 Chip | ✅ 구현됨 |
| 알림 상태 | 배경색 + 점 표시 | ✅ 구현됨 |
| 로그아웃 | 기존 UseCase 재사용 | ✅ 구현됨 |
| 데이터 | 더미 데이터 (향후 API 연동) | ✅ 구현됨 |

모든 NEEDS CLARIFICATION 항목이 해결되었습니다.
