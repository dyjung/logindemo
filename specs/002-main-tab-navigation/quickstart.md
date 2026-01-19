# Quickstart: 탭 기반 메인 네비게이션

**Feature**: 002-main-tab-navigation
**Date**: 2026-01-08

## Overview

TripAdvisor 스타일 5개 탭 기반 메인 화면이 구현되어 있습니다.

## 현재 구현 상태

### 완료된 항목

- [x] MainView - TabView 기반 메인 컨테이너
- [x] ExploreView - 탐색 탭 (추천/인기 장소)
- [x] SearchView - 검색 탭 (검색 바, 카테고리 필터)
- [x] SavedView - 저장됨 탭 (세그먼트: 장소/여행/컬렉션)
- [x] NotificationsView - 알림 탭 (알림 목록, 읽음/삭제)
- [x] ProfileView - 프로필 탭 (사용자 정보, 로그아웃)

### 미완료 항목 (향후 구현)

- [ ] 실제 API 연동
- [ ] ViewModel 구현
- [ ] 단위 테스트 작성
- [ ] 알림 배지 카운트

## 파일 구조

```
LoginDemo/Presentation/Main/
├── MainView.swift                    # 메인 탭 컨테이너
└── Tabs/
    ├── ExploreTab/ExploreView.swift
    ├── SearchTab/SearchView.swift
    ├── SavedTab/SavedView.swift
    ├── NotificationsTab/NotificationsView.swift
    └── ProfileTab/ProfileView.swift
```

## 빌드 및 실행

```bash
# 빌드
xcodebuild -project LoginDemo.xcodeproj -scheme LoginDemo -sdk iphonesimulator -configuration Debug build

# 시뮬레이터 실행
# Xcode에서 실행하거나 다음 명령 사용:
xcrun simctl boot "iPhone 15"
xcrun simctl install booted /path/to/LoginDemo.app
xcrun simctl launch booted com.dyjung.LoginDemo
```

## 테스트 접근법

### 로그인 바이패스 (개발용)

로그인 화면 오른쪽 하단에 "메인으로" 버튼이 있어 로그인 없이 메인 화면을 테스트할 수 있습니다.

### 탭 네비게이션 테스트

1. 앱 실행 후 로그인 또는 "메인으로" 버튼 클릭
2. 하단 탭 바의 5개 탭 확인
3. 각 탭 클릭 시 화면 전환 확인
4. 선택된 탭 아이콘이 filled로 변경되는지 확인

### 각 탭 기능 테스트

**탐색 탭**
- 추천 카드 가로 스크롤
- 인기 장소 세로 스크롤

**검색 탭**
- 검색어 입력/삭제
- 카테고리 필터 선택

**저장됨 탭**
- 세그먼트 전환 (장소/여행/컬렉션)

**알림 탭**
- "모두 읽음" 버튼
- 스와이프 삭제

**프로필 탭**
- 사용자 정보 표시
- 로그아웃 버튼 동작

## 향후 확장 계획

### Phase 1: 데이터 레이어 연동

1. Place, Trip, Collection, Notification 엔티티 생성
2. Repository Protocol 정의
3. UseCase 구현
4. ViewModel 생성 및 View 연결

### Phase 2: API 연동

1. API 클라이언트 구현
2. DTO 및 Mapper 구현
3. Repository 구현

### Phase 3: 테스트

1. UseCase 단위 테스트
2. ViewModel 단위 테스트
3. UI 테스트 (주요 플로우)

## 관련 문서

- [spec.md](./spec.md) - 기능 명세서
- [plan.md](./plan.md) - 구현 계획
- [research.md](./research.md) - 기술 조사
- [data-model.md](./data-model.md) - 데이터 모델
- [contracts/api-contracts.md](./contracts/api-contracts.md) - API 계약
