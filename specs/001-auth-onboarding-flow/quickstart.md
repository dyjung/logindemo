# 빠른 시작 가이드: 인증 및 온보딩 플로우

**Date**: 2026-01-07
**Feature**: 001-auth-onboarding-flow

## 전제 조건

- Xcode 15.0 이상
- iOS 15.0+ 시뮬레이터 또는 실제 디바이스
- Swift 5.9 이상

## 프로젝트 설정

### 1. 의존성 설치

**Swift Package Manager (SPM)**

`File > Add Packages...` 에서 다음 패키지 추가:

```
Alamofire: https://github.com/Alamofire/Alamofire (5.8.0+)
KakaoSDK: https://github.com/kakao/kakao-ios-sdk
```

**수동 설치 (네이버)**

NaverThirdPartyLogin SDK는 수동으로 통합이 필요합니다:
1. [네이버 개발자 센터](https://developers.naver.com)에서 SDK 다운로드
2. `NaverThirdPartyLogin.xcframework`를 프로젝트에 추가

### 2. Info.plist 설정

```xml
<!-- URL Schemes -->
<key>CFBundleURLTypes</key>
<array>
    <!-- 카카오 -->
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>kakao{YOUR_NATIVE_APP_KEY}</string>
        </array>
    </dict>
    <!-- 네이버 -->
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>{YOUR_NAVER_URL_SCHEME}</string>
        </array>
    </dict>
</array>

<!-- 카카오 앱 실행 허용 -->
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>kakaokompassauth</string>
    <string>kakaolink</string>
</array>
```

### 3. Keychain Sharing 설정

`Signing & Capabilities` 탭에서:
1. `+ Capability` 클릭
2. `Keychain Sharing` 추가
3. Keychain Group: `$(AppIdentifierPrefix)com.dyjung.LoginDemo`

### 4. Sign in with Apple 설정

`Signing & Capabilities` 탭에서:
1. `+ Capability` 클릭
2. `Sign in with Apple` 추가

## 빌드 및 실행

### 커맨드 라인

```bash
# 빌드
xcodebuild -project LoginDemo.xcodeproj \
           -scheme LoginDemo \
           -sdk iphonesimulator \
           -configuration Debug \
           build

# 테스트 실행
xcodebuild -project LoginDemo.xcodeproj \
           -scheme LoginDemo \
           -sdk iphonesimulator \
           -destination 'platform=iOS Simulator,name=iPhone 15' \
           test
```

### Xcode

1. `LoginDemo.xcodeproj` 열기
2. 시뮬레이터 또는 디바이스 선택
3. `Cmd + R`로 실행

## 핵심 사용 플로우

### 앱 시작 플로우

```
1. 앱 실행
   │
2. SplashView 표시 (1.5~3초)
   │
3. 앱 상태 확인
   ├─ 최초 실행? → OnboardingView
   ├─ 자동로그인 활성화 + 유효 토큰? → MainView
   └─ 그 외 → LoginView
```

### 로그인 플로우

```swift
// 1. 이메일/비밀번호 입력
let email = "user@example.com"
let password = "password123"

// 2. 유효성 검사 (실시간)
// - 이메일 형식 검증
// - 비밀번호 8자 이상

// 3. 로그인 버튼 탭
// - API 호출: POST /auth/login
// - 성공: 토큰 저장 → MainView 이동
// - 실패: 에러 메시지 표시
```

### 회원가입 플로우

```swift
// 1. 필드 입력
// - 이메일 (중복 확인 자동 실행)
// - 비밀번호 (8자 이상)
// - 비밀번호 확인 (일치 검사)
// - 이름

// 2. 약관 동의
// - 이용약관 동의 (필수)
// - 개인정보처리방침 동의 (필수)

// 3. 회원가입 버튼 탭
// - API 호출: POST /auth/register
// - 성공: 자동 로그인 → MainView 이동
// - 실패: 에러 메시지 표시
```

## API 연동

### 기본 URL 설정

```swift
// Core/Network/APIEndpoint.swift
enum APIEndpoint {
    static let baseURL = "https://api.example.com/v1"

    case login
    case register
    case socialLogin(provider: String)
    case refresh
    case logout
    case checkEmail(email: String)

    var url: URL {
        // URL 구성 로직
    }
}
```

### 인증 헤더

```swift
// 인증이 필요한 요청에 자동 추가
var request = URLRequest(url: endpoint.url)
request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
```

## 테스트

### 단위 테스트 실행

```bash
# 전체 테스트
xcodebuild test -scheme LoginDemo -sdk iphonesimulator

# 특정 테스트 클래스
xcodebuild test -scheme LoginDemo \
    -sdk iphonesimulator \
    -only-testing:LoginDemoTests/LoginUseCaseTests
```

### Mock 데이터 사용

```swift
// 테스트에서 Mock Repository 주입
let mockRepository = MockAuthRepository()
mockRepository.loginResult = .success(AuthToken(...))

let useCase = LoginUseCase(authRepository: mockRepository)
let viewModel = LoginViewModel(loginUseCase: useCase)
```

## 환경 변수

### 개발 환경

| 변수 | 값 | 설명 |
|------|-----|------|
| API_BASE_URL | https://api-dev.example.com/v1 | 개발 서버 |
| KAKAO_APP_KEY | {개발용 앱 키} | 카카오 앱 키 |
| NAVER_CLIENT_ID | {개발용 클라이언트 ID} | 네이버 클라이언트 ID |

### 프로덕션 환경

| 변수 | 값 | 설명 |
|------|-----|------|
| API_BASE_URL | https://api.example.com/v1 | 운영 서버 |
| KAKAO_APP_KEY | {운영용 앱 키} | 카카오 앱 키 |
| NAVER_CLIENT_ID | {운영용 클라이언트 ID} | 네이버 클라이언트 ID |

## 트러블슈팅

### 카카오 로그인 오류

**증상**: 카카오 앱이 실행되지 않음

**해결**:
1. Info.plist의 `LSApplicationQueriesSchemes` 확인
2. URL Scheme에 `kakao{앱키}` 등록 확인
3. 카카오 개발자 콘솔에서 iOS 플랫폼 설정 확인

### Keychain 접근 오류

**증상**: 토큰 저장/조회 실패

**해결**:
1. Keychain Sharing Capability 활성화 확인
2. 시뮬레이터에서 Keychain 초기화: `Device > Erase All Content and Settings`
3. 앱 삭제 후 재설치

### Apple Sign In 오류

**증상**: Sign in with Apple 버튼이 동작하지 않음

**해결**:
1. Sign in with Apple Capability 활성화 확인
2. Apple Developer 계정에서 App ID 설정 확인
3. 실제 디바이스에서 테스트 (시뮬레이터 제한 있음)

## 다음 단계

1. **`/speckit.tasks`** 실행하여 상세 작업 목록 생성
2. Phase별 구현 진행
3. 각 UseCase 단위 테스트 작성
4. UI 통합 테스트 작성
