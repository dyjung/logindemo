import "@typespec/http";
import "@typespec/openapi";

using Http;
using OpenAPI;

@service(#{
  title: "App Service API",
})
@server("https://api.example.com", "Production server")
@info(#{
  version: "1.0.0",
})
@useAuth(BearerAuth)
namespace AppService;

/** Bearer 토큰 인증 */
model BearerAuth is Http.BearerAuth;

// ============================================
// Header Models
// ============================================

/** 공통 클라이언트 헤더 */
model CommonClientHeaders {
  /** 현재 앱 버전 (예: 1.0.0) */
  @header("X-App-Version")
  @pattern("^\\d+\\.\\d+\\.\\d+$")
  appVersion: string;

  /** 플랫폼 */
  @header("X-Platform")
  platform: Platform;

  /** 디바이스 ID (선택) */
  @header("X-Device-Id")
  deviceId?: string;

  /** 요청 고유 식별자 (추적용) */
  @header("X-Request-Id")
  @doc("클라이언트에서 생성한 UUID 또는 서버에서 응답 시 전달하는 요청 ID")
  requestId?: string;
}

/** 인증이 필요한 요청용 헤더 (공통 클라이언트 헤더 포함) */
model AuthorizedHeaders {
  ...CommonClientHeaders;

  /** 액세스 토큰 (Bearer 토큰 형식) */
  @header("Authorization")
  authorization: string;
}

// ============================================
// Enums
// ============================================

/** 인증 방법 */
@doc("소셜 로그인 및 이메일 인증 방법")
enum AuthenticationMethod {
  EMAIL: "EMAIL",
  KAKAO: "KAKAO",
  NAVER: "NAVER",
  APPLE: "APPLE",
  GOOGLE: "GOOGLE",
}

/** 사용자 상태 */
@doc("사용자 계정 상태")
enum UserStatus {
  ACTIVE: "ACTIVE",
  SLEEP: "SLEEP",
  SUSPENDED: "SUSPENDED",
  DELETED: "DELETED",
}

/** 플랫폼 타입 */
@doc("앱 실행 플랫폼")
enum Platform {
  IOS: "iOS",
  ANDROID: "Android",
  WEB: "Web",
}

// ============================================
// Data Models
// ============================================

/** 사용자 정보 */
@doc("통합 사용자 정보 모델")
model User {
  /** 사용자 고유 ID */
  id: string;

  /** 이메일 주소 (소셜 계정만 있는 경우 없을 수 있음) */
  @format("email")
  email?: string;

  /** 닉네임 */
  nickname: string;

  /** 계정 상태 */
  status: UserStatus;

  /** 최초 가입일 */
  createdAt: utcDateTime;

  /** 마지막 로그인 시간 */
  lastLogin?: utcDateTime;

  /** 마지막 업데이트 시간 */
  updatedAt?: utcDateTime;
}

/** 인증 계정 매핑 */
@doc("인증 수단과 사용자를 연결하는 모델 (EMAIL 및 소셜 계정 통합)")
model AuthenticationAccount {
  /** 인증 방법 */
  method: AuthenticationMethod;

  /** 제공자별 고유 ID (소셜: 외부 제공자의 사용자 ID, EMAIL: 미사용) */
  providerId?: string;

  /** 비밀번호 해시 값 (bcrypt/argon2 등 암호학적 해시 알고리즘으로 해시된 값, EMAIL 인증시에만 사용) 
   *  ⚠️ 주의: 이 필드는 해시된 값만 저장하며, 평문 비밀번호는 절대 저장하지 않음
   *  생성/업데이트 시에만 포함되며, API 응답에서는 절대 노출되지 않음 */
  @visibility(Lifecycle.Create, Lifecycle.Update)
  passwordHash?: string;

  /** 연결된 사용자 ID (FK) */
  userId: string;
}

/** 앱 설정 */
@doc("앱 시스템 설정 정보")
model AppConfig {
  /** 최소 지원 버전 */
  minVersion: string;

  /** 점검 모드 여부 */
  maintenanceMode: boolean;

  /** 공지 메시지 */
  noticeMessage?: string;
}

