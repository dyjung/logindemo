# Tasks: 인증 및 온보딩 플로우

**Input**: Design documents from `/specs/001-auth-onboarding-flow/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/auth-api.yaml

**Tests**: 테스트 태스크는 헌법(III. 테스트 주도 개발) 준수를 위해 포함됩니다.

**Organization**: 태스크는 User Story별로 그룹화되어 각 스토리를 독립적으로 구현하고 테스트할 수 있습니다.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: 병렬 실행 가능 (다른 파일, 의존성 없음)
- **[Story]**: 해당 태스크가 속한 User Story (예: US1, US2, US3)
- 설명에 정확한 파일 경로 포함

## Path Conventions

- **iOS App**: `LoginDemo/` 하위에 Clean Architecture 구조
- Domain Layer: `LoginDemo/Domain/`
- Data Layer: `LoginDemo/Data/`
- Presentation Layer: `LoginDemo/Presentation/`
- Core Utilities: `LoginDemo/Core/`
- Tests: `LoginDemoTests/`

---

## Phase 1: Setup (프로젝트 초기화)

**Purpose**: 프로젝트 구조 생성 및 의존성 설정

- [x] T001 Create Clean Architecture folder structure per plan.md in `LoginDemo/`
- [ ] T002 Add Alamofire dependency via SPM (5.8.0+) in `LoginDemo.xcodeproj`
- [ ] T003 [P] Add KakaoSDK dependency via SPM in `LoginDemo.xcodeproj`
- [ ] T004 [P] Download and integrate NaverThirdPartyLogin.xcframework manually
- [x] T005 [P] Configure Info.plist with URL Schemes (kakao, naver) and LSApplicationQueriesSchemes
- [ ] T006 [P] Add Sign in with Apple capability in project settings
- [ ] T007 [P] Add Keychain Sharing capability with group `$(AppIdentifierPrefix)com.dyjung.LoginDemo`
- [x] T008 Create `LoginDemo/App/DIContainer.swift` for dependency injection container structure
- [x] T009 Create color assets (PrimaryColor, BackgroundColor, TextPrimary) in `LoginDemo/Resources/Assets.xcassets/Colors/`

---

## Phase 2: Foundational (핵심 인프라)

**Purpose**: 모든 User Story 구현 전 완료해야 하는 핵심 인프라

**⚠️ CRITICAL**: 이 단계가 완료되어야 User Story 작업 시작 가능

### Domain Layer - Entities & Protocols

- [x] T010 [P] Create `User` entity in `LoginDemo/Domain/Entities/User.swift`
- [x] T011 [P] Create `AuthToken` entity in `LoginDemo/Domain/Entities/AuthToken.swift`
- [x] T012 [P] Create `OnboardingPage` entity in `LoginDemo/Domain/Entities/OnboardingPage.swift`
- [x] T013 [P] Create `AuthProvider` enum in `LoginDemo/Domain/Entities/AuthProvider.swift`
- [x] T014 [P] Create `AuthRepositoryProtocol` in `LoginDemo/Domain/Repositories/AuthRepositoryProtocol.swift`
- [x] T015 [P] Create `UserRepositoryProtocol` in `LoginDemo/Domain/Repositories/UserRepositoryProtocol.swift`
- [x] T016 [P] Create `OnboardingRepositoryProtocol` in `LoginDemo/Domain/Repositories/OnboardingRepositoryProtocol.swift`

### Data Layer - DTOs & Network Infrastructure

- [x] T017 [P] Create `LoginRequestDTO` in `LoginDemo/Data/DTOs/Request/LoginRequestDTO.swift`
- [x] T018 [P] Create `RegisterRequestDTO` in `LoginDemo/Data/DTOs/Request/RegisterRequestDTO.swift`
- [x] T019 [P] Create `SocialLoginRequestDTO` in `LoginDemo/Data/DTOs/Request/SocialLoginRequestDTO.swift`
- [x] T020 [P] Create `RefreshTokenRequestDTO` in `LoginDemo/Data/DTOs/Request/RefreshTokenRequestDTO.swift`
- [x] T021 [P] Create `AuthResponseDTO` in `LoginDemo/Data/DTOs/Response/AuthResponseDTO.swift`
- [x] T022 [P] Create `UserDTO` in `LoginDemo/Data/DTOs/Response/UserDTO.swift`
- [x] T023 [P] Create `ErrorResponseDTO` in `LoginDemo/Data/DTOs/Response/ErrorResponseDTO.swift`
- [x] T024 [P] Create `EmailCheckResponseDTO` in `LoginDemo/Data/DTOs/Response/EmailCheckResponseDTO.swift`
- [x] T025 [P] Create `UserMapper` in `LoginDemo/Data/Mappers/UserMapper.swift`
- [x] T026 [P] Create `AuthTokenMapper` in `LoginDemo/Data/Mappers/AuthTokenMapper.swift`
- [x] T027 Create `APIConstants` with base URL in `LoginDemo/Core/Network/APIConstants.swift`
- [x] T028 Create `AuthRouter` (URLRequestConvertible) in `LoginDemo/Core/Network/AuthRouter.swift`
- [x] T029 Create `NetworkError` enum in `LoginDemo/Core/Network/NetworkError.swift`
- [x] T030 Create `AuthError` enum with LocalizedError in `LoginDemo/Core/Network/AuthError.swift`

### Data Layer - Local Storage

- [x] T031 Create `KeychainHelper` in `LoginDemo/Core/Utilities/KeychainHelper.swift`
- [x] T032 Create `KeychainDataSourceProtocol` in `LoginDemo/Data/DataSources/Local/KeychainDataSourceProtocol.swift`
- [x] T033 Create `KeychainDataSource` implementation in `LoginDemo/Data/DataSources/Local/KeychainDataSource.swift`
- [x] T034 Create `UserDefaultsDataSourceProtocol` in `LoginDemo/Data/DataSources/Local/UserDefaultsDataSourceProtocol.swift`
- [x] T035 Create `UserDefaultsDataSource` implementation in `LoginDemo/Data/DataSources/Local/UserDefaultsDataSource.swift`

### Data Layer - Network Service with Alamofire

- [x] T036 Create `AuthInterceptor` (RequestInterceptor) in `LoginDemo/Data/DataSources/Remote/AuthInterceptor.swift`
- [x] T037 Create `NetworkServiceProtocol` in `LoginDemo/Data/DataSources/Remote/NetworkServiceProtocol.swift`
- [x] T038 Create `NetworkService` with Alamofire Session in `LoginDemo/Data/DataSources/Remote/NetworkService.swift`
- [x] T039 Create `AuthRemoteDataSource` in `LoginDemo/Data/DataSources/Remote/AuthRemoteDataSource.swift`

### Core Components

- [x] T040 [P] Create `String+Validation` extension in `LoginDemo/Core/Extensions/String+Validation.swift`
- [x] T041 [P] Create `View+Keyboard` extension in `LoginDemo/Core/Extensions/View+Keyboard.swift`
- [x] T042 [P] Create `Color+Theme` extension in `LoginDemo/Core/Extensions/Color+Theme.swift`
- [x] T043 [P] Create `PrimaryButton` component in `LoginDemo/Core/Components/PrimaryButton.swift`
- [x] T044 [P] Create `SecureTextField` component in `LoginDemo/Core/Components/SecureTextField.swift`
- [x] T045 [P] Create `LoadingOverlay` component in `LoginDemo/Core/Components/LoadingOverlay.swift`
- [x] T046 [P] Create `ErrorAlert` modifier in `LoginDemo/Core/Components/ErrorAlert.swift`

### Presentation Layer - App State

- [x] T047 Create `AppState` (@Observable) in `LoginDemo/Presentation/App/AppState.swift`
- [x] T048 Create `AppScreen` enum in `LoginDemo/Presentation/App/AppScreen.swift`
- [x] T049 Update `LoginDemoApp.swift` with AppState and RootView in `LoginDemo/App/LoginDemoApp.swift`
- [x] T050 Create `RootView` with conditional rendering in `LoginDemo/Presentation/App/RootView.swift`

### Mocks for Testing

- [x] T051 [P] Create `MockAuthRepository` in `LoginDemoTests/Mocks/MockAuthRepository.swift`
- [x] T052 [P] Create `MockKeychainDataSource` in `LoginDemoTests/Mocks/MockKeychainDataSource.swift`
- [x] T053 [P] Create `MockUserDefaultsDataSource` in `LoginDemoTests/Mocks/MockUserDefaultsDataSource.swift`
- [x] T054 [P] Create `MockNetworkService` in `LoginDemoTests/Mocks/MockNetworkService.swift`

**Checkpoint**: Foundation ready - User Story 구현 시작 가능

---

## Phase 3: User Story 1 - 스플래시 화면 및 앱 초기화 (Priority: P1) 🎯 MVP

**Goal**: 앱 실행 시 스플래시 화면 표시 후 앱 상태에 따라 적절한 화면으로 이동

**Independent Test**: 앱을 다양한 상태(최초 실행, 자동로그인 활성화, 토큰 만료 등)에서 실행하여 올바른 화면으로 이동하는지 검증

### Tests for User Story 1

- [ ] T055 [P] [US1] Create `AutoLoginUseCaseTests` in `LoginDemoTests/Domain/UseCases/AutoLoginUseCaseTests.swift`
- [ ] T056 [P] [US1] Create `SplashViewModelTests` in `LoginDemoTests/Presentation/ViewModels/SplashViewModelTests.swift`

### Implementation for User Story 1

- [x] T057 [US1] Create `CheckOnboardingUseCase` in `LoginDemo/Domain/UseCases/Onboarding/CheckOnboardingUseCase.swift`
- [x] T058 [US1] Create `AutoLoginUseCase` in `LoginDemo/Domain/UseCases/Auth/AutoLoginUseCase.swift`
- [x] T059 [US1] Create `RefreshTokenUseCase` in `LoginDemo/Domain/UseCases/Auth/RefreshTokenUseCase.swift`
- [x] T060 [US1] Create `OnboardingRepository` implementation in `LoginDemo/Data/Repositories/OnboardingRepository.swift`
- [x] T061 [US1] Create `AuthRepository` implementation (partial - token refresh) in `LoginDemo/Data/Repositories/AuthRepository.swift`
- [x] T062 [US1] Create `SplashViewModel` (@Observable) in `LoginDemo/Presentation/Splash/SplashViewModel.swift`
- [x] T063 [US1] Create `SplashView` with logo and branding in `LoginDemo/Presentation/Splash/SplashView.swift`
- [x] T064 [US1] Add splash screen assets (logo image) in `LoginDemo/Resources/Assets.xcassets/Images/`
- [x] T065 [US1] Wire SplashView in RootView and configure DIContainer for US1 in `LoginDemo/App/DIContainer.swift`
- [x] T066 [US1] Add accessibility labels to SplashView components

**Checkpoint**: User Story 1 완료 - 스플래시 화면에서 앱 상태에 따른 라우팅 동작

---

## Phase 4: User Story 3 - 이메일/비밀번호 로그인 (Priority: P1) 🎯 MVP

**Goal**: 기존 회원이 이메일과 비밀번호로 로그인하고 자동로그인 옵션 선택 가능

**Independent Test**: 유효한/무효한 자격증명으로 로그인을 시도하여 성공/실패 시나리오 검증

### Tests for User Story 3

- [ ] T067 [P] [US3] Create `LoginUseCaseTests` in `LoginDemoTests/Domain/UseCases/LoginUseCaseTests.swift`
- [ ] T068 [P] [US3] Create `LoginViewModelTests` in `LoginDemoTests/Presentation/ViewModels/LoginViewModelTests.swift`

### Implementation for User Story 3

- [ ] T069 [US3] Create `LoginUseCase` in `LoginDemo/Domain/UseCases/Auth/LoginUseCase.swift`
- [ ] T070 [US3] Extend `AuthRepository` with login method in `LoginDemo/Data/Repositories/AuthRepository.swift`
- [ ] T071 [US3] Create `LoginViewModel` (@Observable) in `LoginDemo/Presentation/Auth/Login/LoginViewModel.swift`
- [ ] T072 [US3] Create `LoginFormView` with email/password fields in `LoginDemo/Presentation/Auth/Login/LoginFormView.swift`
- [ ] T073 [US3] Create `LoginView` with NavigationStack in `LoginDemo/Presentation/Auth/Login/LoginView.swift`
- [ ] T074 [US3] Create placeholder `MainView` for post-login in `LoginDemo/Presentation/Main/MainView.swift`
- [ ] T075 [US3] Wire LoginView in RootView and update DIContainer for US3 in `LoginDemo/App/DIContainer.swift`
- [ ] T076 [US3] Implement real-time email validation with error feedback
- [ ] T077 [US3] Implement password visibility toggle in SecureTextField
- [ ] T078 [US3] Add auto-login toggle switch to LoginFormView
- [ ] T079 [US3] Add accessibility labels and hints to all login form elements
- [ ] T080 [US3] Implement keyboard dismissal on tap outside

**Checkpoint**: User Story 1 + 3 완료 - 스플래시 및 이메일 로그인 동작

---

## Phase 5: User Story 5 - 회원가입 (Priority: P1) 🎯 MVP

**Goal**: 새로운 사용자가 이메일, 비밀번호, 이름을 입력하고 약관 동의하여 계정 생성

**Independent Test**: 회원가입 폼을 작성하고 제출하여 계정 생성 및 자동 로그인 검증

### Tests for User Story 5

- [ ] T081 [P] [US5] Create `RegisterUseCaseTests` in `LoginDemoTests/Domain/UseCases/RegisterUseCaseTests.swift`
- [ ] T082 [P] [US5] Create `RegisterViewModelTests` in `LoginDemoTests/Presentation/ViewModels/RegisterViewModelTests.swift`

### Implementation for User Story 5

- [ ] T083 [US5] Create `CheckEmailUseCase` for duplicate check in `LoginDemo/Domain/UseCases/Auth/CheckEmailUseCase.swift`
- [ ] T084 [US5] Create `RegisterUseCase` in `LoginDemo/Domain/UseCases/Auth/RegisterUseCase.swift`
- [ ] T085 [US5] Extend `AuthRepository` with register and checkEmail methods in `LoginDemo/Data/Repositories/AuthRepository.swift`
- [ ] T086 [US5] Create `RegisterViewModel` (@Observable) in `LoginDemo/Presentation/Auth/Register/RegisterViewModel.swift`
- [ ] T087 [US5] Create `RegisterView` with all form fields in `LoginDemo/Presentation/Auth/Register/RegisterView.swift`
- [ ] T088 [US5] Create `TermsCheckboxView` for terms agreement in `LoginDemo/Core/Components/TermsCheckboxView.swift`
- [ ] T089 [US5] Add navigation from LoginView to RegisterView
- [ ] T090 [US5] Implement debounced email duplicate check (0.5s)
- [ ] T091 [US5] Implement password confirmation validation
- [ ] T092 [US5] Implement terms/privacy agreement checkbox logic
- [ ] T093 [US5] Add accessibility labels to all register form elements
- [ ] T094 [US5] Wire RegisterView and update DIContainer for US5 in `LoginDemo/App/DIContainer.swift`

**Checkpoint**: MVP 완료 - 스플래시, 로그인, 회원가입 모두 동작

---

## Phase 6: User Story 2 - 온보딩 경험 (Priority: P2)

**Goal**: 최초 앱 사용자에게 앱의 주요 기능과 가치를 슬라이드로 안내

**Independent Test**: 앱 최초 실행 시 온보딩 화면 표시, 스와이프 및 버튼 동작 검증

### Tests for User Story 2

- [ ] T095 [P] [US2] Create `OnboardingViewModelTests` in `LoginDemoTests/Presentation/ViewModels/OnboardingViewModelTests.swift`

### Implementation for User Story 2

- [ ] T096 [US2] Create `OnboardingViewModel` (@Observable) in `LoginDemo/Presentation/Onboarding/OnboardingViewModel.swift`
- [ ] T097 [US2] Create `OnboardingPageView` for single page in `LoginDemo/Presentation/Onboarding/OnboardingPageView.swift`
- [ ] T098 [US2] Create `OnboardingView` with TabView and PageTabViewStyle in `LoginDemo/Presentation/Onboarding/OnboardingView.swift`
- [ ] T099 [US2] Add onboarding images (3 pages) in `LoginDemo/Resources/Assets.xcassets/Images/`
- [ ] T100 [US2] Implement page indicator dots
- [ ] T101 [US2] Implement "건너뛰기" (Skip) button
- [ ] T102 [US2] Implement "시작하기" (Get Started) button on last page
- [ ] T103 [US2] Save onboarding completion state via UserDefaultsDataSource
- [ ] T104 [US2] Wire OnboardingView in RootView and update DIContainer for US2
- [ ] T105 [US2] Add accessibility labels to onboarding elements

**Checkpoint**: User Story 2 완료 - 최초 실행 시 온보딩 플로우 동작

---

## Phase 7: User Story 4 - 소셜 로그인 (Priority: P2)

**Goal**: 사용자가 카카오, 네이버, Apple 계정으로 빠르게 로그인

**Independent Test**: 각 소셜 로그인 버튼 탭 시 OAuth 플로우 시작 및 인증 후 앱 복귀 검증

### Tests for User Story 4

- [ ] T106 [P] [US4] Create `SocialLoginUseCaseTests` in `LoginDemoTests/Domain/UseCases/SocialLoginUseCaseTests.swift`

### Implementation for User Story 4

- [ ] T107 [US4] Create `SocialLoginUseCase` in `LoginDemo/Domain/UseCases/Auth/SocialLoginUseCase.swift`
- [ ] T108 [US4] Create `SocialAuthProvider` protocol in `LoginDemo/Data/DataSources/Remote/SocialAuthProvider.swift`
- [ ] T109 [US4] Create `KakaoAuthProvider` in `LoginDemo/Data/DataSources/Remote/KakaoAuthProvider.swift`
- [ ] T110 [US4] Create `NaverAuthProvider` in `LoginDemo/Data/DataSources/Remote/NaverAuthProvider.swift`
- [ ] T111 [US4] Create `AppleAuthProvider` in `LoginDemo/Data/DataSources/Remote/AppleAuthProvider.swift`
- [ ] T112 [US4] Extend `AuthRepository` with socialLogin method
- [ ] T113 [US4] Create `SocialLoginButton` component in `LoginDemo/Core/Components/SocialLoginButton.swift`
- [ ] T114 [US4] Add social login buttons to LoginView (Kakao yellow #FEE500, Naver green #03C75A, Apple black)
- [ ] T115 [US4] Handle URL callback in SceneDelegate/AppDelegate for social login
- [ ] T116 [US4] Extend `LoginViewModel` with social login methods
- [ ] T117 [US4] Add accessibility labels to social login buttons
- [ ] T118 [US4] Handle social login cancellation with user feedback

**Checkpoint**: User Story 4 완료 - 소셜 로그인 플로우 동작

---

## Phase 8: User Story 6 - 비밀번호 찾기 (Priority: P3)

**Goal**: 비밀번호를 잊어버린 사용자가 이메일로 비밀번호 재설정

**Independent Test**: 비밀번호 찾기 링크 탭 후 이메일 입력하여 재설정 안내 발송 검증

### Tests for User Story 6

- [ ] T119 [P] [US6] Create `ForgotPasswordViewModelTests` in `LoginDemoTests/Presentation/ViewModels/ForgotPasswordViewModelTests.swift`

### Implementation for User Story 6

- [ ] T120 [US6] Create `ForgotPasswordUseCase` in `LoginDemo/Domain/UseCases/Auth/ForgotPasswordUseCase.swift`
- [ ] T121 [US6] Extend `AuthRepository` with forgotPassword method
- [ ] T122 [US6] Create `ForgotPasswordViewModel` in `LoginDemo/Presentation/Auth/ForgotPassword/ForgotPasswordViewModel.swift`
- [ ] T123 [US6] Create `ForgotPasswordView` in `LoginDemo/Presentation/Auth/ForgotPassword/ForgotPasswordView.swift`
- [ ] T124 [US6] Add navigation from LoginView to ForgotPasswordView
- [ ] T125 [US6] Implement email validation and submission
- [ ] T126 [US6] Show success message (same for registered/unregistered emails for security)
- [ ] T127 [US6] Add accessibility labels to forgot password elements

**Checkpoint**: User Story 6 완료 - 비밀번호 찾기 플로우 동작

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: 전체 기능에 걸친 개선사항

- [ ] T128 [P] Create `LogoutUseCase` in `LoginDemo/Domain/UseCases/Auth/LogoutUseCase.swift`
- [ ] T129 [P] Add logout functionality to MainView
- [ ] T130 Implement dark mode support across all views
- [ ] T131 Add `Localizable.strings` for Korean localization in `LoginDemo/Resources/`
- [ ] T132 Implement keyboard scroll handling for all form views
- [ ] T133 Add loading indicators during API calls
- [ ] T134 Implement retry option for network errors
- [ ] T135 Add rate limit handling (429 response)
- [ ] T136 Review and ensure no sensitive data in logs (FR-035)
- [ ] T137 Complete DIContainer with all dependencies wired
- [ ] T138 Run quickstart.md validation - build and test
- [ ] T139 Final accessibility audit (VoiceOver navigation)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: 즉시 시작 가능
- **Foundational (Phase 2)**: Setup 완료 후 - 모든 User Story 차단
- **User Story 1, 3, 5 (P1)**: Foundational 완료 후 시작 가능 (MVP)
- **User Story 2, 4 (P2)**: Foundational 완료 후 시작 가능 (P1과 병렬 가능)
- **User Story 6 (P3)**: Foundational 완료 후 시작 가능
- **Polish (Phase 9)**: 모든 User Story 완료 후

### User Story Dependencies

| Story | 선행 의존성 | 다른 Story 의존성 |
|-------|------------|------------------|
| US1 (스플래시) | Foundational | 없음 |
| US3 (이메일 로그인) | Foundational | 없음 |
| US5 (회원가입) | Foundational | 없음 (LoginView 네비게이션만) |
| US2 (온보딩) | Foundational | 없음 |
| US4 (소셜 로그인) | Foundational | 없음 (LoginView에 버튼 추가) |
| US6 (비밀번호 찾기) | Foundational | 없음 (LoginView 네비게이션만) |

### Within Each User Story

1. Tests 작성 및 실패 확인 (TDD)
2. UseCases 구현
3. Repository 확장/구현
4. ViewModel 구현
5. View 구현
6. DIContainer 연결
7. Accessibility 추가

### Parallel Opportunities

**Phase 1 (Setup)**:
```
T002, T003, T004 - 의존성 추가 (병렬)
T005, T006, T007 - Capability 설정 (병렬)
```

**Phase 2 (Foundational)**:
```
T010-T016 - Entities & Protocols (병렬)
T017-T026 - DTOs & Mappers (병렬)
T040-T046 - Core Components (병렬)
T051-T054 - Mocks (병렬)
```

**User Story Phases**:
```
각 Story의 Test 태스크들 (병렬)
각 Story의 Model 관련 태스크 중 [P] 표시된 것들 (병렬)
```

---

## Parallel Example: Foundational Phase

```bash
# Launch all Entity tasks together:
Task: "Create User entity in LoginDemo/Domain/Entities/User.swift"
Task: "Create AuthToken entity in LoginDemo/Domain/Entities/AuthToken.swift"
Task: "Create OnboardingPage entity in LoginDemo/Domain/Entities/OnboardingPage.swift"
Task: "Create AuthProvider enum in LoginDemo/Domain/Entities/AuthProvider.swift"

