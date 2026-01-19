# 기술 연구: 인증 및 온보딩 플로우

**Date**: 2026-01-07
**Feature**: 001-auth-onboarding-flow

## 1. SwiftUI 상태 관리 패턴

### 결정: @Observable 매크로 + @State 조합 사용

**근거**:
- iOS 17+에서 `@Observable` 매크로는 `ObservableObject`보다 간결하고 성능이 우수
- iOS 15+ 하위 호환이 필요한 경우 `@StateObject` + `ObservableObject` 사용
- 뷰 로컬 상태는 `@State`, 뷰모델 참조는 `@State`(Observable) 또는 `@StateObject`(ObservableObject)

**고려한 대안**:
| 대안 | 거부 이유 |
|------|----------|
| TCA (The Composable Architecture) | 학습 곡선이 높고 이 규모의 프로젝트에는 과도함 |
| Combine만 사용 | SwiftUI 네이티브 상태 관리가 더 간결 |
| @EnvironmentObject 전역 사용 | 의존성 추적이 어려움, DI 패턴과 충돌 |

### 구현 패턴

```swift
// iOS 17+ (권장)
@Observable
final class LoginViewModel {
    var email = ""
    var password = ""
}

// iOS 15+ 하위 호환
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
}
```

## 2. Keychain 저장소 구현

### 결정: Security 프레임워크 직접 사용 (래퍼 클래스 구현)

**근거**:
- 외부 라이브러리 의존성 최소화 (헌법 VI. 단순성 우선)
- Keychain Access 제어 세밀한 설정 가능
- `kSecAttrAccessible` 옵션으로 보안 수준 제어

**고려한 대안**:
| 대안 | 거부 이유 |
|------|----------|
| KeychainAccess (라이브러리) | 외부 의존성 추가, 기능 과잉 |
| SwiftKeychainWrapper | 유지보수 불확실, 불필요한 추상화 |

### 구현 전략

```swift
final class KeychainHelper {
    enum KeychainKey: String {
        case accessToken = "com.dyjung.LoginDemo.accessToken"
        case refreshToken = "com.dyjung.LoginDemo.refreshToken"
        case userId = "com.dyjung.LoginDemo.userId"
    }

    // kSecAttrAccessibleWhenUnlockedThisDeviceOnly 사용
    // - 디바이스 잠금 해제 시에만 접근 가능
    // - 백업에서 복원 불가 (보안 강화)
}
```

## 3. 소셜 로그인 SDK 통합

### 결정: 각 플랫폼 공식 SDK 사용

**근거**:
- Apple Sign In: `AuthenticationServices` 프레임워크 (시스템 제공)
- 카카오: KakaoSDK (Swift Package Manager)
- 네이버: NaverThirdPartyLogin (CocoaPods 또는 수동 통합)

### SDK별 구현 전략

#### Apple Sign In
```swift
// AuthenticationServices 프레임워크 사용
// ASAuthorizationController로 인증 요청
// 결과: identityToken, authorizationCode
```

#### 카카오 로그인
```swift
// KakaoSDK 설치: SPM으로 추가
// URL Scheme: kakao{APP_KEY} 등록 필요
// Info.plist: LSApplicationQueriesSchemes 설정
```

#### 네이버 로그인
```swift
// NaverThirdPartyLogin SDK
// URL Scheme: 앱 등록 시 발급받은 scheme
// 콜백 처리: AppDelegate/SceneDelegate에서 URL 처리
```

### 통합 인터페이스

```swift
// 소셜 로그인 결과를 통일된 형태로 변환
protocol SocialAuthProvider {
    func authenticate() async throws -> SocialAuthResult
}

struct SocialAuthResult {
    let provider: AuthProvider  // kakao, naver, apple
    let oauthToken: String
    let email: String?
    let name: String?
}
```

## 4. 네트워크 레이어 설계

### 결정: Alamofire + async/await 사용