// ============================================
// Request/Response Models
// ============================================

/** 초기화 응답 */
@doc("앱 초기화 응답. X-Refresh-Token 헤더가 제공된 경우에만 autoLogin 필드가 포함됨.")
model InitResponse {
  /** 앱 설정 정보 */
  config: AppConfig;

  /** 강제 업데이트 필요 여부 */
  forceUpdate: boolean;

  /** 서비스 점검 중 여부 */
  isMaintenance: boolean;

  /** 사용자 컨텍스트 (접속 국가/통화/언어 정보) */
  userContext: UserContext;

  /** 자동 로그인 결과 (X-Refresh-Token 헤더가 제공된 경우에만 포함, 없으면 null) */
  autoLogin?: AutoLoginResult;
}

/** 자동 로그인 결과 */
@doc("자동 로그인 결과. 앱 재시작 시 저장된 리프레시 토큰으로 세션 복구를 시도한 결과. success=true일 때만 user, accessToken, refreshToken, expiresIn이 포함됨. success=false일 때는 failureReason이 포함되며, 이 경우 사용자는 재로그인(/v1/auth/login)이 필요함.")
model AutoLoginResult {
  /** 자동 로그인 성공 여부 */
  success: boolean;

  /** 사용자 정보 (success=true일 때만 포함) */
  user?: User;

  /** 새로 발급된 액세스 토큰 (success=true일 때만 포함) */
  accessToken?: string;

  /** 리프레시 토큰 (success=true일 때만 포함, 토큰 Rotation 적용시 새 토큰, 미적용시 null) */
  refreshToken?: string;

  /** 실패 사유 코드 (success=false일 때만 포함) 
   *  - TOKEN_EXPIRED: 리프레시 토큰이 시간 기반 만료 (예: 30일 경과)
   *  - TOKEN_INVALID: 리프레시 토큰이 무효화/취소되었거나 사용 횟수 초과
   *  - 기타 계정 상태 관련 실패 사유
   *  모든 경우 재로그인(/v1/auth/login) 필요 */
  failureReason?: AutoLoginFailureReason;
}

/** 자동 로그인 실패 사유 */
enum AutoLoginFailureReason {
  /** 토큰 없음 */
  NO_TOKEN: "NO_TOKEN",
  /** 토큰 만료 */
  TOKEN_EXPIRED: "TOKEN_EXPIRED",
  /** 토큰 무효 */
  TOKEN_INVALID: "TOKEN_INVALID",
  /** 계정 휴면 상태 */
  ACCOUNT_SLEEP: "ACCOUNT_SLEEP",
  /** 계정 정지 상태 */
  ACCOUNT_SUSPENDED: "ACCOUNT_SUSPENDED",
  /** 계정 삭제됨 */
  ACCOUNT_DELETED: "ACCOUNT_DELETED",
}

/** 사용자 컨텍스트 */
model UserContext {
  /** 접속 국가 코드 (ISO 3166-1 alpha-2) */
  country: string;

  /** 통화 코드 (ISO 4217) */
  currency: string;

  /** 언어 코드 (ISO 639-1) */
  language: string;

  /** 최근 위치 정보 */
  location?: GeoLocation;
}

/** 위치 정보 */
model GeoLocation {
  /** 위도 */
  latitude: float64;

  /** 경도 */
  longitude: float64;
}

/** 디바이스 정보 */
model DeviceInfo {
  /** 디바이스 ID */
  deviceId: string;

  /** 플랫폼 */
  platform: Platform;

  /** 앱 버전 */
  appVersion: string;
}

// --------------------------------------------
// 로그인 관련 모델
// --------------------------------------------

/** 통합 로그인 요청 */
@doc("method에 따라 필수 필드가 달라집니다. EMAIL: email+password 필수, 소셜: socialAccessToken 필수")
model LoginRequest {
  /** 인증 방법 */
  provider: AuthenticationMethod;

  /** 이메일 (EMAIL 로그인시 필수) */
  @format("email")
  email?: string;

  /** 평문 비밀번호 (EMAIL 로그인시 필수, 클라이언트에서 전송되는 평문 값, 서버에서 해시값과 비교하여 인증) */
  password?: string;

  /** 소셜 액세스 토큰 (KAKAO/NAVER/APPLE/GOOGLE 로그인시 필수) */
  socialAccessToken?: string;

  /** 디바이스 정보 */
  deviceInfo?: DeviceInfo;
}

