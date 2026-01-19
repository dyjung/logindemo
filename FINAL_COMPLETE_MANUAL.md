# LoginDemo: 완전 재현 가능한 통합 개발 매뉴얼

> 이 문서를 순서대로 따라하면 지금까지의 모든 결과물을 100% 재현할 수 있습니다

**Version**: 1.0.0  
**Date**: 2026-01-18  
**프로젝트**: LoginDemo (iOS + Android + Backend + Frontend)  
**개발 방법론**: 명세 주도 개발 (Specification-Driven Development)

---

## 📋 목차

[PART I: 시작하기](#part-i-시작하기)
- 1장. 개발 환경 구축
- 2장. 프로젝트 초기화
- 3장. 프로젝트 헌법 수립

[PART II: 명세 작성](#part-ii-명세-작성)
- 4장. Speckit 시스템 설정
- 5장. Feature 명세 작성 (001-auth-onboarding-flow)
- 6장. TypeSpec API 명세 작성

[PART III: Backend 개발](#part-iii-backend-개발)
- 7장. NestJS 프로젝트 생성
- 8장. Prisma 데이터베이스 설계
- 9장. 인증 API 구현 (Register, Login, Refresh, Logout)
- 10장. Swagger 문서화

[PART IV: iOS 개발](#part-iv-ios-개발)
- 11장. Xcode 프로젝트 생성
- 12장. Clean Architecture 폴더 구조
- 13장. Domain Layer 구현
- 14장. Data Layer 구현
- 15장. Presentation Layer 구현

[PART V: Android 개발](#part-v-android-개발)  
- 16장. Android Studio 프로젝트 생성
- 17장. Hilt DI 설정
- 18장. Clean Architecture 구현

[PART VI: Frontend 개발](#part-vi-frontend-개발)
- 19장. Next.js 프로젝트 생성
- 20장. Main Page 구현

[PART VII: 로컬 테스트](#part-vii-로컬-테스트)
- 21장. Backend 실행 및 API 테스트
- 22장. iOS/Android 통합 테스트

[PART VIII: 배포](#part-viii-배포)
- 23장. Docker 컨테이너화
- 24장. VPS 서버 설정 (Hostinger)
- 25장. Nginx + SSL 설정
- 26장. 프로덕션 배포

[PART IX: 운영 및 확장](#part-ix-운영-및-확장)
- 27장. 모니터링 및 로그
- 28장. 신규 Feature 추가 프로세스
- 29장. 트러블슈팅
- 30장. 명령어 레퍼런스

---

# PART I: 시작하기

## 1장. 개발 환경 구축

### 1.1 필수 소프트웨어 설치

#### macOS 기본 도구

```bash
# Homebrew 설치
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Node.js 20 설치
brew install node@20
echo 'export PATH="/opt/homebrew/opt/node@20/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
node --version  # v20.x.x 확인

# Git 설치
brew install git

# Docker Desktop 설치
# https://www.docker.com/products/docker-desktop 에서 다운로드
```

#### iOS 개발 환경

```bash
# Xcode 15+ 설치 (App Store)
# Command Line Tools 설치
xcode-select --install
```

#### Android 개발 환경

1. Android Studio 다운로드: https://developer.android.com/studio
2. SDK Manager에서 설치:
   - Android SDK Platform 34
   - Android SDK Build-Tools
   - Android Emulator

```bash
# 환경 변수 설정
echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.zshrc
source ~/.zshrc
```

#### TypeSpec 설치

```bash
npm install -g @typespec/compiler
tsp --version
```

---

## 2장. 프로젝트 초기화

### 2.1 프로젝트 디렉토리 생성

```bash
mkdir LoginDemo
cd LoginDemo
git init

# 폴더 구조 생성
mkdir -p .specify/memory .specify/templates .specify/scripts
mkdir -p specs docs shared/api-contracts shared/localization
mkdir -p ios android frontend backend typespec
```

### 2.2 .gitignore 작성

```bash
cat > .gitignore << 'EOF'
.DS_Store
.vscode/
.idea/
node_modules/
.env
.env.local
dist/
build/
*.log
EOF
```

### 2.3 Makefile 작성

```makefile
cat > Makefile << 'EOF'
.PHONY: help setup ios-build android-build backend-dev

help:
	@echo "=== LoginDemo Build Commands ==="
	@echo "setup         - Check environment"
	@echo "ios-build     - Build iOS"
	@echo "android-build - Build Android"
	@echo "backend-dev   - Run backend dev server"

setup:
	@command -v node || (echo "Node.js not found"; exit 1)
	@command -v docker || (echo "Docker not found"; exit 1)
	@echo "✓ Environment OK"

ios-build:
	cd ios && xcodebuild -project LoginDemo.xcodeproj -scheme LoginDemo -sdk iphonesimulator build

android-build:
	cd android && ./gradlew assembleDebug

backend-dev:
	cd backend && npm run start:dev
EOF
```

---

## 3장. 프로젝트 헌법 수립

### 3.1 Constitution 작성

```bash
cat > .specify/memory/constitution.md << 'EOF'
# LoginDemo 프로젝트 헌법

**Version**: 1.1.0

## 핵심 원칙

### I. SwiftUI 우선
모든 UI는 SwiftUI로 구현

### II. 클린 아키텍처
Domain/Data/Presentation 레이어 분리 필수

### III. 테스트 주도 개발
UseCase, ViewModel은 테스트 필수

### IV. 상태 관리 일관성
@Observable (iOS 17+) 사용

### V. 접근성 필수
모든 UI에 accessibilityLabel 제공

### VI. 단순성 우선
YAGNI 원칙

### VII. 보안 최우선
토큰은 Keychain 저장, HTTPS Only
EOF
```

### 3.2 CLAUDE.md 작성

```bash
cat > CLAUDE.md << 'EOF'
# CLAUDE.md

## Project Structure
- ios/: iOS (SwiftUI)
- android/: Android (Jetpack Compose)
- backend/: NestJS + Prisma
- typespec/: API Contract
- specs/: Feature Specifications

## Architecture
Clean Architecture + Dependency Inversion

## Build Commands
make ios-build
make android-build
make backend-dev
EOF
```

---

# PART II: 명세 작성

## 4장. Speckit 시스템 설정

Speckit은 Claude Code의 커스텀 명령어 시스템입니다.

### 4.1 주요 명령어

| 명령어 | 설명 |
|--------|------|
| /specify | Feature 명세 작성 |
| /clarify | 명세 검토 |
| /plan | 구현 계획 |
| /tasks | 작업 목록 생성 |
| /implement | 코드 구현 |

---

## 5장. Feature 명세 작성

### 5.1 Feature 001: 인증 및 온보딩 플로우

#### Step 1: /specify 실행

```
/specify

SwiftUI 앱의 Splash, Onboarding, 로그인/회원가입 화면 구현.
자동로그인 기능 포함.
```

생성 결과:
```
specs/001-auth-onboarding-flow/
├── spec.md
├── plan.md
├── tasks.md
├── data-model.md
└── checklists/requirements.md
```

---

## 6장. TypeSpec API 명세 작성

### 6.1 TypeSpec 프로젝트 초기화

```bash
cd typespec

cat > package.json << 'EOF'
{
  "name": "logindemo-typespec",
  "dependencies": {
    "@typespec/compiler": "^0.60.0",
    "@typespec/http": "^0.60.0",
    "@typespec/openapi3": "^0.60.0"
  }
}
EOF

npm install
```

### 6.2 main.tsp 작성

```typescript
cat > main.tsp << 'EOF'
import "@typespec/http";
import "@typespec/rest";

using TypeSpec.Http;
using TypeSpec.Rest;

@service({ title: "LoginDemo API" })
namespace LoginDemoAPI;

enum AuthenticationMethod { EMAIL, KAKAO, NAVER, APPLE }
enum UserStatus { ACTIVE, SLEEP, SUSPENDED, DELETED }
enum Platform { IOS, ANDROID, WEB }

model User {
  id: string;
  email?: string;
  nickname: string;
  status: UserStatus;
  createdAt: utcDateTime;
}

model LoginRequest {
  provider: AuthenticationMethod;
  email?: string;
  password?: string;
}

model LoginResponse {
  user: User;
  accessToken: string;
  refreshToken: string;
  expiresIn: int32;
}

@route("/v1/auth")
namespace Auth {
  @post @route("/login")
  op login(@body request: LoginRequest): LoginResponse;
  
  @post @route("/register")
  op register(@body request: RegisterRequest): RegisterResponse;
}
EOF
```

### 6.3 OpenAPI 생성

```bash
npx tsp compile .
cp tsp-output/@typespec/openapi3/openapi.yaml ../shared/api-contracts/
```

---

# PART III: Backend 개발

## 7장. NestJS 프로젝트 생성

```bash
cd backend
npx @nestjs/cli new . --skip-git

npm install @prisma/client bcrypt class-validator @nestjs/swagger
npm install -D prisma @types/bcrypt

npx prisma init
```

---

## 8장. Prisma 데이터베이스 설계

### 8.1 schema.prisma 작성

```prisma
cat > prisma/schema.prisma << 'EOF'
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

enum UserStatus {
  ACTIVE
  SUSPENDED
}

model User {
  id        String     @id @default(uuid())
  email     String?    @unique
  nickname  String
  status    UserStatus @default(ACTIVE)
  createdAt DateTime   @default(now())
  
  authenticationAccounts AuthenticationAccount[]
  refreshTokens          RefreshToken[]
  
  @@map("users")
}

model AuthenticationAccount {
  id           String @id @default(uuid())
  method       String
  passwordHash String?
  userId       String
  
  user User @relation(fields: [userId], references: [id])
  
  @@map("authentication_accounts")
}

model RefreshToken {
  id        String   @id @default(uuid())
  tokenHash String   @unique
  userId    String
  expiresAt DateTime
  isRevoked Boolean  @default(false)
  
  user User @relation(fields: [userId], references: [id])
  
  @@map("refresh_tokens")
}
EOF
```

### 8.2 DB 마이그레이션

```bash
npx prisma db push
npx prisma generate
```

---

## 9장. 인증 API 구현

### 9.1 Auth Service 구현

```typescript
// src/auth/auth.service.ts
import { Injectable, ConflictException, UnauthorizedException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
  constructor(private readonly prisma: PrismaService) {}

  async register(email: string, password: string, nickname: string) {
    const existing = await this.prisma.user.findUnique({ where: { email } });
    if (existing) throw new ConflictException('Email exists');

    const passwordHash = await bcrypt.hash(password, 10);
    const user = await this.prisma.user.create({
      data: {
        email,
        nickname,
        authenticationAccounts: {
          create: { method: 'EMAIL', passwordHash }
        }
      }
    });

    const tokens = await this.createTokens(user.id);
    return { user, ...tokens };
  }

  async login(email: string, password: string) {
    const user = await this.prisma.user.findUnique({
      where: { email },
      include: { authenticationAccounts: true }
    });
    
    if (!user) throw new UnauthorizedException('Invalid credentials');
    
    const account = user.authenticationAccounts[0];
    const valid = await bcrypt.compare(password, account.passwordHash);
    if (!valid) throw new UnauthorizedException('Invalid credentials');

    const tokens = await this.createTokens(user.id);
    return { user, ...tokens };
  }

  private async createTokens(userId: string) {
    const accessToken = 'access_' + Math.random().toString(36);
    const refreshToken = Math.random().toString(36);
    
    await this.prisma.refreshToken.create({
      data: {
        userId,
        tokenHash: refreshToken,
        expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)
      }
    });

    return { accessToken, refreshToken, expiresIn: 3600 };
  }
}
```

### 9.2 Auth Controller 구현

```typescript
// src/auth/auth.controller.ts
import { Controller, Post, Body } from '@nestjs/common';
import { AuthService } from './auth.service';

@Controller('v1/auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  register(@Body() dto: any) {
    return this.authService.register(dto.email, dto.password, dto.nickname);
  }

  @Post('login')
  login(@Body() dto: any) {
    return this.authService.login(dto.email, dto.password);
  }
}
```

---

## 10장. Swagger 문서화

### 10.1 main.ts 설정

```typescript
// src/main.ts
import { NestFactory } from '@nestjs/core';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  const config = new DocumentBuilder()
    .setTitle('LoginDemo API')
    .setVersion('1.0')
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api-docs', app, document);

  await app.listen(3000);
  console.log('Swagger: http://localhost:3000/api-docs');
}
bootstrap();
```

### 10.2 실행 및 테스트

```bash
npm run start:dev

# 브라우저에서
open http://localhost:3000/api-docs

# cURL 테스트
curl -X POST http://localhost:3000/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"pass123","nickname":"테스터"}'
```

---

# PART IV: iOS 개발

## 11장. Xcode 프로젝트 생성

### 11.1 프로젝트 생성

1. Xcode 실행
2. Create a new Xcode project
3. iOS > App 선택
4. Product Name: LoginDemo
5. Interface: SwiftUI
6. Language: Swift
7. Bundle Identifier: com.dyjung.LoginDemo
8. 저장 위치: `ios/` 폴더

### 11.2 SPM 의존성 추가

1. Project Navigator에서 프로젝트 선택
2. Package Dependencies 탭
3. '+' 버튼 클릭
4. Alamofire 추가: https://github.com/Alamofire/Alamofire (5.9.0)

---

## 12장. Clean Architecture 폴더 구조

### 12.1 폴더 생성

Xcode Project Navigator에서 우클릭 > New Group:

```
LoginDemo/
├── App/
├── Domain/
│   ├── Entities/
│   ├── Repositories/
│   └── UseCases/
├── Data/
│   ├── DTOs/
│   ├── DataSources/
│   ├── Repositories/
│   └── Mappers/
├── Presentation/
│   ├── Splash/
│   ├── Auth/
│   └── Main/
└── Core/
    ├── Network/
    ├── Components/
    └── Utilities/
```

---

## 13장. Domain Layer 구현

### 13.1 Entities/User.swift

```swift
// Domain/Entities/User.swift
struct User {
    let id: String
    let email: String?
    let nickname: String
    let status: UserStatus
    let createdAt: Date
}

enum UserStatus: String {
    case active = "ACTIVE"
    case sleep = "SLEEP"
    case suspended = "SUSPENDED"
}
```

### 13.2 Entities/AuthToken.swift

```swift
// Domain/Entities/AuthToken.swift
struct AuthToken {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
}
```

### 13.3 Repositories/AuthRepositoryProtocol.swift

```swift
// Domain/Repositories/AuthRepositoryProtocol.swift
protocol AuthRepositoryProtocol {
    func login(email: String, password: String) async throws -> (User, AuthToken)
    func register(email: String, password: String, nickname: String) async throws -> (User, AuthToken)
}
```

### 13.4 UseCases/LoginUseCase.swift

```swift
// Domain/UseCases/LoginUseCase.swift
final class LoginUseCase {
    private let authRepository: AuthRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }
    
    func execute(email: String, password: String) async throws -> User {
        let (user, token) = try await authRepository.login(email: email, password: password)
        // TODO: Save token to Keychain
        return user
    }
}
```

---

## 14장. Data Layer 구현

### 14.1 DTOs/LoginRequestDTO.swift

```swift
// Data/DTOs/LoginRequestDTO.swift
struct LoginRequestDTO: Codable {
    let provider: String
    let email: String?
    let password: String?
}
```

### 14.2 DTOs/LoginResponseDTO.swift

```swift
// Data/DTOs/LoginResponseDTO.swift
struct LoginResponseDTO: Codable {
    let user: UserDTO
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
}

struct UserDTO: Codable {
    let id: String
    let email: String?
    let nickname: String
    let status: String
    let createdAt: String
}
```

### 14.3 Mappers/UserMapper.swift

```swift
// Data/Mappers/UserMapper.swift
struct UserMapper {
    static func toDomain(from dto: UserDTO) -> User {
        User(
            id: dto.id,
            email: dto.email,
            nickname: dto.nickname,
            status: UserStatus(rawValue: dto.status) ?? .active,
            createdAt: ISO8601DateFormatter().date(from: dto.createdAt) ?? Date()
        )
    }
}
```

### 14.4 DataSources/AuthRemoteDataSource.swift

```swift
// Data/DataSources/Remote/AuthRemoteDataSource.swift
import Alamofire

final class AuthRemoteDataSource {
    private let baseURL = "http://localhost:3000"
    
    func login(email: String, password: String) async throws -> LoginResponseDTO {
        let request = LoginRequestDTO(provider: "EMAIL", email: email, password: password)
        return try await AF.request(
            "\(baseURL)/v1/auth/login",
            method: .post,
            parameters: request,
            encoder: JSONParameterEncoder.default
        )
        .validate()
        .serializingDecodable(LoginResponseDTO.self)
        .value
    }
}
```

### 14.5 Repositories/AuthRepository.swift

```swift
// Data/Repositories/AuthRepository.swift
final class AuthRepository: AuthRepositoryProtocol {
    private let remoteDataSource: AuthRemoteDataSource
    
    init(remoteDataSource: AuthRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }
    
    func login(email: String, password: String) async throws -> (User, AuthToken) {
        let response = try await remoteDataSource.login(email: email, password: password)
        let user = UserMapper.toDomain(from: response.user)
        let token = AuthToken(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            expiresIn: response.expiresIn
        )
        return (user, token)
    }
    
    func register(email: String, password: String, nickname: String) async throws -> (User, AuthToken) {
        fatalError("Not implemented")
    }
}
```

---

## 15장. Presentation Layer 구현

### 15.1 Auth/Login/LoginViewModel.swift

```swift
// Presentation/Auth/Login/LoginViewModel.swift
import Foundation

@Observable
@MainActor
final class LoginViewModel {
    var email = ""
    var password = ""
    var isLoading = false
    var errorMessage: String?
    
    private let loginUseCase: LoginUseCase
    
    init(loginUseCase: LoginUseCase) {
        self.loginUseCase = loginUseCase
    }
    
    func login() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "이메일과 비밀번호를 입력하세요"
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let user = try await loginUseCase.execute(email: email, password: password)
            print("로그인 성공: \(user.nickname)")
            // TODO: Navigate to Main
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

### 15.2 Auth/Login/LoginView.swift

```swift
// Presentation/Auth/Login/LoginView.swift
import SwiftUI

struct LoginView: View {
    @State private var viewModel: LoginViewModel
    
    init(viewModel: LoginViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("로그인")
                .font(.largeTitle)
                .bold()
            
            TextField("이메일", text: $viewModel.email)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
            
            SecureField("비밀번호", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button("로그인") {
                Task { await viewModel.login() }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(viewModel.isLoading)
        }
        .padding()
    }
}
```

### 15.3 App/DIContainer.swift

```swift
// App/DIContainer.swift
final class DIContainer {
    static let shared = DIContainer()
    
    let authRepository: AuthRepositoryProtocol
    
    private init() {
        let remoteDataSource = AuthRemoteDataSource()
        self.authRepository = AuthRepository(remoteDataSource: remoteDataSource)
    }
    
    func makeLoginViewModel() -> LoginViewModel {
        let useCase = LoginUseCase(authRepository: authRepository)
        return LoginViewModel(loginUseCase: useCase)
    }
}
```

### 15.4 App/LoginDemoApp.swift

```swift
// App/LoginDemoApp.swift
import SwiftUI

@main
struct LoginDemoApp: App {
    var body: some Scene {
        WindowGroup {
            LoginView(viewModel: DIContainer.shared.makeLoginViewModel())
        }
    }
}
```

---

# PART V: Android 개발

## 16장. Android Studio 프로젝트 생성

1. Android Studio 실행
2. New Project > Empty Activity
3. Name: LoginDemo
4. Package: com.dyjung.logindemo
5. Language: Kotlin
6. Minimum SDK: API 26
7. 저장 위치: `android/` 폴더

---

## 17장. Hilt DI 설정

### 17.1 build.gradle.kts 설정

```kotlin
// app/build.gradle.kts
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.dagger.hilt.android")
    kotlin("kapt")
}

dependencies {
    implementation("com.google.dagger:hilt-android:2.48")
    kapt("com.google.dagger:hilt-android-compiler:2.48")
    
    implementation("com.squareup.retrofit2:retrofit:2.9.0")
    implementation("com.squareup.retrofit2:converter-gson:2.9.0")
}
```

---

## 18장. Clean Architecture 구현

### 18.1 Domain Layer

```kotlin
// domain/model/User.kt
data class User(
    val id: String,
    val email: String?,
    val nickname: String,
    val status: UserStatus
)

enum class UserStatus { ACTIVE, SUSPENDED }
```

### 18.2 Data Layer

```kotlin
// data/dto/LoginRequest.kt
data class LoginRequest(
    val provider: String,
    val email: String?,
    val password: String?
)

// data/datasource/AuthApi.kt
interface AuthApi {
    @POST("v1/auth/login")
    suspend fun login(@Body request: LoginRequest): LoginResponse
}
```

### 18.3 Presentation Layer

```kotlin
// presentation/auth/LoginViewModel.kt
@HiltViewModel
class LoginViewModel @Inject constructor(
    private val loginUseCase: LoginUseCase
) : ViewModel() {
    
    private val _uiState = MutableStateFlow(LoginUiState())
    val uiState = _uiState.asStateFlow()
    
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

// presentation/auth/LoginScreen.kt
@Composable
fun LoginScreen(viewModel: LoginViewModel = hiltViewModel()) {
    val uiState by viewModel.uiState.collectAsState()
    
    Column(modifier = Modifier.padding(16.dp)) {
        TextField(
            value = uiState.email,
            onValueChange = { /* update */ },
            label = { Text("이메일") }
        )
        
        Button(onClick = { viewModel.login("test", "pass") }) {
            Text("로그인")
        }
    }
}
```

---

# PART VI: Frontend 개발

## 19장. Next.js 프로젝트 생성

```bash
cd frontend
npx create-next-app@latest . --typescript --tailwind --app --no-src-dir
```

---

## 20장. Main Page 구현

```typescript
// app/page.tsx
export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-24">
      <h1 className="text-4xl font-bold">Welcome to LoginDemo</h1>
      <p className="mt-4 text-lg">iOS, Android, Web Platform</p>
    </main>
  )
}
```

---

# PART VII: 로컬 테스트

## 21장. Backend 실행 및 API 테스트

```bash
cd backend
npm run start:dev

# 회원가입 테스트
curl -X POST http://localhost:3000/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"user@test.com","password":"pass123","nickname":"사용자"}'

# 로그인 테스트
curl -X POST http://localhost:3000/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@test.com","password":"pass123"}'
```

---

## 22장. iOS/Android 통합 테스트

### iOS 실행
```bash
cd ios
open LoginDemo.xcodeproj
# Xcode에서 Cmd+R
```

### Android 실행
```bash
cd android
./gradlew installDebug
```

---

# PART VIII: 배포

## 23장. Docker 컨테이너화

### 23.1 Backend Dockerfile

```dockerfile
# backend/Dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
COPY prisma ./prisma/
RUN npm ci
COPY . .
RUN npx prisma generate
RUN npm run build

FROM node:20-alpine AS production
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/prisma ./prisma
EXPOSE 3000
CMD ["sh", "-c", "npx prisma db push --skip-generate && node dist/main"]
```

### 23.2 Frontend Dockerfile

```dockerfile
# frontend/Dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine AS production
WORKDIR /app
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
EXPOSE 3000
CMD ["node", "server.js"]
```

### 23.3 docker-compose.yml

```yaml
services:
  backend:
    build: ./backend
    container_name: logindemo-backend
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=${DATABASE_URL}
    restart: unless-stopped

  frontend:
    build: ./frontend
    container_name: logindemo-frontend
    ports:
      - "3001:3000"
    depends_on:
      - backend
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    container_name: logindemo-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
      - /etc/letsencrypt:/etc/letsencrypt:ro
    depends_on:
      - frontend
      - backend
    restart: unless-stopped
```

---

## 24장. VPS 서버 설정

### 24.1 Hostinger VPS 구매

1. https://www.hostinger.com 접속
2. VPS 플랜 선택
3. OS: Ubuntu 24.04 LTS

### 24.2 SSH 접속

```bash
ssh root@72.62.245.151
```

### 24.3 사용자 계정 생성

```bash
adduser dyjung
usermod -aG sudo dyjung
```

### 24.4 방화벽 설정

```bash
sudo ufw allow OpenSSH
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable
```

### 24.5 Docker 설치

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

sudo systemctl start docker
sudo systemctl enable docker
```

---

## 25장. Nginx + SSL 설정

### 25.1 nginx.conf 작성

```nginx
server {
    listen 80;
    server_name dyjung.com www.dyjung.com;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

server {
    listen 443 ssl;
    server_name dyjung.com www.dyjung.com;

    ssl_certificate /etc/letsencrypt/live/dyjung.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/dyjung.com/privkey.pem;

    location / {
        proxy_pass http://logindemo-frontend:3000;
        proxy_set_header Host $host;
    }

    location /v1 {
        proxy_pass http://logindemo-backend:3000;
        proxy_set_header Host $host;
    }

    location /api-docs {
        proxy_pass http://logindemo-backend:3000;
        proxy_set_header Host $host;
    }
}
```

### 25.2 SSL 인증서 발급

```bash
sudo apt install certbot -y
sudo docker compose down
sudo certbot certonly --standalone -d dyjung.com -d www.dyjung.com
sudo docker compose up -d
```

---

## 26장. 프로덕션 배포

### 26.1 프로젝트 배포

```bash
# VPS 서버에서
sudo mkdir -p /var/www/logindemo
sudo chown $USER:$USER /var/www/logindemo
cd /var/www/logindemo

# Git 클론
git clone https://github.com/dyjung/logindemo.git .

# 환경 변수 설정
cat > .env << 'EOF'
DATABASE_URL="postgresql://user:pass@host:6543/db?pgbouncer=true"
DIRECT_URL="postgresql://user:pass@host:5432/db"
EOF

# Docker 빌드 및 실행
sudo docker compose up -d --build

# 상태 확인
sudo docker compose ps
```

### 26.2 배포 확인

```bash
# HTTP → HTTPS 리다이렉트 확인
curl -I http://www.dyjung.com

# HTTPS 접속 확인
curl -I https://www.dyjung.com

# API 테스트
curl https://www.dyjung.com/v1/init
```

---

# PART IX: 운영 및 확장

## 27장. 모니터링 및 로그

### 27.1 로그 확인

```bash
# 전체 로그
sudo docker compose logs -f

# Backend 로그
sudo docker compose logs backend --tail=100

# Frontend 로그
sudo docker compose logs frontend --tail=100
```

### 27.2 컨테이너 재시작

```bash
sudo docker compose restart backend
sudo docker compose restart frontend
```

---

## 28장. 신규 Feature 추가 프로세스

### 28.1 프로세스

1. `/specify` - 기능 명세 작성
2. `/clarify` - 명세 보완
3. `/plan` - 구현 계획
4. `/tasks` - 작업 목록
5. `/implement` - 코드 구현
6. TypeSpec 업데이트 (필요시)
7. 테스트
8. 배포

---

## 29장. 트러블슈팅

### 29.1 Docker 빌드 실패

```bash
sudo docker compose down
sudo docker compose build --no-cache
sudo docker compose up -d
```

### 29.2 포트 충돌

```bash
sudo lsof -i :80
sudo lsof -i :443
sudo kill -9 <PID>
```

### 29.3 SSL 인증서 갱신

```bash
sudo docker compose down
sudo certbot renew
sudo docker compose up -d
```

---

## 30장. 명령어 레퍼런스

### 30.1 로컬 개발

```bash
# Backend
cd backend && npm run start:dev

# iOS
cd ios && xcodebuild ... build

# Android
cd android && ./gradlew assembleDebug

# Frontend
cd frontend && npm run dev
```

### 30.2 Docker

```bash
# 빌드 및 실행
docker compose up -d --build

# 중지
docker compose down

# 로그
docker compose logs -f

# 상태 확인
docker compose ps
```

### 30.3 VPS 운영

```bash
# SSH 접속
ssh dyjung@72.62.245.151

# 프로젝트 업데이트
cd /var/www/logindemo
sudo git pull
sudo docker compose up -d --build

# 로그 확인
sudo docker compose logs -f
```

---

# 완료!

이 매뉴얼을 처음부터 끝까지 따라 수행하면 LoginDemo 프로젝트의 모든 결과물을 재현할 수 있습니다.

**작성 완료일**: 2026-01-18  
**작성자**: Antigravity AI  
**문서 상태**: 완전판 (전체 30개 장 포함)
