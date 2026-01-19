# LoginDemo 작업 명세서

> speckit + TypeSpec 기반 명세 주도 개발 (Specification-Driven Development) 순차적 작업 흐름

**Version**: 1.0.0
**Last Updated**: 2026-01-14
**Status**: Demo Complete (iOS + Android + Backend)

---

## 목차

1. [개요](#1-개요)
2. [개발 도구 및 환경](#2-개발-도구-및-환경)
3. [Phase 1: 프로젝트 헌법 수립](#phase-1-프로젝트-헌법-수립)
4. [Phase 2: Feature 명세 작성 (speckit)](#phase-2-feature-명세-작성-speckit)
5. [Phase 3: API 명세 작성 (TypeSpec)](#phase-3-api-명세-작성-typespec)
6. [Phase 4: Backend 구현 (NestJS)](#phase-4-backend-구현-nestjs)
7. [Phase 5: iOS 구현 (SwiftUI)](#phase-5-ios-구현-swiftui)
8. [Phase 6: Android 구현 (Jetpack Compose)](#phase-6-android-구현-jetpack-compose)
9. [검증 및 테스트](#7-검증-및-테스트)
10. [향후 작업](#8-향후-작업)

---

## 1. 개요

### 1.1 명세 주도 개발 (Specification-Driven Development)

이 프로젝트는 **명세서를 먼저 작성하고, 그 명세서에 따라 구현**하는 방식으로 개발되었습니다.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        개발 순서 (Work Flow)                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   1. Constitution (헌법)                                                 │
│      └── 프로젝트의 핵심 원칙과 규칙 정의                                    │
│                                                                         │
│   2. Feature Specification (speckit)                                    │
│      ├── spec.md      → User Stories & Requirements                     │
│      ├── plan.md      → Implementation Plan                             │
│      ├── research.md  → Technical Research                              │
│      ├── data-model.md → Data Model Design                              │
│      └── tasks.md     → Actionable Tasks                                │
│                                                                         │
│   3. API Contract (TypeSpec)                                            │
│      ├── main.tsp     → API 명세 정의                                    │
│      └── openapi.yaml → 생성된 OpenAPI 스펙                              │
│                                                                         │
│   4. Backend Implementation (NestJS)                                    │
│      ├── Prisma Schema → Database Model                                 │
│      ├── Services      → Business Logic                                 │
│      └── Controllers   → API Endpoints                                  │
│                                                                         │
│   5. iOS Implementation (SwiftUI)                                       │
│      ├── Domain Layer  → Entities, UseCases, Protocols                  │
│      ├── Data Layer    → Repositories, DTOs, Network                    │
│      └── Presentation  → Views, ViewModels                              │
│                                                                         │
│   6. Android Implementation (Jetpack Compose)                           │
│      ├── Domain Layer  → Models, UseCases, Repository Interface         │
│      ├── Data Layer    → Repositories, DTOs, Network                    │
│      └── Presentation  → Screens, ViewModels                            │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### 1.2 프로젝트 구조

```
LoginDemo/
├── .specify/                    # speckit 템플릿
│   ├── memory/
│   │   └── constitution.md      # 프로젝트 헌법
│   └── templates/               # 명세서 템플릿
│
├── specs/                       # Feature 명세서
│   ├── 001-auth-onboarding-flow/
│   │   ├── spec.md              # 기능 명세
│   │   ├── plan.md              # 구현 계획
│   │   ├── research.md          # 기술 조사
│   │   ├── data-model.md        # 데이터 모델
│   │   └── tasks.md             # 작업 목록
│   │
│   └── 002-main-tab-navigation/
│       ├── spec.md
│       ├── plan.md
│       └── tasks.md
│
├── typespec/                    # API 명세
│   ├── main.tsp                 # TypeSpec 정의
│   └── backend/                 # NestJS 백엔드
│       ├── src/
│       └── prisma/
│
├── ios/                         # iOS 프로젝트
│   └── LoginDemo/
│
├── android/                     # Android 프로젝트
│   └── app/
│
├── shared/                      # 공유 리소스
│   ├── localization/            # 다국어 문자열
│   └── api-contracts/           # OpenAPI 스펙
│
├── CLAUDE.md                    # Claude Code 가이드
├── MANUAL.md                    # 프로젝트 매뉴얼
├── WORK_ORDER.md                # 이 문서
└── Makefile                     # 빌드 명령어
```

---

## 2. 개발 도구 및 환경

### 2.1 명세 도구

| 도구 | 용도 | 버전 |
|------|------|------|
| speckit | Feature 명세 워크플로우 | Claude Code Custom Commands |
| TypeSpec | API 명세 정의 언어 | 0.x |
| OpenAPI | REST API 스펙 | 3.0 |

### 2.2 Backend

| 기술 | 용도 | 버전 |
|------|------|------|
| NestJS | 백엔드 프레임워크 | 11.x |
| TypeScript | 프로그래밍 언어 | 5.x |
| Prisma | ORM | 6.x |
| PostgreSQL | 데이터베이스 | 15+ |

### 2.3 iOS

| 기술 | 용도 | 버전 |
|------|------|------|
| Swift | 프로그래밍 언어 | 5.9+ |
| SwiftUI | UI 프레임워크 | iOS 17+ |
| Alamofire | HTTP 클라이언트 | 5.x |
| Keychain | 보안 저장소 | - |

### 2.4 Android

| 기술 | 용도 | 버전 |
|------|------|------|
| Kotlin | 프로그래밍 언어 | 1.9+ |
| Jetpack Compose | UI 프레임워크 | - |
| Hilt | 의존성 주입 | 2.x |
| Retrofit | HTTP 클라이언트 | 2.x |

---

## Phase 1: 프로젝트 헌법 수립

### 1.1 목적

프로젝트의 핵심 원칙과 규칙을 정의하여 일관된 개발 방향을 확립합니다.

### 1.2 명령어

```bash
# speckit constitution 생성
/speckit.constitution
```

### 1.3 산출물

**파일**: `.specify/memory/constitution.md`

### 1.4 주요 원칙 (Version 1.1.0)

| 원칙 | 설명 |
|------|------|
| I. SwiftUI 우선 | 모든 UI는 SwiftUI로 구현 |
| II. 클린 아키텍처 | Domain/Data/Presentation 레이어 분리 |
| III. TDD | 테스트 우선 개발 |
| IV. 상태 관리 일관성 | @State, @Observable 등 일관된 패턴 |
| V. 접근성 필수 | VoiceOver, accessibilityLabel 필수 |
| VI. 단순성 우선 | YAGNI 원칙 |
| VII. 보안 최우선 | Keychain 사용, 자동로그인 보안 규칙 |

### 1.5 작업 완료 기준

- [x] constitution.md 작성 완료
- [x] 핵심 원칙 7개 정의
- [x] 클린 아키텍처 레이어 규칙 명시
- [x] 자동로그인 보안 규칙 추가
- [x] 코딩 규칙 및 파일 구조 정의

---

## Phase 2: Feature 명세 작성 (speckit)

### 2.1 목적

각 Feature의 요구사항, 구현 계획, 작업 목록을 체계적으로 정의합니다.

### 2.2 speckit 워크플로우

```bash
# 1. Feature Spec 생성
/speckit.specify

# 2. 명세 명확화 (질문-답변)
/speckit.clarify

# 3. 구현 계획 수립
/speckit.plan

# 4. 작업 목록 생성
/speckit.tasks

# 5. 일관성 분석
/speckit.analyze
```

### 2.3 Feature 001: 인증 및 온보딩 플로우

**디렉토리**: `specs/001-auth-onboarding-flow/`

#### User Stories (Priority 순)

| ID | User Story | Priority | 설명 |
|----|------------|----------|------|
| US1 | 스플래시 화면 | P1 | 앱 시작 시 스플래시 표시 후 상태별 라우팅 |
| US3 | 이메일/비밀번호 로그인 | P1 | 이메일, 비밀번호 입력 + 자동로그인 |
| US5 | 회원가입 | P1 | 이메일, 비밀번호, 닉네임, 약관 동의 |
| US2 | 온보딩 | P2 | 최초 사용자 대상 3페이지 슬라이드 |
| US4 | 소셜 로그인 | P2 | 카카오, 네이버, Apple |
| US6 | 비밀번호 찾기 | P3 | 이메일 기반 비밀번호 재설정 |

#### 작업 진행 상황

| Phase | 설명 | Tasks | Status |
|-------|------|-------|--------|
| Setup | 프로젝트 초기화 | T001-T009 | 부분 완료 |
| Foundational | 핵심 인프라 | T010-T054 | ✅ 완료 |
| US1 | 스플래시 | T055-T066 | ✅ 완료 |
| US3 | 로그인 | T067-T080 | 진행중 |
| US5 | 회원가입 | T081-T094 | 대기 |
| US2 | 온보딩 | T095-T105 | 대기 |
| US4 | 소셜 로그인 | T106-T118 | 대기 |
| US6 | 비밀번호 찾기 | T119-T127 | 대기 |

### 2.4 Feature 002: 탭 기반 메인 네비게이션

**디렉토리**: `specs/002-main-tab-navigation/`

#### User Stories

| ID | User Story | Priority | 설명 |
|----|------------|----------|------|
| US1 | 탭 네비게이션 | P1 | 5개 탭 (탐색, 검색, 저장됨, 알림, 프로필) |
| US2 | 탐색 화면 | P1 | 오늘의 추천, 인기 장소 |
| US3 | 검색 화면 | P2 | 검색 + 카테고리 필터 |
| US4 | 저장됨 화면 | P2 | 장소, 여행, 컬렉션 세그먼트 |
| US5 | 알림 화면 | P3 | 알림 목록, 읽음/삭제 |
| US6 | 프로필 화면 | P2 | 사용자 정보, 통계, 로그아웃 |

#### 작업 진행 상황

| Phase | 설명 | Tasks | Status |
|-------|------|-------|--------|
| Setup | 폴더 구조 | T001-T003 | ✅ 완료 |
| Foundational | 기반 작업 | T004-T006 | ✅ 완료 |
| US1-US6 | 모든 탭 UI | T007-T044 | ✅ 완료 |
| Polish | 접근성, 다크모드 | T045-T047 | ✅ 완료 |
| Data Layer | API 연동 | T048-T060 | 대기 (향후) |

### 2.5 작업 완료 기준

- [x] 001-auth-onboarding-flow spec.md 완료
- [x] 001-auth-onboarding-flow tasks.md 생성 (139개 태스크)
- [x] 002-main-tab-navigation spec.md 완료
- [x] 002-main-tab-navigation tasks.md 생성 (60개 태스크)
- [x] UI 레벨 MVP 완료 (더미 데이터)

---

## Phase 3: API 명세 작성 (TypeSpec)

### 3.1 목적

Backend와 Mobile 간의 API 계약을 명확하게 정의합니다.

### 3.2 TypeSpec 파일 구조

```
typespec/
├── main.tsp           # 메인 TypeSpec 정의
├── package.json
├── tspconfig.yaml
└── tsp-output/
    └── @typespec/
        └── openapi3/
            └── openapi.yaml  # 생성된 OpenAPI 스펙
```

### 3.3 API 엔드포인트 정의

**파일**: `typespec/main.tsp`

#### 시스템 API

| Method | Endpoint | 설명 |
|--------|----------|------|
| GET | `/v1/init` | 앱 초기화 (자동로그인 포함) |

#### 인증 API

| Method | Endpoint | 설명 |
|--------|----------|------|
| POST | `/v1/auth/register` | 회원가입 |
| POST | `/v1/auth/login` | 로그인 |
| POST | `/v1/auth/refresh` | 토큰 갱신 |
| GET | `/v1/auth/verify` | 토큰 검증 |
| POST | `/v1/auth/logout` | 로그아웃 |
| GET | `/v1/auth/find-id` | 이메일 찾기 |
| POST | `/v1/auth/password-reset` | 비밀번호 재설정 요청 |
| PATCH | `/v1/auth/password-confirm` | 비밀번호 변경 확정 |

### 3.4 주요 모델 정의

#### Enums

```typescript
enum AuthenticationMethod {
  EMAIL, KAKAO, NAVER, APPLE, GOOGLE
}

enum UserStatus {
  ACTIVE, SLEEP, SUSPENDED, DELETED
}

enum Platform {
  IOS, ANDROID, WEB
}
```

#### 핵심 모델

| Model | 설명 |
|-------|------|
| User | 사용자 정보 (id, email, nickname, status) |
| AuthenticationAccount | 인증 계정 (method, providerId, passwordHash) |
| LoginRequest | 로그인 요청 (provider, email, password, socialAccessToken) |
| LoginResponse | 로그인 응답 (user, accessToken, refreshToken, expiresIn) |
| RegisterRequest | 회원가입 요청 |
| TokenRefreshRequest | 토큰 갱신 요청 |

### 3.5 OpenAPI 생성

```bash
cd typespec
npx tsp compile .
# 결과: tsp-output/@typespec/openapi3/openapi.yaml
```

### 3.6 작업 완료 기준

- [x] main.tsp 작성 완료 (632 lines)
- [x] 공통 헤더 모델 정의 (CommonClientHeaders, AuthorizedHeaders)
- [x] 인증 관련 모든 Request/Response 모델 정의
- [x] 자동로그인 실패 사유 Enum 정의 (AutoLoginFailureReason)
- [x] OpenAPI 스펙 생성

---

## Phase 4: Backend 구현 (NestJS)

### 4.1 목적

TypeSpec으로 정의된 API를 NestJS로 구현합니다.

### 4.2 디렉토리 구조

```
typespec/backend/
├── src/
│   ├── main.ts                 # 앱 부트스트랩
│   ├── app.module.ts           # 루트 모듈
│   ├── auth/
│   │   ├── auth.module.ts      # Auth 모듈
│   │   ├── auth.controller.ts  # API 엔드포인트
│   │   └── auth.service.ts     # 비즈니스 로직
│   ├── prisma/
│   │   ├── prisma.module.ts    # DB 모듈
│   │   └── prisma.service.ts   # Prisma 클라이언트
│   ├── system/
│   │   └── system.controller.ts
│   └── common/
│       ├── dto.ts              # DTO 정의
│       ├── enums.ts            # Enum 정의
│       ├── models.ts           # 모델 정의
│       └── utils/
│           └── password.util.ts
│
└── prisma/
    └── schema.prisma           # DB 스키마
```

### 4.3 Prisma 스키마 정의

**파일**: `prisma/schema.prisma`

#### 모델

| Model | 설명 |
|-------|------|
| User | 사용자 정보 |
| AuthenticationAccount | 인증 계정 (EMAIL + 소셜) |
| RefreshToken | 리프레시 토큰 (Token Rotation) |
| Device | 디바이스 정보 |
| PasswordResetToken | 비밀번호 재설정 토큰 |
| AppConfig | 앱 설정 |

### 4.4 구현 순서

#### Step 1: 프로젝트 초기화

```bash
cd typespec
nest new backend
cd backend
npm install @prisma/client bcrypt class-validator class-transformer
npm install -D prisma @types/bcrypt
```

#### Step 2: Prisma 설정

```bash
npx prisma init
# schema.prisma 작성
npx prisma db push
npx prisma generate
```

#### Step 3: 모듈 구현

1. **PrismaModule** - 데이터베이스 연결
2. **AuthModule** - 인증 로직
   - `auth.service.ts`: register, login, refresh, logout, passwordReset
   - `auth.controller.ts`: REST 엔드포인트

#### Step 4: Swagger 설정

```typescript
// main.ts
const config = new DocumentBuilder()
  .setTitle('LoginDemo API')
  .setVersion('1.0')
  .addBearerAuth()
  .build();
const document = SwaggerModule.createDocument(app, config);
SwaggerModule.setup('api-docs', app, document);
```

### 4.5 구현 완료 기능

| 기능 | Endpoint | Status |
|------|----------|--------|
| 회원가입 | POST /v1/auth/register | ✅ |
| 로그인 | POST /v1/auth/login | ✅ |
| 토큰 갱신 | POST /v1/auth/refresh | ✅ |
| 토큰 검증 | GET /v1/auth/verify | ✅ |
| 로그아웃 | POST /v1/auth/logout | ✅ |
| 비밀번호 재설정 요청 | POST /v1/auth/password-reset | ✅ |
| 비밀번호 변경 확정 | PATCH /v1/auth/password-confirm | ✅ |

### 4.6 실행 명령어

```bash
cd typespec/backend

# 개발 모드
npm run start:dev

# 프로덕션 빌드
npm run build
npm run start:prod

# Swagger 문서
open http://localhost:3000/api-docs

# Prisma Studio
npx prisma studio
```

### 4.7 작업 완료 기준

- [x] Prisma 스키마 정의 (6개 모델)
- [x] Auth 모듈 구현 (register, login, refresh, logout)
- [x] 비밀번호 해싱 (bcrypt)
- [x] Token Rotation 구현
- [x] Swagger 문서 자동 생성
- [x] 에러 처리 (ConflictException, UnauthorizedException)

---

## Phase 5: iOS 구현 (SwiftUI)

### 5.1 목적

Clean Architecture 기반으로 iOS 앱을 구현합니다.

### 5.2 디렉토리 구조

```
ios/LoginDemo/LoginDemo/
├── App/
│   ├── LoginDemoApp.swift      # 앱 진입점
│   └── DIContainer.swift       # 의존성 주입
│
├── Domain/
│   ├── Entities/
│   │   ├── User.swift
│   │   ├── AuthToken.swift
│   │   ├── AuthProvider.swift
│   │   └── OnboardingPage.swift
│   ├── Repositories/
│   │   ├── AuthRepositoryProtocol.swift
│   │   ├── UserRepositoryProtocol.swift
│   │   └── OnboardingRepositoryProtocol.swift
│   └── UseCases/
│       ├── Auth/
│       │   ├── AutoLoginUseCase.swift
│       │   ├── RefreshTokenUseCase.swift
│       │   └── LogoutUseCase.swift
│       └── Onboarding/
│           └── CheckOnboardingUseCase.swift
│
├── Data/
│   ├── Repositories/
│   │   ├── AuthRepository.swift
│   │   └── OnboardingRepository.swift
│   ├── DataSources/
│   │   ├── Local/
│   │   │   ├── KeychainDataSource.swift
│   │   │   └── UserDefaultsDataSource.swift
│   │   └── Remote/
│   │       ├── NetworkService.swift
│   │       ├── AuthRemoteDataSource.swift
│   │       └── AuthInterceptor.swift
│   ├── DTOs/
│   │   ├── Request/
│   │   │   ├── LoginRequestDTO.swift
│   │   │   └── RegisterRequestDTO.swift
│   │   └── Response/
│   │       ├── AuthResponseDTO.swift
│   │       └── UserDTO.swift
│   └── Mappers/
│       ├── UserMapper.swift
│       └── AuthTokenMapper.swift
│
├── Presentation/
│   ├── App/
│   │   ├── AppState.swift
│   │   ├── AppScreen.swift
│   │   └── RootView.swift
│   ├── Splash/
│   │   ├── SplashView.swift
│   │   └── SplashViewModel.swift
│   ├── Auth/
│   │   └── Login/
│   │       ├── LoginView.swift
│   │       └── LoginViewModel.swift
│   └── Main/
│       ├── MainView.swift
│       └── Tabs/
│           ├── ExploreTab/
│           ├── SearchTab/
│           ├── SavedTab/
│           ├── NotificationsTab/
│           └── ProfileTab/
│
├── Core/
│   ├── Components/
│   │   ├── PrimaryButton.swift
│   │   ├── SecureTextField.swift
│   │   └── LoadingOverlay.swift
│   ├── Extensions/
│   │   ├── String+Validation.swift
│   │   ├── View+Keyboard.swift
│   │   └── Color+Theme.swift
│   ├── Network/
│   │   ├── APIConstants.swift
│   │   ├── AuthRouter.swift
│   │   └── NetworkError.swift
│   └── Utilities/
│       └── KeychainHelper.swift
│
└── Resources/
    └── Assets.xcassets/
```

### 5.3 구현 순서

#### Step 1: Foundational (핵심 인프라)

```
T010-T054: Domain/Data Layer 기반 구조
- Entities (User, AuthToken, AuthProvider, OnboardingPage)
- Repository Protocols
- DTOs (Request/Response)
- Mappers
- Network Service (Alamofire)
- Keychain/UserDefaults DataSource
- Core Components (PrimaryButton, SecureTextField)
```

#### Step 2: Feature 001 - 인증 플로우

```
T055-T066: US1 - 스플래시 화면
- SplashView, SplashViewModel
- AutoLoginUseCase
- RootView 라우팅 로직

T067-T080: US3 - 이메일 로그인 (진행중)
- LoginView, LoginViewModel
- LoginUseCase

T081-T094: US5 - 회원가입 (대기)
- RegisterView, RegisterViewModel
- RegisterUseCase, CheckEmailUseCase
```

#### Step 3: Feature 002 - 메인 탭

```
T007-T044: 모든 탭 UI 구현 완료
- MainView (TabView)
- ExploreView (추천, 인기 장소)
- SearchView (검색, 카테고리 필터)
- SavedView (장소, 여행, 컬렉션)
- NotificationsView (알림 목록)
- ProfileView (프로필, 로그아웃)
```

### 5.4 구현 완료 현황

| 영역 | 구현 | Status |
|------|------|--------|
| Domain Layer | Entities, Protocols | ✅ |
| Data Layer | DTOs, Mappers, DataSources | ✅ |
| Presentation - Splash | SplashView/ViewModel | ✅ |
| Presentation - Main | 5개 탭 UI | ✅ |
| Network | Alamofire, AuthInterceptor | ✅ |
| Keychain | 토큰 저장/조회 | ✅ |
| 접근성 | accessibilityLabel | ✅ |
| 다크모드 | Semantic Colors | ✅ |

### 5.5 빌드 명령어

```bash
# Makefile 사용
make ios-build
make ios-test

# 또는 직접 실행
cd ios
xcodebuild -project LoginDemo.xcodeproj \
  -scheme LoginDemo \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  build
```

### 5.6 작업 완료 기준

- [x] Clean Architecture 구조 적용
- [x] Domain Layer (Entities, Protocols, UseCases)
- [x] Data Layer (Repositories, DataSources, DTOs)
- [x] Splash 화면 + 자동로그인 로직
- [x] 5개 탭 메인 화면 UI
- [x] Alamofire 네트워크 서비스
- [x] Keychain 토큰 저장
- [x] 접근성 (VoiceOver)
- [x] 다크모드 지원

---

## Phase 6: Android 구현 (Jetpack Compose)

### 6.1 목적

iOS와 동일한 Clean Architecture로 Android 앱을 구현합니다.

### 6.2 디렉토리 구조

```
android/app/src/main/java/com/dyjung/logindemo/
├── di/                         # Hilt 모듈
│   ├── RepositoryModule.kt
│   └── NetworkModule.kt
│
├── domain/
│   ├── model/
│   │   ├── User.kt
│   │   ├── AuthToken.kt
│   │   └── AuthProvider.kt
│   ├── repository/
│   │   ├── AuthRepository.kt
│   │   └── UserRepository.kt
│   └── usecase/
│       ├── LoginUseCase.kt
│       └── AutoLoginUseCase.kt
│
├── data/
│   ├── repository/
│   │   └── AuthRepositoryImpl.kt
│   ├── datasource/
│   │   ├── local/
│   │   │   └── SecureStorage.kt
│   │   └── remote/
│   │       ├── AuthApi.kt
│   │       └── AuthInterceptor.kt
│   └── dto/
│       ├── LoginRequest.kt
│       └── LoginResponse.kt
│
├── presentation/
│   ├── auth/
│   │   ├── LoginScreen.kt
│   │   └── LoginViewModel.kt
│   ├── onboarding/
│   ├── main/
│   │   ├── MainScreen.kt
│   │   └── tabs/
│   └── splash/
│
└── core/
    ├── components/
    └── theme/
```

### 6.3 주요 기술

| 기술 | 용도 |
|------|------|
| Jetpack Compose | 선언적 UI |
| Hilt | 의존성 주입 |
| Retrofit | REST API 통신 |
| OkHttp | HTTP 클라이언트 |
| Coroutines | 비동기 처리 |
| StateFlow | 상태 관리 |
| EncryptedSharedPreferences | 보안 저장소 |

### 6.4 구현 패턴

#### ViewModel 패턴

```kotlin
@HiltViewModel
class LoginViewModel @Inject constructor(
    private val loginUseCase: LoginUseCase
) : ViewModel() {

    private val _uiState = MutableStateFlow(LoginUiState())
    val uiState: StateFlow<LoginUiState> = _uiState.asStateFlow()

    fun login(email: String, password: String) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            try {
                val user = loginUseCase(email, password)
                _uiState.update { it.copy(isLoading = false, user = user) }
            } catch (e: Exception) {
                _uiState.update { it.copy(isLoading = false, error = e.message) }
            }
        }
    }
}
```

#### Compose Screen 패턴

```kotlin
@Composable
fun LoginScreen(
    viewModel: LoginViewModel = hiltViewModel(),
    onLoginSuccess: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsState()

    Column {
        TextField(
            value = uiState.email,
            onValueChange = { viewModel.updateEmail(it) }
        )

        PrimaryButton(
            text = "Login",
            onClick = { viewModel.login() },
            isLoading = uiState.isLoading
        )
    }
}
```

### 6.5 빌드 명령어

```bash
# Makefile 사용
make android-build
make android-test

# 또는 직접 실행
cd android
./gradlew assembleDebug
./gradlew installDebug
```

### 6.6 작업 완료 기준

- [x] Clean Architecture 구조 적용
- [x] Hilt 의존성 주입 설정
- [x] Domain Layer (Models, Repository Interface, UseCases)
- [x] Data Layer (RepositoryImpl, Retrofit API)
- [x] Presentation Layer (Compose Screens, ViewModels)
- [x] 보안 저장소 (EncryptedSharedPreferences)

---

## 7. 검증 및 테스트

### 7.1 Backend 테스트

```bash
cd typespec/backend

# 회원가입
curl -X POST http://localhost:3000/v1/auth/register \
  -H "Content-Type: application/json" \
  -H "X-App-Version: 1.0.0" \
  -H "X-Platform: iOS" \
  -d '{
    "provider": "EMAIL",
    "email": "test@example.com",
    "password": "password123",
    "nickname": "테스트"
  }'

# 로그인
curl -X POST http://localhost:3000/v1/auth/login \
  -H "Content-Type: application/json" \
  -H "X-App-Version: 1.0.0" \
  -H "X-Platform: iOS" \
  -d '{
    "provider": "EMAIL",
    "email": "test@example.com",
    "password": "password123"
  }'
```

### 7.2 iOS 테스트

```bash
make ios-test

# 또는
cd ios
xcodebuild test -scheme LoginDemo \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

### 7.3 Android 테스트

```bash
make android-test

# 또는
cd android
./gradlew test
```

---

## 8. 향후 작업

### 8.1 Feature 001 - 남은 작업

| Phase | 작업 | Priority |
|-------|------|----------|
| US3 | 이메일 로그인 완성 | P1 |
| US5 | 회원가입 | P1 |
| US2 | 온보딩 | P2 |
| US4 | 소셜 로그인 (카카오, 네이버, Apple) | P2 |
| US6 | 비밀번호 찾기 | P3 |

### 8.2 Feature 002 - 남은 작업

| 작업 | 설명 |
|------|------|
| Data Layer 연동 | 탐색, 검색, 저장됨 탭 API 연동 |
| ViewModels | 각 탭별 ViewModel 구현 |
| Unit Tests | ViewModel 단위 테스트 |

### 8.3 공통 향후 작업

| 작업 | 설명 |
|------|------|
| 테스트 커버리지 | Domain/Presentation 80% 이상 |
| 다국어 | 한국어/영어 Localizable.strings |
| CI/CD | GitHub Actions 빌드 자동화 |
| 푸시 알림 | FCM/APNs 연동 |

---

## 부록: 명령어 요약

### Makefile

```bash
make setup        # 환경 확인
make build        # 전체 빌드
make test         # 전체 테스트
make clean        # 전체 정리

make ios-build    # iOS 빌드
make ios-test     # iOS 테스트

make android-build # Android 빌드
make android-test  # Android 테스트
```

### speckit 명령어

```bash
/speckit.constitution  # 헌법 생성/수정
/speckit.specify       # Feature Spec 생성
/speckit.clarify       # 명세 명확화
/speckit.plan          # 구현 계획
/speckit.tasks         # 작업 목록 생성
/speckit.analyze       # 일관성 분석
/speckit.implement     # 구현 실행
```

### TypeSpec

```bash
cd typespec
npx tsp compile .      # OpenAPI 생성
```

### Backend

```bash
cd typespec/backend
npm run start:dev      # 개발 서버
npx prisma studio      # DB GUI
npx prisma db push     # 스키마 적용
```

---

*Last Updated: 2026-01-14*
