# 구현 계획: 인증 및 온보딩 플로우

**Branch**: `001-auth-onboarding-flow` | **Date**: 2026-01-07 | **Spec**: [spec.md](./spec.md)
**Input**: `/specs/001-auth-onboarding-flow/spec.md`

## 요약

SwiftUI 기반 iOS 앱의 인증 및 온보딩 플로우를 클린 아키텍처 패턴으로 구현합니다. 스플래시 화면, 온보딩, 이메일/소셜 로그인, 회원가입 기능을 포함하며, Keychain 기반 자동로그인과 토큰 갱신 메커니즘을 적용합니다.

## 기술 컨텍스트

**Language/Version**: Swift 5.9+ (iOS 17 Observation 매크로 사용)
**Primary Dependencies**: SwiftUI, Combine, Alamofire, AuthenticationServices (Apple Sign In), KakaoSDK, NaverThirdPartyLogin
**Storage**: Keychain (토큰), UserDefaults (앱 설정)
**Testing**: XCTest, XCUITest
**Target Platform**: iOS 15+
**Project Type**: mobile (iOS single app)
**Performance Goals**: 스플래시→다음화면 3초 이내, 폼 검증 피드백 0.3초 이내
**Constraints**: HTTPS 필수, Keychain 암호화 저장, 오프라인 모드 지원
**Scale/Scope**: 4개 화면 (Splash, Onboarding, Login, Register), 6개 UseCase

## 헌법 체크

*GATE: Phase 0 연구 전 통과 필수. Phase 1 설계 후 재확인.*

| 원칙 | 상태 | 설명 |
|------|------|------|
| I. SwiftUI 우선 | ✅ 준수 | 모든 UI를 SwiftUI View 프로토콜로 구현 |
| II. 클린 아키텍처 | ✅ 준수 | Domain/Data/Presentation 3개 레이어 분리 |
| III. 테스트 주도 개발 | ✅ 준수 | UseCase, ViewModel 단위 테스트 작성 |
| IV. 상태 관리 일관성 | ✅ 준수 | @Observable 매크로 및 @State/@Binding 사용 |
| V. 접근성 필수 | ✅ 준수 | 모든 인터랙티브 요소에 accessibilityLabel |
| VI. 단순성 우선 | ✅ 준수 | YAGNI 원칙 적용, 필요한 기능만 구현 |
| VII. 보안 최우선 | ✅ 준수 | Keychain 저장, HTTPS 통신, 로그 마스킹 |

## 프로젝트 구조

### 문서 구조 (이 기능)

```text
specs/001-auth-onboarding-flow/
├── plan.md              # 이 파일 (/speckit.plan 출력)
├── spec.md              # 기능 명세서
├── research.md          # Phase 0 출력 - 기술 연구
├── data-model.md        # Phase 1 출력 - 데이터 모델
├── quickstart.md        # Phase 1 출력 - 빠른 시작 가이드
├── contracts/           # Phase 1 출력 - API 계약
│   └── auth-api.yaml
├── checklists/          # 체크리스트
│   └── requirements.md
└── tasks.md             # Phase 2 출력 (/speckit.tasks)
```

### 소스 코드 구조 (저장소 루트)