/** 로그인 응답 */
model LoginResponse {
  /** 사용자 정보 */
  user: User;

  /** 액세스 토큰 */
  accessToken: string;

  /** 리프레시 토큰 */
  refreshToken: string;

  /** 액세스 토큰 만료 시간 (초) */
  expiresIn: int32;
}

// --------------------------------------------
// 토큰 관련 모델
// --------------------------------------------

/** 토큰 갱신 요청 */
@doc("액세스 토큰이 만료되었을 때 리프레시 토큰으로 새 액세스 토큰 발급. 리프레시 토큰이 만료/무효화된 경우 실패.")
model TokenRefreshRequest {
  /** 리프레시 토큰 (최초 로그인/회원가입 시 발급받은 토큰) */
  refreshToken: string;

  /** 디바이스 정보 */
  deviceInfo?: DeviceInfo;
}

/** 토큰 갱신 응답 */
@doc("토큰 갱신 성공 응답. 리프레시 토큰이 만료/무효화/취소된 경우 401 에러 반환 (재로그인 필요)")
model TokenRefreshResponse {
  /** 새 액세스 토큰 */
  accessToken: string;

  /** 새 리프레시 토큰 (토큰 Rotation 적용시 새 토큰 발급, 미적용시 null) */
  refreshToken?: string;
}

/** 토큰 검증 응답 */
model TokenVerifyResponse {
  /** 유효 여부 */
  valid: boolean;

  /** 사용자 정보 (유효시) */
  user?: User;
}

/** 로그아웃 요청 */
model LogoutRequest {
  /** 리프레시 토큰 (서버에서 무효화) */
  refreshToken?: string;

  /** 모든 디바이스 로그아웃 여부 */
  allDevices?: boolean;
}

/** 로그아웃 응답 */
model LogoutResponse {
  /** 성공 여부 */
  success: boolean;

  /** 메시지 */
  message: string;
}

// --------------------------------------------
// 회원가입 관련 모델
// --------------------------------------------

/** 통합 회원가입 요청 */
@doc("method에 따라 필수 필드가 달라집니다. EMAIL: email+password+nickname 필수, 소셜: socialAccessToken+nickname 필수")
model RegisterRequest {
  /** 인증 방법 */
  provider: AuthenticationMethod;

  /** 이메일 (EMAIL 가입시 필수, 소셜은 선택) */
  @format("email")
  email?: string;

  /** 평문 비밀번호 (EMAIL 가입시 필수, 클라이언트에서 전송되는 평문 값, 서버에서 수신 후 즉시 해시화하여 저장) */
  @minLength(8)
  @maxLength(100)
  password?: string;

  /** 닉네임 */
  @minLength(2)
  @maxLength(20)
  nickname: string;

  /** 소셜 액세스 토큰 (소셜 가입시 필수) */
  socialAccessToken?: string;

  /** 마케팅 수신 동의 */
  marketingConsent?: boolean;

  /** 디바이스 정보 */
  deviceInfo?: DeviceInfo;
}

/** 회원가입 응답 */
model RegisterResponse {
  /** 생성된 사용자 정보 */
  user: User;

  /** 액세스 토큰 */
  accessToken: string;

  /** 리프레시 토큰 */
  refreshToken: string;

  /** 액세스 토큰 만료 시간 (초) */
  expiresIn: int32;
}

// --------------------------------------------
// 아이디/비밀번호 찾기 관련 모델
// --------------------------------------------

/** 이메일 찾기 요청 쿼리 */
model FindIdQuery {
  /** 인증 제공자 (소셜만 가능) */
  @query provider: "KAKAO" | "NAVER" | "APPLE" | "GOOGLE";

  /** 소셜 액세스 토큰 */
  @query socialAccessToken: string;
}

