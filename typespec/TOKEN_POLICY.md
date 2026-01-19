# 토큰 정책 및 자동 로그인 메커니즘

## 🔐 토큰의 역할 구분

### AccessToken (액세스 토큰)
- **용도**: API 호출 시 인증
- **수명**: 짧음 (예: 1시간, 15분)
- **만료 처리**: `/v1/auth/refresh` 엔드포인트로 새 토큰 발급

### RefreshToken (리프레시 토큰)
- **용도 1**: AccessToken 만료 시 새 AccessToken 발급 (`/v1/auth/refresh`)
- **용도 2**: 앱 재시작 시 자동 로그인 (`/v1/init` 또는 `/v1/auth/refresh`)
- **수명**: 길음 (예: 30일, 90일)
- **보안**: 안전한 저장소에 저장 (Keychain, EncryptedSharedPreferences 등)

---

## 🔄 자동 로그인 메커니즘

### 왜 RefreshToken을 사용하는가?

**기본 원리:**
1. RefreshToken은 **긴 수명**을 가지며 (예: 30일), 사용자가 재로그인 없이 장기간 사용 가능
2. 앱이 재시작되어도 저장된 RefreshToken으로 **세션을 복구**할 수 있음
3. AccessToken만으로는 앱 재시작 시 **세션이 끊어짐** (AccessToken은 짧은 수명)

**자동 로그인 시나리오:**
```
1. 사용자가 EMAIL/소셜 로그인 성공
   ↓
2. AccessToken (1시간) + RefreshToken (30일) 발급
   ↓
3. 두 토큰을 안전한 저장소에 저장
   ↓
4. 앱 재시작 시 저장된 RefreshToken으로 /v1/init 호출
   ↓
5. 서버에서 RefreshToken 검증 후 새 AccessToken 발급 → 자동 로그인 성공
```

---

## ⚠️ RefreshToken 만료 및 제한 정책

### 1. 시간 기반 만료
- RefreshToken은 **시간 기반 만료**가 있음
- 예: 발급 후 30일 경과 시 자동 만료
- 만료 시: `TOKEN_EXPIRED` 에러 → **재로그인 필요**

### 2. 사용 횟수 제한 (선택적)
- 보안을 위해 RefreshToken 사용 횟수 제한 가능
- 예: 최대 N회 사용 후 무효화
- 초과 시: `TOKEN_INVALID` 에러 → **재로그인 필요**

### 3. 수동 무효화
- 사용자가 로그아웃 시 RefreshToken 무효화
- 비정상적인 활동 감지 시 서버에서 무효화
- 무효화 시: `TOKEN_INVALID` 에러 → **재로그인 필요**

---

## 📋 자동 로그인 실패 처리

### RefreshToken 만료/무효화 시나리오

```
1. 앱 재시작 시 저장된 RefreshToken으로 /v1/init 호출
   ↓
2. 서버에서 RefreshToken 검증
   ↓
3. 만료/무효화/취소된 경우:
   {
     "autoLogin": {
       "success": false,
       "failureReason": "TOKEN_EXPIRED" 또는 "TOKEN_INVALID"
     }
   }
   ↓
4. 클라이언트 처리:
   - 저장된 토큰 삭제
   - 로그인 화면 표시
   - 사용자가 EMAIL/소셜로 재로그인 필요
```

### 실패 사유별 처리

| 실패 사유 | 원인 | 사용자 행동 |
|----------|------|-----------|
| `NO_TOKEN` | 저장된 RefreshToken이 없음 | 로그인 화면 표시 |
| `TOKEN_EXPIRED` | RefreshToken 시간 만료 (예: 30일 경과) | 재로그인 필요 |
| `TOKEN_INVALID` | RefreshToken 무효화/취소/사용 횟수 초과 | 재로그인 필요 |
| `ACCOUNT_SLEEP` | 계정 휴면 상태 | 휴면 해제 절차 안내 |
| `ACCOUNT_SUSPENDED` | 계정 정지 상태 | 고객센터 문의 안내 |
| `ACCOUNT_DELETED` | 계정 삭제됨 | 재가입 안내 |

---

## 🔄 전체 토큰 라이프사이클

### 시나리오 1: 정상 사용 플로우

```
[최초 로그인]
EMAIL/소셜 로그인
  → AccessToken (1시간) + RefreshToken (30일) 발급
  → 두 토큰 저장

[일반 API 사용]
AccessToken으로 API 호출
  → AccessToken 유효: 정상 처리

[AccessToken 만료]
API 호출 시 401 에러
  → /v1/auth/refresh 호출 (RefreshToken 사용)
  → 새 AccessToken 발급 (RefreshToken 유지 또는 Rotation)
  → 새 AccessToken으로 재시도

[앱 재시작 - 자동 로그인]
/v1/init 호출 (RefreshToken 사용)
  → RefreshToken 유효: 새 AccessToken 발급, 자동 로그인 성공
  → RefreshToken 만료: 재로그인 필요
```

### 시나리오 2: RefreshToken 만료 플로우

```
[앱 재시작 - RefreshToken 만료]
/v1/init 호출 (저장된 RefreshToken)
  ↓
서버 검증: RefreshToken이 30일 경과로 만료
  ↓
응답: { "autoLogin": { "success": false, "failureReason": "TOKEN_EXPIRED" } }
  ↓
클라이언트 처리:
  1. 저장된 토큰 삭제
  2. 로그인 화면 표시
  3. 사용자가 EMAIL/소셜로 재로그인
```

