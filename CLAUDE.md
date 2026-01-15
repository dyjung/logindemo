# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Structure

This is a **cross-platform mobile application** supporting both iOS and Android.

```
LoginDemo/
├── ios/                    # iOS project (SwiftUI)
│   ├── LoginDemo.xcodeproj
│   ├── LoginDemo/
│   └── LoginDemoTests/
├── android/                # Android project (Jetpack Compose)
│   ├── app/
│   └── build.gradle.kts
├── shared/                 # Shared resources
│   ├── assets/             # Shared images, icons
│   ├── api-contracts/      # OpenAPI specs
│   └── localization/       # i18n strings (JSON)
├── specs/                  # Feature specifications
├── Makefile                # Unified build commands
└── CLAUDE.md
```

## Build Commands

### Using Makefile (Recommended)

```bash
# Both platforms
make build              # Build both
make test               # Test both
make clean              # Clean both

# iOS only
make ios-build          # Build iOS debug
make ios-test           # Run iOS tests
make ios-release        # Build iOS release

# Android only
make android-build      # Build Android debug
make android-test       # Run Android tests
make android-release    # Build Android release

# Setup
make setup              # Check environment
make help               # Show all commands
```

### Direct Commands

```bash
# iOS
cd ios && xcodebuild -project LoginDemo.xcodeproj -scheme LoginDemo -sdk iphonesimulator build

# Android
cd android && ./gradlew assembleDebug
```

## Architecture (Shared Across Platforms)

Both platforms follow **Clean Architecture** with **Dependency Inversion**.

```
┌─────────────────────────────────────────────┐
│  Presentation (SwiftUI / Compose)           │
├─────────────────────────────────────────────┤
│  Domain (UseCases, Entities, Protocols)     │
├─────────────────────────────────────────────┤
│  Data (Repositories, DataSources, Network)  │
└─────────────────────────────────────────────┘
```

### Layer Mapping

| Concept | iOS (Swift) | Android (Kotlin) |
|---------|-------------|------------------|
| DI Container | DIContainer | Hilt Module |
| ViewModel | @Observable | ViewModel + StateFlow |
| UI State | @State, @Binding | remember, mutableStateOf |
| Async | async/await, Task | Coroutines, Flow |
| Network | Alamofire | Retrofit + OkHttp |
| Secure Storage | Keychain | EncryptedSharedPreferences |
| Local Storage | UserDefaults | SharedPreferences |

### iOS Layer Structure

```
ios/LoginDemo/
├── App/                    # App entry point & DI Container
│   ├── LoginDemoApp.swift  # @main entry point
│   ├── DIContainer.swift   # Dependency Coordinator
│   └── AppState.swift      # Global app state
├── Domain/                 # Business logic (interfaces)
│   ├── Entities/           # Domain models
│   ├── Repositories/       # Repository Protocols
│   └── UseCases/           # Business logic
├── Data/                   # Data layer (implementations)
│   ├── Repositories/       # *RepositoryImpl.swift
│   ├── DataSources/        # Local/Remote data sources
│   ├── DTOs/               # Data Transfer Objects
│   └── Mocks/              # Mock implementations
├── Presentation/           # UI layer
│   ├── Auth/               # Login, Register
│   ├── Onboarding/         # Onboarding flow
│   └── Main/               # Tab-based main screens
└── Core/                   # Shared utilities
```

### Android Layer Structure (Target)

```
android/app/src/main/java/com/dyjung/logindemo/
├── di/                     # Hilt modules
├── domain/                 # Business logic
│   ├── model/              # Domain models
│   ├── repository/         # Repository interfaces
│   └── usecase/            # Use cases
├── data/                   # Data layer
│   ├── repository/         # *RepositoryImpl
│   ├── datasource/         # Local/Remote
│   └── dto/                # DTOs
├── presentation/           # UI layer
│   ├── auth/               # Auth screens
│   ├── onboarding/         # Onboarding
│   └── main/               # Main screens
└── core/                   # Utilities
```

### Dependency Inversion Pattern

```swift
// iOS Example
protocol AuthRepositoryProtocol { ... }
final class AuthRepositoryImpl: AuthRepositoryProtocol { ... }
final class MockAuthRepository: AuthRepositoryProtocol { ... }

final class DIContainer {
    let authRepository: AuthRepositoryProtocol  // Interface, not implementation
    static func makeProduction() -> DIContainer { ... }
    static func makeTest() -> DIContainer { ... }
}
```

```kotlin
// Android Example
interface AuthRepository { ... }
class AuthRepositoryImpl @Inject constructor(...): AuthRepository { ... }

@Module
@InstallIn(SingletonComponent::class)
object RepositoryModule {
    @Provides
    @Singleton
    fun provideAuthRepository(impl: AuthRepositoryImpl): AuthRepository = impl
}
```

## Shared Resources

### Localization

Shared strings in `shared/localization/`:
- `ko.json` - Korean
- `en.json` - English

Both platforms should consume these JSON files for consistent translations.

### API Contracts

OpenAPI specs in `shared/api-contracts/` define the backend API.
Both platforms generate client code from these specs.

## Project Configuration

### iOS
- **Target**: iOS 17+
- **Swift Version**: 5.9+
- **UI Framework**: SwiftUI
- **Concurrency**: Swift Concurrency (async/await)
- **Bundle ID**: com.dyjung.LoginDemo

### Android
- **Target**: Android API 26+ (Android 8.0)
- **Kotlin Version**: 1.9+
- **UI Framework**: Jetpack Compose
- **Concurrency**: Coroutines + Flow
- **Package**: com.dyjung.logindemo

## Active Technologies
- Swift 5.9+ + SwiftUI, Foundation
- UserDefaults (최근 검색), Keychain (인증 토큰)
- Alamofire (Network)
