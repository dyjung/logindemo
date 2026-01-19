<!--
===== 동기화 영향 보고서 =====
버전 변경: 1.1.0 → 1.2.0
수정된 원칙: 없음 (기존 원칙 모두 유지)
추가된 섹션:
  - VIII. 웹 서비스 아키텍처 (Next.js + NestJS) - 새 원칙
  - IX. 역할 기반 접근 제어 (RBAC) - 새 원칙
  - 홍보 콘텐츠 관리 기능 요구사항
  - Admin 서비스 구현 가이드
  - 웹 서비스 코딩 규칙
삭제된 섹션: 없음
템플릿 업데이트 필요:
  ✅ plan-template.md - Constitution Check 섹션에서 본 헌법 참조
  ✅ spec-template.md - 기능 요구사항 작성 시 본 헌법 준수 필요
  ✅ tasks-template.md - 작업 분류 시 본 헌법의 원칙 반영 필요
  ✅ checklist-template.md - 체크리스트 항목이 본 헌법 원칙 준수 확인 필요
후속 TODO: 없음
================================
-->

# LoginDemo 프로젝트 헌법

## 핵심 원칙

### I. SwiftUI 우선 (SwiftUI-First)

모든 UI 컴포넌트는 반드시 SwiftUI로 구현해야 합니다.

- 모든 뷰는 `View` 프로토콜을 준수하는 구조체로 작성해야 합니다
- UIKit 사용은 SwiftUI에서 제공하지 않는 기능에 한해 `UIViewRepresentable` 또는 `UIViewControllerRepresentable`을 통해서만 허용됩니다
- 뷰 컴포넌트는 재사용 가능하고 독립적으로 테스트 가능해야 합니다
- 화면 전환은 반드시 `NavigationStack` 또는 상태 기반 조건부 렌더링을 사용해야 합니다

**근거**: SwiftUI는 Apple의 선언적 UI 프레임워크로, 코드의 일관성과 유지보수성을 보장합니다.

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

#### 레이어별 규칙

**Domain Layer (핵심 비즈니스 로직)**
- 다른 레이어에 대한 의존성 절대 금지 (순수 Swift만 사용)
- `Entity`: 핵심 비즈니스 모델, 불변(immutable) 구조체로 작성
- `UseCase`: 단일 비즈니스 작업을 수행하는 프로토콜 + 구현체
- `RepositoryProtocol`: 데이터 접근 추상화 (프로토콜만 정의)

**Data Layer (데이터 접근)**
- Domain Layer에만 의존 가능
- `Repository`: Domain의 RepositoryProtocol 구현
- `DataSource`: 실제 데이터 소스 접근 (Network, Local, Keychain)
- `DTO`: 외부 데이터 전송 객체, Entity로 매핑 필수
- `Mapper`: DTO ↔ Entity 변환 담당

**Presentation Layer (UI)**
- Domain Layer에만 의존 가능 (Data Layer 직접 참조 금지)
- `View`: SwiftUI 뷰, UI 렌더링만 담당
- `ViewModel`: UseCase를 호출하여 비즈니스 로직 실행, `@Observable` 또는 `ObservableObject`로 구현
- ViewModel은 반드시 UseCase 프로토콜에 의존 (구체 타입 의존 금지)

#### 의존성 주입 (Dependency Injection)

- 모든 의존성은 생성자 주입(Constructor Injection) 방식 사용
- 앱 진입점에서 DI Container를 통해 의존성 조립
- 테스트 시 Mock 객체 주입이 용이해야 함

**근거**: 클린 아키텍처는 관심사 분리, 테스트 용이성, 유지보수성을 극대화합니다.

### III. 테스트 주도 개발 (Test-First) - 비타협 원칙

테스트 코드는 구현 코드보다 먼저 작성해야 합니다.

- 모든 UseCase와 ViewModel은 반드시 단위 테스트가 있어야 합니다
- Red-Green-Refactor 사이클을 엄격히 준수해야 합니다
  1. 실패하는 테스트 작성 (Red)
  2. 테스트를 통과하는 최소한의 코드 구현 (Green)
  3. 코드 품질 개선 (Refactor)
- XCTest 프레임워크를 사용하며, 테스트 커버리지는 Domain/Presentation Layer 기준 80% 이상 유지
- UI 테스트는 핵심 사용자 플로우에 대해 작성해야 합니다
- Repository는 Mock을 통해 테스트하고, 실제 DataSource는 통합 테스트에서 검증