**근거**:
- 검증된 네트워킹 라이브러리로 안정성 확보
- `RequestInterceptor`를 통한 토큰 갱신 자동화
- `RequestRetrier`로 재시도 로직 표준화
- JSON 인코딩/디코딩, 에러 처리 등 보일러플레이트 코드 감소
- Swift Concurrency (async/await) 완벽 지원

**고려한 대안**:
| 대안 | 거부 이유 |
|------|----------|
| URLSession 직접 사용 | 인터셉터, 재시도 로직 직접 구현 필요, 보일러플레이트 증가 |
| Moya | Alamofire 위에 추가 추상화 레이어, 이 규모에서는 과도함 |

### Alamofire 설정

```swift
// SPM 패키지 추가
// https://github.com/Alamofire/Alamofire (5.8.0+)
```

### 구현 전략

```swift
// MARK: - API Router (URLRequestConvertible)
enum AuthRouter: URLRequestConvertible {
    case login(email: String, password: String, autoLogin: Bool)
    case register(email: String, password: String, name: String, agreedToTerms: Bool, agreedToPrivacy: Bool)
    case socialLogin(provider: String, oauthToken: String, autoLogin: Bool)
    case refreshToken(refreshToken: String)
    case checkEmail(email: String)
    case logout

    var method: HTTPMethod {
        switch self {
        case .login, .register, .socialLogin, .refreshToken, .logout:
            return .post
        case .checkEmail:
            return .get
        }
    }

    var path: String {
        switch self {
        case .login: return "/auth/login"
        case .register: return "/auth/register"
        case .socialLogin(let provider, _, _): return "/auth/oauth/\(provider)"
        case .refreshToken: return "/auth/refresh"
        case .checkEmail: return "/auth/check-email"
        case .logout: return "/auth/logout"
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = try APIConstants.baseURL.asURL().appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.method = method
        // 파라미터 인코딩...
        return request
    }
}

// MARK: - Auth Interceptor (토큰 갱신 자동화)
final class AuthInterceptor: RequestInterceptor {
    private let tokenStorage: KeychainDataSourceProtocol
    private let tokenRefresher: TokenRefresherProtocol

    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = urlRequest
        if let accessToken = tokenStorage.getAccessToken() {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        completion(.success(request))
    }

    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401 else {
            completion(.doNotRetry)
            return
        }

        // 토큰 갱신 시도
        Task {
            do {
                try await tokenRefresher.refreshToken()
                completion(.retry)
            } catch {
                completion(.doNotRetryWithError(error))
            }
        }
    }
}

// MARK: - Network Service
protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ router: URLRequestConvertible) async throws -> T
}

final class NetworkService: NetworkServiceProtocol {
    private let session: Session

    init(interceptor: RequestInterceptor) {
        self.session = Session(interceptor: interceptor)
    }

    func request<T: Decodable>(_ router: URLRequestConvertible) async throws -> T {
        return try await session.request(router)
            .validate(statusCode: 200..<300)
            .serializingDecodable(T.self)
            .value
    }
}
```

### 에러 처리

```swift
// Alamofire 에러를 도메인 에러로 변환
extension AFError {
    var toAuthError: AuthError {
        switch self {
        case .responseValidationFailed(let reason):
            if case .unacceptableStatusCode(let code) = reason {
                switch code {
                case 401: return .invalidCredentials
                case 409: return .emailAlreadyExists
                case 429: return .rateLimitExceeded
                default: return .serverError
                }
            }
            return .unknown
        case .sessionTaskFailed(let error):
            if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                return .networkUnavailable
            }
            return .unknown
        default:
            return .unknown
        }
    }
}
```

## 5. 화면 전환 및 네비게이션

### 결정: 상태 기반 조건부 렌더링 + NavigationStack 조합

**근거**:
- 앱 전역 상태(인증, 온보딩)에 따른 루트 뷰 전환: 조건부 렌더링
- 각 플로우 내 화면 전환: NavigationStack
- 헌법 I. SwiftUI 우선 원칙 준수

### 앱 상태 모델

