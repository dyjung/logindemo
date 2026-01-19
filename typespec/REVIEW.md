# TypeSpec 문서 검토 결과

## 🔴 심각한 설계 문제

### 1. SocialAccount 모델의 개념적 혼란 (Line 62-76)
**문제점:**
- `SocialAccount` 모델에 `EMAIL` provider와 `password` 필드가 포함되어 있음
- EMAIL 인증은 "소셜" 계정이 아님에도 불구하고 `SocialAccount`에 포함됨
- 모델명과 실제 용도가 일치하지 않음

**영향:**
- 개발자의 혼란 및 잘못된 도메인 모델링
- EMAIL 인증과 소셜 인증의 차이가 모호해짐

**권장 해결방안:**
```typescript
// 옵션 1: 모델명 변경
model AuthenticationAccount {
  provider: AuthProvider;
  providerId: string;
  password?: string;  // EMAIL만 해당
  userId: string;
}

// 옵션 2: EMAIL과 소셜 계정 분리
model EmailAccount {
  email: string;
  passwordHash: string;
  userId: string;
}

model SocialAccount {
  provider: Exclude<AuthProvider, "EMAIL">;
  providerId: string;
  userId: string;
}
```

### 2. User 모델에 최초가입일(createdAt) 누락 (Line 42-59)
**문제점:**
- `User` 모델에 계정 생성 시간(`createdAt` 또는 `registeredAt`)이 없음
- `FindIdResponse`(Line 346)에는 `registeredAt`이 있는데 `User` 모델에는 없어 불일치
- 최초가입일은 통계, 분석, UI 표시 등에서 자주 사용되는 필드

**권장 해결방안:**
```typescript
model User {
  id: string;
  email: string;
  nickname: string;
  status: UserStatus;
  /** 최초 가입일 */
  createdAt: utcDateTime;
  /** 마지막 로그인 시간 */
  lastLogin?: utcDateTime;
  /** 마지막 업데이트 시간 (선택) */
  updatedAt?: utcDateTime;
}
```

### 3. User.email이 필수 필드인데 소셜 계정만 있는 경우 문제 (Line 48-49)
**문제점:**
- `User.email`이 필수(`string`)로 정의되어 있음
- 소셜 로그인만 사용하는 경우 이메일을 제공하지 않을 수 있음
- `RegisterRequest`(Line 290)에서도 소셜 가입시 이메일이 선택적(`email?`)임

**영향:**
- 소셜 계정 전용 사용자 생성 시 문제 발생 가능
- 데이터 불일치 가능성

**권장 해결방안:**
```typescript
model User {
  // ...
  /** 이메일 주소 (소셜 계정만 있는 경우 없을 수 있음) */
  @format("email")
  email?: string;  // 필수가 아닌 선택으로 변경
  // ...
}
```

---

## 🟡 설계 개선 권장 사항

### 4. AuthProvider enum 명명 혼란 (Line 22-28)
**문제점:**
- `AuthProvider`에 `EMAIL`이 포함되어 있으나 "Provider"라는 이름이 혼란을 야기
- EMAIL은 외부 제공자가 아닌 자체 인증 방식

**권장 해결방안:**
- enum 이름을 `AuthenticationMethod` 또는 `AuthType`으로 변경 고려
- 또는 EMAIL을 별도로 처리하는 구조 고려

### 5. expiresIn 필드의 일관성 문제 (Line 128, 220, 245, 257, 324)
**문제점:**
- `AutoLoginResult.expiresIn`(Line 128): 선택적(`?`)
- `LoginResponse.expiresIn`(Line 220): 필수
- `TokenRefreshResponse.expiresIn`(Line 245): 필수
- `TokenVerifyResponse.expiresIn`(Line 257): 선택적
- `RegisterResponse.expiresIn`(Line 324): 필수

**분석:**
- `AutoLoginResult`에서 `success=false`일 때는 `expiresIn`이 의미 없으므로 선택적이 맞음
- 하지만 토큰 발급 응답(`LoginResponse`, `RegisterResponse`)에서는 필수여야 함
- **현재 설계는 적절함** - 성공/실패에 따라 달라지는 것이므로 일관성 있음

