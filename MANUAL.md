# LoginDemo 프로젝트 매뉴얼

> 크로스플랫폼 모바일 인증 시스템 (iOS + Android + NestJS Backend)

---

## 목차

1. [프로젝트 개요](#1-프로젝트-개요)
2. [기술 스택](#2-기술-스택)
3. [프로젝트 구조](#3-프로젝트-구조)
4. [환경 설정](#4-환경-설정)
5. [iOS 프로젝트](#5-ios-프로젝트)
6. [Android 프로젝트](#6-android-프로젝트)
7. [Backend (NestJS)](#7-backend-nestjs)
8. [Database (Prisma)](#8-database-prisma)
9. [API 명세](#9-api-명세)
10. [인증 플로우](#10-인증-플로우)
11. [빌드 및 실행](#11-빌드-및-실행)
12. [테스트](#12-테스트)

---

## 1. 프로젝트 개요

**LoginDemo**는 iOS와 Android를 지원하는 크로스플랫폼 모바일 인증 시스템입니다.

### 주요 기능

| 기능 | 설명 |
|------|------|
| 이메일 회원가입/로그인 | 이메일과 비밀번호 기반 인증 |
| 소셜 로그인 | 카카오, 네이버, 애플 로그인 지원 |
| 자동 로그인 | 앱 재실행 시 토큰 기반 자동 로그인 |
| 토큰 갱신 | Refresh Token Rotation 적용 |
| 비밀번호 재설정 | 이메일 기반 비밀번호 초기화 |
| 멀티 디바이스 | 여러 기기 로그인 및 전체 로그아웃 |

### 아키텍처

모든 플랫폼에서 **Clean Architecture** + **Dependency Inversion** 패턴 적용:

```
┌─────────────────────────────────────────────┐
│  Presentation (SwiftUI / Compose)           │
├─────────────────────────────────────────────┤
│  Domain (UseCases, Entities, Protocols)     │
├─────────────────────────────────────────────┤
│  Data (Repositories, DataSources, Network)  │
└─────────────────────────────────────────────┘
```

---

## 2. 기술 스택

### iOS
| 기술 | 버전 | 용도 |
|------|------|------|
| Swift | 5.9+ | 프로그래밍 언어 |
| SwiftUI | iOS 17+ | UI 프레임워크 |
| Alamofire | 5.x | 네트워크 통신 |
| Keychain | - | 보안 토큰 저장 |
| async/await | - | 비동기 처리 |

### Android
| 기술 | 버전 | 용도 |
|------|------|------|
| Kotlin | 1.9+ | 프로그래밍 언어 |
| Jetpack Compose | - | UI 프레임워크 |
| Hilt | 2.x | 의존성 주입 |
| Retrofit | 2.x | 네트워크 통신 |
| Coroutines | - | 비동기 처리 |
| EncryptedSharedPreferences | - | 보안 토큰 저장 |

### Backend
| 기술 | 버전 | 용도 |
|------|------|------|
| NestJS | 11.x | 백엔드 프레임워크 |
| TypeScript | 5.x | 프로그래밍 언어 |
| Prisma | 6.x | ORM |
| PostgreSQL | 15+ | 데이터베이스 |
| bcrypt | - | 비밀번호 해싱 |
| Swagger | - | API 문서화 |

---

## 3. 프로젝트 구조

```
LoginDemo/
├── ios/                          # iOS 프로젝트
│   ├── LoginDemo.xcodeproj
│   └── LoginDemo/
│       ├── App/                  # 앱 진입점, DI
│       ├── Domain/               # 비즈니스 로직
│       ├── Data/                 # 데이터 레이어
│       ├── Presentation/         # UI (SwiftUI)
│       └── Core/                 # 유틸리티
│
├── android/                      # Android 프로젝트
│   └── app/src/main/java/com/dyjung/logindemo/
│       ├── di/                   # Hilt 모듈
│       ├── domain/               # 비즈니스 로직
│       ├── data/                 # 데이터 레이어
│       ├── presentation/         # UI (Compose)
│       └── core/                 # 유틸리티
│
├── typespec/backend/             # NestJS 백엔드
│   ├── src/
│   │   ├── auth/                 # 인증 모듈
│   │   ├── prisma/               # DB 서비스
│   │   ├── system/               # 시스템 API
│   │   └── common/               # 공통 유틸
│   └── prisma/
│       └── schema.prisma         # DB 스키마
│
├── shared/                       # 공유 리소스
│   ├── localization/             # 다국어 (ko, en)
│   ├── api-contracts/            # OpenAPI 스펙
│   └── assets/                   # 공유 이미지
│
├── Makefile                      # 통합 빌드 명령어
├── CLAUDE.md                     # 프로젝트 가이드
└── MANUAL.md                     # 이 매뉴얼
```

---

## 4. 환경 설정

### 4.1 필수 요구사항

```bash
# macOS (iOS 개발 필수)
Xcode 15+
iOS Simulator or Device (iOS 17+)

# Android
Android Studio Hedgehog+
JDK 17+
Android SDK (API 26+)

# Backend
Node.js 20+
PostgreSQL 15+
npm 10+
```

### 4.2 Backend 환경 설정

```bash
# 1. 프로젝트 디렉토리로 이동
cd typespec/backend

# 2. 의존성 설치
npm install

# 3. 환경 변수 설정
cp .env.example .env

# 4. .env 파일 수정
DATABASE_URL="postgresql://postgres:password@localhost:5432/logindemo"

# 5. DB 마이그레이션
npx prisma db push

# 6. Prisma Client 생성
npx prisma generate
```

### 4.3 iOS 환경 설정

```bash
# 1. 프로젝트 열기
cd ios
open LoginDemo.xcodeproj

# 2. Signing & Capabilities에서 Team 설정
# 3. Bundle Identifier 확인: com.dyjung.LoginDemo
```

### 4.4 Android 환경 설정

```bash
# 1. Android Studio에서 android/ 폴더 열기
# 2. Gradle Sync 실행
# 3. local.properties에 SDK 경로 확인
```

---

## 5. iOS 프로젝트

### 5.1 레이어 구조

#### App Layer
```swift
// LoginDemoApp.swift - 앱 진입점
@main
struct LoginDemoApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}

// DIContainer.swift - 의존성 주입 컨테이너
final class DIContainer {
    static let shared = DIContainer()

    let authRepository: AuthRepositoryProtocol
    let onboardingRepository: OnboardingRepositoryProtocol

    static func makeProduction() -> DIContainer { ... }
    static func makeTest() -> DIContainer { ... }
}
```

#### Domain Layer
```swift
// Entities
struct User {
    let id: String
    let nickname: String
    let status: UserStatus
    let createdAt: Date
}

enum AuthProvider: String {
    case kakao, naver, apple
}

// Repository Protocol
protocol AuthRepositoryProtocol {
    func login(email: String, password: String) async throws -> AuthToken
    func register(request: RegisterRequest) async throws -> AuthToken
    func socialLogin(provider: AuthProvider, token: String) async throws -> AuthToken
    func refreshToken() async throws -> AuthToken
    func logout() async throws
}

// UseCase
final class LoginUseCase {
    private let authRepository: AuthRepositoryProtocol

    func execute(email: String, password: String) async throws -> User {
        let token = try await authRepository.login(email: email, password: password)
        // Store token, return user
    }
}
```

#### Data Layer
```swift
// Repository Implementation
final class AuthRepositoryImpl: AuthRepositoryProtocol {
    private let remoteDataSource: AuthRemoteDataSource
    private let localDataSource: KeychainDataSource

    func login(email: String, password: String) async throws -> AuthToken {
        let response = try await remoteDataSource.login(email: email, password: password)
        try localDataSource.saveToken(response.token)
        return response.token
    }
}

// Network Service (Alamofire)
final class NetworkService {
    func request<T: Decodable>(_ router: AuthRouter) async throws -> T {
        try await AF.request(router)
            .validate()
            .serializingDecodable(T.self)
            .value
    }
}
```

#### Presentation Layer
```swift
// ViewModel
@Observable
final class LoginViewModel {
    var email = ""
    var password = ""
    var isLoading = false
    var errorMessage: String?

    private let loginUseCase: LoginUseCase

    func login() async {
        isLoading = true
        do {
            let user = try await loginUseCase.execute(email: email, password: password)
            // Navigate to main
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

// View
struct LoginView: View {
    @State private var viewModel = LoginViewModel()

    var body: some View {
        VStack {
            TextField("Email", text: $viewModel.email)
            SecureField("Password", text: $viewModel.password)

            PrimaryButton("Login") {
                Task { await viewModel.login() }
            }
            .disabled(viewModel.isLoading)
        }
    }
}
```

### 5.2 주요 컴포넌트

| 파일 | 역할 |
|------|------|
| `KeychainHelper.swift` | 토큰 보안 저장 |
| `AuthRouter.swift` | API 라우팅 (Alamofire) |
| `AuthInterceptor.swift` | 토큰 갱신 인터셉터 |
| `PrimaryButton.swift` | 공통 버튼 컴포넌트 |
| `Color+Theme.swift` | 앱 컬러 테마 |

---

## 6. Android 프로젝트

### 6.1 레이어 구조

#### DI Layer (Hilt)
```kotlin
// RepositoryModule.kt
@Module
@InstallIn(SingletonComponent::class)
abstract class RepositoryModule {
    @Binds
    @Singleton
    abstract fun bindAuthRepository(
        impl: AuthRepositoryImpl
    ): AuthRepository
}
```

#### Domain Layer
```kotlin
// Entities
data class User(
    val id: String,
    val nickname: String,
    val status: UserStatus,
    val createdAt: Date
)

enum class AuthProvider { KAKAO, NAVER, APPLE }

// Repository Interface
interface AuthRepository {
    suspend fun login(email: String, password: String): AuthToken
    suspend fun register(request: RegisterRequest): AuthToken
    suspend fun socialLogin(provider: AuthProvider, token: String): AuthToken
    suspend fun refreshToken(): AuthToken
    suspend fun logout()
}

// UseCase
class LoginUseCase @Inject constructor(
    private val authRepository: AuthRepository
) {
    suspend operator fun invoke(email: String, password: String): User {
        val token = authRepository.login(email, password)
        // Store token, return user
    }
}
```

#### Data Layer
```kotlin
// Repository Implementation
class AuthRepositoryImpl @Inject constructor(
    private val authApi: AuthApi,
    private val secureStorage: SecureStorage
) : AuthRepository {

    override suspend fun login(email: String, password: String): AuthToken {
        val response = authApi.login(LoginRequest(email, password))
        secureStorage.saveToken(response.token)
        return response.token
    }
}

// Retrofit API
interface AuthApi {
    @POST("v1/auth/login")
    suspend fun login(@Body request: LoginRequest): LoginResponse

    @POST("v1/auth/register")
    suspend fun register(@Body request: RegisterRequest): RegisterResponse
}
```

#### Presentation Layer
```kotlin
// ViewModel
@HiltViewModel
class LoginViewModel @Inject constructor(
    private val loginUseCase: LoginUseCase
) : ViewModel() {

    private val _uiState = MutableStateFlow(LoginUiState())
    val uiState: StateFlow<LoginUiState> = _uiState.asStateFlow()

    fun login(email: String, password: String) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            try {
                val user = loginUseCase(email, password)
                _uiState.update { it.copy(isLoading = false, user = user) }
            } catch (e: Exception) {
                _uiState.update { it.copy(isLoading = false, error = e.message) }
            }
        }
    }
}

// Compose Screen
@Composable
fun LoginScreen(
    viewModel: LoginViewModel = hiltViewModel(),
    onLoginSuccess: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsState()

    Column {
        TextField(
            value = uiState.email,
            onValueChange = { viewModel.updateEmail(it) }
        )

        PrimaryButton(
            text = "Login",
            onClick = { viewModel.login() },
            isLoading = uiState.isLoading
        )
    }
}
```

### 6.2 주요 컴포넌트

| 파일 | 역할 |
|------|------|
| `SecureStorage.kt` | EncryptedSharedPreferences |
| `AuthApi.kt` | Retrofit API 정의 |
| `AuthInterceptor.kt` | OkHttp 토큰 인터셉터 |
| `PrimaryButton.kt` | 공통 버튼 컴포넌트 |
| `Theme.kt` | Material3 테마 |

---

## 7. Backend (NestJS)

### 7.1 모듈 구조

```
src/
├── main.ts                 # 앱 부트스트랩
├── app.module.ts           # 루트 모듈
├── auth/
│   ├── auth.module.ts      # Auth 모듈 정의
│   ├── auth.controller.ts  # API 엔드포인트
│   └── auth.service.ts     # 비즈니스 로직
├── prisma/
│   ├── prisma.module.ts    # 전역 DB 모듈
│   └── prisma.service.ts   # Prisma 클라이언트
├── system/
│   └── system.controller.ts
└── common/
    ├── dto.ts              # 모든 DTO
    ├── enums.ts            # 열거형
    ├── models.ts           # 모델 정의
    └── utils/
        └── password.util.ts
```

### 7.2 주요 서비스 코드

```typescript
// auth.service.ts
@Injectable()
export class AuthService {
    constructor(private readonly prisma: PrismaService) {}

    // 회원가입
    async register(request: RegisterRequest): Promise<RegisterResponse> {
        // 1. 이메일 중복 체크
        const existing = await this.prisma.user.findUnique({
            where: { email: request.email }
        });
        if (existing) throw new ConflictException('Email already exists');

        // 2. 비밀번호 해싱
        const passwordHash = await hashPassword(request.password);

        // 3. User + AuthenticationAccount 생성
        const user = await this.prisma.user.create({
            data: {
                email: request.email,
                nickname: request.nickname,
                authenticationAccounts: {
                    create: {
                        method: 'EMAIL',
                        passwordHash
                    }
                }
            }
        });

        // 4. 토큰 생성 및 저장
        const { accessToken, refreshToken } = await this.createTokensForUser(user.id);

        return { user, accessToken, refreshToken, expiresIn: 3600 };
    }

    // 로그인
    async login(request: LoginRequest): Promise<LoginResponse> {
        // 1. 사용자 조회
        const user = await this.prisma.user.findUnique({
            where: { email: request.email },
            include: { authenticationAccounts: true }
        });
        if (!user) throw new UnauthorizedException('Invalid email or password');

        // 2. 비밀번호 검증
        const account = user.authenticationAccounts.find(a => a.method === 'EMAIL');
        const isValid = await verifyPassword(request.password, account.passwordHash);
        if (!isValid) throw new UnauthorizedException('Invalid email or password');

        // 3. 토큰 생성
        const { accessToken, refreshToken } = await this.createTokensForUser(user.id);

        return { user, accessToken, refreshToken, expiresIn: 3600 };
    }

    // 토큰 갱신 (Rotation)
    async refresh(request: TokenRefreshRequest): Promise<TokenRefreshResponse> {
        const tokenHash = this.hashToken(request.refreshToken);

        // 1. 토큰 조회
        const storedToken = await this.prisma.refreshToken.findUnique({
            where: { tokenHash },
            include: { user: true }
        });
        if (!storedToken || storedToken.isRevoked) {
            throw new UnauthorizedException('Invalid refresh token');
        }

        // 2. 기존 토큰 무효화
        await this.prisma.refreshToken.update({
            where: { id: storedToken.id },
            data: { isRevoked: true, revokedReason: 'Token rotated' }
        });

        // 3. 새 토큰 생성
        return this.createTokensForUser(storedToken.userId);
    }
}
```

### 7.3 미들웨어 설정

```typescript
// main.ts
async function bootstrap() {
    const app = await NestFactory.create(AppModule);

    // 유효성 검사 파이프
    app.useGlobalPipes(new ValidationPipe({
        whitelist: true,
        transform: true
    }));

    // Swagger 설정
    const config = new DocumentBuilder()
        .setTitle('LoginDemo API')
        .setVersion('1.0')
        .addBearerAuth()
        .build();
    const document = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup('api-docs', app, document);

    await app.listen(3000);
}
```

---

## 8. Database (Prisma)

### 8.1 스키마 정의

```prisma
// prisma/schema.prisma

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// 열거형
enum AuthenticationMethod {
  EMAIL
  KAKAO
  NAVER
  APPLE
  GOOGLE
}

enum UserStatus {
  ACTIVE
  SLEEP
  SUSPENDED
  DELETED
}

enum Platform {
  IOS     @map("iOS")
  ANDROID @map("Android")
  WEB     @map("Web")
}

// 사용자
model User {
  id               String   @id @default(uuid())
  email            String?  @unique
  nickname         String
  status           UserStatus @default(ACTIVE)
  marketingConsent Boolean @default(false)
  createdAt        DateTime @default(now())
  lastLogin        DateTime?
  updatedAt        DateTime @updatedAt

  authenticationAccounts AuthenticationAccount[]
  refreshTokens          RefreshToken[]
  devices                Device[]
  passwordResetTokens    PasswordResetToken[]

  @@map("users")
}

// 인증 계정 (이메일 + 소셜)
model AuthenticationAccount {
  id           String   @id @default(uuid())
  method       AuthenticationMethod
  providerId   String?  // 소셜 로그인 시 외부 ID
  passwordHash String?  // 이메일 로그인 시 bcrypt 해시
  userId       String
  createdAt    DateTime @default(now())
  updatedAt    DateTime @updatedAt

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@unique([method, providerId])
  @@unique([userId, method])
  @@index([userId])
  @@map("authentication_accounts")
}

// 리프레시 토큰
model RefreshToken {
  id            String   @id @default(uuid())
  tokenHash     String   @unique  // SHA-256 해시
  userId        String
  deviceId      String?
  expiresAt     DateTime
  usageCount    Int      @default(0)
  maxUsageCount Int?
  isRevoked     Boolean  @default(false)
  revokedReason String?
  revokedAt     DateTime?
  createdAt     DateTime @default(now())
  lastUsedAt    DateTime?

  user   User    @relation(fields: [userId], references: [id], onDelete: Cascade)
  device Device? @relation(fields: [deviceId], references: [id], onDelete: SetNull)

  @@index([userId])
  @@index([expiresAt])
  @@index([isRevoked])
  @@map("refresh_tokens")
}

// 디바이스
model Device {
  id           String   @id @default(uuid())
  deviceId     String
  userId       String
  platform     Platform
  appVersion   String
  pushToken    String?
  lastActiveAt DateTime @default(now())
  createdAt    DateTime @default(now())
  updatedAt    DateTime @updatedAt

  user          User           @relation(fields: [userId], references: [id], onDelete: Cascade)
  refreshTokens RefreshToken[]

  @@unique([userId, deviceId])
  @@index([userId])
  @@map("devices")
}

// 비밀번호 재설정 토큰
model PasswordResetToken {
  id        String   @id @default(uuid())
  tokenHash String   @unique
  userId    String
  expiresAt DateTime
  isUsed    Boolean  @default(false)
  usedAt    DateTime?
  createdAt DateTime @default(now())

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@index([userId])
  @@index([expiresAt])
  @@map("password_reset_tokens")
}

// 앱 설정
model AppConfig {
  id              String  @id @default(uuid())
  configKey       String  @unique
  minVersion      String
  maintenanceMode Boolean @default(false)
  noticeMessage   String?
  createdAt       DateTime @default(now())
  updatedAt       DateTime @updatedAt

  @@map("app_configs")
}
```

### 8.2 Prisma 명령어

```bash
# 스키마를 DB에 적용
npx prisma db push

# 마이그레이션 생성
npx prisma migrate dev --name init

# Prisma Client 재생성
npx prisma generate

# DB GUI 실행
npx prisma studio

# DB 시드 실행
npx prisma db seed
```

---

## 9. API 명세

### 9.1 인증 API

| Method | Endpoint | 설명 |
|--------|----------|------|
| POST | `/v1/auth/register` | 회원가입 |
| POST | `/v1/auth/login` | 로그인 |
| POST | `/v1/auth/refresh` | 토큰 갱신 |
| GET | `/v1/auth/verify` | 토큰 검증 |
| POST | `/v1/auth/logout` | 로그아웃 |
| GET | `/v1/auth/find-id` | 이메일 찾기 |
| POST | `/v1/auth/password-reset` | 비밀번호 재설정 요청 |
| PATCH | `/v1/auth/password-confirm` | 비밀번호 변경 확정 |

### 9.2 상세 API 명세

#### POST /v1/auth/register
```json
// Request
{
  "provider": "EMAIL",
  "email": "user@example.com",
  "password": "password123",
  "nickname": "홍길동",
  "marketingConsent": true
}

// Response (201)
{
  "user": {
    "id": "uuid",
    "nickname": "홍길동",
    "status": "ACTIVE",
    "createdAt": "2026-01-14T00:00:00.000Z"
  },
  "accessToken": "access_xxx",
  "refreshToken": "refresh_xxx",
  "expiresIn": 3600
}
```

#### POST /v1/auth/login
```json
// Request
{
  "provider": "EMAIL",
  "email": "user@example.com",
  "password": "password123"
}

// Response (200)
{
  "user": { ... },
  "accessToken": "access_xxx",
  "refreshToken": "refresh_xxx",
  "expiresIn": 3600
}
```

#### POST /v1/auth/refresh
```json
// Request
{
  "refreshToken": "refresh_xxx"
}

// Response (200)
{
  "accessToken": "access_new",
  "refreshToken": "refresh_new"
}
```

#### POST /v1/auth/logout
```json
// Request
{
  "refreshToken": "refresh_xxx",
  "allDevices": false  // true: 모든 기기 로그아웃
}

// Response (200)
{
  "success": true,
  "message": "Successfully logged out"
}
```

#### POST /v1/auth/password-reset
```json
// Request
{
  "email": "user@example.com"
}

// Response (200)
{
  "sent": true,
  "message": "Password reset email sent",
  "retryAfter": 60
}
```

#### PATCH /v1/auth/password-confirm
```json
// Request
{
  "token": "reset-token-uuid",
  "newPassword": "newpassword123"
}

// Response (200)
{
  "success": true,
  "message": "Password changed successfully"
}
```

### 9.3 공통 헤더

```
X-App-Version: 1.0.0      # 필수
X-Platform: iOS           # 필수 (iOS, Android, Web)
X-Device-Id: device-uuid  # 선택
Authorization: Bearer xxx  # 인증 필요 API
```

---

## 10. 인증 플로우

### 10.1 이메일 로그인

```
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
│  User   │     │   App   │     │ Backend │     │   DB    │
└────┬────┘     └────┬────┘     └────┬────┘     └────┬────┘
     │               │               │               │
     │  Enter Email  │               │               │
     │  & Password   │               │               │
     │───────────────>               │               │
     │               │  POST /login  │               │
     │               │───────────────>               │
     │               │               │  Find User    │
     │               │               │───────────────>
     │               │               │<──────────────│
     │               │               │  Verify Hash  │
     │               │               │───────────────>
     │               │               │<──────────────│
     │               │               │  Create Token │
     │               │               │───────────────>
     │               │               │<──────────────│
     │               │<──────────────│               │
     │               │  Save Token   │               │
     │               │  (Keychain)   │               │
     │<──────────────│               │               │
     │  Show Main    │               │               │
```

### 10.2 토큰 갱신 (Rotation)

```
┌─────────┐     ┌─────────┐     ┌─────────┐
│   App   │     │ Backend │     │   DB    │
└────┬────┘     └────┬────┘     └────┬────┘
     │               │               │
     │ Access Token  │               │
     │   Expired     │               │
     │───────────────│               │
     │               │               │
     │ POST /refresh │               │
     │───────────────>               │
     │               │ Find Token    │
     │               │───────────────>
     │               │<──────────────│
     │               │               │
     │               │ Revoke Old    │
     │               │───────────────>
     │               │<──────────────│
     │               │               │
     │               │ Create New    │
     │               │───────────────>
     │               │<──────────────│
     │<──────────────│               │
     │               │               │
     │ Update Token  │               │
     │ (Keychain)    │               │
```

### 10.3 비밀번호 재설정

```
1. 사용자가 "비밀번호 찾기" 요청
2. 서버가 재설정 토큰 생성 (1시간 유효)
3. 이메일로 토큰 전송 (현재는 콘솔 로그)
4. 사용자가 새 비밀번호 + 토큰으로 확정
5. 서버가 비밀번호 변경 + 모든 세션 로그아웃
```

---

## 11. 빌드 및 실행

### 11.1 Makefile 명령어

```bash
# 환경 확인
make setup

# 전체 빌드
make build

# 전체 테스트
make test

# 전체 정리
make clean

# iOS만
make ios-build
make ios-test
make ios-release

# Android만
make android-build
make android-test
make android-release
```

### 11.2 Backend 실행

```bash
cd typespec/backend

# 개발 모드 (Hot Reload)
npm run start:dev

# 프로덕션 빌드
npm run build
npm run start:prod

# 서버 확인
curl http://localhost:3000/api-docs
```

### 11.3 iOS 실행

```bash
# Xcode에서 실행
cd ios
open LoginDemo.xcodeproj
# Cmd + R (Run)

# 또는 CLI
xcodebuild -project LoginDemo.xcodeproj \
  -scheme LoginDemo \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  build
```

### 11.4 Android 실행

```bash
cd android

# Debug APK 빌드
./gradlew assembleDebug

# 에뮬레이터에 설치
./gradlew installDebug

# Android Studio에서
# Run > Run 'app'
```

---

## 12. 테스트

### 12.1 API 테스트 (curl)

```bash
# 회원가입
curl -X POST http://localhost:3000/v1/auth/register \
  -H "Content-Type: application/json" \
  -H "X-App-Version: 1.0.0" \
  -H "X-Platform: iOS" \
  -d '{
    "provider": "EMAIL",
    "email": "test@example.com",
    "password": "password123",
    "nickname": "테스트"
  }'

# 로그인
curl -X POST http://localhost:3000/v1/auth/login \
  -H "Content-Type: application/json" \
  -H "X-App-Version: 1.0.0" \
  -H "X-Platform: iOS" \
  -d '{
    "provider": "EMAIL",
    "email": "test@example.com",
    "password": "password123"
  }'

# 토큰 갱신
curl -X POST http://localhost:3000/v1/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{"refreshToken": "refresh_xxx"}'

# 토큰 검증
curl -X GET http://localhost:3000/v1/auth/verify \
  -H "Authorization: Bearer access_xxx" \
  -H "X-App-Version: 1.0.0" \
  -H "X-Platform: iOS"

# 로그아웃
curl -X POST http://localhost:3000/v1/auth/logout \
  -H "Content-Type: application/json" \
  -d '{"refreshToken": "refresh_xxx"}'

# 비밀번호 재설정 요청
curl -X POST http://localhost:3000/v1/auth/password-reset \
  -H "Content-Type: application/json" \
  -H "X-App-Version: 1.0.0" \
  -H "X-Platform: iOS" \
  -d '{"email": "test@example.com"}'

# 비밀번호 변경 확정
curl -X PATCH http://localhost:3000/v1/auth/password-confirm \
  -H "Content-Type: application/json" \
  -H "X-App-Version: 1.0.0" \
  -H "X-Platform: iOS" \
  -d '{
    "token": "reset-token-uuid",
    "newPassword": "newpassword123"
  }'
```

### 12.2 DB 확인

```bash
# Prisma Studio
cd typespec/backend
npx prisma studio
# http://localhost:5555 에서 DB 확인

# 직접 쿼리
npx ts-node -e "
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
prisma.user.findMany().then(console.log);
"
```

### 12.3 Swagger UI

브라우저에서 열기:
```
http://localhost:3000/api-docs
```

---

## 부록: 보안 체크리스트

| 항목 | iOS | Android | Backend |
|------|-----|---------|---------|
| 토큰 보안 저장 | Keychain | EncryptedSharedPreferences | SHA-256 해시 |
| 비밀번호 해싱 | - | - | bcrypt (salt 10) |
| Token Rotation | O | O | O |
| HTTPS Only | O | O | 설정 필요 |
| 입력값 검증 | O | O | ValidationPipe |
| 에러 메시지 보안 | O | O | O |

---

## 문의

- **Swagger 문서**: http://localhost:3000/api-docs
- **Prisma Studio**: http://localhost:5555

---

*Last Updated: 2026-01-14*