**근거**: 테스트 우선 개발은 버그를 조기에 발견하고 설계 품질을 향상시킵니다.

### IV. 상태 관리 일관성 (State Management)

앱의 상태 관리는 일관된 패턴을 따라야 합니다.

- 로컬 뷰 상태: `@State` 사용 (해당 뷰에서만 사용되는 상태)
- 바인딩: `@Binding` 사용 (부모로부터 전달받은 상태)
- 전역 앱 상태: `@Environment` 또는 `@EnvironmentObject` 사용
- ViewModel 참조: `@StateObject` (소유) 또는 `@ObservedObject` (비소유) 사용
- iOS 17+ 타겟 시 `@Observable` 매크로 우선 사용
- 앱 전역 인증 상태는 `AuthState` 싱글톤 또는 Environment로 관리

**근거**: 일관된 상태 관리는 데이터 흐름을 예측 가능하게 만들고 디버깅을 용이하게 합니다.

### V. 접근성 필수 (Accessibility Required)

모든 UI 컴포넌트는 접근성을 지원해야 합니다.

- 모든 인터랙티브 요소에 `accessibilityLabel` 반드시 제공
- 이미지에는 적절한 `accessibilityLabel` 또는 `.accessibilityHidden(true)` 적용
- VoiceOver 테스트를 통해 스크린 리더 호환성 검증 필수
- Dynamic Type 지원으로 텍스트 크기 조절 대응 필수
- 색상만으로 정보를 전달하지 않음 (색각 이상 사용자 고려)

**근거**: 접근성은 선택이 아닌 필수입니다. 모든 사용자가 앱을 이용할 수 있어야 합니다.

### VI. 단순성 우선 (Simplicity First)

복잡성은 반드시 정당화되어야 합니다.