```swift
enum AppScreen {
    case splash
    case onboarding
    case login
    case main
}

@Observable
final class AppState {
    var currentScreen: AppScreen = .splash
    var isAuthenticated = false
    var hasCompletedOnboarding = false
}
```

### 루트 뷰 구조

```swift
struct RootView: View {
    @State private var appState: AppState

    var body: some View {
        Group {
            switch appState.currentScreen {
            case .splash:
                SplashView(...)
            case .onboarding:
                OnboardingView(...)
            case .login:
                NavigationStack {
                    LoginView(...)
                }
            case .main:
                MainView(...)
            }
        }
    }
}
```

## 6. 폼 유효성 검사

### 결정: Combine + 실시간 검증 패턴

**근거**:
- 입력값 변경 시 즉시 검증 (debounce 0.3초)
- 이메일 중복 확인은 debounce 0.5초로 API 호출 최소화
- 검증 결과를 뷰에 즉시 반영

### 검증 규칙

| 필드 | 규칙 | 검증 시점 |
|------|------|----------|
| 이메일 | RFC 5322 형식 | 입력 즉시 |
| 이메일 중복 | API 호출 | 입력 후 0.5초 |
| 비밀번호 | 8자 이상 | 입력 즉시 |
| 비밀번호 확인 | 비밀번호와 일치 | 입력 즉시 |
| 이름 | 1자 이상 | 입력 즉시 |

### 구현 패턴

```swift
@Observable
final class RegisterViewModel {
    var email = ""
    var emailError: String?
    var isEmailAvailable: Bool?

    private var emailCheckTask: Task<Void, Never>?

    func validateEmail() {
        // 1. 형식 검증 (즉시)
        guard email.isValidEmail else {
            emailError = "올바른 이메일 형식이 아닙니다"
            return
        }

        // 2. 중복 확인 (debounce)
        emailCheckTask?.cancel()
        emailCheckTask = Task {
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            // API 호출
        }
    }
}
```

## 7. 에러 처리 전략

### 결정: 계층별 에러 타입 정의 + 사용자 친화적 메시지 매핑

**근거**:
- Domain Layer: 비즈니스 에러 (AuthError, ValidationError)
- Data Layer: 네트워크/저장소 에러 (NetworkError, KeychainError)
- Presentation Layer: 사용자 메시지로 변환

### 에러 타입 정의

```swift
// Domain Layer
enum AuthError: Error {
    case invalidCredentials
    case emailAlreadyExists
    case tokenExpired
    case networkUnavailable
}

// 사용자 메시지 매핑
extension AuthError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "이메일 또는 비밀번호가 올바르지 않습니다"
        case .emailAlreadyExists:
            return "이미 사용 중인 이메일입니다"
        case .tokenExpired:
            return "로그인이 만료되었습니다. 다시 로그인해주세요"
        case .networkUnavailable:
            return "네트워크 연결을 확인해주세요"
        }
    }
}
```

## 8. 접근성 구현

### 결정: SwiftUI 네이티브 접근성 API 활용

**근거**:
- `accessibilityLabel`: 모든 인터랙티브 요소에 적용
- `accessibilityHint`: 복잡한 동작에 힌트 제공
- `accessibilityValue`: 상태 값 전달 (토글, 슬라이더 등)
- Dynamic Type: 시스템 텍스트 크기 설정 존중

### 구현 가이드

```swift
// 버튼
Button("로그인") { ... }
    .accessibilityLabel("로그인 버튼")
    .accessibilityHint("탭하여 로그인합니다")

// 입력 필드
TextField("이메일", text: $email)
    .accessibilityLabel("이메일 입력")
    .accessibilityValue(email.isEmpty ? "비어 있음" : email)

// 에러 메시지
if let error = emailError {
    Text(error)
        .accessibilityLabel("이메일 오류: \(error)")
}
```

## 9. 다크모드 지원

### 결정: Asset Catalog 색상 + 조건부 이미지

**근거**:
- Color Set으로 라이트/다크 색상 정의
- Image Set으로 모드별 이미지 제공
- `@Environment(\.colorScheme)` 로 필요시 조건부 처리

