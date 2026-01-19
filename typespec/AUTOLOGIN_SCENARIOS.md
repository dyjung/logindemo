# 자동 로그인 시나리오 분석

현재 TypeSpec 문서 기반 자동 로그인 시나리오 정리

## 📋 개요

자동 로그인은 **EMAIL 로그인과 소셜 로그인 모두 동일한 방식**으로 동작합니다. 
인증 방법에 관계없이 리프레시 토큰 기반으로 자동 로그인이 처리됩니다.

---

## 🔄 전체 플로우

### 1️⃣ 최초 로그인/회원가입 단계

#### EMAIL 로그인
```http
POST /v1/auth/login
Content-Type: application/json

{
  "provider": "EMAIL",
  "email": "user@example.com",
  "password": "plaintext_password",
  "deviceInfo": { ... }
}
```

**응답:**
```json
{
  "user": { ... },
  "accessToken": "jwt_access_token",
  "refreshToken": "jwt_refresh_token",  // ⭐ 자동 로그인에 사용
  "expiresIn": 3600
}
```

#### 소셜 로그인 (KAKAO/NAVER/APPLE/GOOGLE)
```http
POST /v1/auth/login
Content-Type: application/json

{
  "provider": "KAKAO",  // 또는 NAVER, APPLE, GOOGLE
  "socialAccessToken": "kakao_access_token",
  "deviceInfo": { ... }
}
```

**응답:**
```json
{
  "user": { ... },
  "accessToken": "jwt_access_token",
  "refreshToken": "jwt_refresh_token",  // ⭐ 자동 로그인에 사용
  "expiresIn": 3600
}
```

#### 회원가입 (EMAIL/소셜 동일)
회원가입(`/v1/auth/register`)도 동일하게 `refreshToken`을 반환합니다.

---

### 2️⃣ 자동 로그인 실행 단계

앱이 다시 실행될 때, 클라이언트는 **로컬 저장소에 저장된 `refreshToken`**을 사용합니다.

#### 시나리오 A: `/v1/init` 엔드포인트 사용 (권장)

앱 초기화와 자동 로그인을 **한 번의 API 호출**로 처리합니다.

```http
GET /v1/init
X-App-Version: 1.0.0
X-Platform: iOS
X-Device-Id: device-uuid
X-Refresh-Token: jwt_refresh_token  // ⭐ 로컬 저장소에서 가져온 토큰
```

**응답 (자동 로그인 성공 시):**
```json
{
  "config": { ... },
  "forceUpdate": false,
  "isMaintenance": false,
  "userContext": { ... },
  "autoLogin": {  // ⭐ 자동 로그인 결과
    "success": true,
    "user": {
      "id": "user-id",
      "email": "user@example.com",
      "nickname": "닉네임",
      "status": "ACTIVE",
      "createdAt": "2024-01-01T00:00:00Z",
      "lastLogin": "2024-01-02T12:00:00Z"
    },
    "accessToken": "new_jwt_access_token",  // 새로 발급
    "refreshToken": "new_jwt_refresh_token", // Rotation 적용시 새 토큰
    "expiresIn": 3600
  }
}
```

**응답 (자동 로그인 실패 시):**
```json
{
  "config": { ... },
  "forceUpdate": false,
  "isMaintenance": false,
  "userContext": { ... },
  "autoLogin": {
    "success": false,
    "failureReason": "TOKEN_EXPIRED"  // 또는 다른 실패 사유
  }
}
```

**응답 (토큰이 없는 경우):**
```json
{
  "config": { ... },
  "forceUpdate": false,
  "isMaintenance": false,
  "userContext": { ... },
  "autoLogin": null  // ⭐ 토큰이 없으면 null
}
```

#### 시나리오 B: `/v1/auth/refresh` 엔드포인트 사용

자동 로그인만 별도로 처리하고 싶은 경우:

```http
POST /v1/auth/refresh
Content-Type: application/json

{
  "refreshToken": "jwt_refresh_token",
  "deviceInfo": { ... }
}
```