# Launch all DTO tasks together:
Task: "Create LoginRequestDTO in LoginDemo/Data/DTOs/Request/LoginRequestDTO.swift"
Task: "Create RegisterRequestDTO in LoginDemo/Data/DTOs/Request/RegisterRequestDTO.swift"
Task: "Create SocialLoginRequestDTO in LoginDemo/Data/DTOs/Request/SocialLoginRequestDTO.swift"
...
```

---

## Implementation Strategy

### MVP First (User Story 1, 3, 5 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1 (스플래시)
4. Complete Phase 4: User Story 3 (이메일 로그인)
5. Complete Phase 5: User Story 5 (회원가입)
6. **STOP and VALIDATE**: Test all P1 stories independently
7. Deploy/demo if ready - 핵심 인증 플로우 완성

### Incremental Delivery

1. Setup + Foundational → Foundation ready
2. Add US1 (스플래시) → Test → **기본 앱 시작 플로우**
3. Add US3 (로그인) → Test → **로그인 가능**
4. Add US5 (회원가입) → Test → **MVP 완성!**
5. Add US2 (온보딩) → Test → **최초 사용자 경험 개선**
6. Add US4 (소셜 로그인) → Test → **편의성 향상**
7. Add US6 (비밀번호 찾기) → Test → **계정 복구 지원**

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1 (스플래시) + User Story 2 (온보딩)
   - Developer B: User Story 3 (로그인) + User Story 4 (소셜 로그인)
   - Developer C: User Story 5 (회원가입) + User Story 6 (비밀번호 찾기)
3. Stories complete and integrate independently

---

## Notes

- [P] tasks = 다른 파일, 의존성 없음 - 병렬 실행 가능
- [Story] label = 특정 User Story에 매핑 (추적성)
- 각 User Story는 독립적으로 완료 및 테스트 가능
- TDD: 테스트 실패 확인 후 구현
- 각 태스크 또는 논리적 그룹 완료 후 커밋
- 체크포인트에서 독립적으로 Story 검증 가능
- 회피: 모호한 태스크, 같은 파일 충돌, Story 간 의존성으로 인한 독립성 훼손