/** 이메일 찾기 응답 */
model FindIdResponse {
  /** 마스킹된 이메일 (예: te***@example.com) */
  maskedEmail: string;

  /** 최초 가입일 (User.createdAt과 동일) */
  createdAt: utcDateTime;

  /** 연결된 인증 방법 목록 */
  linkedMethods: AuthenticationMethod[];
}

/** 비밀번호 재설정 요청 */
model PasswordResetRequest {
  /** 이메일 */
  @format("email")
  email: string;
}

/** 비밀번호 재설정 응답 */
model PasswordResetResponse {
  /** 재설정 메일 발송 여부 */
  sent: boolean;

  /** 메시지 */
  message: string;

  /** 재요청 가능 시간 (초) */
  retryAfter?: int32;
}

/** 비밀번호 변경 확정 요청 */
model PasswordConfirmRequest {
  /** 재설정 토큰 */
  token: string;

  /** 새 평문 비밀번호 (클라이언트에서 전송되는 평문 값, 서버에서 수신 후 즉시 해시화하여 저장) */
  @minLength(8)
  @maxLength(100)
  newPassword: string;
}

/** 비밀번호 변경 확정 응답 */
model PasswordConfirmResponse {
  /** 변경 성공 여부 */
  success: boolean;

  /** 메시지 */
  message: string;
}

// ============================================
// Error Model
// ============================================

/** API 에러 응답 */
@error
model ApiError {
  /** HTTP 상태 코드 */
  statusCode: int32;

  /** 에러 코드 */
  errorCode: string;

  /** 에러 메시지 */
  message: string;

  /** 상세 정보 */
  details?: Record<string>;
}

// ============================================
// API Routes
// ============================================

/** 시스템 초기화 API */
@route("/v1/init")
@tag("System")
interface SystemInit {
  /**
   * 앱 초기화 및 부트스트랩
   * 
   * 처리 순서:
   * 1. Version Check: 앱 버전과 서버 min_version 비교 (강제 업데이트 처리)
   * 2. Service Status: is_maintenance 플래그 확인하여 점검 페이지 유도
   * 3. User Context: 접속 국가 기반 통화, 언어, 최근 위치 정보 응답
   * 4. Auto Login (X-Refresh-Token 헤더가 있는 경우):
   *    - 리프레시 토큰 유효성 검증 (만료 시간, 사용 횟수, 무효화 여부 확인)
   *    - 유효한 경우: 새 액세스 토큰/리프레시 토큰 발급, 사용자 정보 반환 (autoLogin.success=true)
   *    - 무효한 경우: 실패 사유 반환 (autoLogin.success=false, failureReason 포함)
   *    - 토큰이 없는 경우: autoLogin 필드 자체가 null (로그인 필요)
   * 
   * ⚠️ 리프레시 토큰 만료 정책:
   * - 리프레시 토큰은 시간 기반 만료가 있으며 (예: 30일), 만료 시 TOKEN_EXPIRED 반환
   * - 리프레시 토큰은 사용 횟수 제한이 있을 수 있으며, 초과 시 TOKEN_INVALID 반환
   * - 리프레시 토큰이 서버에서 무효화/취소된 경우 TOKEN_INVALID 반환
   * - 모든 경우 실패 시 사용자는 재로그인(EMAIL/소셜)이 필요함
   * 
   * AutoLogin 성공시:
   * - autoLogin.user: 사용자 정보
   * - autoLogin.accessToken: 새로 발급된 액세스 토큰
   * - autoLogin.refreshToken: 새로 발급된 리프레시 토큰 (토큰 Rotation 적용시, 미적용시 null)
   * 
   * AutoLogin 실패시:
   * - autoLogin.success: false
   * - autoLogin.failureReason: 실패 사유 코드 (TOKEN_EXPIRED, TOKEN_INVALID 등)
   * - 사용자는 재로그인(/v1/auth/login) 필요
   */
  @get
  @summary("앱 초기화 및 부트스트랩")
  initialize(
    ...CommonClientHeaders,

    /** 리프레시 토큰 (자동 로그인용, 있을 경우 토큰 검증 후 세션 복구) */
    @header("X-Refresh-Token") refreshToken?: string,
  ): InitResponse | ApiError;
}