**응답:**
```json
{
  "accessToken": "new_jwt_access_token",
  "refreshToken": "new_jwt_refresh_token",  // Rotation 적용시
  "expiresIn": 3600
}
```

---

## 🔐 자동 로그인 실패 사유

자동 로그인 실패 시 다음 사유 중 하나가 반환됩니다:

| 실패 사유 | 설명 | 사용자 행동 |
|----------|------|-----------|
| `NO_TOKEN` | 리프레시 토큰이 없음 | 로그인 화면으로 이동 |
| `TOKEN_EXPIRED` | 리프레시 토큰이 만료됨 | 로그인 화면으로 이동 |
| `TOKEN_INVALID` | 리프레시 토큰이 유효하지 않음 | 로그인 화면으로 이동 |
| `ACCOUNT_SLEEP` | 계정이 휴면 상태 | 휴면 해제 안내 |
| `ACCOUNT_SUSPENDED` | 계정이 정지 상태 | 고객센터 문의 안내 |
| `ACCOUNT_DELETED` | 계정이 삭제됨 | 재가입 안내 |

---

## 📱 클라이언트 구현 가이드

### 저장소 관리
1. 로그인/회원가입 성공 시 `refreshToken`을 안전한 저장소에 저장
   - iOS: Keychain
   - Android: EncryptedSharedPreferences
   - Web: HttpOnly Cookie (권장) 또는 Secure Storage

2. 로그아웃 시 `refreshToken` 삭제

### 자동 로그인 로직
```typescript
// 앱 시작 시
async function handleAppInit() {
  const refreshToken = await getStoredRefreshToken();
  
  const response = await fetch('/v1/init', {
    headers: {
      'X-App-Version': appVersion,
      'X-Platform': platform,
      'X-Refresh-Token': refreshToken || undefined
    }
  });
  
  const data = await response.json();
  
  if (data.autoLogin?.success) {
    // ✅ 자동 로그인 성공
    // - 새 accessToken 저장
    // - 새 refreshToken 저장 (Rotation 적용시)
    // - 사용자 정보 캐시
    saveTokens(data.autoLogin);
    setUser(data.autoLogin.user);
  } else if (data.autoLogin?.success === false) {
    // ❌ 자동 로그인 실패
    // - 실패 사유에 따라 처리
    handleAutoLoginFailure(data.autoLogin.failureReason);
  } else {
    // ℹ️ 토큰이 없음 - 로그인 화면 표시
    showLoginScreen();
  }
}
```

---

## ⚡ 주요 특징

### 1. 인증 방법 통합
- EMAIL 로그인과 소셜 로그인이 **동일한 토큰 기반 자동 로그인** 사용
- 인증 방법에 관계없이 동일한 플로우

### 2. 토큰 Rotation 지원
- 자동 로그인 성공 시 새 `refreshToken` 발급 가능
- 보안 강화: 토큰 탈취 시 피해 최소화

### 3. 단일 API 호출
- `/v1/init` 엔드포인트로 초기화와 자동 로그인을 동시 처리
- 네트워크 호출 최소화로 앱 시작 속도 향상

### 4. 명확한 실패 처리
- 다양한 실패 사유 코드 제공
- 클라이언트에서 사용자에게 적절한 안내 가능

---

## 🔄 토큰 갱신 시나리오

액세스 토큰이 만료되었을 때:

```http
POST /v1/auth/refresh
Content-Type: application/json

{
  "refreshToken": "stored_refresh_token"
}
```

이 엔드포인트는 자동 로그인과 동일한 로직을 사용하지만, 앱 초기화 없이 토큰만 갱신합니다.

---

## ⚠️ 주의사항

1. **리프레시 토큰 보안**
   - 반드시 안전한 저장소에 저장
   - HTTPS 통신 필수
   - 토큰 탈취 시 즉시 무효화 가능한 구조 권장

2. **토큰 만료 처리**
   - 리프레시 토큰도 만료될 수 있음
   - 만료 시 사용자에게 재로그인 요청

3. **다중 디바이스**
   - 동일 사용자가 여러 디바이스에서 로그인 가능
   - 각 디바이스별로 별도의 리프레시 토큰 관리

