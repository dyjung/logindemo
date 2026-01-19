# 데이터 모델: 인증 및 온보딩 플로우

**Date**: 2026-01-07
**Feature**: 001-auth-onboarding-flow

## 엔티티 (Domain Layer)

### User

사용자 정보를 나타내는 핵심 엔티티입니다.

```swift
struct User: Equatable, Sendable {
    let id: String
    let email: String
    let name: String
    let provider: AuthProvider?  // 소셜 로그인 제공자 (nil = 이메일 가입)
    let createdAt: Date
}

enum AuthProvider: String, Codable, Sendable {
    case email
    case kakao
    case naver
    case apple
}
```

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| id | String | ✅ | 사용자 고유 식별자 |
| email | String | ✅ | 이메일 주소 |
| name | String | ✅ | 사용자 이름 |
| provider | AuthProvider? | ❌ | 인증 제공자 |
| createdAt | Date | ✅ | 계정 생성 일시 |

### AuthToken

인증 토큰 정보를 나타내는 엔티티입니다.

```swift
struct AuthToken: Equatable, Sendable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: TimeInterval  // Access Token 만료 시간 (초)
    let tokenType: String        // "Bearer"
}
```

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| accessToken | String | ✅ | API 인증용 토큰 |
| refreshToken | String | ✅ | 토큰 갱신용 토큰 |
| expiresIn | TimeInterval | ✅ | 만료 시간 (초) |
| tokenType | String | ✅ | 토큰 타입 |

### OnboardingPage

온보딩 페이지 정보를 나타내는 엔티티입니다.

```swift
struct OnboardingPage: Identifiable, Equatable, Sendable {
    let id: Int
    let imageName: String   // Asset 이미지 이름
    let title: String
    let description: String
}
```

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| id | Int | ✅ | 페이지 순서 (0, 1, 2) |
| imageName | String | ✅ | 이미지 에셋 이름 |
| title | String | ✅ | 제목 |
| description | String | ✅ | 설명 |

## DTO (Data Layer)

### 요청 DTO

#### LoginRequestDTO

```swift
struct LoginRequestDTO: Encodable {
    let email: String
    let password: String
    let autoLogin: Bool
}
```

#### RegisterRequestDTO

```swift
struct RegisterRequestDTO: Encodable {
    let email: String
    let password: String
    let name: String
    let agreedToTerms: Bool
    let agreedToPrivacy: Bool
}
```

#### SocialLoginRequestDTO

```swift
struct SocialLoginRequestDTO: Encodable {
    let oauthToken: String
    let provider: String     // "kakao", "naver", "apple"
    let autoLogin: Bool
}
```

#### RefreshTokenRequestDTO

```swift
struct RefreshTokenRequestDTO: Encodable {
    let refreshToken: String
}
```

### 응답 DTO

#### AuthResponseDTO

```swift
struct AuthResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let tokenType: String
    let user: UserDTO
}
```

#### UserDTO

```swift
struct UserDTO: Decodable {
    let id: String
    let email: String
    let name: String
    let provider: String?
    let createdAt: String  // ISO8601 형식
}
```

#### ErrorResponseDTO

```swift
struct ErrorResponseDTO: Decodable {
    let code: Int
    let message: String
    let details: [String: String]?
}
```

#### EmailCheckResponseDTO

```swift
struct EmailCheckResponseDTO: Decodable {
    let available: Bool
}
```

## 매퍼 (Data Layer)

### UserMapper

```swift
struct UserMapper {
    static func toEntity(_ dto: UserDTO) -> User {
        User(
            id: dto.id,
            email: dto.email,
            name: dto.name,
            provider: dto.provider.flatMap { AuthProvider(rawValue: $0) },
            createdAt: ISO8601DateFormatter().date(from: dto.createdAt) ?? Date()
        )
    }
}
```

### AuthTokenMapper

```swift
struct AuthTokenMapper {
    static func toEntity(_ dto: AuthResponseDTO) -> AuthToken {
        AuthToken(
            accessToken: dto.accessToken,
            refreshToken: dto.refreshToken,
            expiresIn: TimeInterval(dto.expiresIn),
            tokenType: dto.tokenType
        )
    }
}
```

## 로컬 저장소 스키마

### Keychain 저장 항목

| 키 | 타입 | 용도 |
|----|------|------|
| `com.dyjung.LoginDemo.accessToken` | String | Access Token |
| `com.dyjung.LoginDemo.refreshToken` | String | Refresh Token |
| `com.dyjung.LoginDemo.userId` | String | 사용자 ID |

### UserDefaults 저장 항목

| 키 | 타입 | 기본값 | 용도 |
|----|------|--------|------|
| `isFirstLaunch` | Bool | true | 최초 실행 여부 |
| `hasCompletedOnboarding` | Bool | false | 온보딩 완료 여부 |
| `autoLoginEnabled` | Bool | false | 자동로그인 활성화 |
| `lastLoginEmail` | String? | nil | 마지막 로그인 이메일 |

## 상태 전이 다이어그램

### 앱 상태 전이

```
┌─────────────────────────────────────────────────────────────┐
│                        앱 시작                               │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Splash 화면                             │
│  - 최초 실행 확인 (isFirstLaunch)                            │
│  - 자동로그인 확인 (autoLoginEnabled + refreshToken 존재)    │
│  - 토큰 유효성 검증                                          │
└─────────────────────────────────────────────────────────────┘
                              │
           ┌──────────────────┼──────────────────┐
           │                  │                  │
           ▼                  ▼                  ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│   Onboarding    │ │     Login       │ │      Main       │
│   (최초 실행)    │ │ (비로그인 상태)  │ │  (로그인 완료)   │
└─────────────────┘ └─────────────────┘ └─────────────────┘
           │                  │                  │
           │                  ▼                  │
           │        ┌─────────────────┐          │
           │        │    Register     │          │
           │        │   (회원가입)     │          │
           │        └─────────────────┘          │
           │                  │                  │
           └──────────────────┴──────────────────┘
```

### 인증 상태 전이

```
┌─────────────┐     로그인 성공      ┌─────────────┐
│  Logged Out │ ──────────────────▶ │  Logged In  │
│             │                     │             │
└─────────────┘                     └─────────────┘
       ▲                                   │
       │         토큰 만료/로그아웃          │
       └───────────────────────────────────┘
```

## 검증 규칙

### 이메일 검증

```swift
extension String {
    var isValidEmail: Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return range(of: pattern, options: .regularExpression) != nil
    }
}
```

### 비밀번호 검증

```swift
extension String {
    var isValidPassword: Bool {
        count >= 8
    }
}
```

### 이름 검증

```swift
extension String {
    var isValidName: Bool {
        !trimmingCharacters(in: .whitespaces).isEmpty
    }
}
```
