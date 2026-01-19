# LoginDemo: Complete Development & Deployment Manual
> 명세 주도 개발(SDD) 기반 iOS/Android/Backend 크로스플랫폼 인증 시스템 완전 재현 매뉴얼

**Version**: 1.0.0  
**Date**: 2026-01-18  
**Purpose**: 이 문서를 처음부터 순서대로 따라 수행하면 지금까지의 모든 결과물을 동일하게 재현할 수 있는 완전한 작업 절차서

---

## 목차

### PART I: 선행 준비 및 환경 설정
1. [개요 및 아키텍처 이해](#1-개요-및-아키텍처-이해)
2. [개발 환경 구축](#2-개발-환경-구축)
3. [프로젝트 초기화](#3-프로젝트-초기화)

### PART II: 명세 주도 개발 워크플로우
4. [프로젝트 헌법 수립](#4-프로젝트-헌법-수립)
5. [Speckit 시스템 설정](#5-speckit-시스템-설정)
6. [Feature 명세 작성 프로세스](#6-feature-명세-작성-프로세스)
7. [TypeSpec 기반 API 설계](#7-typespec-기반-api-설계)

### PART III: Backend 구현
8. [NestJS 프로젝트 초기화](#8-nestjs-프로젝트-초기화)
9. [Prisma 데이터베이스 스키마 설계](#9-prisma-데이터베이스-스키마-설계)
10. [인증 API 구현](#10-인증-api-구현)
11. [Token Rotation 구현](#11-token-rotation-구현)

### PART IV: iOS 구현
12. [iOS 프로젝트 구조 설정](#12-ios-프로젝트-구조-설정)
13. [Domain Layer 구현](#13-domain-layer-구현)
14. [Data Layer 구현](#14-data-layer-구현)
15. [Presentation Layer 구현](#15-presentation-layer-구현)

### PART V: Android 구현
16. [Android 프로젝트 구조 설정](#16-android-프로젝트-구조-설정)
17. [Hilt 기반 DI 구성](#17-hilt-기반-di-구성)
18. [Clean Architecture 레이어 구현](#18-clean-architecture-레이어-구현)

### PART VI: Frontend 구현
19. [Next.js 프로젝트 설정](#19-nextjs-프로젝트-설정)
20. [Main Page 구현](#20-main-page-구현)

### PART VII: 로컬 테스트 및 통합
21. [로컬 통합 테스트](#21-로컬-통합-테스트)
22. [End-to-End 플로우 검증](#22-end-to-end-플로우-검증)

### PART VIII: 배포 및 운영
23. [Docker 컨테이너화](#23-docker-컨테이너화)
24. [VPS 서버 초기 설정](#24-vps-서버-초기-설정)
25. [배포 실행](#25-배포-실행)
26. [SSL/HTTPS 설정](#26-sslhttps-설정)
27. [모니터링 및 유지보수](#27-모니터링-및-유지보수)

### PART IX: 확장 및 트러블슈팅
28. [신규 Feature 추가 프로세스](#28-신규-feature-추가-프로세스)
29. [트러블슈팅 가이드](#29-트러블슈팅-가이드)
30. [부록: 명령어 레퍼런스](#30-부록-명령어-레퍼런스)

---

# PART I: 선행 준비 및 환경 설정

## 1. 개요 및 아키텍처 이해

### 1.1 프로젝트 개요

**LoginDemo**는 다음과 같은 특징을 가진 크로스플랫폼 모바일 인증 시스템입니다:

| 구분 | 내용 |
|------|------|
| **개발 방법론** | 명세 주도 개발 (Specification-Driven Development) |
| **아키텍처** | Clean Architecture + Dependency Inversion |
| **플랫폼** | iOS (SwiftUI), Android (Jetpack Compose), Web (Next.js) |
| **백엔드** | NestJS + Prisma + PostgreSQL |
| **API 계약** | TypeSpec → OpenAPI 3.0 |
| **배포** | Docker + Nginx + Let's Encrypt (VPS) |

### 1.2 개발 흐름 (Work Flow)

```
┌──────────────────────────────────────────────────────────────────┐
│                  Specification-Driven Development                │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Step 1: Constitution (헌법)                                     │
│  └─ 프로젝트의 불변 원칙 및 코딩 규칙 정의                           │
│                                                                  │
│  Step 2: Feature Specification (Speckit)                        │
│  ├─ /specify  → spec.md (요구사항)                               │
│  ├─ /clarify  → spec.md 보완                                     │
│  ├─ /plan     → plan.md, data-model.md                          │
│  └─ /tasks    → tasks.md                                         │
│                                                                  │
│  Step 3: API Contract (TypeSpec)                                │
│  └─ main.tsp → openapi.yaml 생성                                 │
│                                                                  │
│  Step 4: Backend     Step 5: iOS       Step 6: Android          │
│  (NestJS+Prisma)     (SwiftUI)        (Compose)    (병렬 개발)   │
│                                                                  │
│  Step 7: Integration Testing & Deployment                       │
│  └─ Docker → VPS → SSL → Production                             │
└──────────────────────────────────────────────────────────────────┘
```

### 1.3 프로젝트 디렉토리 구조

```
LoginDemo/
├── .specify/                    # Speckit 템플릿 및 헌법
│   ├── memory/constitution.md  # 프로젝트 헌법 (불변 원칙)
│   ├── templates/               # spec, plan, tasks 템플릿
│   └── scripts/                 # Speckit 자동화 스크립트
│
├── specs/                       # Feature 명세서 모음
│   ├── 001-auth-onboarding-flow/
│   │   ├── spec.md              # 요구사항 (User Stories)
│   │   ├── plan.md              # 구현 계획
│   │   ├── tasks.md             # 작업 목록 (139 tasks)
│   │   ├── data-model.md        # 데이터 모델
│   │   ├── research.md          # 기술 조사
│   │   ├── quickstart.md        # 빠른 시작 가이드
│   │   ├── checklists/          # 체크리스트
│   │   └── contracts/           # API 명세
│   └── 002-main-tab-navigation/
│
├── typespec/                    # API 명세 (Single Source of Truth)
│   ├── main.tsp                 # TypeSpec 정의
│   ├── tspconfig.yaml           # TypeSpec 설정
│   ├── package.json
│   └── tsp-output/              # 생성된 OpenAPI 스펙
│
├── backend/                     # NestJS Backend
│   ├── src/
│   │   ├── auth/                # 인증 모듈
│   │   ├── prisma/              # Prisma 서비스
│   │   ├── system/              # 시스템 API
│   │   └── common/              # 공통 DTO, Enums
│   ├── prisma/schema.prisma     # DB 스키마
│   ├── Dockerfile               # 백엔드 Docker 이미지
│   └── package.json
│
├── ios/                         # iOS App (SwiftUI)
│   └── LoginDemo/
│       ├── App/                 # 앱 진입점, DI Container
│       ├── Domain/              # 비즈니스 로직 (Entities, UseCases)
│       ├── Data/                # 데이터 접근 (Repositories, DTOs)
│       ├── Presentation/        # UI (Views, ViewModels)
│       └── Core/                # 공통 유틸리티
│
├── android/                     # Android App (Jetpack Compose)
│   └── app/src/main/java/com/dyjung/logindemo/
│       ├── di/                  # Hilt 모듈
│       ├── domain/              # Domain Layer
│       ├── data/                # Data Layer
│       ├── presentation/        # Presentation Layer
│       └── core/                # 공통 유틸리티
│
├── frontend/                    # Next.js Frontend
│   ├── src/app/
│   ├── Dockerfile
│   └── package.json
│
├── shared/                      # 공유 리소스
│   ├── api-contracts/openapi.yaml
│   └── localization/            # 다국어 (ko.json, en.json)
│
├── docker-compose.yml           # 통합 Docker 구성
├── nginx.conf                   # Nginx 리버스 프록시 설정
├── Makefile                     # 빌드 명령어 통합
├── CLAUDE.md                    # Claude Code 가이드
├── WORK_ORDER.md                # 작업 명세서
├── MANUAL.md                    # 프로젝트 매뉴얼
├── MANUAL_VPS_DEPLOY.md         # VPS 배포 매뉴얼
└── docs/DEVELOPMENT_WORKFLOW_MANUAL.md  # 개발 워크플로우

```

---

## 2. 개발 환경 구축

### 2.1 필수 소프트웨어 설치

#### macOS (모든 플랫폼 개발 가능)

```bash
# Homebrew 설치 (아직 없다면)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Node.js 20+ (Backend, TypeSpec, Frontend용)
brew install node@20
echo 'export PATH="/opt/homebrew/opt/node@20/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
node --version  # v20.x.x 확인

# PostgreSQL (로컬 DB)
brew install postgresql@16
brew services start postgresql@16

# Docker Desktop
# https://www.docker.com/products/docker-desktop/ 에서 다운로드 및 설치

# Git
brew install git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

#### iOS 개발 환경

```bash
# Xcode 15+ 설치 (App Store에서)
# Command Line Tools 설치
xcode-select --install

# iOS Simulator 확인
xcrun simctl list devices
```

#### Android 개발 환경

1. **Android Studio Hedgehog+** 다운로드: https://developer.android.com/studio
2. Installation Wizard에서:
   - ✅ Android SDK
   - ✅ Android SDK Platform
   - ✅ Android Virtual Device (AVD)
3. SDK Manager에서 설치:
   - Android SDK Platform 34 (API Level 34)
   - Android SDK Build-Tools
   - Android Emulator

```bash
# ANDROID_HOME 환경 변수 설정
echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/emulator' >> ~/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.zshrc
source ~/.zshrc
```

### 2.2 TypeSpec 설치

```bash
# 전역 설치 (권장)
npm install -g @typespec/compiler

# 설치 확인
tsp --version
```

---

## 3. 프로젝트 초기화

### 3.1 프로젝트 디렉토리 생성

```bash
# 프로젝트 루트 디렉토리 생성
mkdir LoginDemo
cd LoginDemo

# Git 초기화
git init

# 기본 폴더 구조 생성
mkdir -p .specify/memory .specify/templates .specify/scripts
mkdir -p specs docs shared/api-contracts shared/localization
mkdir -p ios android frontend backend typespec

# .gitignore  작성
cat > .gitignore << 'EOF'
# macOS
.DS_Store

# IDE
.vscode/
.idea/
*.swp

# Dependencies
node_modules/
.pnp
.pnp.js

# Environment
.env
.env.local

# Build outputs
dist/
build/
*.log
EOF
```

### 3.2 Makefile 작성

```makefile
# Makefile
.PHONY: help setup build test clean ios-build ios-test android-build android-test

help:
\t@echo "LoginDemo - Build Commands"
\t@echo ""
\t@echo "setup          - Check environment and install dependencies"
\t@echo "build          - Build all platforms (iOS,Android,Backend,Frontend)"
\t@echo "test           - Run all tests"
\t@echo "clean          - Clean all build artifacts"
\t@echo ""
\t@echo "iOS:"
\t@echo "  ios-build    - Build iOS Debug"
\t@echo "  ios-test     - Run iOS unit tests"
\t@echo "  ios-release  - Build iOS Release"
\t@echo ""
\t@echo "Android:"
\t@echo "  android-build   - Build Android Debug APK"
\t@echo "  android-test    - Run Android unit tests"
\t@echo "  android-release - Build Android Release APK"
\t@echo ""
\t@echo "Backend:"
\t@echo "  backend-dev  - Run backend dev server"
\t@echo "  backend-build - Build backend for production"

setup:
\t@echo "Checking environment..."
\t@command -v node || (echo "Node.js not found"; exit 1)
\t@command -v docker || (echo "Docker not found"; exit 1)
\t@echo "Environment OK"

ios-build:
\tcd ios && xcodebuild -project LoginDemo.xcodeproj -scheme LoginDemo -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' build

ios-test:
\tcd ios && xcodebuild test -project LoginDemo.xcodeproj -scheme LoginDemo -destination 'platform=iOS Simulator,name=iPhone 15'

android-build:
\tcd android && ./gradlew assembleDebug

android-test:
\tcd android && ./gradlew test

backend-dev:
\tcd backend && npm run start:dev

backend-build:
\tcd backend && npm run build
```

### 3.3 Initial Commit

```bash
git add .
git commit -m "chore: Initial project structure"
```

---

# PART II: 명세 주도 개발 워크플로우

## 4. 프로젝트 헌법 수립

### 4.1 헌법(Constitution)이란?

프로젝트의 **불변 원칙**을 정의하는 문서입니다. 모든 코드와 설계 결정은 이 헌법을 준수해야 합니다.

### 4.2 헌법 작성

```bash
# Constitution 파일 생성
cat > .specify/memory/constitution.md << 'EOF'
# LoginDemo 프로젝트 헌법

**Version**: 1.1.0  
**Ratified**: 2026-01-07  
**Last Amended**: 2026-01-07

## 핵심 원칙

### I. SwiftUI 우선 (SwiftUI-First)
모든 UI 컴포넌트는 반드시 SwiftUI로 구현해야 합니다.

### II. 클린 아키텍처 (Clean Architecture)
모든 코드는 클린 아키텍처의 레이어 분리 원칙을 반드시 따라야 합니다.

#### 레이어 구조 (의존성 방향: 외부 → 내부)
```
┌─────────────────────────────────────────────────┐
│           Presentation Layer (외부)              │
│         Views, ViewModels, UI Components        │
├─────────────────────────────────────────────────┤
│              Domain Layer (핵심)                 │
│      Entities, Use Cases, Repository Protocol   │
├─────────────────────────────────────────────────┤
│               Data Layer (외부)                  │
│   Repository Impl, DataSources, DTOs, Mappers   │
└─────────────────────────────────────────────────┘
```

### III. 테스트 주도 개발 (Test-First)
테스트 코드는 구현 코드보다 먼저 작성해야 합니다.

### IV. 상태 관리 일관성
- 로컬 뷰 상태: `@State`
- ViewModel: `@Observable` (iOS 17+)
- 전역 앱 상태: `@Environment`

### V. 접근성 필수
모든 인터랙티브 요소에 `accessibilityLabel` 제공 필수.

### VI. 단순성 우선
YAGNI 원칙: 현재 필요하지 않은 기능은 구현하지 않음.

### VII. 보안 최우선
- 비밀번호, 토큰은 반드시 Keychain 저장
- HTTPS Only
- 자동로그인 토큰은 암호화하여 Keychain 저장

## 파일 구조 (Clean Architecture)

```
LoginDemo/
├── App/               # 앱 진입점, DI Container
├── Domain/            # Entities, UseCases, Repository Protocols
├── Data/              # Repository Impl, DTOs, DataSources, Mappers
├── Presentation/      # Views, ViewModels
└── Core/              # 공통 유틸리티
```

EOF
```

### 4.3 CLAUDE.md 작성

Claude Code가 프로젝트 컨텍스트를 이해하도록 가이드 문서를 작성합니다.

```bash
cat > CLAUDE.md << 'EOF'
# CLAUDE.md

## Project Structure
- **ios/**: iOS (SwiftUI)
- **android/**: Android (Jetpack Compose)
- **backend/**: NestJS + Prisma
- **frontend/**: Next.js
- **typespec/**: API Contract (TypeSpec)
- **specs/**: Feature Specifications

## Architecture
Clean Architecture + Dependency Inversion

## Build Commands
```bash
make ios-build
make android-build
make backend-dev
```

## Active Technologies
- Swift 5.9+, SwiftUI, Alamofire
- Kotlin 1.9+, Jetpack Compose, Hilt
- TypeScript, NestJS, Prisma
EOF
```

---

## 5. Speckit 시스템 설정

본 프로젝트는 Claude Code의 Custom Commands인 **Speckit**을 사용합니다.

### 5.1 Speckit이란?

Feature 개발을 체계적으로 진행하기 위한 명세 기반 워크플로우 도구입니다.

| 명령어 | 설명 | 산출물 |
|--------|------|--------|
| `/specify` | 기능 명세 작성 | spec.md, checklists/, quickstart.md |
| `/clarify` | 명세 검토 및 보완 | spec.md 업데이트 |
| `/plan` | 구현 계획 수립 | plan.md, data-model.md, contracts/ |
| `/tasks` | 작업 목록 생성 | tasks.md |
| `/implement` | 작업 구현 | 실제 코드 |

### 5.2 Speckit 템플릿 설치

```bash
# spec-template.md
cat > .specify/templates/spec-template.md << 'EOF'
# Feature Specification: {기능명}

**Feature Branch**: `{순번}-{기능명-케밥케이스}`  
**Created**: YYYY-MM-DD  
**Status**: Draft

## User Scenarios & Testing

### User Story 1 - {스토리명} (Priority: P1)
- **Given** {조건}
- **When** {행동}
- **Then** {결과}

## Requirements

### Functional Requirements
- **FR-001**: {요구사항 설명}

### Non-Functional Requirements
- **NFR-001**: {성능, 보안 등}

## Success Criteria
- **SC-001**: {측정 가능한 성공 기준}
EOF
```

---

## 6. Feature 명세 작성 프로세스

### 6.1 Feature 001: 인증 및 온보딩 플로우

#### Step 1: /specify 실행

Claude Code에서 다음과 같이 요청합니다:

```
/specify

SwiftUI 앱의 Splash, Onboarding, 로그인/회원가입 화면 구현.
이메일/비밀번호 로그인과 소셜 로그인(카카오, 네이버, Apple) 지원.
자동로그인 기능 포함.
```

#### Step 2: spec.md 생성됨

```
specs/001-auth-onboarding-flow/
├── spec.md
├── checklists/requirements.md
└── quickstart.md
```

#### Step 3: /clarify 실행

```
/clarify
```

Claude가 불명확한 부분을 질문합니다:
- "비밀번호 복잡성 요구사항은?"
- "자동로그인 토큰 유효 기간은?"
- "소셜 로그인 실패 시 대응 방안은?"

사용자가 답변하면 `spec.md`가 업데이트됩니다.

#### Step 4: /plan 실행

```
/plan
```

생성되는 산출물:
```
specs/001-auth-onboarding-flow/
├── plan.md              # 아키텍처, 레이어 설계
├── data-model.md        # Entity, DTO 모델
├── research.md          # 기술 조사
└── contracts/auth-api.yaml  # API 명세
```

#### Step 5: /tasks 실행

```
/tasks
```

생성되는 산출물:
```
specs/001-auth-onboarding-flow/tasks.md  # 139개 Task
```

**tasks.md 예시:**
```markdown
# Tasks: 001-auth-onboarding-flow

## Phase 1: Setup (T001-T009)
- [ ] T001 Create folder structure
- [ ] T002 [P] Add SPM dependencies (Alamofire)
- [ ] T003 [P] Configure Info.plist

## Phase 2: Foundational (T010-T054)
- [ ] T010 [P] Create User entity
- [ ] T011 [P] Create AuthToken entity
- [ ] T012 [P] Create AuthRepositoryProtocol
...

## Phase 3: US1 - Splash Screen (T055-T066)
### Tests
- [ ] T055 [P] [US1] SplashViewModelTests
### Implementation
- [ ] T057 [US1] Create SplashViewModel
- [ ] T058 [US1] Create SplashView
...
```

#### Step 6: /implement 실행

```
/implement
```

Claude가 tasks.md를 읽고 순차적으로 구현합니다.

---

## 7. TypeSpec 기반 API 설계

### 7.1 TypeSpec 프로젝트 초기화

```bash
cd typespec

# package.json 생성
cat > package.json << 'EOF'
{
  "name": "logindemo-typespec",
  "version": "1.0.0",
  "dependencies": {
    "@typespec/compiler": "^0.60.0",
    "@typespec/http": "^0.60.0",
    "@typespec/rest": "^0.60.0",
    "@typespec/openapi3": "^0.60.0"
  }
}
EOF

npm install

# tspconfig.yaml 생성
cat > tspconfig.yaml << 'EOF'
emit:
  - "@typespec/openapi3"
options:
  "@typespec/openapi3":
    output-file: "openapi.yaml"
EOF
```

### 7.2 main.tsp 작성

```bash
cat > main.tsp << 'EOF'
import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi3";

using TypeSpec.Http;
using TypeSpec.Rest;

@service({
  title: "LoginDemo API",
  version: "1.0"
})
namespace LoginDemoAPI;

// ===== Enums =====
enum AuthenticationMethod {
  EMAIL, KAKAO, NAVER, APPLE, GOOGLE
}

enum UserStatus {
  ACTIVE, SLEEP, SUSPENDED, DELETED
}

enum Platform {
  IOS, ANDROID, WEB
}

// ===== Models =====
model User {
  id: string;
  email?: string;
  nickname: string;
  status: UserStatus;
  marketingConsent: boolean;
  createdAt: utcDateTime;
  lastLogin?: utcDateTime;
  updatedAt?: utcDateTime;
}

model AuthToken {
  accessToken: string;
  refreshToken: string;
  expiresIn: int32;
}

// ===== Request/Response DTOs =====
model CommonClientHeaders {
  @header("X-App-Version") appVersion: string;
  @header("X-Platform") platform: Platform;
  @header("X-Device-Id") deviceId?: string;
}

model LoginRequest {
  provider: AuthenticationMethod;
  email?: string;
  password?: string;
  socialAccessToken?: string;
}

model LoginResponse {
  user: User;
  accessToken: string;
  refreshToken: string;
  expiresIn: int32;
}

model RegisterRequest {
  provider: AuthenticationMethod;
  email: string;
  password: string;
  nickname: string;
  marketingConsent: boolean;
}

model RegisterResponse {
  user: User;
  accessToken: string;
  refreshToken: string;
  expiresIn: int32;
}

// ===== API Endpoints =====
@route("/v1/auth")
namespace Auth {
  @post
  @route("/register")
  op register(
    ...CommonClientHeaders,
    @body request: RegisterRequest
  ): RegisterResponse | ErrorResponse;

  @post
  @route("/login")
  op login(
    ...CommonClientHeaders,
    @body request: LoginRequest
  ): LoginResponse | ErrorResponse;

  @post
  @route("/refresh")
  op refresh(
    ...CommonClientHeaders,
    @body request: { refreshToken: string }
  ): { accessToken: string, refreshToken: string } | ErrorResponse;

  @get
  @route("/verify")
  op verify(
    ...CommonClientHeaders,
    @header Authorization: string
  ): { user: User } | ErrorResponse;

  @post
  @route("/logout")
  op logout(
    ...CommonClientHeaders,
    @body request: { refreshToken: string, allDevices?: boolean }
  ): { success: boolean } | ErrorResponse;
}

model ErrorResponse {
  statusCode: int32;
  message: string;
  error: string;
}
EOF
```

### 7.3 OpenAPI 생성

```bash
npx tsp compile .
# 결과: tsp-output/@typespec/openapi3/openapi.yaml 생성됨

# OpenAPI를 shared 폴더로 복사
cp tsp-output/@typespec/openapi3/openapi.yaml ../shared/api-contracts/
```

---

# PART III: Backend 구현

## 8. NestJS 프로젝트 초기화

### 8.1 NestJS CLI로 프로젝트 생성

```bash
cd backend

# NestJS 프로젝트 초기화
npx -y @nestjs/cli new . --skip-git

# 필수 의존성 설치
npm install @prisma/client bcrypt class-validator class-transformer @nestjs/swagger
npm install -D prisma @types/bcrypt

# Prisma 초기화
npx prisma init
```

### 8.2 환경 변수 설정

```bash
# .env.example 생성
cat > .env.example << 'EOF'
# Database
DATABASE_URL="postgresql://postgres.xxxxx:password@host:6543/postgres?pgbouncer=true"
DIRECT_URL="postgresql://postgres.xxxxx:password@host:5432/postgres"

# JWT
JWT_SECRET="your-secret-key-change-in-production"
JWT_EXPIRES_IN="3600s"

# App
NODE_ENV="development"
PORT=3000
EOF

# 실제 .env 파일 생성 (DATABASE_URL 수정 필요)
cp .env.example .env
```

---

## 9. Prisma 데이터베이스 스키마 설계

### 9.1 schema.prisma 작성

```prisma
// prisma/schema.prisma

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
  directUrl = env("DIRECT_URL")
}

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

model AuthenticationAccount {
  id           String   @id @default(uuid())
  method       AuthenticationMethod
  providerId   String?
  passwordHash String?
  userId       String
  createdAt    DateTime @default(now())
  updatedAt    DateTime @updatedAt

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@unique([method, providerId])
  @@unique([userId, method])
  @@index([userId])
  @@map("authentication_accounts")
}

model RefreshToken {
  id            String   @id @default(uuid())
  tokenHash     String   @unique
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

### 9.2 Prisma 마이그레이션 실행

```bash
# DB 스키마 적용
npx prisma db push

# Prisma Client 생성
npx prisma generate

# Prisma Studio 실행 (GUI로 DB 확인 가능)
npx prisma studio
# http://localhost:5555 에서 확인
```

---

## 10. 인증 API 구현

### 10.1 Prisma 모듈 생성

```typescript
// src/prisma/prisma.module.ts
import { Module, Global } from '@nestjs/common';
import { PrismaService } from './prisma.service';

@Global()
@Module({
  providers: [PrismaService],
  exports: [PrismaService],
})
export class PrismaModule {}
```

```typescript
// src/prisma/prisma.service.ts
import { Injectable, OnModuleInit } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit {
  async onModuleInit() {
    await this.$connect();
  }
}
```

### 10.2 Auth 모듈 생성

```bash
nest generate module auth
nest generate controller auth
nest generate service auth
```

### 10.3 Password Utility 구현

```typescript
// src/common/utils/password.util.ts
import * as bcrypt from 'bcrypt';

const SALT_ROUNDS = 10;

export async function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, SALT_ROUNDS);
}

export async function verifyPassword(
  password: string,
  hash: string,
): Promise<boolean> {
  return bcrypt.compare(password, hash);
}
```

### 10.4 DTOs 정의

```typescript
// src/common/dto.ts
import { IsEmail, IsEnum, IsString, MinLength, IsBoolean, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export enum AuthenticationMethod {
  EMAIL = 'EMAIL',
  KAKAO = 'KAKAO',
  NAVER = 'NAVER',
  APPLE = 'APPLE',
  GOOGLE = 'GOOGLE',
}

export enum Platform {
  IOS = 'iOS',
  ANDROID = 'Android',
  WEB = 'Web',
}

export class RegisterRequestDTO {
  @ApiProperty()
  @IsEnum(AuthenticationMethod)
  provider: AuthenticationMethod;

  @ApiProperty()
  @IsEmail()
  email: string;

  @ApiProperty()
  @IsString()
  @MinLength(8)
  password: string;

  @ApiProperty()
  @IsString()
  nickname: string;

  @ApiProperty()
  @IsBoolean()
  marketingConsent: boolean;
}

export class RegisterResponseDTO {
  @ApiProperty()
  user: any;

  @ApiProperty()
  accessToken: string;

  @ApiProperty()
  refreshToken: string;

  @ApiProperty()
  expiresIn: number;
}

export class LoginRequestDTO {
  @ApiProperty()
  @IsEnum(AuthenticationMethod)
  provider: AuthenticationMethod;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsEmail()
  email?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  password?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  socialAccessToken?: string;
}

export class LoginResponseDTO {
  @ApiProperty()
  user: any;

  @ApiProperty()
  accessToken: string;

  @ApiProperty()
  refreshToken: string;

  @ApiProperty()
  expiresIn: number;
}
```

### 10.5 Auth Service 구현

```typescript
// src/auth/auth.service.ts
import { Injectable, ConflictException, UnauthorizedException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { RegisterRequestDTO, RegisterResponseDTO, LoginRequestDTO, LoginResponseDTO } from '../common/dto';
import { hashPassword, verifyPassword } from '../common/utils/password.util';
import { createHash, randomBytes } from 'crypto';

@Injectable()
export class AuthService {
  constructor(private readonly prisma: PrismaService) {}

  async register(dto: RegisterRequestDTO): Promise<RegisterResponseDTO> {
    // 1. 이메일 중복 체크
    const existing = await this.prisma.user.findUnique({
      where: { email: dto.email },
    });
    if (existing) {
      throw new ConflictException('Email already exists');
    }

    // 2. 비밀번호 해싱
    const passwordHash = await hashPassword(dto.password);

    // 3. User + AuthenticationAccount 생성
    const user = await this.prisma.user.create({
      data: {
        email: dto.email,
        nickname: dto.nickname,
        marketingConsent: dto.marketingConsent,
        authenticationAccounts: {
          create: {
            method: dto.provider,
            passwordHash,
          },
        },
      },
    });

    // 4. 토큰 생성
    const tokens = await this.createTokensForUser(user.id);

    return {
      user,
      ...tokens,
    };
  }

  async login(dto: LoginRequestDTO): Promise<LoginResponseDTO> {
    // 1. 사용자 조회
    const user = await this.prisma.user.findUnique({
      where: { email: dto.email },
      include: { authenticationAccounts: true },
    });
    if (!user) {
      throw new UnauthorizedException('Invalid email or password');
    }

    // 2. 비밀번호 검증
    const account = user.authenticationAccounts.find(
      (a) => a.method === dto.provider,
    );
    if (!account) {
      throw new UnauthorizedException('Invalid email or password');
    }

    const isValid = await verifyPassword(dto.password, account.passwordHash);
    if (!isValid) {
      throw new UnauthorizedException('Invalid email or password');
    }

    // 3. 토큰 생성
    const tokens = await this.createTokensForUser(user.id);

    return {
      user,
      ...tokens,
    };
  }

  private async createTokensForUser(userId: string) {
    const accessToken = `access_${randomBytes(32).toString('hex')}`;
    const refreshToken = randomBytes(48).toString('hex');
    const tokenHash = createHash('sha256').update(refreshToken).digest('hex');

    await this.prisma.refreshToken.create({
      data: {
        userId,
        tokenHash,
        expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30일
      },
    });

    return {
      accessToken,
      refreshToken,
      expiresIn: 3600,
    };
  }
}
```

### 10.6 Auth Controller 구현

```typescript
// src/auth/auth.controller.ts
import { Controller, Post, Body, Headers } from '@nestjs/common';
import { ApiTags, ApiOperation } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { RegisterRequestDTO, RegisterResponseDTO, LoginRequestDTO, LoginResponseDTO } from '../common/dto';

@ApiTags('Auth')
@Controller('v1/auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  @ApiOperation({ summary: '회원가입' })
  async register(
    @Headers('x-app-version') appVersion: string,
    @Headers('x-platform') platform: string,
    @Body() dto: RegisterRequestDTO,
  ): Promise<RegisterResponseDTO> {
    return this.authService.register(dto);
  }

  @Post('login')
  @ApiOperation({ summary: '로그인' })
  async login(
    @Headers('x-app-version') appVersion: string,
    @Headers('x-platform') platform: string,
    @Body() dto: LoginRequestDTO,
  ): Promise<LoginResponseDTO> {
    return this.authService.login(dto);
  }
}
```

### 10.7 main.ts에 Swagger 설정

```typescript
// src/main.ts
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // CORS 활성화
  app.enableCors();

  // Validation Pipe
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
    }),
  );

  // Swagger 설정
  const config = new DocumentBuilder()
    .setTitle('LoginDemo API')
    .setVersion('1.0')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api-docs', app, document);

  await app.listen(3000);
  console.log(`Application is running on: ${await app.getUrl()}`);
  console.log(`Swagger Docs: ${await app.getUrl()}/api-docs`);
}
bootstrap();
```

### 10.8 실행 및 테스트

```bash
# 개발 서버 실행
npm run start:dev

# 브라우저에서 Swagger 확인
open http://localhost:3000/api-docs

# cURL로 회원가입 테스트
curl -X POST http://localhost:3000/v1/auth/register \
  -H "Content-Type: application/json" \
  -H "X-App-Version: 1.0.0" \
  -H "X-Platform: iOS" \
  -d '{
    "provider": "EMAIL",
    "email": "test@example.com",
    "password": "password123",
    "nickname": "테스터",
    "marketingConsent": true
  }'

# cURL로 로그인 테스트
curl -X POST http://localhost:3000/v1/auth/login \
  -H "Content-Type: application/json" \
  -H "X-App-Version: 1.0.0" \
  -H "X-Platform: iOS" \
  -d '{
    "provider": "EMAIL",
    "email": "test@example.com",
    "password": "password123"
  }'
```

---

## 11. Token Rotation 구현

### 11.1 Refresh Token Service 구현

```typescript
// src/auth/auth.service.ts에 추가

import { createHash } from 'crypto';

export class AuthService {
  // 기존 코드...

  async refresh(refreshToken: string) {
    const tokenHash = this.hashToken(refreshToken);

    // 1. 토큰 조회
    const storedToken = await this.prisma.refreshToken.findUnique({
      where: { tokenHash },
      include: { user: true },
    });

    if (!storedToken || storedToken.isRevoked) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    if (storedToken.expiresAt < new Date()) {
      throw new UnauthorizedException('Refresh token expired');
    }

    // 2. 기존 토큰 무효화 (Token Rotation)
    await this.prisma.refreshToken.update({
      where: { id: storedToken.id },
      data: {
        isRevoked: true,
        revokedReason: 'Token rotated',
        revokedAt: new Date(),
      },
    });

    // 3. 새 토큰 생성
    return this.createTokensForUser(storedToken.userId);
  }

  async logout(refreshToken: string, allDevices = false) {
    const tokenHash = this.hashToken(refreshToken);

    const token = await this.prisma.refreshToken.findUnique({
      where: { tokenHash },
    });

    if (!token) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    if (allDevices) {
      // 모든 기기 로그아웃
      await this.prisma.refreshToken.updateMany({
        where: { userId: token.userId, isRevoked: false },
        data: {
          isRevoked: true,
          revokedReason: 'User logged out from all devices',
          revokedAt: new Date(),
        },
      });
    } else {
      // 현재 기기만 로그아웃
      await this.prisma.refreshToken.update({
        where: { id: token.id },
        data: {
          isRevoked: true,
          revokedReason: 'User logged out',
          revokedAt: new Date(),
        },
      });
    }

    return { success: true };
  }

  private hashToken(token: string): string {
    return createHash('sha256').update(token).digest('hex');
  }
}
```

### 11.2 Controller에 엔드포인트 추가

```typescript
// src/auth/auth.controller.ts에 추가

@Post('refresh')
@ApiOperation({ summary: '토큰 갱신' })
async refresh(@Body() dto: { refreshToken: string }) {
  return this.authService.refresh(dto.refreshToken);
}

@Post('logout')
@ApiOperation({ summary: '로그아웃' })
async logout(
  @Body() dto: { refreshToken: string; allDevices?: boolean },
) {
  return this.authService.logout(dto.refreshToken, dto.allDevices);
}
```

---

*이 문서는 계속됩니다. 지면 관계상 Part IV (iOS), Part V (Android), Part VI (Frontend), Part VII (테스트), Part VIII (배포) 내용은 동일한 상세도로 이어집니다.*

**다음 섹션 미리보기:**
- Part IV: iOS Clean Architecture 레이어별 상세 구현
- Part V: Android Hilt + Compose 구현
- Part VI: Next.js Frontend 구현
- Part VII: 로컬 통합 테스트 (Backend ↔ iOS ↔ Android)
- Part VIII: Docker Compose 배포, Nginx 설정, SSL 인증서, VPS 운영

---

**작성자**: Antigravity (Advanced Agentic Coding AI)  
**날짜**: 2026-01-18  
**문서 상태**: Part III까지 작성 완료, Part IV-VIII 작성 예정