```text
LoginDemo/
├── App/
│   ├── LoginDemoApp.swift              # 앱 진입점, 앱 상태 관리
│   └── DIContainer.swift               # 의존성 주입 컨테이너
│
├── Domain/                              # 🔵 Domain Layer
│   ├── Entities/
│   │   ├── User.swift                  # 사용자 엔티티
│   │   ├── AuthToken.swift             # 인증 토큰 엔티티
│   │   └── OnboardingPage.swift        # 온보딩 페이지 엔티티
│   ├── UseCases/
│   │   ├── Auth/
│   │   │   ├── LoginUseCase.swift          # 이메일 로그인
│   │   │   ├── SocialLoginUseCase.swift    # 소셜 로그인 (카카오/네이버/Apple)
│   │   │   ├── RegisterUseCase.swift       # 회원가입
│   │   │   ├── AutoLoginUseCase.swift      # 자동로그인 처리
│   │   │   ├── RefreshTokenUseCase.swift   # 토큰 갱신
│   │   │   └── LogoutUseCase.swift         # 로그아웃
│   │   └── Onboarding/
│   │       └── CheckOnboardingUseCase.swift # 온보딩 완료 확인
│   └── Repositories/
│       ├── AuthRepositoryProtocol.swift    # 인증 리포지토리 프로토콜
│       ├── UserRepositoryProtocol.swift    # 사용자 리포지토리 프로토콜
│       └── OnboardingRepositoryProtocol.swift # 온보딩 리포지토리 프로토콜
│
├── Data/                                # 🟢 Data Layer
│   ├── Repositories/
│   │   ├── AuthRepository.swift        # 인증 리포지토리 구현
│   │   ├── UserRepository.swift        # 사용자 리포지토리 구현
│   │   └── OnboardingRepository.swift  # 온보딩 리포지토리 구현
│   ├── DataSources/
│   │   ├── Remote/
│   │   │   ├── AuthRemoteDataSource.swift      # 인증 API 호출
│   │   │   └── NetworkService.swift            # 네트워크 서비스
│   │   └── Local/
│   │       ├── KeychainDataSource.swift        # Keychain 접근
│   │       └── UserDefaultsDataSource.swift    # UserDefaults 접근
│   ├── DTOs/
│   │   ├── Request/
│   │   │   ├── LoginRequestDTO.swift
│   │   │   ├── RegisterRequestDTO.swift
│   │   │   ├── SocialLoginRequestDTO.swift
│   │   │   └── RefreshTokenRequestDTO.swift
│   │   └── Response/
│   │       ├── AuthResponseDTO.swift
│   │       ├── UserDTO.swift
│   │       └── ErrorResponseDTO.swift
│   └── Mappers/
│       ├── UserMapper.swift            # UserDTO ↔ User
│       └── AuthTokenMapper.swift       # AuthResponseDTO ↔ AuthToken
│
├── Presentation/                        # 🟠 Presentation Layer
│   ├── App/
│   │   ├── AppState.swift              # 앱 전역 상태 (인증 상태)
│   │   └── AppRouter.swift             # 앱 라우팅 로직
│   ├── Splash/
│   │   ├── SplashView.swift
│   │   └── SplashViewModel.swift
│   ├── Onboarding/
│   │   ├── OnboardingView.swift
│   │   ├── OnboardingPageView.swift
│   │   └── OnboardingViewModel.swift
│   ├── Auth/
│   │   ├── Login/
│   │   │   ├── LoginView.swift
│   │   │   ├── LoginFormView.swift
│   │   │   └── LoginViewModel.swift
│   │   ├── Register/
│   │   │   ├── RegisterView.swift
│   │   │   └── RegisterViewModel.swift
│   │   └── ForgotPassword/
│   │       ├── ForgotPasswordView.swift
│   │       └── ForgotPasswordViewModel.swift
│   └── Main/
│       └── MainView.swift              # 메인 화면 (로그인 후)
│
├── Core/                                # 공통 유틸리티
│   ├── Components/
│   │   ├── PrimaryButton.swift         # 기본 버튼 컴포넌트
│   │   ├── SecureTextField.swift       # 비밀번호 입력 필드
│   │   ├── SocialLoginButton.swift     # 소셜 로그인 버튼
│   │   ├── LoadingOverlay.swift        # 로딩 오버레이
│   │   └── ErrorAlert.swift            # 에러 알림
│   ├── Extensions/
│   │   ├── String+Validation.swift     # 이메일/비밀번호 검증
│   │   ├── View+Keyboard.swift         # 키보드 처리
│   │   └── Color+Theme.swift           # 테마 색상
│   ├── Network/
│   │   ├── APIEndpoint.swift           # API 엔드포인트 정의
│   │   ├── HTTPMethod.swift            # HTTP 메서드
│   │   └── NetworkError.swift          # 네트워크 에러 정의
│   └── Utilities/
│       ├── KeychainHelper.swift        # Keychain 헬퍼
│       └── Validator.swift             # 입력값 검증기
│
├── Resources/
│   ├── Assets.xcassets/
│   │   ├── AppIcon.appiconset/
│   │   ├── Colors/                     # 색상 에셋
│   │   └── Images/                     # 이미지 에셋 (온보딩 등)
│   └── Localizable.strings             # 다국어 문자열
│
└── LoginDemoTests/                      # 테스트
    ├── Domain/
    │   └── UseCases/
    │       ├── LoginUseCaseTests.swift
    │       ├── RegisterUseCaseTests.swift
    │       └── AutoLoginUseCaseTests.swift
    ├── Presentation/
    │   └── ViewModels/
    │       ├── LoginViewModelTests.swift
    │       ├── RegisterViewModelTests.swift
    │       └── SplashViewModelTests.swift
    └── Mocks/
        ├── MockAuthRepository.swift
        └── MockKeychainDataSource.swift
```

**구조 결정**: 클린 아키텍처 기반 iOS 모바일 앱 구조. Domain/Data/Presentation 레이어로 분리하여 헌법의 아키텍처 원칙을 준수합니다.

## 복잡성 추적

> **헌법 체크에서 위반 사항이 없으므로 이 섹션은 해당 없음**

| 위반 | 필요 이유 | 더 단순한 대안을 거부한 이유 |
|------|----------|----------------------------|
| 없음 | - | - |