### 6. SocialAccount.providerId의 의미 모호성 (Line 68)
**문제점:**
- EMAIL provider의 경우 `providerId`가 무엇을 의미하는지 불명확
- 소셜의 경우는 외부 제공자의 사용자 ID를 의미하지만, EMAIL의 경우는?

**권장 해결방안:**
- 문서에 명확한 설명 추가 또는 EMAIL은 `providerId` 미사용으로 명시

### 7. 모델 간 관계 정의 부족
**문제점:**
- `User`와 `SocialAccount` 간의 관계가 문자열 FK로만 표현됨
- TypeSpec의 관계 표현 기능을 활용하지 않음

**권장 해결방안:**
- 필요시 확장 가능한 관계 정의 고려

### 8. UserStatus enum이 불완전 (Line 32-35)
**문제점:**
- `ACCOUNT_DELETED`가 `AutoLoginFailureReason`(Line 145)에는 있으나 `UserStatus`에는 없음
- 일반적으로 `DELETED`, `SUSPENDED` 등의 상태도 필요

**권장 해결방안:**
```typescript
enum UserStatus {
  ACTIVE: "ACTIVE",
  SLEEP: "SLEEP",
  SUSPENDED: "SUSPENDED",
  DELETED: "DELETED",
}
```

### 9. 비밀번호 필드의 보안 표시 명확성
**문제점:**
- `SocialAccount.password`(Line 72)에 `@visibility(Lifecycle.Create)`만 있고 읽기 시 보안 처리 명시 부족
- API 응답에서 비밀번호가 노출되지 않아야 함

**권장 해결방안:**
- `@visibility(Lifecycle.Read, "never")` 추가하여 응답에서 제외 명시

---

## 🟢 사소한 개선 사항

### 10. FindIdResponse의 registeredAt vs User.createdAt 불일치
- `FindIdResponse`에는 `registeredAt`이 있으나 `User` 모델에는 없음
- 일관성을 위해 동일한 필드명 사용 권장

### 11. 디바이스 정보의 플랫폼 타입 정의
**문제점:**
- `DeviceInfo.platform`(Line 178)이 일반 `string`으로 정의됨
- `SystemInit` 인터페이스(Line 433)의 주석에는 "iOS, Android, Web"이라고 명시되어 있음

**권장 해결방안:**
```typescript
enum Platform {
  IOS: "iOS",
  ANDROID: "Android",
  WEB: "Web",
}

model DeviceInfo {
  deviceId: string;
  platform: Platform;  // enum으로 변경
  appVersion: string;
}
```

### 12. 에러 코드 정의 부족
**문제점:**
- `ApiError.errorCode`(Line 402)가 일반 `string`으로 정의됨
- 표준화된 에러 코드 enum이 없음

**권장 해결방안:**
- 일반적인 에러 코드 enum 정의 고려

---

## 📋 요약

### 사용자 의견 (Line 128-129) 검토
✅ **최초가입일 누락**: 정확한 지적 - `User` 모델에 `createdAt` 추가 필요
✅ **SocialAccount에 password 포함 문제**: 정확한 지적 - EMAIL 인증을 SocialAccount에 포함하는 것은 설계상 문제
⚠️ **expiresIn**: 현재 설계가 적절함 - `AutoLoginResult`에서 실패시에는 의미 없으므로 선택적이 맞음

### 우선순위별 권장 수정 사항

**높음:**
1. `User` 모델에 `createdAt` 필드 추가
2. `SocialAccount` 모델 재설계 (EMAIL 분리 또는 모델명 변경)
3. `User.email`을 선택적 필드로 변경

**중간:**
4. `UserStatus` enum 확장
5. `DeviceInfo.platform`을 enum으로 변경
6. `AuthProvider` enum 명명 개선

**낮음:**
7. 비밀번호 필드 보안 명시 강화
8. 에러 코드 enum 정의
9. 모델 관계 정의 강화
