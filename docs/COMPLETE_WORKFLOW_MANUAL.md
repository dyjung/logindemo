# LoginDemo 프로젝트 완전 작업 절차 매뉴얼

> **macOS 환경에서 처음부터 끝까지 따라하는 정석 가이드**
>
> speckit 명세 작성 → 개발 → Supabase + Hostinger VPS 배포

**Version**: 1.0.0
**작성일**: 2026-01-18
**대상 환경**: macOS (Apple Silicon / Intel)

---

## 목차

| 단계 | 내용 | 예상 소요 |
|------|------|-----------|
| **STEP 1** | [개발 환경 설정](#step-1-개발-환경-설정) | 30분 |
| **STEP 2** | [프로젝트 초기화](#step-2-프로젝트-초기화) | 10분 |
| **STEP 3** | [Speckit 헌법 수립](#step-3-speckit-헌법-수립) | 15분 |
| **STEP 4** | [Feature 명세 작성](#step-4-feature-명세-작성) | 30분 |
| **STEP 5** | [TypeSpec API 명세](#step-5-typespec-api-명세) | 20분 |
| **STEP 6** | [Backend 개발 (NestJS)](#step-6-backend-개발-nestjs) | 60분 |
| **STEP 7** | [iOS 개발 (SwiftUI)](#step-7-ios-개발-swiftui) | 90분 |
| **STEP 8** | [Android 개발 (Compose)](#step-8-android-개발-compose) | 60분 |
| **STEP 9** | [Frontend 개발 (Next.js)](#step-9-frontend-개발-nextjs) | 20분 |
| **STEP 10** | [Supabase 데이터베이스 설정](#step-10-supabase-데이터베이스-설정) | 15분 |
| **STEP 11** | [Docker 컨테이너화](#step-11-docker-컨테이너화) | 30분 |
| **STEP 12** | [Hostinger VPS 배포](#step-12-hostinger-vps-배포) | 45분 |
| **STEP 13** | [SSL/HTTPS 설정](#step-13-sslhttps-설정) | 20분 |
| **STEP 14** | [운영 및 유지보수](#step-14-운영-및-유지보수) | - |

---

# STEP 1: 개발 환경 설정

## 1.1 Homebrew 설치

```bash
# Homebrew 설치
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Apple Silicon Mac인 경우 PATH 설정
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
source ~/.zshrc

# 설치 확인
brew --version
```

## 1.2 Node.js 20 설치

```bash
# Node.js 20 LTS 설치
brew install node@20

# PATH 설정
echo 'export PATH="/opt/homebrew/opt/node@20/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# 설치 확인
node --version    # v20.x.x
npm --version     # 10.x.x
```

## 1.3 Git 설치 및 설정

```bash
# Git 설치
brew install git

# 사용자 정보 설정
git config --global user.name "Your Name"
git config --global user.email "your@email.com"

# 설치 확인
git --version
```

## 1.4 Docker Desktop 설치

```bash
# Docker Desktop 다운로드 및 설치
# https://www.docker.com/products/docker-desktop 에서 다운로드

# 또는 Homebrew Cask로 설치
brew install --cask docker

# Docker Desktop 실행 후 확인
docker --version
docker compose version
```

## 1.5 Xcode 설치 (iOS 개발용)

```bash
# App Store에서 Xcode 15+ 설치 후

# Command Line Tools 설치
xcode-select --install

# 라이선스 동의
sudo xcodebuild -license accept

# 설치 확인
xcodebuild -version
```

## 1.6 Android Studio 설치 (Android 개발용)

1. https://developer.android.com/studio 에서 다운로드
2. 설치 후 실행
3. SDK Manager에서 설치:
   - Android SDK Platform 34
   - Android SDK Build-Tools
   - Android Emulator

```bash
# 환경 변수 설정
echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.zshrc
source ~/.zshrc

# 설치 확인
adb --version
```

## 1.7 TypeSpec 설치

```bash
# TypeSpec 컴파일러 전역 설치
npm install -g @typespec/compiler

# 설치 확인
tsp --version
```

## 1.8 Claude Code 설치

```bash
# Claude Code CLI 설치
npm install -g @anthropic-ai/claude-code

# 설치 확인
claude --version

# Claude Code 실행 및 인증
claude
```

---

# STEP 2: 프로젝트 초기화

## 2.1 프로젝트 디렉토리 생성

```bash
# 프로젝트 루트 생성
mkdir -p ~/WorkSpace/iOS/LoginDemo
cd ~/WorkSpace/iOS/LoginDemo

# Git 초기화
git init

# 폴더 구조 생성
mkdir -p .specify/memory .specify/templates .specify/scripts
mkdir -p specs docs
mkdir -p shared/api-contracts shared/localization shared/assets
mkdir -p ios android frontend backend typespec
```

## 2.2 .gitignore 작성

```bash
cat > .gitignore << 'EOF'
# macOS
.DS_Store

# IDE
.vscode/
.idea/

# Node
node_modules/
dist/
build/
*.log

# Environment
.env
.env.local
.env.*.local

# iOS
*.xcuserstate
xcuserdata/
DerivedData/
*.ipa
*.dSYM.zip

# Android
*.apk
*.aab
local.properties
.gradle/
build/

# Docker
docker-compose.override.yml
EOF
```

## 2.3 Makefile 작성

```bash
cat > Makefile << 'EOF'
.PHONY: help setup ios-build android-build backend-dev clean

help:
	@echo "=== LoginDemo Build Commands ==="
	@echo "setup           - Check development environment"
	@echo "ios-build       - Build iOS project"
	@echo "android-build   - Build Android project"
	@echo "backend-dev     - Run backend dev server"
	@echo "clean           - Clean all build artifacts"

setup:
	@echo "Checking environment..."
	@command -v node >/dev/null 2>&1 || (echo "Node.js not found"; exit 1)
	@command -v docker >/dev/null 2>&1 || (echo "Docker not found"; exit 1)
	@command -v xcodebuild >/dev/null 2>&1 || (echo "Xcode not found"; exit 1)
	@echo "✓ All requirements satisfied"

ios-build:
	cd ios && xcodebuild -project LoginDemo.xcodeproj -scheme LoginDemo -sdk iphonesimulator build

android-build:
	cd android && ./gradlew assembleDebug

backend-dev:
	cd backend && npm run start:dev

clean:
	rm -rf ios/build android/build backend/dist frontend/.next
EOF
```

## 2.4 CLAUDE.md 작성

```bash
cat > CLAUDE.md << 'EOF'
# CLAUDE.md

## Project Structure

```
LoginDemo/
├── ios/        # iOS (SwiftUI)
├── android/    # Android (Jetpack Compose)
├── backend/    # NestJS + Prisma
├── frontend/   # Next.js
├── typespec/   # API Contract
├── specs/      # Feature Specifications
└── shared/     # Shared Resources
```

## Architecture

Clean Architecture + Dependency Inversion

```
Presentation → Domain → Data
```

## Build Commands

```bash
make ios-build
make android-build
make backend-dev
```

## Key Technologies

- iOS: Swift 5.9+, SwiftUI, Alamofire
- Android: Kotlin 1.9+, Jetpack Compose, Hilt, Retrofit
- Backend: NestJS, Prisma, PostgreSQL
EOF
```

---

# STEP 3: Speckit 헌법 수립

## 3.1 Constitution 작성

> Constitution은 프로젝트 전체의 핵심 원칙과 규칙을 정의합니다.

```bash
cat > .specify/memory/constitution.md << 'EOF'
# LoginDemo 프로젝트 헌법

**Version**: 1.1.0
**Last Updated**: 2026-01-18

---

## 핵심 원칙

### I. SwiftUI 우선
모든 iOS UI는 SwiftUI로 구현한다.

### II. 클린 아키텍처
Domain/Data/Presentation 레이어 분리를 필수로 한다.

### III. 테스트 주도 개발
UseCase, ViewModel은 단위 테스트를 필수로 작성한다.

### IV. 상태 관리 일관성
- iOS: @Observable (iOS 17+) 사용
- Android: StateFlow 사용

### V. 접근성 필수
모든 UI에 accessibilityLabel을 제공한다.

### VI. 단순성 우선
YAGNI 원칙을 따른다. 필요한 기능만 구현한다.

### VII. 보안 최우선
- 토큰은 Keychain/EncryptedSharedPreferences에 저장
- 프로덕션은 HTTPS Only

---

## 코딩 규칙

### 네이밍
- iOS: lowerCamelCase (함수/변수), UpperCamelCase (타입)
- Android: lowerCamelCase (함수/변수), UpperCamelCase (타입)
- 파일명: 내용을 나타내는 명확한 이름

### 폴더 구조
```
Domain/
  Entities/      # 도메인 모델
  Repositories/  # Protocol/Interface
  UseCases/      # 비즈니스 로직

Data/
  Repositories/  # Implementation
  DataSources/   # Local/Remote
  DTOs/          # 데이터 전송 객체

Presentation/
  Feature/       # View + ViewModel
```

---

## 인증 보안 규칙

1. Access Token: 메모리 또는 Keychain 저장 (1시간 유효)
2. Refresh Token: Keychain 저장 (30일 유효)
3. Token Rotation: Refresh 시 새 토큰 쌍 발급
4. 모든 디바이스 로그아웃 기능 제공
EOF
```

## 3.2 Speckit 템플릿 설정

```bash
# spec-template.md
cat > .specify/templates/spec-template.md << 'EOF'
# Feature: {FEATURE_NAME}

**Version**: 1.0.0
**Status**: Draft

## Overview

[기능 개요 설명]

## User Stories

| ID | Story | Priority |
|----|-------|----------|
| US1 | As a user, I want to... | P1 |

## Requirements

### Functional Requirements
- [ ] FR1: ...

### Non-Functional Requirements
- [ ] NFR1: ...

## Acceptance Criteria

- [ ] AC1: ...

## Out of Scope

- ...
EOF

# tasks-template.md
cat > .specify/templates/tasks-template.md << 'EOF'
# Tasks: {FEATURE_NAME}

## Phase 1: Setup

| ID | Task | Depends | Status |
|----|------|---------|--------|
| T001 | ... | - | pending |

## Phase 2: Implementation

| ID | Task | Depends | Status |
|----|------|---------|--------|
| T010 | ... | T001 | pending |
EOF
```

---

# STEP 4: Feature 명세 작성

## 4.1 Claude Code에서 speckit 명령어 사용

```bash
# Claude Code 실행
cd ~/WorkSpace/iOS/LoginDemo
claude

# /specify 명령어로 Feature 명세 생성
/specify

# 프롬프트에 기능 설명 입력:
SwiftUI 앱의 Splash, Onboarding, 로그인/회원가입 화면 구현.
자동로그인 기능 포함. Clean Architecture 적용.
```

## 4.2 Speckit 워크플로우

### Step 1: /specify - 명세 생성

```
/specify

# 입력:
로그인/회원가입 인증 플로우 구현
- 이메일 로그인/회원가입
- 소셜 로그인 (카카오, 네이버, 애플)
- 자동 로그인
- 비밀번호 찾기
```

**생성되는 파일:**
```
specs/001-auth-onboarding-flow/
├── spec.md           # 기능 명세
├── plan.md           # 구현 계획
├── data-model.md     # 데이터 모델
└── tasks.md          # 작업 목록
```

### Step 2: /clarify - 명세 보완

```
/clarify

# 질문에 답변하여 명세를 구체화
```

### Step 3: /plan - 구현 계획 수립

```
/plan

# 구현 순서와 의존성을 정의
```

### Step 4: /tasks - 작업 목록 생성

```
/tasks

# 세부 작업 목록 (T001, T002...) 생성
```

### Step 5: /analyze - 일관성 검증

```
/analyze

# spec.md, plan.md, tasks.md 간 일관성 검증
```

## 4.3 생성된 명세 예시

**specs/001-auth-onboarding-flow/spec.md:**

```markdown
# Feature: 인증 및 온보딩 플로우

## User Stories

| ID | Story | Priority |
|----|-------|----------|
| US1 | 스플래시 화면 | P1 |
| US2 | 온보딩 (최초 사용자) | P2 |
| US3 | 이메일 로그인 | P1 |
| US4 | 소셜 로그인 | P2 |
| US5 | 회원가입 | P1 |
| US6 | 비밀번호 찾기 | P3 |

## Requirements

### FR1: 스플래시 화면
- 앱 시작 시 2초간 로고 표시
- 토큰 존재 시 자동로그인 시도
- 결과에 따라 라우팅 (Main/Login/Onboarding)
```

---

# STEP 5: TypeSpec API 명세

## 5.1 TypeSpec 프로젝트 초기화

```bash
cd ~/WorkSpace/iOS/LoginDemo/typespec

# package.json 생성
cat > package.json << 'EOF'
{
  "name": "logindemo-typespec",
  "private": true,
  "dependencies": {
    "@typespec/compiler": "^0.60.0",
    "@typespec/http": "^0.60.0",
    "@typespec/rest": "^0.60.0",
    "@typespec/openapi3": "^0.60.0"
  }
}
EOF

# 의존성 설치
npm install
```

## 5.2 tspconfig.yaml 생성

```bash
cat > tspconfig.yaml << 'EOF'
emit:
  - "@typespec/openapi3"
options:
  "@typespec/openapi3":
    emitter-output-dir: "{project-root}/tsp-output"
EOF
```

## 5.3 main.tsp 작성

```bash
cat > main.tsp << 'EOF'
import "@typespec/http";
import "@typespec/rest";

using TypeSpec.Http;
using TypeSpec.Rest;

@service({
  title: "LoginDemo API",
  version: "1.0.0"
})
namespace LoginDemoAPI;

// ========== Enums ==========

enum AuthenticationMethod {
  EMAIL,
  KAKAO,
  NAVER,
  APPLE,
  GOOGLE
}

enum UserStatus {
  ACTIVE,
  SLEEP,
  SUSPENDED,
  DELETED
}

enum Platform {
  IOS,
  ANDROID,
  WEB
}

// ========== Models ==========

model User {
  id: string;
  email?: string;
  nickname: string;
  status: UserStatus;
  createdAt: utcDateTime;
}

model AuthToken {
  accessToken: string;
  refreshToken: string;
  expiresIn: int32;
}

// ========== Request/Response ==========

model RegisterRequest {
  provider: AuthenticationMethod;
  email?: string;
  password?: string;
  nickname: string;
  marketingConsent?: boolean;
}

model RegisterResponse {
  user: User;
  ...AuthToken;
}

model LoginRequest {
  provider: AuthenticationMethod;
  email?: string;
  password?: string;
  socialAccessToken?: string;
}

model LoginResponse {
  user: User;
  ...AuthToken;
}

model TokenRefreshRequest {
  refreshToken: string;
}

model TokenRefreshResponse {
  accessToken: string;
  refreshToken: string;
}

model LogoutRequest {
  refreshToken: string;
  allDevices?: boolean;
}

model LogoutResponse {
  success: boolean;
  message: string;
}

// ========== Auth API ==========

@route("/v1/auth")
namespace Auth {
  @post
  @route("/register")
  op register(@body request: RegisterRequest): RegisterResponse;

  @post
  @route("/login")
  op login(@body request: LoginRequest): LoginResponse;

  @post
  @route("/refresh")
  op refresh(@body request: TokenRefreshRequest): TokenRefreshResponse;

  @post
  @route("/logout")
  op logout(@body request: LogoutRequest): LogoutResponse;
}

// ========== System API ==========

@route("/v1")
namespace System {
  @get
  @route("/init")
  op init(): {
    serverTime: utcDateTime;
    minVersion: string;
    maintenanceMode: boolean;
  };
}
EOF
```

## 5.4 OpenAPI 생성

```bash
# TypeSpec 컴파일
npx tsp compile .

# 생성된 파일 확인
ls tsp-output/@typespec/openapi3/

# shared 폴더에 복사
cp tsp-output/@typespec/openapi3/openapi.yaml ../shared/api-contracts/
```

---

# STEP 6: Backend 개발 (NestJS)

## 6.1 NestJS 프로젝트 생성

```bash
cd ~/WorkSpace/iOS/LoginDemo/backend

# NestJS CLI로 프로젝트 생성
npx @nestjs/cli new . --skip-git --package-manager npm

# 필요한 패키지 설치
npm install @prisma/client bcrypt class-validator class-transformer
npm install @nestjs/swagger swagger-ui-express
npm install -D prisma @types/bcrypt

# Prisma 초기화
npx prisma init
```

## 6.2 Prisma 스키마 작성

```bash
cat > prisma/schema.prisma << 'EOF'
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider  = "postgresql"
  url       = env("DATABASE_URL")
  directUrl = env("DIRECT_URL")
}

enum UserStatus {
  ACTIVE
  SUSPENDED
}

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

  @@map("users")
}

model AuthenticationAccount {
  id           String   @id @default(uuid())
  method       String
  providerId   String?
  passwordHash String?
  userId       String
  createdAt    DateTime @default(now())

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@unique([userId, method])
  @@map("authentication_accounts")
}

model RefreshToken {
  id            String   @id @default(uuid())
  tokenHash     String   @unique
  userId        String
  expiresAt     DateTime
  isRevoked     Boolean  @default(false)
  revokedReason String?
  createdAt     DateTime @default(now())

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@index([userId])
  @@index([isRevoked])
  @@map("refresh_tokens")
}
EOF
```

## 6.3 Prisma 서비스 생성

```bash
mkdir -p src/prisma

# prisma.module.ts
cat > src/prisma/prisma.module.ts << 'EOF'
import { Global, Module } from '@nestjs/common';
import { PrismaService } from './prisma.service';

@Global()
@Module({
  providers: [PrismaService],
  exports: [PrismaService],
})
export class PrismaModule {}
EOF

# prisma.service.ts
cat > src/prisma/prisma.service.ts << 'EOF'
import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  async onModuleInit() {
    await this.$connect();
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }
}
EOF
```

## 6.4 Auth 모듈 생성

```bash
mkdir -p src/auth

# auth.module.ts
cat > src/auth/auth.module.ts << 'EOF'
import { Module } from '@nestjs/common';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';

@Module({
  controllers: [AuthController],
  providers: [AuthService],
})
export class AuthModule {}
EOF
```

## 6.5 Auth Service 구현

```bash
cat > src/auth/auth.service.ts << 'EOF'
import { Injectable, ConflictException, UnauthorizedException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import * as bcrypt from 'bcrypt';
import * as crypto from 'crypto';

@Injectable()
export class AuthService {
  constructor(private readonly prisma: PrismaService) {}

  // 회원가입
  async register(email: string, password: string, nickname: string) {
    // 이메일 중복 확인
    const existing = await this.prisma.user.findUnique({ where: { email } });
    if (existing) {
      throw new ConflictException('Email already exists');
    }

    // 비밀번호 해싱
    const passwordHash = await bcrypt.hash(password, 10);

    // 사용자 생성
    const user = await this.prisma.user.create({
      data: {
        email,
        nickname,
        authenticationAccounts: {
          create: {
            method: 'EMAIL',
            passwordHash,
          },
        },
      },
    });

    // 토큰 생성
    const tokens = await this.createTokens(user.id);
    return { user, ...tokens };
  }

  // 로그인
  async login(email: string, password: string) {
    // 사용자 조회
    const user = await this.prisma.user.findUnique({
      where: { email },
      include: { authenticationAccounts: true },
    });

    if (!user) {
      throw new UnauthorizedException('Invalid email or password');
    }

    // 비밀번호 검증
    const account = user.authenticationAccounts.find(a => a.method === 'EMAIL');
    if (!account || !account.passwordHash) {
      throw new UnauthorizedException('Invalid email or password');
    }

    const isValid = await bcrypt.compare(password, account.passwordHash);
    if (!isValid) {
      throw new UnauthorizedException('Invalid email or password');
    }

    // 토큰 생성
    const tokens = await this.createTokens(user.id);
    return { user, ...tokens };
  }

  // 토큰 갱신
  async refresh(refreshToken: string) {
    const tokenHash = this.hashToken(refreshToken);

    // 토큰 조회
    const storedToken = await this.prisma.refreshToken.findUnique({
      where: { tokenHash },
      include: { user: true },
    });

    if (!storedToken || storedToken.isRevoked || storedToken.expiresAt < new Date()) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    // 기존 토큰 무효화 (Token Rotation)
    await this.prisma.refreshToken.update({
      where: { id: storedToken.id },
      data: { isRevoked: true, revokedReason: 'Token rotated' },
    });

    // 새 토큰 생성
    return this.createTokens(storedToken.userId);
  }

  // 로그아웃
  async logout(refreshToken: string, allDevices: boolean = false) {
    const tokenHash = this.hashToken(refreshToken);

    const storedToken = await this.prisma.refreshToken.findUnique({
      where: { tokenHash },
    });

    if (!storedToken) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    if (allDevices) {
      // 모든 디바이스 로그아웃
      await this.prisma.refreshToken.updateMany({
        where: { userId: storedToken.userId },
        data: { isRevoked: true, revokedReason: 'Logout all devices' },
      });
    } else {
      // 현재 디바이스만 로그아웃
      await this.prisma.refreshToken.update({
        where: { id: storedToken.id },
        data: { isRevoked: true, revokedReason: 'Logout' },
      });
    }

    return { success: true, message: 'Successfully logged out' };
  }

  // 토큰 생성
  private async createTokens(userId: string) {
    const accessToken = 'access_' + crypto.randomBytes(32).toString('hex');
    const refreshToken = crypto.randomBytes(32).toString('hex');
    const tokenHash = this.hashToken(refreshToken);

    // Refresh Token 저장
    await this.prisma.refreshToken.create({
      data: {
        tokenHash,
        userId,
        expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30일
      },
    });

    return {
      accessToken,
      refreshToken,
      expiresIn: 3600,
    };
  }

  private hashToken(token: string): string {
    return crypto.createHash('sha256').update(token).digest('hex');
  }
}
EOF
```

## 6.6 Auth Controller 구현

```bash
cat > src/auth/auth.controller.ts << 'EOF'
import { Controller, Post, Body } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { AuthService } from './auth.service';

class RegisterDto {
  email: string;
  password: string;
  nickname: string;
}

class LoginDto {
  email: string;
  password: string;
}

class RefreshDto {
  refreshToken: string;
}

class LogoutDto {
  refreshToken: string;
  allDevices?: boolean;
}

@ApiTags('Auth')
@Controller('v1/auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  @ApiOperation({ summary: '회원가입' })
  @ApiResponse({ status: 201, description: '회원가입 성공' })
  @ApiResponse({ status: 409, description: '이메일 중복' })
  async register(@Body() dto: RegisterDto) {
    return this.authService.register(dto.email, dto.password, dto.nickname);
  }

  @Post('login')
  @ApiOperation({ summary: '로그인' })
  @ApiResponse({ status: 200, description: '로그인 성공' })
  @ApiResponse({ status: 401, description: '인증 실패' })
  async login(@Body() dto: LoginDto) {
    return this.authService.login(dto.email, dto.password);
  }

  @Post('refresh')
  @ApiOperation({ summary: '토큰 갱신' })
  @ApiResponse({ status: 200, description: '토큰 갱신 성공' })
  @ApiResponse({ status: 401, description: '유효하지 않은 토큰' })
  async refresh(@Body() dto: RefreshDto) {
    return this.authService.refresh(dto.refreshToken);
  }

  @Post('logout')
  @ApiOperation({ summary: '로그아웃' })
  @ApiResponse({ status: 200, description: '로그아웃 성공' })
  async logout(@Body() dto: LogoutDto) {
    return this.authService.logout(dto.refreshToken, dto.allDevices);
  }
}
EOF
```

## 6.7 System Controller 생성

```bash
mkdir -p src/system

cat > src/system/system.controller.ts << 'EOF'
import { Controller, Get } from '@nestjs/common';
import { ApiTags, ApiOperation } from '@nestjs/swagger';

@ApiTags('System')
@Controller('v1')
export class SystemController {
  @Get('init')
  @ApiOperation({ summary: '앱 초기화' })
  init() {
    return {
      serverTime: new Date().toISOString(),
      minVersion: '1.0.0',
      maintenanceMode: false,
    };
  }

  @Get('health')
  health() {
    return { status: 'ok' };
  }
}
EOF

cat > src/system/system.module.ts << 'EOF'
import { Module } from '@nestjs/common';
import { SystemController } from './system.controller';

@Module({
  controllers: [SystemController],
})
export class SystemModule {}
EOF
```

## 6.8 App Module 수정

```bash
cat > src/app.module.ts << 'EOF'
import { Module } from '@nestjs/common';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { SystemModule } from './system/system.module';

@Module({
  imports: [PrismaModule, AuthModule, SystemModule],
})
export class AppModule {}
EOF
```

## 6.9 main.ts 수정 (Swagger 추가)

```bash
cat > src/main.ts << 'EOF'
import { NestFactory } from '@nestjs/core';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Validation Pipe
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    transform: true,
  }));

  // CORS
  app.enableCors();

  // Swagger 설정
  const config = new DocumentBuilder()
    .setTitle('LoginDemo API')
    .setDescription('LoginDemo Backend API Documentation')
    .setVersion('1.0')
    .addBearerAuth()
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api-docs', app, document);

  // 서버 시작
  const port = process.env.PORT || 3000;
  await app.listen(port);
  console.log(`Server running on http://localhost:${port}`);
  console.log(`Swagger docs: http://localhost:${port}/api-docs`);
}
bootstrap();
EOF
```

## 6.10 환경 변수 설정 및 실행

```bash
# .env 파일 생성 (로컬 테스트용)
cat > .env << 'EOF'
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/logindemo"
EOF

# Prisma Client 생성
npx prisma generate

# 개발 서버 실행
npm run start:dev

# 테스트
curl http://localhost:3000/v1/init
curl http://localhost:3000/api-docs
```

---

# STEP 7: iOS 개발 (SwiftUI)

## 7.1 Xcode 프로젝트 생성

1. Xcode 실행
2. File → New → Project
3. iOS → App 선택
4. 설정:
   - Product Name: **LoginDemo**
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Bundle Identifier: **com.yourname.LoginDemo**
5. 저장 위치: `~/WorkSpace/iOS/LoginDemo/ios/`

## 7.2 SPM 의존성 추가

1. Project Navigator에서 프로젝트 선택
2. Package Dependencies 탭
3. '+' 버튼 클릭
4. Alamofire 추가:
   - URL: `https://github.com/Alamofire/Alamofire`
   - Version: Up to Next Major `5.9.0`

## 7.3 폴더 구조 생성

Xcode에서 New Group으로 생성:

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
├── Core/
│   ├── Network/
│   ├── Components/
│   └── Utilities/
└── Resources/
```

## 7.4 Domain Layer 구현

### Domain/Entities/User.swift

```swift
import Foundation

struct User: Identifiable {
    let id: String
    let email: String?
    let nickname: String
    let status: UserStatus
    let createdAt: Date
}

enum UserStatus: String {
    case active = "ACTIVE"
    case suspended = "SUSPENDED"
}
```

### Domain/Entities/AuthToken.swift

```swift
struct AuthToken {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
}
```

### Domain/Repositories/AuthRepositoryProtocol.swift

```swift
protocol AuthRepositoryProtocol {
    func login(email: String, password: String) async throws -> (User, AuthToken)
    func register(email: String, password: String, nickname: String) async throws -> (User, AuthToken)
    func refreshToken() async throws -> AuthToken
    func logout() async throws
}
```

### Domain/UseCases/LoginUseCase.swift

```swift
final class LoginUseCase {
    private let authRepository: AuthRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    func execute(email: String, password: String) async throws -> User {
        let (user, _) = try await authRepository.login(email: email, password: password)
        return user
    }
}
```

## 7.5 Data Layer 구현

### Data/DTOs/AuthDTOs.swift

```swift
struct LoginRequestDTO: Codable {
    let provider: String
    let email: String?
    let password: String?
}

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

### Core/Network/APIConstants.swift

```swift
enum APIConstants {
    #if DEBUG
    static let baseURL = "http://localhost:3000"
    #else
    static let baseURL = "https://your-domain.com"
    #endif
}
```

### Data/DataSources/Remote/AuthRemoteDataSource.swift

```swift
import Alamofire

final class AuthRemoteDataSource {
    private let baseURL = APIConstants.baseURL

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

    func register(email: String, password: String, nickname: String) async throws -> LoginResponseDTO {
        let parameters: [String: Any] = [
            "provider": "EMAIL",
            "email": email,
            "password": password,
            "nickname": nickname
        ]
        return try await AF.request(
            "\(baseURL)/v1/auth/register",
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
        .validate()
        .serializingDecodable(LoginResponseDTO.self)
        .value
    }
}
```

### Core/Utilities/KeychainHelper.swift

```swift
import Security
import Foundation

final class KeychainHelper {
    static let shared = KeychainHelper()

    func save(_ value: String, for key: String) {
        guard let data = value.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    func get(for key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)

        guard let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func delete(for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
```

## 7.6 Presentation Layer 구현

### Presentation/Auth/Login/LoginViewModel.swift

```swift
import Foundation

@Observable
@MainActor
final class LoginViewModel {
    var email = ""
    var password = ""
    var isLoading = false
    var errorMessage: String?
    var isLoggedIn = false

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
        errorMessage = nil

        do {
            let user = try await loginUseCase.execute(email: email, password: password)
            print("로그인 성공: \(user.nickname)")
            isLoggedIn = true
        } catch {
            errorMessage = "로그인 실패: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
```

### Presentation/Auth/Login/LoginView.swift

```swift
import SwiftUI

struct LoginView: View {
    @State private var viewModel: LoginViewModel

    init(viewModel: LoginViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // 로고
                Text("LoginDemo")
                    .font(.largeTitle)
                    .bold()

                Spacer()

                // 입력 필드
                VStack(spacing: 16) {
                    TextField("이메일", text: $viewModel.email)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()

                    SecureField("비밀번호", text: $viewModel.password)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal)

                // 에러 메시지
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                }

                // 로그인 버튼
                Button {
                    Task { await viewModel.login() }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("로그인")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal)
                .disabled(viewModel.isLoading)

                Spacer()
            }
            .navigationDestination(isPresented: $viewModel.isLoggedIn) {
                MainView()
            }
        }
    }
}
```

### App/DIContainer.swift

```swift
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

### App/LoginDemoApp.swift

```swift
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

## 7.7 빌드 및 실행

```bash
# Xcode에서 Cmd + R로 실행
# 또는 CLI:
cd ~/WorkSpace/iOS/LoginDemo/ios
xcodebuild -project LoginDemo.xcodeproj \
  -scheme LoginDemo \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  build
```

---

# STEP 8: Android 개발 (Compose)

## 8.1 Android Studio 프로젝트 생성

1. Android Studio 실행
2. New Project → Empty Activity
3. 설정:
   - Name: **LoginDemo**
   - Package: **com.yourname.logindemo**
   - Language: **Kotlin**
   - Minimum SDK: **API 26 (Android 8.0)**
4. 저장 위치: `~/WorkSpace/iOS/LoginDemo/android/`

## 8.2 build.gradle.kts (app) 수정

```kotlin
plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.compose)
    id("com.google.dagger.hilt.android")
    kotlin("kapt")
}

android {
    namespace = "com.yourname.logindemo"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.yourname.logindemo"
        minSdk = 26
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }
    buildFeatures {
        compose = true
    }
}

dependencies {
    // Compose
    implementation(platform(libs.androidx.compose.bom))
    implementation(libs.androidx.ui)
    implementation(libs.androidx.ui.graphics)
    implementation(libs.androidx.ui.tooling.preview)
    implementation(libs.androidx.material3)
    implementation(libs.androidx.activity.compose)
    implementation(libs.androidx.lifecycle.runtime.ktx)

    // Hilt
    implementation("com.google.dagger:hilt-android:2.48")
    kapt("com.google.dagger:hilt-android-compiler:2.48")
    implementation("androidx.hilt:hilt-navigation-compose:1.1.0")

    // Retrofit
    implementation("com.squareup.retrofit2:retrofit:2.9.0")
    implementation("com.squareup.retrofit2:converter-gson:2.9.0")
    implementation("com.squareup.okhttp3:logging-interceptor:4.12.0")

    // Coroutines
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")

    // EncryptedSharedPreferences
    implementation("androidx.security:security-crypto:1.1.0-alpha06")
}
```

## 8.3 Hilt Application 설정

### LoginDemoApplication.kt

```kotlin
package com.yourname.logindemo

import android.app.Application
import dagger.hilt.android.HiltAndroidApp

@HiltAndroidApp
class LoginDemoApplication : Application()
```

### AndroidManifest.xml 수정

```xml
<application
    android:name=".LoginDemoApplication"
    ...>
```

## 8.4 Domain Layer

### domain/model/User.kt

```kotlin
package com.yourname.logindemo.domain.model

data class User(
    val id: String,
    val email: String?,
    val nickname: String,
    val status: UserStatus
)

enum class UserStatus {
    ACTIVE, SUSPENDED
}
```

### domain/repository/AuthRepository.kt

```kotlin
package com.yourname.logindemo.domain.repository

import com.yourname.logindemo.domain.model.User

interface AuthRepository {
    suspend fun login(email: String, password: String): User
    suspend fun register(email: String, password: String, nickname: String): User
    suspend fun logout()
}
```

### domain/usecase/LoginUseCase.kt

```kotlin
package com.yourname.logindemo.domain.usecase

import com.yourname.logindemo.domain.model.User
import com.yourname.logindemo.domain.repository.AuthRepository
import javax.inject.Inject

class LoginUseCase @Inject constructor(
    private val authRepository: AuthRepository
) {
    suspend operator fun invoke(email: String, password: String): User {
        return authRepository.login(email, password)
    }
}
```

## 8.5 Data Layer

### data/api/AuthApi.kt

```kotlin
package com.yourname.logindemo.data.api

import com.yourname.logindemo.data.dto.LoginRequest
import com.yourname.logindemo.data.dto.LoginResponse
import retrofit2.http.Body
import retrofit2.http.POST

interface AuthApi {
    @POST("v1/auth/login")
    suspend fun login(@Body request: LoginRequest): LoginResponse

    @POST("v1/auth/register")
    suspend fun register(@Body request: LoginRequest): LoginResponse
}
```

### data/dto/AuthDtos.kt

```kotlin
package com.yourname.logindemo.data.dto

data class LoginRequest(
    val provider: String = "EMAIL",
    val email: String?,
    val password: String?,
    val nickname: String? = null
)

data class LoginResponse(
    val user: UserDto,
    val accessToken: String,
    val refreshToken: String,
    val expiresIn: Int
)

data class UserDto(
    val id: String,
    val email: String?,
    val nickname: String,
    val status: String
)
```

### data/repository/AuthRepositoryImpl.kt

```kotlin
package com.yourname.logindemo.data.repository

import com.yourname.logindemo.data.api.AuthApi
import com.yourname.logindemo.data.dto.LoginRequest
import com.yourname.logindemo.domain.model.User
import com.yourname.logindemo.domain.model.UserStatus
import com.yourname.logindemo.domain.repository.AuthRepository
import javax.inject.Inject

class AuthRepositoryImpl @Inject constructor(
    private val authApi: AuthApi
) : AuthRepository {

    override suspend fun login(email: String, password: String): User {
        val response = authApi.login(LoginRequest(email = email, password = password))
        return User(
            id = response.user.id,
            email = response.user.email,
            nickname = response.user.nickname,
            status = UserStatus.valueOf(response.user.status)
        )
    }

    override suspend fun register(email: String, password: String, nickname: String): User {
        val response = authApi.register(
            LoginRequest(email = email, password = password, nickname = nickname)
        )
        return User(
            id = response.user.id,
            email = response.user.email,
            nickname = response.user.nickname,
            status = UserStatus.valueOf(response.user.status)
        )
    }

    override suspend fun logout() {
        // TODO: Implement
    }
}
```

## 8.6 DI Module

### di/NetworkModule.kt

```kotlin
package com.yourname.logindemo.di

import com.yourname.logindemo.data.api.AuthApi
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {

    @Provides
    @Singleton
    fun provideRetrofit(): Retrofit {
        return Retrofit.Builder()
            .baseUrl("http://10.0.2.2:3000/") // Android Emulator localhost
            .addConverterFactory(GsonConverterFactory.create())
            .build()
    }

    @Provides
    @Singleton
    fun provideAuthApi(retrofit: Retrofit): AuthApi {
        return retrofit.create(AuthApi::class.java)
    }
}
```

### di/RepositoryModule.kt

```kotlin
package com.yourname.logindemo.di

import com.yourname.logindemo.data.repository.AuthRepositoryImpl
import com.yourname.logindemo.domain.repository.AuthRepository
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
abstract class RepositoryModule {

    @Binds
    @Singleton
    abstract fun bindAuthRepository(impl: AuthRepositoryImpl): AuthRepository
}
```

## 8.7 Presentation Layer

### presentation/auth/LoginViewModel.kt

```kotlin
package com.yourname.logindemo.presentation.auth

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.yourname.logindemo.domain.model.User
import com.yourname.logindemo.domain.usecase.LoginUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

data class LoginUiState(
    val email: String = "",
    val password: String = "",
    val isLoading: Boolean = false,
    val error: String? = null,
    val user: User? = null
)

@HiltViewModel
class LoginViewModel @Inject constructor(
    private val loginUseCase: LoginUseCase
) : ViewModel() {

    private val _uiState = MutableStateFlow(LoginUiState())
    val uiState: StateFlow<LoginUiState> = _uiState.asStateFlow()

    fun updateEmail(email: String) {
        _uiState.update { it.copy(email = email) }
    }

    fun updatePassword(password: String) {
        _uiState.update { it.copy(password = password) }
    }

    fun login() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            try {
                val user = loginUseCase(
                    _uiState.value.email,
                    _uiState.value.password
                )
                _uiState.update { it.copy(isLoading = false, user = user) }
            } catch (e: Exception) {
                _uiState.update { it.copy(isLoading = false, error = e.message) }
            }
        }
    }
}
```

### presentation/auth/LoginScreen.kt

```kotlin
package com.yourname.logindemo.presentation.auth

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel

@Composable
fun LoginScreen(
    viewModel: LoginViewModel = hiltViewModel(),
    onLoginSuccess: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsState()

    if (uiState.user != null) {
        onLoginSuccess()
        return
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(
            text = "LoginDemo",
            style = MaterialTheme.typography.headlineLarge
        )

        Spacer(modifier = Modifier.height(48.dp))

        OutlinedTextField(
            value = uiState.email,
            onValueChange = { viewModel.updateEmail(it) },
            label = { Text("이메일") },
            modifier = Modifier.fillMaxWidth(),
            singleLine = true
        )

        Spacer(modifier = Modifier.height(16.dp))

        OutlinedTextField(
            value = uiState.password,
            onValueChange = { viewModel.updatePassword(it) },
            label = { Text("비밀번호") },
            modifier = Modifier.fillMaxWidth(),
            singleLine = true,
            visualTransformation = PasswordVisualTransformation()
        )

        uiState.error?.let { error ->
            Spacer(modifier = Modifier.height(8.dp))
            Text(text = error, color = MaterialTheme.colorScheme.error)
        }

        Spacer(modifier = Modifier.height(24.dp))

        Button(
            onClick = { viewModel.login() },
            modifier = Modifier.fillMaxWidth(),
            enabled = !uiState.isLoading
        ) {
            if (uiState.isLoading) {
                CircularProgressIndicator(
                    modifier = Modifier.size(24.dp),
                    color = MaterialTheme.colorScheme.onPrimary
                )
            } else {
                Text("로그인")
            }
        }
    }
}
```

## 8.8 빌드 및 실행

```bash
cd ~/WorkSpace/iOS/LoginDemo/android

# Debug APK 빌드
./gradlew assembleDebug

# 에뮬레이터에 설치
./gradlew installDebug
```

---

# STEP 9: Frontend 개발 (Next.js)

## 9.1 Next.js 프로젝트 생성

```bash
cd ~/WorkSpace/iOS/LoginDemo/frontend

# Next.js 프로젝트 생성
npx create-next-app@latest . --typescript --tailwind --app --no-src-dir

# 설정 선택:
# - ESLint: Yes
# - Tailwind CSS: Yes
# - App Router: Yes
```

## 9.2 메인 페이지 수정

### app/page.tsx

```typescript
export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-24 bg-gradient-to-b from-blue-100 to-white">
      <div className="text-center">
        <h1 className="text-6xl font-bold text-blue-600 mb-4">
          LoginDemo
        </h1>
        <p className="text-xl text-gray-600 mb-8">
          iOS, Android, Web Cross-Platform
        </p>
        <div className="flex gap-4 justify-center">
          <a
            href="/api-docs"
            className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
          >
            API Docs
          </a>
        </div>
      </div>
    </main>
  )
}
```

## 9.3 Health Check API

### app/api/health/route.ts

```typescript
export async function GET() {
  return Response.json({ status: 'ok', timestamp: new Date().toISOString() })
}
```

## 9.4 next.config.js 수정 (Standalone 빌드)

```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone',
}

module.exports = nextConfig
```

## 9.5 로컬 실행

```bash
# 개발 서버
npm run dev

# 브라우저에서 확인
open http://localhost:3001
```

---

# STEP 10: Supabase 데이터베이스 설정

## 10.1 Supabase 프로젝트 생성

1. https://supabase.com 접속
2. 회원가입/로그인
3. **New Project** 클릭
4. 설정:
   - Organization: 선택 또는 새로 생성
   - Name: **logindemo**
   - Database Password: 안전한 비밀번호 설정 (기록해두기)
   - Region: **Northeast Asia (Seoul)** - ap-northeast-2
5. **Create new project** 클릭

## 10.2 연결 문자열 확인

1. 프로젝트 대시보드에서 **Settings** → **Database**
2. **Connection string** 섹션에서:

### Session Mode (기본 연결)
```
postgresql://postgres.[project-ref]:[password]@aws-0-ap-northeast-2.pooler.supabase.com:5432/postgres
```

### Transaction Mode (Prisma용 - pgbouncer)
```
postgresql://postgres.[project-ref]:[password]@aws-0-ap-northeast-2.pooler.supabase.com:6543/postgres?pgbouncer=true
```

## 10.3 Backend .env 수정

```bash
cd ~/WorkSpace/iOS/LoginDemo/backend

cat > .env << 'EOF'
# Supabase PostgreSQL
# Transaction mode (pgbouncer) - Prisma queries
DATABASE_URL="postgresql://postgres.xxxxx:YOUR_PASSWORD@aws-0-ap-northeast-2.pooler.supabase.com:6543/postgres?pgbouncer=true"

# Session mode - Prisma migrations
DIRECT_URL="postgresql://postgres.xxxxx:YOUR_PASSWORD@aws-0-ap-northeast-2.pooler.supabase.com:5432/postgres"
EOF
```

## 10.4 Prisma 스키마에 directUrl 추가

```prisma
datasource db {
  provider  = "postgresql"
  url       = env("DATABASE_URL")
  directUrl = env("DIRECT_URL")
}
```

## 10.5 데이터베이스 마이그레이션

```bash
# Prisma Client 재생성
npx prisma generate

# 스키마를 DB에 적용
npx prisma db push

# 확인
npx prisma studio
```

---

# STEP 11: Docker 컨테이너화

## 11.1 Backend Dockerfile

```bash
cat > ~/WorkSpace/iOS/LoginDemo/backend/Dockerfile << 'EOF'
# ============================================
# Multi-stage Dockerfile for NestJS Production
# ============================================

# Stage 1: Dependencies
FROM node:20-alpine AS deps
WORKDIR /app

# Install dependencies for native modules (bcrypt)
RUN apk add --no-cache python3 make g++

COPY package*.json ./
COPY prisma ./prisma/

RUN npm ci

# Stage 2: Builder
FROM node:20-alpine AS builder
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Generate Prisma Client
RUN npx prisma generate

# Build NestJS
RUN npm run build

# Stage 3: Production
FROM node:20-alpine AS production
WORKDIR /app

ENV NODE_ENV=production

# Create non-root user
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nestjs

# Copy necessary files
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/prisma ./prisma

# Set ownership
RUN chown -R nestjs:nodejs /app

USER nestjs

EXPOSE 3000

# Start command
CMD ["sh", "-c", "npx prisma db push --skip-generate && node dist/main"]
EOF
```

## 11.2 Frontend Dockerfile

```bash
cat > ~/WorkSpace/iOS/LoginDemo/frontend/Dockerfile << 'EOF'
# ============================================
# Multi-stage Dockerfile for Next.js Production
# ============================================

# Stage 1: Dependencies
FROM node:20-alpine AS deps
WORKDIR /app

COPY package*.json ./
RUN npm ci

# Stage 2: Builder
FROM node:20-alpine AS builder
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Build argument for API URL
ARG NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL

RUN npm run build

# Stage 3: Production
FROM node:20-alpine AS production
WORKDIR /app

ENV NODE_ENV=production

# Create non-root user
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Copy built files
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

# Set ownership
RUN chown -R nextjs:nodejs /app

USER nextjs

EXPOSE 3000

ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

CMD ["node", "server.js"]
EOF
```

## 11.3 docker-compose.yml

```bash
cat > ~/WorkSpace/iOS/LoginDemo/docker-compose.yml << 'EOF'
# ============================================
# Docker Compose - LoginDemo
# ============================================

services:
  # NestJS API Server
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: logindemo-backend
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - PORT=3000
      - DATABASE_URL=${DATABASE_URL}
      - DIRECT_URL=${DIRECT_URL}
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3000/v1/init"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 10s
    networks:
      - app-network

  # Next.js Frontend
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
      args:
        - NEXT_PUBLIC_API_URL=
    container_name: logindemo-frontend
    restart: unless-stopped
    ports:
      - "3001:3000"
    environment:
      - NODE_ENV=production
    depends_on:
      backend:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 10s
    networks:
      - app-network

  # Nginx Reverse Proxy
  nginx:
    image: nginx:alpine
    container_name: logindemo-nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
      - /etc/letsencrypt:/etc/letsencrypt:ro
      - /var/www/certbot:/var/www/certbot:ro
    depends_on:
      - frontend
      - backend
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
EOF
```

## 11.4 nginx.conf

```bash
cat > ~/WorkSpace/iOS/LoginDemo/nginx.conf << 'EOF'
# HTTP -> HTTPS 리다이렉트
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

# HTTPS 서버
server {
    listen 443 ssl;
    server_name your-domain.com www.your-domain.com;

    # SSL 인증서
    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;

    # SSL 설정
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers off;

    # Frontend (Next.js)
    location / {
        proxy_pass http://logindemo-frontend:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Backend API
    location /v1 {
        proxy_pass http://logindemo-backend:3000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Swagger API Docs
    location /api-docs {
        proxy_pass http://logindemo-backend:3000;
        proxy_set_header Host $host;
    }
}
EOF
```

## 11.5 로컬 Docker 테스트

```bash
cd ~/WorkSpace/iOS/LoginDemo

# .env 파일 생성
cat > .env << 'EOF'
DATABASE_URL="postgresql://postgres.xxxxx:password@aws-0-ap-northeast-2.pooler.supabase.com:6543/postgres?pgbouncer=true"
DIRECT_URL="postgresql://postgres.xxxxx:password@aws-0-ap-northeast-2.pooler.supabase.com:5432/postgres"
EOF

# 빌드 및 실행 (nginx 제외 - SSL 인증서 없음)
docker compose up backend frontend -d --build

# 상태 확인
docker compose ps

# 로그 확인
docker compose logs -f
```

---

# STEP 12: Hostinger VPS 배포

## 12.1 Hostinger VPS 구매

1. https://www.hostinger.com 접속
2. VPS 플랜 선택 (KVM 1 이상 권장)
3. OS: **Ubuntu 24.04 LTS** 선택
4. 초기 root 비밀번호 설정

## 12.2 SSH 접속

```bash
# VPS IP 확인 후 접속
ssh root@YOUR_VPS_IP

# 비밀번호 입력
```

## 12.3 사용자 계정 생성

```bash
# 새 사용자 생성
adduser deploy

# sudo 권한 부여
usermod -aG sudo deploy

# SSH 키 복사
mkdir -p /home/deploy/.ssh
cp ~/.ssh/authorized_keys /home/deploy/.ssh/
chown -R deploy:deploy /home/deploy/.ssh
chmod 700 /home/deploy/.ssh
chmod 600 /home/deploy/.ssh/authorized_keys

# 이후 새 계정으로 접속
exit
ssh deploy@YOUR_VPS_IP
```

## 12.4 시스템 업데이트

```bash
sudo apt update
sudo apt upgrade -y
```

## 12.5 방화벽 설정

```bash
# SSH 허용
sudo ufw allow OpenSSH

# HTTP/HTTPS 허용
sudo ufw allow 80
sudo ufw allow 443

# 방화벽 활성화
sudo ufw enable

# 상태 확인
sudo ufw status
```

## 12.6 Docker 설치

```bash
# 필수 패키지 설치
sudo apt install -y ca-certificates curl gnupg lsb-release

# Docker GPG 키 추가
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Docker 저장소 추가
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Docker 설치
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Docker 서비스 시작
sudo systemctl start docker
sudo systemctl enable docker

# 현재 사용자를 docker 그룹에 추가
sudo usermod -aG docker $USER

# 재접속
exit
ssh deploy@YOUR_VPS_IP

# 설치 확인
docker --version
docker compose version
```

## 12.7 프로젝트 배포

```bash
# 프로젝트 디렉토리 생성
sudo mkdir -p /var/www/logindemo
sudo chown -R $USER:$USER /var/www/logindemo
cd /var/www/logindemo

# Git 클론 (또는 로컬에서 파일 전송)
git clone https://github.com/your-repo/logindemo.git .

# 환경 변수 파일 생성
cat > .env << 'EOF'
DATABASE_URL="postgresql://postgres.xxxxx:password@aws-0-ap-northeast-2.pooler.supabase.com:6543/postgres?pgbouncer=true"
DIRECT_URL="postgresql://postgres.xxxxx:password@aws-0-ap-northeast-2.pooler.supabase.com:5432/postgres"
EOF

# 권한 설정
chmod 600 .env
```

## 12.8 도메인 DNS 설정

Hostinger 대시보드 또는 도메인 등록 업체에서 DNS 설정:

| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | @ | YOUR_VPS_IP | 14400 |
| A | www | YOUR_VPS_IP | 14400 |

```bash
# DNS 전파 확인
dig your-domain.com +short
```

---

# STEP 13: SSL/HTTPS 설정

## 13.1 Certbot 설치

```bash
sudo apt update
sudo apt install certbot -y
```

## 13.2 SSL 인증서 발급

```bash
# Docker 중지 (포트 80 해제)
cd /var/www/logindemo
sudo docker compose down

# SSL 인증서 발급
sudo certbot certonly --standalone -d your-domain.com -d www.your-domain.com

# 입력:
# 1. 이메일 주소
# 2. 약관 동의 (Y)
# 3. 이메일 수신 동의 (선택)
```

## 13.3 nginx.conf 도메인 수정

```bash
# nginx.conf의 your-domain.com을 실제 도메인으로 변경
sed -i 's/your-domain.com/actual-domain.com/g' nginx.conf
```

## 13.4 Docker 재시작

```bash
# 빌드 및 실행
sudo docker compose up -d --build

# 상태 확인
sudo docker compose ps

# 로그 확인
sudo docker compose logs -f
```

## 13.5 HTTPS 접속 확인

```bash
# HTTPS 접속 확인
curl -I https://your-domain.com

# HTTP 리다이렉트 확인
curl -I http://your-domain.com

# API 테스트
curl https://your-domain.com/v1/init
```

---

# STEP 14: 운영 및 유지보수

## 14.1 로그 확인

```bash
# 전체 로그
sudo docker compose logs -f

# 특정 서비스 로그
sudo docker compose logs backend --tail=100
sudo docker compose logs frontend --tail=100
sudo docker compose logs nginx --tail=100
```

## 14.2 서비스 재시작

```bash
# 전체 재시작
sudo docker compose restart

# 특정 서비스 재시작
sudo docker compose restart backend
```

## 14.3 코드 업데이트 배포

```bash
cd /var/www/logindemo

# 최신 코드 가져오기
sudo git pull

# 재빌드 및 재시작
sudo docker compose down
sudo docker compose up -d --build
```

## 14.4 SSL 인증서 갱신

```bash
# Let's Encrypt 인증서는 90일 유효
# 수동 갱신:
sudo docker compose down
sudo certbot renew
sudo docker compose up -d
```

## 14.5 디스크 정리

```bash
# Docker 미사용 리소스 정리
sudo docker system prune -a

# 디스크 사용량 확인
df -h
sudo docker system df
```

---

# 부록: 명령어 레퍼런스

## 로컬 개발

```bash
# Backend
cd backend && npm run start:dev

# iOS
cd ios && open LoginDemo.xcodeproj  # Cmd+R로 실행

# Android
cd android && ./gradlew installDebug

# Frontend
cd frontend && npm run dev
```

## Docker

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

## VPS 운영

```bash
# SSH 접속
ssh deploy@YOUR_VPS_IP

# 프로젝트 경로
cd /var/www/logindemo

# 업데이트 배포
sudo git pull && sudo docker compose up -d --build

# 로그 확인
sudo docker compose logs -f
```

## Speckit 명령어 (Claude Code)

```bash
/specify      # Feature 명세 생성
/clarify      # 명세 보완
/plan         # 구현 계획
/tasks        # 작업 목록
/analyze      # 일관성 검증
/implement    # 코드 구현
```

---

# 체크리스트

## 최초 배포 체크리스트

- [ ] 개발 환경 설정 완료
- [ ] 프로젝트 초기화 완료
- [ ] Speckit 헌법 수립
- [ ] Feature 명세 작성
- [ ] TypeSpec API 명세 작성
- [ ] Backend 구현 완료
- [ ] iOS 앱 구현 완료
- [ ] Android 앱 구현 완료
- [ ] Frontend 구현 완료
- [ ] Supabase 데이터베이스 설정
- [ ] Docker 컨테이너화
- [ ] VPS 서버 설정
- [ ] 도메인 DNS 설정
- [ ] SSL 인증서 발급
- [ ] 프로덕션 배포 완료
- [ ] HTTPS 접속 확인

---

**작성 완료일**: 2026-01-18
**작성자**: Claude Code
**문서 버전**: 1.0.0