- YAGNI (You Aren't Gonna Need It): 현재 필요하지 않은 기능은 구현하지 않음
- 추상화는 3회 이상 반복될 때만 도입
- 외부 라이브러리 도입 전 Swift 표준 라이브러리 우선 검토
- 과도한 제네릭이나 프로토콜 추상화 지양
- 코드는 읽기 쉽고 의도가 명확해야 함

**근거**: 단순한 코드는 이해하기 쉽고, 버그가 적으며, 유지보수가 용이합니다.

### VII. 보안 최우선 (Security First)

사용자 인증 정보와 민감한 데이터는 안전하게 처리해야 합니다.

#### 기본 보안 규칙

- 비밀번호, 토큰 등 민감 정보는 반드시 Keychain에 저장
- UserDefaults에 민감 정보 저장 절대 금지
- 네트워크 통신은 반드시 HTTPS 사용
- 로그에 민감 정보 출력 금지 (디버그 모드 포함)
- 입력값 검증은 클라이언트와 서버 양쪽에서 수행

#### 자동로그인 보안 규칙

- 자동로그인 토큰(Refresh Token)은 반드시 Keychain에 암호화하여 저장
- Access Token 만료 시 Refresh Token으로 자동 갱신
- Refresh Token 만료 또는 무효화 시 로그인 화면으로 강제 이동
- 자동로그인 활성화 여부는 사용자 선택으로 결정 (기본값: 비활성화)
- 로그아웃 시 Keychain의 모든 인증 토큰 완전 삭제
- 디바이스 탈옥/루팅 감지 시 자동로그인 비활성화 권장
- 일정 기간(예: 30일) 미사용 시 자동로그인 만료 처리

**근거**: 로그인 기능을 다루는 앱으로서 사용자의 개인정보 보호는 최우선 과제입니다.

### VIII. 웹 서비스 아키텍처 (Next.js + NestJS)

웹 서비스는 기존 Next.js 프론트엔드와 NestJS 백엔드에 기능을 추가하는 방식으로 구현합니다.

#### 백엔드 (NestJS) 확장 규칙

기존 모듈 구조를 유지하면서 새로운 기능 모듈을 추가해야 합니다:

- 새 기능은 반드시 독립된 모듈로 생성 (예: `promotion/promotion.module.ts`)
- Controller → Service → Repository 패턴 준수
- DTO를 사용한 입력값 검증 필수 (class-validator 사용)
- Prisma 스키마에 새 모델 추가 시 마이그레이션 필수 실행

```
backend/src/
├── auth/                   # 기존 인증 모듈 (유지)
├── prisma/                 # 기존 Prisma 모듈 (유지)
├── system/                 # 기존 시스템 모듈 (유지)
├── common/                 # 기존 공통 유틸리티 (확장)
│   ├── enums.ts            # 열거형 추가
│   ├── decorators/         # 커스텀 데코레이터 추가
│   └── guards/             # 인증/권한 Guard 추가
└── promotion/              # 🆕 홍보 콘텐츠 모듈 (신규 추가)
    ├── promotion.module.ts
    ├── promotion.controller.ts
    ├── promotion.service.ts
    └── dto/
```

#### 프론트엔드 (Next.js) 확장 규칙

기존 App Router 구조에 페이지를 추가해야 합니다:

- Server Components 기본 사용, 클라이언트 상호작용 필요시에만 `'use client'` 사용
- 이미지는 반드시 `next/image` 컴포넌트 사용
- Admin 라우트는 `/admin` 경로 하위에 구성

```
frontend/src/app/
├── layout.tsx              # 기존 레이아웃 (유지)
├── page.tsx                # 기존 메인 페이지 (유지)
├── main/                   # 기존 메인 페이지 (유지)
├── promotions/             # 🆕 홍보 콘텐츠 (신규 추가)
│   ├── page.tsx            # 목록 페이지 (일반 사용자)
│   └── [id]/
│       └── page.tsx        # 상세 페이지 (일반 사용자)
└── admin/                  # 🆕 Admin 전용 (신규 추가)
    ├── layout.tsx          # Admin 레이아웃 (인증 체크)
    └── promotions/
        ├── page.tsx        # 콘텐츠 관리 목록
        ├── new/
        │   └── page.tsx    # 콘텐츠 등록
        └── [id]/
            └── edit/
                └── page.tsx # 콘텐츠 수정
```

**근거**: 기존 프로젝트 구조를 최대한 활용하여 일관성을 유지하고 개발 효율을 높입니다.

### IX. 역할 기반 접근 제어 (RBAC)

시스템은 Admin과 일반 사용자 역할을 구분하여 권한을 관리합니다.

#### 역할 정의

| 역할 | 설명 | 권한 |
|------|------|------|
| **ADMIN** | 시스템 관리자 | 홍보 콘텐츠 등록/수정/삭제, 사용자 관리 |
| **USER** | 일반 사용자 | 홍보 콘텐츠 목록 조회 및 상세 보기만 가능 |

#### User 모델 확장

기존 Prisma User 모델에 role 필드를 추가해야 합니다:

```prisma
enum UserRole {
  ADMIN
  USER
}

model User {
  // ... 기존 필드 모두 유지
  role      UserRole @default(USER)  // 🆕 역할 필드 추가
}
```

#### 접근 제어 구현 규칙

**백엔드 (NestJS)**
- Guard 기반 접근 제어 사용 (RolesGuard)
- `@Roles()` 데코레이터로 엔드포인트별 권한 지정
- JWT 토큰에 role 정보 포함 필수

**프론트엔드 (Next.js)**
- Admin 라우트에 미들웨어로 role 체크 적용
- 권한 없는 접근 시 로그인 페이지로 리다이렉트

**근거**: 명확한 역할 분리는 보안을 강화하고 권한 관리를 단순화합니다.

## 기능 요구사항

### 자동로그인 (Auto Login)

앱 재실행 시 사용자가 다시 로그인하지 않아도 되는 편의 기능입니다.

#### 필수 구현 사항

1. **토큰 기반 인증**
   - Access Token: 짧은 만료 시간 (예: 15분~1시간)
   - Refresh Token: 긴 만료 시간 (예: 7일~30일)
   - 토큰 저장소: Keychain (SecItem API 사용)

2. **자동로그인 플로우**
   ```
   앱 시작
     ↓
   Keychain에서 Refresh Token 확인
     ↓
   [토큰 있음] → 토큰 유효성 검증 → [유효] → 메인 화면
                                    ↓
                                [만료/무효] → 로그인 화면
     ↓
   [토큰 없음] → 온보딩 완료 여부 확인 → 온보딩/로그인 화면
   ```

3. **사용자 설정**
   - 로그인 화면에 "자동로그인" 체크박스/토글 제공
   - 설정에서 자동로그인 활성화/비활성화 가능
   - 자동로그인 비활성화 시 저장된 토큰 즉시 삭제

4. **에러 처리**
   - 네트워크 오류 시 캐시된 사용자 정보로 임시 접근 허용 (오프라인 모드)
   - 토큰 갱신 실패 시 명확한 에러 메시지와 함께 로그인 화면 이동

### 홍보 콘텐츠 관리 (Promotion Content)

특정 장소를 홍보하기 위한 콘텐츠 관리 기능입니다.

#### 콘텐츠 엔티티 구조

| 필드명 | 타입 | 필수 | 설명 |
|--------|------|------|------|
| id | UUID | O | 고유 식별자 |
| title | string | O | 제목 (최대 100자) |
| description | string | O | 간단 설명 (목록에 표시, 최대 500자) |
| content | string | O | 상세 내용 (마크다운 지원) |
| imageUrl | string | O | 대표 이미지 URL |
| images | string[] | X | 추가 이미지 URL 배열 |
| category | enum | O | 카테고리 (PLACE, FOOD, EVENT 등) |
| authorId | UUID | O | 작성자 ID (Admin) |
| status | enum | O | 상태 (DRAFT, PUBLISHED, ARCHIVED) |
| createdAt | DateTime | O | 생성일시 |
| updatedAt | DateTime | O | 수정일시 |
| publishedAt | DateTime | X | 게시일시 |

#### Prisma 스키마 추가

기존 `prisma/schema.prisma`에 다음 모델을 추가해야 합니다:

```prisma
enum PromotionCategory {
  PLACE       // 장소
  FOOD        // 음식
  EVENT       // 이벤트
  OTHER       // 기타
}

enum PromotionStatus {
  DRAFT       // 임시저장
  PUBLISHED   // 게시됨
  ARCHIVED    // 보관됨
}

model Promotion {
  id          String   @id @default(uuid())
  title       String   @db.VarChar(100)
  description String   @db.VarChar(500)
  content     String   @db.Text
  imageUrl    String
  images      String[]
  category    PromotionCategory
  status      PromotionStatus @default(DRAFT)
  authorId    String
  publishedAt DateTime?
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt

  author      User     @relation(fields: [authorId], references: [id])

  @@index([status])
  @@index([category])
  @@index([authorId])
  @@map("promotions")
}
```

#### API 엔드포인트

| 메서드 | 경로 | 설명 | 권한 |
|--------|------|------|------|
| GET | /promotions | 콘텐츠 목록 조회 | 모든 사용자 |
| GET | /promotions/:id | 콘텐츠 상세 조회 | 모든 사용자 |
| POST | /promotions | 콘텐츠 생성 | Admin |
| PATCH | /promotions/:id | 콘텐츠 수정 | Admin |
| DELETE | /promotions/:id | 콘텐츠 삭제 | Admin |
| POST | /promotions/:id/publish | 콘텐츠 게시 | Admin |
| POST | /upload/image | 이미지 업로드 | Admin |

#### 일반 사용자 화면 요구사항

**목록 페이지 (`/promotions`)**
- 게시된 콘텐츠만 표시 (status = PUBLISHED)
- 썸네일, 제목, 간단 설명 표시
- 페이지네이션 또는 무한 스크롤
- 카테고리별 필터링

**상세 페이지 (`/promotions/:id`)**
- 대표 이미지 및 추가 이미지 갤러리
- 제목, 상세 내용 (마크다운 렌더링)
- 작성자 정보, 작성일시

### Admin 서비스 구현 가이드

Admin 기능은 별도 프로젝트가 아닌 기존 Next.js 프로젝트 내에서 구현합니다.

#### Admin 라우트 구성

```
/admin                      # Admin 대시보드
/admin/promotions           # 콘텐츠 관리 목록
/admin/promotions/new       # 새 콘텐츠 등록
/admin/promotions/:id/edit  # 콘텐츠 수정
```

#### Admin 레이아웃 필수 구현 사항

1. **인증 체크**: Admin 레이아웃에서 사용자 role 확인
2. **권한 없음 처리**: ADMIN이 아닌 경우 로그인 페이지로 리다이렉트
3. **사이드바 네비게이션**: Admin 전용 메뉴 구성

```typescript
// app/admin/layout.tsx 예시
export default async function AdminLayout({ children }) {
  const session = await getServerSession();

  if (!session || session.user.role !== 'ADMIN') {
    redirect('/login');
  }

  return (
    <div className="flex">
      <AdminSidebar />
      <main className="flex-1">{children}</main>
    </div>
  );
}
```

#### Admin 콘텐츠 관리 페이지 필수 기능

1. **목록 페이지**
   - 모든 상태의 콘텐츠 표시 (DRAFT, PUBLISHED, ARCHIVED)
   - 상태별 필터링
   - 등록/수정/삭제 버튼

2. **등록/수정 폼**
   - 이미지 업로드 (드래그 앤 드롭 지원)
   - 마크다운 에디터 또는 리치 텍스트 에디터
   - 미리보기 기능
   - 임시 저장 (Draft) 기능

3. **삭제 처리**
   - 확인 모달 필수
   - 소프트 삭제 권장 (status = ARCHIVED)

## 코딩 규칙

SwiftUI iOS 개발을 위한 구체적인 코딩 가이드라인입니다.

### 파일 구조 (클린 아키텍처 기반)

```text
LoginDemo/
├── App/
│   ├── LoginDemoApp.swift          # 앱 진입점
│   └── DIContainer.swift           # 의존성 주입 컨테이너
│
├── Domain/                         # 🔵 Domain Layer (핵심)
│   ├── Entities/
│   │   ├── User.swift
│   │   └── AuthToken.swift
│   ├── UseCases/
│   │   ├── LoginUseCase.swift
│   │   ├── AutoLoginUseCase.swift
│   │   ├── LogoutUseCase.swift
│   │   └── CheckOnboardingUseCase.swift
│   └── Repositories/
│       ├── AuthRepositoryProtocol.swift
│       └── UserRepositoryProtocol.swift
│
├── Data/                           # 🟢 Data Layer
│   ├── Repositories/
│   │   ├── AuthRepository.swift
│   │   └── UserRepository.swift
│   ├── DataSources/
│   │   ├── Remote/
│   │   │   └── AuthRemoteDataSource.swift
│   │   └── Local/
│   │       ├── KeychainDataSource.swift
│   │       └── UserDefaultsDataSource.swift
│   ├── DTOs/
│   │   ├── LoginRequestDTO.swift
│   │   ├── LoginResponseDTO.swift
│   │   └── UserDTO.swift
│   └── Mappers/
│       └── UserMapper.swift
│
├── Presentation/                   # 🟠 Presentation Layer
│   ├── Splash/
│   │   ├── SplashView.swift
│   │   └── SplashViewModel.swift
│   ├── Onboarding/
│   │   ├── OnboardingView.swift
│   │   ├── OnboardingPageView.swift
│   │   ├── OnboardingViewModel.swift
│   │   └── OnboardingPage.swift    # Presentation 전용 모델
│   ├── Login/
│   │   ├── LoginView.swift
│   │   ├── LoginFormView.swift
│   │   └── LoginViewModel.swift
│   └── Main/
│       └── MainView.swift
│
├── Core/                           # 공통 유틸리티
│   ├── Components/                 # 재사용 가능한 UI 컴포넌트
│   ├── Extensions/                 # Swift 확장
│   ├── Network/                    # 네트워크 인프라
│   │   ├── NetworkService.swift
│   │   └── APIEndpoint.swift
│   └── Utilities/                  # 유틸리티 함수
│       └── KeychainHelper.swift
│
└── Resources/
    ├── Assets.xcassets
    └── Localizable.strings
```

### 네이밍 규칙

| 구분 | 규칙 | 예시 |
|------|------|------|
| View | PascalCase + "View" 접미사 | `LoginView`, `SplashView` |
| ViewModel | PascalCase + "ViewModel" 접미사 | `LoginViewModel` |
| Entity | PascalCase, 단수형 명사 | `User`, `AuthToken` |
| UseCase | PascalCase + "UseCase" 접미사 | `LoginUseCase`, `AutoLoginUseCase` |
| Repository Protocol | PascalCase + "RepositoryProtocol" 접미사 | `AuthRepositoryProtocol` |
| Repository | PascalCase + "Repository" 접미사 | `AuthRepository` |
| DataSource | PascalCase + "DataSource" 접미사 | `KeychainDataSource` |
| DTO | PascalCase + "DTO" 접미사 | `LoginRequestDTO` |
| 프로토콜 | PascalCase + 형용사 또는 "-able" | `Authenticatable` |
| 상수 | camelCase | `maxRetryCount`, `defaultTimeout` |
| 열거형 케이스 | camelCase | `.loggedIn`, `.onboarding` |

### 코드 스타일

```swift
// ✅ 올바른 예시 - 클린 아키텍처 적용

// Domain Layer - UseCase
protocol LoginUseCaseProtocol {
    func execute(email: String, password: String) async throws -> User
}

final class LoginUseCase: LoginUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    func execute(email: String, password: String) async throws -> User {
        return try await authRepository.login(email: email, password: password)
    }
}

// Presentation Layer - ViewModel
@Observable
final class LoginViewModel {
    private let loginUseCase: LoginUseCaseProtocol
    private let autoLoginUseCase: AutoLoginUseCaseProtocol

    var email = ""
    var password = ""
    var isAutoLoginEnabled = false
    var isLoading = false
    var errorMessage: String?

    init(
        loginUseCase: LoginUseCaseProtocol,
        autoLoginUseCase: AutoLoginUseCaseProtocol
    ) {
        self.loginUseCase = loginUseCase
        self.autoLoginUseCase = autoLoginUseCase
    }

    func login() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let user = try await loginUseCase.execute(
                email: email,
                password: password
            )
            if isAutoLoginEnabled {
                try await autoLoginUseCase.saveCredentials()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// Presentation Layer - View
struct LoginView: View {
    @State private var viewModel: LoginViewModel

    init(viewModel: LoginViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 16) {
            emailTextField
            passwordTextField
            autoLoginToggle
            loginButton
        }
        .padding()
    }

    private var autoLoginToggle: some View {
        Toggle("자동로그인", isOn: $viewModel.isAutoLoginEnabled)
            .accessibilityLabel("자동로그인 설정")
    }
}

// ❌ 잘못된 예시 - 레이어 분리 위반
struct BadLoginView: View {
    // ViewModel이 Repository를 직접 참조 (Data Layer 직접 의존)
    @StateObject var viewModel = LoginViewModel(
        repository: AuthRepository()  // 구체 타입 의존!
    )
}
```

### 필수 주석 규칙

- 모든 public 인터페이스에 문서화 주석(`///`) 작성
- UseCase의 비즈니스 규칙에는 설명 주석 추가
- TODO, FIXME는 담당자와 날짜 명시: `// TODO: (담당자, 날짜) 내용`

## 개발 워크플로우

기능 개발 시 반드시 따라야 하는 절차입니다.

### 코드 리뷰 필수 사항

1. **헌법 준수 확인**: 모든 핵심 원칙 준수 여부 검토
2. **클린 아키텍처 검증**: 레이어 간 의존성 방향 확인
3. **테스트 확인**: UseCase, ViewModel 테스트 존재 및 통과 여부
4. **접근성 확인**: 접근성 레이블 및 VoiceOver 지원 확인
5. **보안 검토**: 민감 정보 처리 방식, 자동로그인 구현 확인

### 커밋 메시지 형식

```
[타입]: 간단한 설명

본문 (선택사항)

- 변경 사항 상세 설명
- 관련 이슈 번호
```

**타입 종류**:
- `feat`: 새로운 기능
- `fix`: 버그 수정
- `refactor`: 코드 리팩토링
- `test`: 테스트 코드
- `docs`: 문서 수정
- `style`: 코드 스타일 변경 (포맷팅 등)

### 품질 게이트

PR 병합 전 반드시 통과해야 하는 항목:

- [ ] 모든 테스트 통과 (`xcodebuild test`)
- [ ] SwiftLint 경고 0건
- [ ] 코드 리뷰 승인 1인 이상
- [ ] 헌법 원칙 준수 확인
- [ ] 클린 아키텍처 레이어 의존성 검증

## 거버넌스

이 헌법의 관리 및 개정에 관한 규정입니다.

### 헌법의 효력

- 이 헌법은 프로젝트의 모든 코드와 문서에 우선합니다
- 헌법에 명시된 원칙과 충돌하는 코드는 리뷰에서 거부되어야 합니다
- 긴급한 상황에서 예외가 필요한 경우, 반드시 문서화하고 팀의 승인을 받아야 합니다

### 개정 절차

1. **제안**: 개정안을 문서로 작성하여 제출
2. **검토**: 팀 전체가 변경 사항의 영향을 검토
3. **승인**: 팀원 과반수의 동의 필요
4. **적용**: 버전 번호 증가와 함께 개정 내용 반영
5. **전파**: 관련 템플릿 및 문서 동기화

### 버전 관리 정책

- **MAJOR** (X.0.0): 기존 원칙의 삭제 또는 근본적 변경
- **MINOR** (0.X.0): 새로운 원칙 추가 또는 기존 원칙의 확장
- **PATCH** (0.0.X): 오타 수정, 문구 명확화, 비의미적 변경

### 준수 검토

- 모든 PR은 헌법 준수 여부를 체크리스트로 확인
- 분기별 헌법 준수 현황 검토 권장
- 위반 사항 발견 시 즉시 수정 또는 예외 문서화

**Version**: 1.1.0 | **Ratified**: 2026-01-07 | **Last Amended**: 2026-01-07