/** 통합 인증 API */
@route("/v1/auth")
@tag("Auth")
interface Auth {
  /**
   * 통합 로그인
   * - EMAIL: 이메일(필수) + 비밀번호(필수) 인증
   * - KAKAO/NAVER/APPLE/GOOGLE: 소셜 액세스 토큰(필수) 인증
   * - 성공시 액세스 토큰, 리프레시 토큰, 사용자 정보 반환
   */
  @route("/login")
  @post
  @summary("통합 로그인")
  login(
    ...CommonClientHeaders,
    @body body: LoginRequest,
  ): LoginResponse | ApiError;

  /**
   * 토큰 갱신 (액세스 토큰 만료 시)
   * - 액세스 토큰이 만료되었을 때 리프레시 토큰으로 새 액세스 토큰 발급
   * - 리프레시 토큰 Rotation 적용 가능 (새 리프레시 토큰 반환)
   * - ⚠️ 리프레시 토큰이 만료/무효화/취소된 경우 401 에러 반환 (재로그인 필요)
   * - /v1/init의 AutoLogin과 동일한 토큰 갱신 로직 사용
   * 
   * 사용 시나리오:
   * 1. 일반 API 호출 중 액세스 토큰 만료 (401 에러) → 이 엔드포인트로 토큰 갱신
   * 2. 앱 시작 시 자동 로그인 → /v1/init 엔드포인트 사용 권장
   */
  @route("/refresh")
  @post
  @summary("토큰 갱신")
  refresh(
    ...CommonClientHeaders,
    @body body: TokenRefreshRequest,
  ): TokenRefreshResponse | ApiError;

  /**
   * 토큰 검증
   * - 액세스 토큰 유효성 확인
   * - 유효시 사용자 정보 반환
   */
  @route("/verify")
  @get
  @summary("토큰 검증")
  verify(
    ...AuthorizedHeaders,
  ): TokenVerifyResponse | ApiError;

  /**
   * 로그아웃
   * - 리프레시 토큰 무효화
   * - 전체 디바이스 로그아웃 옵션
   */
  @route("/logout")
  @post
  @summary("로그아웃")
  logout(
    ...AuthorizedHeaders,
    @body body: LogoutRequest,
  ): LogoutResponse | ApiError;

  /**
   * 통합 회원가입
   * - EMAIL: 이메일 + 비밀번호 + 닉네임 필수
   * - KAKAO/NAVER/APPLE/GOOGLE: 소셜 토큰 + 닉네임 필수
   * - 모든 계정은 단일 User ID로 통합
   */
  @route("/register")
  @post
  @summary("통합 회원가입")
  register(
    ...CommonClientHeaders,
    @body body: RegisterRequest,
  ): {
    @statusCode statusCode: 201;
    @body body: RegisterResponse;
  } | ApiError;

  /**
   * 이메일 찾기
   * - 소셜 계정으로 연결된 이메일 조회
   * - 마스킹된 이메일 반환
   */
  @route("/find-id")
  @get
  @summary("이메일(아이디) 찾기")
  findId(
    ...CommonClientHeaders,
    ...FindIdQuery
  ): FindIdResponse | ApiError;

  /**
   * 비밀번호 재설정 요청
   * - 재설정 링크가 포함된 이메일 발송
   * - EMAIL 인증 사용자만 해당
   */
  @route("/password-reset")
  @post
  @summary("비밀번호 재설정 요청")
  passwordReset(
    ...CommonClientHeaders,
    @body body: PasswordResetRequest,
  ): PasswordResetResponse | ApiError;

  /**
   * 비밀번호 변경 확정
   * - 재설정 토큰 검증 후 비밀번호 변경
   */
  @route("/password-confirm")
  @patch(#{implicitOptionality: false})
  @summary("비밀번호 변경 확정")
  passwordConfirm(
    ...CommonClientHeaders,
    @body body: PasswordConfirmRequest,
  ): PasswordConfirmResponse | ApiError;
}
