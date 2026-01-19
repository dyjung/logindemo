# Claude Code + Speckit 개발 워크플로우 매뉴얼

이 매뉴얼은 Claude Code와 Speckit을 활용한 **iOS, Android, Backend** 크로스 플랫폼 개발 프로세스를 설명합니다.

---

## 목차

1. [전체 개발 흐름 요약](#1-전체-개발-흐름-요약)
2. [Phase 1: 프로젝트 초기 설정](#2-phase-1-프로젝트-초기-설정)
3. [Phase 2: 기능 명세 작성 (/specify)](#3-phase-2-기능-명세-작성-specify)
4. [Phase 3: 명세 검토 및 보완 (/clarify)](#4-phase-3-명세-검토-및-보완-clarify)
5. [Phase 4: 구현 계획 수립 (/plan)](#5-phase-4-구현-계획-수립-plan)
6. [Phase 5: 태스크 분해 (/tasks)](#6-phase-5-태스크-분해-tasks)
7. [Phase 6: 구현 (/implement)](#7-phase-6-구현-implement)
8. [Phase 7: TypeSpec 기반 API 현행화](#8-phase-7-typespec-기반-api-현행화)
9. [프로젝트 구조](#9-프로젝트-구조)
10. [플랫폼별 구현 가이드](#10-플랫폼별-구현-가이드)
11. [브랜치 전략](#11-브랜치-전략)
12. [명령어 참조](#12-명령어-참조)

---

## 1. 전체 개발 흐름 요약

```
┌─────────────────────────────────────────────────────────────────┐
│                    Claude Code + Speckit 워크플로우               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Initial Setup                                               │
│     └── 프로젝트 생성, CLAUDE.md 설정, 기본 구조 생성              │
│                                                                 │
│  2. /specify (기능 명세)                                         │
│     └── 자연어로 기능 설명 → spec.md 생성                         │
│                                                                 │
│  3. /clarify (명세 검토)                                         │
│     └── 불명확한 부분 질문 → spec.md 보완                         │
│                                                                 │
│  4. /plan (구현 계획)                                            │
│     └── 아키텍처 결정 → plan.md, data-model.md, contracts/ 생성   │
│                                                                 │
│  5. /tasks (태스크 분해)                                         │
│     └── 구현 단위 분해 → tasks.md 생성                            │
│                                                                 │
│  6. /implement (구현)                                            │
│     └── tasks.md 기반 코드 구현                                   │
│                                                                 │
│  7. API 현행화 (필요시)                                           │
│     └── TypeSpec 기반 Data Layer 동기화                          │
│                                                                 │
│  [반복] 다음 기능으로 이동                                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Phase 1: 프로젝트 초기 설정

### 2.1 프로젝트 생성

```bash
# 새 프로젝트 디렉토리 생성
mkdir MyProject && cd MyProject

# Git 초기화
git init

# 기본 구조 생성
mkdir -p ios android shared specs docs
```

### 2.2 CLAUDE.md 생성

프로젝트 루트에 `CLAUDE.md` 파일을 생성하여 Claude Code에게 프로젝트 컨텍스트를 제공합니다.

```markdown
# CLAUDE.md

## Project Structure
- ios/: iOS 프로젝트 (SwiftUI)
- android/: Android 프로젝트 (Jetpack Compose)
- shared/: 공유 리소스
- specs/: 기능 명세

## Architecture
Clean Architecture + Dependency Inversion

## Build Commands
make ios-build, make android-build

## Active Technologies
Swift 5.9+, SwiftUI, Alamofire
```

### 2.3 Makefile 생성

```makefile
# Makefile
ios-build:
	cd ios && xcodebuild -project MyApp.xcodeproj -scheme MyApp build

ios-test:
	cd ios && xcodebuild test -project MyApp.xcodeproj -scheme MyApp
```

### 2.4 Initial Commit

```bash
git add .
git commit -m "Initial Commit"
```

---

## 3. Phase 2: 기능 명세 작성 (/specify)

### 3.1 명령어 실행

Claude Code에서 `/specify` 명령어를 실행합니다.

```
/specify
```

### 3.2 기능 설명 입력

자연어로 구현하고자 하는 기능을 설명합니다.

```
SwiftUI 앱의 Splash, Onboarding, 로그인/회원가입 화면 구현.
이메일/비밀번호 로그인과 소셜 로그인(카카오, 네이버, Apple) 지원.
자동로그인 기능 포함.
```

### 3.3 생성되는 산출물

```
specs/001-auth-onboarding-flow/
├── spec.md              # 기능 명세 (User Stories, Requirements)
├── checklists/
│   └── requirements.md  # 요구사항 체크리스트
└── quickstart.md        # 빠른 시작 가이드
```

### 3.4 spec.md 구조

```markdown
# Feature Specification: [기능명]

**Feature Branch**: `001-feature-name`
**Created**: YYYY-MM-DD
**Status**: Draft

## User Scenarios & Testing
### User Story 1 - [스토리명] (Priority: P1)
- **Given** 조건, **When** 행동, **Then** 결과

## Requirements
### Functional Requirements
- **FR-001**: 요구사항 설명

## Success Criteria
- **SC-001**: 측정 가능한 성공 기준
```

---

## 4. Phase 3: 명세 검토 및 보완 (/clarify)

### 4.1 명령어 실행

```
/clarify
```

### 4.2 프로세스

Claude가 spec.md를 분석하여 불명확하거나 누락된 부분을 질문합니다.

**예시 질문들:**
- "비밀번호 복잡성 요구사항은 무엇인가요?"
- "세션 타임아웃 정책은 어떻게 되나요?"
- "소셜 로그인 실패 시 폴백 전략은?"

### 4.3 응답 후 spec.md 업데이트

답변 내용이 spec.md에 반영되어 명세가 더욱 구체화됩니다.

---

## 5. Phase 4: 구현 계획 수립 (/plan)

### 5.1 명령어 실행

```
/plan
```

### 5.2 생성되는 산출물

```
specs/001-auth-onboarding-flow/
├── plan.md              # 구현 계획 (아키텍처, 레이어 설계)
├── data-model.md        # 데이터 모델 정의
├── research.md          # 기술 리서치
└── contracts/
    └── auth-api.yaml    # API 명세 (OpenAPI)
```

### 5.3 plan.md 구조

```markdown
# Implementation Plan: [기능명]

## Architecture Overview
- Clean Architecture 레이어 구조

## Layer Design
### Domain Layer
- Entities, UseCases, Repository Protocols

### Data Layer
- DTOs, DataSources, Repository Implementations

### Presentation Layer
- ViewModels, Views

## API Design
- 엔드포인트 정의

## Security Considerations
- 토큰 저장, 암호화 등
```

---

## 6. Phase 5: 태스크 분해 (/tasks)

### 6.1 명령어 실행

```
/tasks
```

### 6.2 생성되는 산출물

```
specs/001-auth-onboarding-flow/
└── tasks.md             # 구현 태스크 목록
```

### 6.3 tasks.md 구조

```markdown
# Tasks: [기능명]

## Format: `[ID] [P?] [Story] Description`
- **[P]**: 병렬 실행 가능
- **[Story]**: 해당 User Story

## Phase 1: Setup
- [ ] T001 Create folder structure
- [ ] T002 [P] Add dependencies

## Phase 2: Foundational
- [ ] T010 [P] Create User entity
- [ ] T011 [P] Create AuthToken entity

## Phase 3: User Story 1 (Priority: P1)
### Tests
- [ ] T055 [P] [US1] Create UseCaseTests
### Implementation
- [ ] T057 [US1] Create UseCase

## Dependencies
| Story | 선행 의존성 |
|-------|-----------|
| US1   | Foundational |
```

### 6.4 태스크 특징

- **[P] 마킹**: 다른 파일/의존성 없음 → 병렬 실행 가능
- **[US?] 마킹**: User Story 매핑으로 추적성 확보
- **Phase 구분**: Setup → Foundational → User Stories → Polish
- **체크박스**: 진행 상황 추적 가능

---

## 7. Phase 6: 구현 (/implement)

### 7.1 명령어 실행

```
/implement
```

### 7.2 프로세스

Claude가 tasks.md를 읽고 순차적으로 태스크를 구현합니다.

1. 체크되지 않은 태스크 확인
2. 의존성 검증 (선행 태스크 완료 여부)
3. 코드 구현
4. 태스크 완료 체크 `[x]`
5. 다음 태스크로 이동

### 7.3 플랫폼별 구현 순서

#### iOS 구현 순서
```
Phase 1: Setup
  ├── T001 폴더 구조 생성
  └── T002-T007 의존성 및 설정 (병렬)

Phase 2: Foundational
  ├── T010-T016 Entities & Protocols (병렬)
  ├── T017-T026 DTOs & Mappers (병렬)
  └── T036-T039 Network Infrastructure

Phase 3+: User Stories
  ├── US1: Splash
  ├── US3: Login
  └── US5: Register
```

#### Android 구현 순서
```
Phase 1: Setup
  ├── T001 프로젝트 구조 생성
  └── T002-T007 Gradle 의존성 설정 (병렬)

Phase 2: Foundational
  ├── T010-T016 Domain Models & Repository Interfaces (병렬)
  ├── T017-T026 DTOs & Mappers (병렬)
  ├── T027-T030 Hilt Modules (병렬)
  └── T036-T039 Retrofit Setup

Phase 3+: User Stories
  ├── US1: Splash (ViewModel, Screen)
  ├── US3: Login (ViewModel, Screen)
  └── US5: Register (ViewModel, Screen)
```

#### Backend 구현 순서
```
Phase 1: Setup
  ├── T001 프로젝트 초기화 (NestJS/Spring Boot)
  ├── T002 Database 설정 (Prisma/JPA)
  └── T003-T005 환경 설정 (병렬)

Phase 2: Foundational
  ├── T010-T016 Entity 정의 (병렬)
  ├── T017-T020 Repository 구현 (병렬)
  ├── T021-T025 공통 모듈 (Guards, Interceptors, Filters)
  └── T026-T030 JWT/인증 인프라

Phase 3+: API Endpoints (User Stories)
  ├── US1: Init API (GET /v1/init)
  ├── US3: Login API (POST /v1/auth/login)
  ├── US4: Register API (POST /v1/auth/register)
  ├── US5: Token Refresh API (POST /v1/auth/refresh)
  └── US6: Logout API (POST /v1/auth/logout)
```

### 7.4 Feature Branch 생성

각 기능 구현 전 브랜치를 생성합니다.

```bash
git checkout -b 001-auth-onboarding-flow
```

### 7.5 플랫폼별 구현 요청

```bash
# iOS만 구현
"iOS 코드만 구현해줘"

# Android만 구현
"Android 코드만 구현해줘"

# Backend만 구현
"Backend API만 구현해줘"

# 전체 플랫폼 구현
"모든 플랫폼 구현해줘"
```

---

## 8. Phase 7: TypeSpec 기반 API 현행화

### 8.1 TypeSpec 파일 구조

```
typespec/
└── main.tsp             # API 명세 (TypeSpec 형식)
```

### 8.2 현행화 요청

TypeSpec 변경 시 Claude에게 현행화를 요청합니다.

```
iOS 코드의 Data Layer를 main.tsp 기준으로 현행화하라
```

### 8.3 영향받는 파일들

| 영역 | 파일 경로 |
|------|----------|
| Domain Entities | `Domain/Entities/*.swift` |
| Request DTOs | `Data/DTOs/Request/*.swift` |
| Response DTOs | `Data/DTOs/Response/*.swift` |
| API Router | `Core/Network/AuthRouter.swift` |
| DataSource | `Data/DataSources/Remote/*.swift` |
| Mappers | `Data/Mappers/*.swift` |

### 8.4 현행화 체크리스트

- [ ] Enum 추가/수정 (UserStatus, Platform 등)
- [ ] Entity 필드 업데이트
- [ ] Request DTO 필드 매핑
- [ ] Response DTO 필드 매핑
- [ ] API HTTP Method/Path 변경
- [ ] Mapper 로직 업데이트
- [ ] 빌드 검증

---

## 9. 프로젝트 구조

### 9.1 전체 구조

```
MyProject/
├── CLAUDE.md                    # Claude Code 가이드
├── Makefile                     # 빌드 명령어
├── ios/                         # iOS 프로젝트
│   └── MyApp/
│       ├── App/                 # 앱 진입점, DI Container
│       ├── Domain/              # 비즈니스 로직
│       │   ├── Entities/
│       │   ├── Repositories/    # Protocols
│       │   └── UseCases/
│       ├── Data/                # 데이터 레이어
│       │   ├── DTOs/
│       │   ├── DataSources/
│       │   ├── Repositories/    # Implementations
│       │   └── Mappers/
│       ├── Presentation/        # UI 레이어
│       │   ├── Auth/
│       │   ├── Main/
│       │   └── Onboarding/
│       └── Core/                # 공통 유틸리티
│           ├── Network/
│           ├── Extensions/
│           └── Components/
├── specs/                       # 기능 명세
│   ├── 001-auth-onboarding/
│   └── 002-main-navigation/
├── typespec/                    # API 명세
│   └── main.tsp
└── docs/                        # 문서
```

### 9.2 specs/ 디렉토리 구조

```
specs/
└── 001-feature-name/
    ├── spec.md                  # 기능 명세
    ├── plan.md                  # 구현 계획
    ├── tasks.md                 # 태스크 목록
    ├── research.md              # 기술 리서치
    ├── data-model.md            # 데이터 모델
    ├── quickstart.md            # 빠른 시작
    ├── checklists/
    │   └── requirements.md      # 요구사항 체크리스트
    └── contracts/
        └── api.yaml             # API 명세
```

---

## 10. 플랫폼별 구현 가이드

### 10.1 iOS (Swift + SwiftUI)

#### 기술 스택
| 영역 | 기술 |
|------|------|
| UI Framework | SwiftUI |
| Architecture | Clean Architecture + MVVM |
| DI | Manual (DIContainer) |
| Networking | Alamofire |
| Async | Swift Concurrency (async/await) |
| Secure Storage | Keychain |
| Local Storage | UserDefaults |

#### 레이어 구조
```
ios/LoginDemo/
├── App/
│   ├── LoginDemoApp.swift       # @main 진입점
│   ├── DIContainer.swift        # 의존성 주입 컨테이너
│   └── AppState.swift           # 전역 앱 상태
├── Domain/
│   ├── Entities/                # User, AuthToken 등
│   ├── Repositories/            # Protocol 정의
│   └── UseCases/                # 비즈니스 로직
├── Data/
│   ├── DTOs/                    # Request/Response DTO
│   ├── DataSources/             # Local/Remote
│   ├── Repositories/            # Protocol 구현체
│   └── Mappers/                 # DTO ↔ Entity 변환
├── Presentation/
│   ├── Auth/                    # 로그인, 회원가입
│   ├── Onboarding/              # 온보딩
│   └── Main/                    # 메인 탭
└── Core/
    ├── Network/                 # Router, Interceptor
    ├── Extensions/              # 확장 함수
    └── Components/              # 공통 UI
```

#### ViewModel 패턴
```swift
@Observable
@MainActor
final class LoginViewModel {
    private(set) var isLoading = false
    private(set) var error: Error?

    private let loginUseCase: LoginUseCase

    func login(email: String, password: String) async {
        isLoading = true
        defer { isLoading = false }

        let result = await loginUseCase.execute(email: email, password: password)
        // Handle result...
    }
}
```

#### 빌드 명령어
```bash
make ios-build          # Debug 빌드
make ios-test           # 테스트 실행
make ios-release        # Release 빌드
```

---

### 10.2 Android (Kotlin + Jetpack Compose)

#### 기술 스택
| 영역 | 기술 |
|------|------|
| UI Framework | Jetpack Compose |
| Architecture | Clean Architecture + MVVM |
| DI | Hilt |
| Networking | Retrofit + OkHttp |
| Async | Coroutines + Flow |
| Secure Storage | EncryptedSharedPreferences |
| Local Storage | SharedPreferences / DataStore |

#### 레이어 구조
```
android/app/src/main/java/com/dyjung/logindemo/
├── di/                          # Hilt 모듈
│   ├── NetworkModule.kt
│   ├── RepositoryModule.kt
│   └── UseCaseModule.kt
├── domain/
│   ├── model/                   # User, AuthToken 등
│   ├── repository/              # Interface 정의
│   └── usecase/                 # 비즈니스 로직
├── data/
│   ├── dto/                     # Request/Response DTO
│   ├── datasource/              # Local/Remote
│   ├── repository/              # Interface 구현체
│   └── mapper/                  # DTO ↔ Model 변환
├── presentation/
│   ├── auth/                    # 로그인, 회원가입
│   ├── onboarding/              # 온보딩
│   └── main/                    # 메인 탭
└── core/
    ├── network/                 # API 인터페이스, Interceptor
    ├── extensions/              # 확장 함수
    └── components/              # 공통 Composable
```

#### Hilt 모듈 예시
```kotlin
@Module
@InstallIn(SingletonComponent::class)
object RepositoryModule {
    @Provides
    @Singleton
    fun provideAuthRepository(
        remoteDataSource: AuthRemoteDataSource,
        localDataSource: AuthLocalDataSource
    ): AuthRepository = AuthRepositoryImpl(remoteDataSource, localDataSource)
}
```

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

            loginUseCase(email, password)
                .onSuccess { user ->
                    _uiState.update { it.copy(isLoading = false, user = user) }
                }
                .onFailure { error ->
                    _uiState.update { it.copy(isLoading = false, error = error) }
                }
        }
    }
}
```

#### Compose UI 예시
```kotlin
@Composable
fun LoginScreen(
    viewModel: LoginViewModel = hiltViewModel(),
    onLoginSuccess: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    Column(modifier = Modifier.padding(16.dp)) {
        TextField(
            value = email,
            onValueChange = { email = it },
            label = { Text("이메일") }
        )
        // ...
        Button(
            onClick = { viewModel.login(email, password) },
            enabled = !uiState.isLoading
        ) {
            Text("로그인")
        }
    }
}
```

#### 빌드 명령어
```bash
make android-build      # Debug APK 빌드
make android-test       # 테스트 실행
make android-release    # Release APK 빌드
```

---

### 10.3 Backend (TypeSpec + NestJS/Spring Boot)

#### TypeSpec 기반 API 정의

TypeSpec은 **API 명세의 Single Source of Truth**로 사용됩니다.

```
typespec/
├── main.tsp            # 메인 API 명세
├── models/             # 공통 모델 정의
│   ├── user.tsp
│   └── auth.tsp
└── tspconfig.yaml      # TypeSpec 설정
```

#### TypeSpec 예시 (main.tsp)
```typespec
import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi3";

using TypeSpec.Http;
using TypeSpec.Rest;

@service({
  title: "LoginDemo API"
})
namespace LoginDemoAPI;

// 모델 정의
model User {
  id: string;
  email: string;
  nickname: string;
  status: UserStatus;
  provider?: AuthenticationMethod;
  createdAt: utcDateTime;
  lastLogin?: utcDateTime;
  updatedAt?: utcDateTime;
}

enum UserStatus {
  ACTIVE,
  SLEEP,
  SUSPENDED,
  DELETED
}

// API 엔드포인트
@route("/v1/auth")
namespace Auth {
  @post
  @route("/login")
  op login(@body request: LoginRequest): AuthResponse | ErrorResponse;

  @post
  @route("/register")
  op register(@body request: RegisterRequest): AuthResponse | ErrorResponse;

  @post
  @route("/refresh")
  op refresh(@body request: RefreshTokenRequest): TokenRefreshResponse | ErrorResponse;
}
```

#### NestJS 구현 예시

```
backend/
├── src/
│   ├── app.module.ts
│   ├── auth/
│   │   ├── auth.module.ts
│   │   ├── auth.controller.ts
│   │   ├── auth.service.ts
│   │   └── dto/
│   │       ├── login.dto.ts
│   │       └── register.dto.ts
│   ├── user/
│   │   ├── user.module.ts
│   │   ├── user.service.ts
│   │   └── entities/
│   │       └── user.entity.ts
│   └── common/
│       ├── guards/
│       ├── interceptors/
│       └── filters/
└── prisma/
    └── schema.prisma
```

```typescript
// auth.controller.ts
@Controller('v1/auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('login')
  async login(@Body() loginDto: LoginDto): Promise<AuthResponse> {
    return this.authService.login(loginDto);
  }

  @Post('register')
  async register(@Body() registerDto: RegisterDto): Promise<AuthResponse> {
    return this.authService.register(registerDto);
  }
}
```

#### Spring Boot 구현 예시

```
backend/
├── src/main/kotlin/com/dyjung/logindemo/
│   ├── LoginDemoApplication.kt
│   ├── auth/
│   │   ├── AuthController.kt
│   │   ├── AuthService.kt
│   │   └── dto/
│   │       ├── LoginRequest.kt
│   │       └── AuthResponse.kt
│   ├── user/
│   │   ├── UserService.kt
│   │   └── entity/
│   │       └── User.kt
│   └── config/
│       ├── SecurityConfig.kt
│       └── JwtConfig.kt
└── src/main/resources/
    └── application.yml
```

```kotlin
// AuthController.kt
@RestController
@RequestMapping("/v1/auth")
class AuthController(
    private val authService: AuthService
) {
    @PostMapping("/login")
    fun login(@RequestBody request: LoginRequest): ResponseEntity<AuthResponse> {
        return ResponseEntity.ok(authService.login(request))
    }

    @PostMapping("/register")
    fun register(@RequestBody request: RegisterRequest): ResponseEntity<AuthResponse> {
        return ResponseEntity.ok(authService.register(request))
    }
}
```

#### TypeSpec → 코드 생성

```bash
# OpenAPI 스펙 생성
npx tsp compile typespec/main.tsp --emit @typespec/openapi3

# 생성된 OpenAPI로 클라이언트 코드 생성 (선택사항)
npx openapi-generator generate -i openapi.yaml -g kotlin -o android/generated
npx openapi-generator generate -i openapi.yaml -g swift5 -o ios/generated
```

#### 백엔드 빌드 명령어
```bash
# NestJS
make backend-build      # 빌드
make backend-test       # 테스트
make backend-dev        # 개발 서버 실행

# Spring Boot
make backend-build      # ./gradlew build
make backend-test       # ./gradlew test
make backend-run        # ./gradlew bootRun
```

---

### 10.4 플랫폼 간 매핑 테이블

| 개념 | iOS (Swift) | Android (Kotlin) | Backend (TypeSpec) |
|------|-------------|------------------|-------------------|
| DI Container | DIContainer | Hilt Module | NestJS Module |
| ViewModel | @Observable | ViewModel + StateFlow | - |
| UI State | @State, @Binding | remember, mutableStateOf | - |
| Async | async/await | Coroutines, Flow | async/await |
| Network | Alamofire | Retrofit + OkHttp | Axios / Fetch |
| Secure Storage | Keychain | EncryptedSharedPrefs | JWT / Session |
| Local Storage | UserDefaults | SharedPreferences | Database |
| Model | struct/class | data class | model (TypeSpec) |
| Enum | enum | enum class | enum (TypeSpec) |

---

## 11. 브랜치 전략

### 11.1 브랜치 네이밍

```
{순번}-{기능명-케밥케이스}
```

**예시:**
- `001-auth-onboarding-flow`
- `002-main-tab-navigation`
- `003-place-detail-screen`

### 11.2 워크플로우

```
main
  │
  ├── 001-auth-onboarding-flow      # Feature 1
  │     ├── 구현 완료
  │     └── PR → main 머지
  │
  ├── 002-main-tab-navigation       # Feature 2
  │     ├── 구현 중
  │     └── ...
  │
  └── 003-place-detail-screen       # Feature 3 (대기)
```

### 11.3 브랜치 생성

```bash
# 새 기능 브랜치 생성
git checkout main
git checkout -b 002-main-tab-navigation
```

---

## 12. 명령어 참조

### 12.1 Speckit 명령어

| 명령어 | 설명 | 산출물 |
|--------|------|--------|
| `/specify` | 기능 명세 작성 | spec.md, checklists/, quickstart.md |
| `/clarify` | 명세 검토 및 질문 | spec.md 업데이트 |
| `/plan` | 구현 계획 수립 | plan.md, data-model.md, contracts/ |
| `/tasks` | 태스크 분해 | tasks.md |
| `/implement` | 태스크 구현 | 코드 파일들 |
| `/analyze` | 산출물 일관성 검증 | 분석 리포트 |

### 12.2 일반적인 Claude Code 사용

```bash
# 빌드 및 테스트
make ios-build
make ios-test

# 특정 파일 수정 요청
"LoginViewModel.swift에서 에러 핸들링 개선해줘"

# 버그 수정
"로그인 시 토큰 저장이 안 되는 버그 수정해줘"

# 리팩토링
"AuthRepository를 프로토콜 기반으로 리팩토링해줘"

# API 현행화
"main.tsp 기준으로 iOS Data Layer 현행화해줘"
```

### 12.3 Git 커밋 규칙

```bash
# Claude Code가 자동 생성하는 커밋 메시지 형식
git commit -m "$(cat <<'EOF'
[Feature] Add login functionality

- Implement LoginUseCase
- Create LoginViewModel with validation
- Add LoginView with form fields

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

---

## 부록: 실제 개발 사례

### A. 001-auth-onboarding-flow

1. **목표**: 스플래시, 온보딩, 로그인/회원가입 구현
2. **User Stories**: 6개 (스플래시, 온보딩, 이메일 로그인, 소셜 로그인, 회원가입, 비밀번호 찾기)
3. **Tasks**: 139개
4. **산출물**:
   - Domain: 4 Entities, 3 Repositories, 8 UseCases
   - Data: 10 DTOs, 5 DataSources, 3 Repositories
   - Presentation: 4 ViewModels, 10+ Views

### B. 002-main-tab-navigation

1. **목표**: TripAdvisor 스타일 탭 기반 메인 화면
2. **User Stories**: 6개 (탭 네비게이션, 탐색, 검색, 저장됨, 알림, 프로필)
3. **산출물**:
   - MainView with TabView
   - 5개 탭 화면 (Explore, Search, Saved, Notifications, Profile)

---

## 부록 B: 크로스 플랫폼 개발 흐름

### B.1 API-First 개발 프로세스

```
┌────────────────────────────────────────────────────────────────────┐
│                    API-First 개발 흐름                              │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  1. TypeSpec 작성 (API 명세)                                        │
│     └── typespec/main.tsp                                          │
│                                                                    │
│  2. OpenAPI 생성                                                    │
│     └── npx tsp compile → openapi.yaml                             │
│                                                                    │
│  3. 병렬 개발 시작                                                   │
│     ┌─────────────┬─────────────┬─────────────┐                    │
│     │   Backend   │     iOS     │   Android   │                    │
│     ├─────────────┼─────────────┼─────────────┤                    │
│     │ Controller  │    DTO      │    DTO      │                    │
│     │ Service     │   Router    │  API Svc    │                    │
│     │ Repository  │ DataSource  │ DataSource  │                    │
│     └─────────────┴─────────────┴─────────────┘                    │
│                                                                    │
│  4. 통합 테스트                                                      │
│     └── Backend ↔ iOS/Android 연동 검증                             │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

### B.2 TypeSpec 변경 시 각 플랫폼 현행화

```bash
# 1. TypeSpec 수정 후

# 2. iOS 현행화 요청
"main.tsp 기준으로 iOS Data Layer 현행화해줘"

# 3. Android 현행화 요청
"main.tsp 기준으로 Android Data Layer 현행화해줘"

# 4. Backend 현행화 요청
"main.tsp 기준으로 Backend Controller/DTO 현행화해줘"

# 5. 각 플랫폼 빌드 검증
make ios-build
make android-build
make backend-build
```

### B.3 공유 리소스 관리

```
shared/
├── assets/              # 공유 이미지/아이콘
│   ├── icons/
│   └── images/
├── localization/        # 다국어 문자열
│   ├── ko.json          # 한국어
│   └── en.json          # 영어
└── api-contracts/       # OpenAPI 스펙
    └── openapi.yaml
```

### B.4 플랫폼별 작업 배분 예시

| 기능 | iOS 담당 | Android 담당 | Backend 담당 |
|------|---------|-------------|-------------|
| 로그인 API | Router, DTO | API Service, DTO | Controller, Service |
| 로그인 UI | LoginView, ViewModel | LoginScreen, ViewModel | - |
| 토큰 저장 | Keychain | EncryptedSharedPrefs | JWT 발급 |
| 자동 로그인 | SplashViewModel | SplashViewModel | Token 검증 |

---

## 핵심 원칙

1. **명세 우선**: 코드 작성 전 spec.md로 요구사항 명확화
2. **계획 기반**: plan.md로 아키텍처 결정 후 구현
3. **태스크 단위**: tasks.md로 작은 단위 구현 및 추적
4. **점진적 구현**: MVP 먼저 (P1) → 확장 기능 (P2, P3)
5. **브랜치 격리**: 기능별 브랜치로 독립적 개발
6. **API 동기화**: TypeSpec으로 프론트엔드-백엔드 일관성 유지
7. **크로스 플랫폼**: iOS, Android, Backend 병렬 개발 지원

---

*이 매뉴얼은 LoginDemo 프로젝트 개발 경험을 기반으로 작성되었습니다.*
*Claude Code + Speckit 버전: 2026.01*