### 시나리오 3: 사용자 로그아웃 플로우

```
[로그아웃]
/v1/auth/logout 호출
  ↓
서버에서 RefreshToken 무효화
  ↓
클라이언트에서 저장된 토큰 삭제
  ↓
다음 앱 시작 시:
  - 저장된 토큰 없음 → 로그인 화면 표시
```

---

## 💡 설계 고려사항

### 1. RefreshToken 수명 설정
- **너무 짧으면**: 사용자가 자주 재로그인해야 해서 불편
- **너무 길면**: 토큰 탈취 시 장기간 피해 가능
- **권장**: 30일 ~ 90일 (보안 요구사항에 따라 조정)

### 2. RefreshToken Rotation
- RefreshToken 사용 시마다 새 RefreshToken 발급
- **장점**: 토큰 탈취 시 피해 최소화
- **단점**: 구현 복잡도 증가, 동시 요청 시 처리 필요

### 3. 다중 디바이스 관리
- 사용자가 여러 디바이스에서 로그인 가능
- 각 디바이스별로 별도의 RefreshToken 발급
- 한 디바이스에서 로그아웃해도 다른 디바이스는 영향 없음

### 4. 보안 강화
- RefreshToken은 반드시 안전한 저장소에 저장
- HTTPS 통신 필수
- 이상 활동 감지 시 RefreshToken 무효화

---

## 🔧 클라이언트 구현 가이드

### 토큰 저장 전략

```typescript
// 안전한 저장소에 저장
await secureStorage.set('refreshToken', refreshToken);
await secureStorage.set('accessToken', accessToken);
```

### 자동 로그인 처리

```typescript
async function attemptAutoLogin() {
  const refreshToken = await secureStorage.get('refreshToken');
  
  if (!refreshToken) {
    // 토큰 없음 → 로그인 화면
    showLoginScreen();
    return;
  }
  
  try {
    const response = await fetch('/v1/init', {
      headers: {
        'X-Refresh-Token': refreshToken
      }
    });
    
    const data = await response.json();
    
    if (data.autoLogin?.success) {
      // ✅ 자동 로그인 성공
      await secureStorage.set('accessToken', data.autoLogin.accessToken);
      if (data.autoLogin.refreshToken) {
        await secureStorage.set('refreshToken', data.autoLogin.refreshToken);
      }
      setUser(data.autoLogin.user);
    } else {
      // ❌ 자동 로그인 실패 (RefreshToken 만료/무효)
      await secureStorage.delete('refreshToken');
      await secureStorage.delete('accessToken');
      showLoginScreen();
    }
  } catch (error) {
    // 네트워크 오류 등
    showLoginScreen();
  }
}
```

### AccessToken 만료 처리

```typescript
async function callAPI(endpoint: string) {
  let accessToken = await secureStorage.get('accessToken');
  
  try {
    let response = await fetch(endpoint, {
      headers: { 'Authorization': `Bearer ${accessToken}` }
    });
    
    if (response.status === 401) {
      // AccessToken 만료 → RefreshToken으로 갱신
      const refreshToken = await secureStorage.get('refreshToken');
      const refreshResponse = await fetch('/v1/auth/refresh', {
        method: 'POST',
        body: JSON.stringify({ refreshToken })
      });
      
      if (refreshResponse.ok) {
        const { accessToken: newAccessToken, refreshToken: newRefreshToken } = 
          await refreshResponse.json();
        
        await secureStorage.set('accessToken', newAccessToken);
        if (newRefreshToken) {
          await secureStorage.set('refreshToken', newRefreshToken);
        }
        
        // 원래 API 재시도
        accessToken = newAccessToken;
        response = await fetch(endpoint, {
          headers: { 'Authorization': `Bearer ${accessToken}` }
        });
      } else {
        // RefreshToken도 만료 → 재로그인 필요
        await secureStorage.delete('refreshToken');
        await secureStorage.delete('accessToken');
        showLoginScreen();
        throw new Error('Refresh token expired');
      }
    }
    
    return response;
  } catch (error) {
    // 에러 처리
    throw error;
  }
}
```

---

## 📝 결론

**RefreshToken을 자동 로그인에 사용하는 이유:**
1. **긴 수명**: 사용자가 재로그인 없이 장기간 사용 가능
2. **세션 복구**: 앱 재시작 시에도 세션 유지
3. **보안**: 짧은 수명의 AccessToken으로 최소 권한 원칙 준수

**RefreshToken 만료 시 처리:**
1. `TOKEN_EXPIRED` 또는 `TOKEN_INVALID` 에러 반환
2. 클라이언트에서 저장된 토큰 삭제
3. 사용자에게 재로그인(EMAIL/소셜) 요청
4. 재로그인 성공 시 새 RefreshToken 발급

**핵심:**
- RefreshToken도 **반드시 만료**됨 (시간 기반 또는 사용 횟수)
- 만료 시 **재로그인**이 필요하며, 이는 **정상적인 보안 절차**
- 자동 로그인은 "영원히" 지속되는 것이 아니라, **RefreshToken 수명 동안만** 유효