### 색상 시스템

```swift
// Assets.xcassets/Colors/
// - PrimaryColor: Light #007AFF, Dark #0A84FF
// - BackgroundColor: Light #FFFFFF, Dark #000000
// - TextPrimary: Light #000000, Dark #FFFFFF

extension Color {
    static let primaryColor = Color("PrimaryColor")
    static let backgroundColor = Color("BackgroundColor")
}
```

## 10. 테스트 전략

### 결정: 프로토콜 기반 Mock 주입

**근거**:
- Domain Layer: UseCase 단위 테스트 (Mock Repository)
- Presentation Layer: ViewModel 단위 테스트 (Mock UseCase)
- UI 테스트: 핵심 사용자 플로우

### Mock 구현 패턴

```swift
final class MockAuthRepository: AuthRepositoryProtocol {
    var loginResult: Result<AuthToken, Error> = .failure(AuthError.invalidCredentials)

    func login(email: String, password: String) async throws -> AuthToken {
        switch loginResult {
        case .success(let token):
            return token
        case .failure(let error):
            throw error
        }
    }
}
```

## 11. 의존성 주입 컨테이너 설계 (Updated: 2026-01-08)

### 결정: Constructor Injection 기반 DIContainer (Coordinator 패턴)

**근거**:
- 의존성 역전 원칙(DIP) 완전 준수
- 테스트 시 Mock 주입 용이
- 컴파일 타임 타입 안전성 보장
- DIContainer가 순수 조립(Coordination) 역할만 수행

**이전 방식의 문제점**:
| 문제 | 설명 |
|------|------|
| Mock 교체 불가 | `lazy var`로 생성된 인스턴스 교체 불가능 |
| Service Locator 패턴 | 진정한 DI가 아닌 전역 접근 방식 |
| 의존성 숨김 | 구체 타입이 DIContainer 내부에 숨겨짐 |

### 구현 전략

```swift
// 1. Repository 명명 규칙: Protocol + Impl
protocol AuthRepositoryProtocol { ... }           // Domain Layer
final class AuthRepositoryImpl: AuthRepositoryProtocol { ... }  // Data Layer
final class MockAuthRepository: AuthRepositoryProtocol { ... }  // Test

// 2. DIContainer: Constructor Injection
@MainActor
final class DIContainer {
    // Protocol 타입으로 보유 (구체 타입 아님)
    let authRepository: AuthRepositoryProtocol
    let onboardingRepository: OnboardingRepositoryProtocol

    // 생성자 주입
    init(
        authRepository: AuthRepositoryProtocol,
        onboardingRepository: OnboardingRepositoryProtocol
    ) {
        self.authRepository = authRepository
        self.onboardingRepository = onboardingRepository
    }

    // Factory Methods
    static func makeProduction() -> DIContainer {
        return DIContainer(
            authRepository: AuthRepositoryImpl(...),
            onboardingRepository: OnboardingRepositoryImpl(...)
        )
    }

    static func makeTest() -> DIContainer {
        return DIContainer(
            authRepository: MockAuthRepository(),
            onboardingRepository: MockOnboardingRepository()
        )
    }
}
```

### 파일 구조

```
LoginDemo/Data/
├── Repositories/
│   ├── AuthRepositoryImpl.swift      # 구현체
│   └── OnboardingRepositoryImpl.swift
└── Mocks/
    ├── MockDataSources.swift         # Mock DataSources
    └── MockRepositories.swift        # Mock Repositories
```

### 테스트에서 사용

```swift
func testLogin() async throws {
    // Given
    let mockRepo = MockAuthRepository()
    mockRepo.mockUser = User(...)
    mockRepo.mockToken = AuthToken(...)

    let container = DIContainer(
        authRepository: mockRepo,
        onboardingRepository: MockOnboardingRepository()
    )

    let viewModel = container.makeLoginViewModel()

    // When
    await viewModel.login()

    // Then
    XCTAssertTrue(viewModel.isLoggedIn)
}
