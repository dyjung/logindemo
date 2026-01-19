//
//  DIContainer.swift
//  LoginDemo
//
//  의존성 주입 컨테이너 (Coordinator)
//  Clean Architecture의 의존성 조립을 담당합니다.
//

import Foundation
import Alamofire

/// 앱 전역 의존성 주입 컨테이너
/// 생성자 주입을 통해 Mock/Production 구현체를 선택할 수 있습니다.
@MainActor
final class DIContainer {

    // MARK: - Dependencies (Protocol 타입으로 보유)

    let keychainDataSource: KeychainDataSourceProtocol
    let userDefaultsDataSource: UserDefaultsDataSourceProtocol
    let networkService: NetworkServiceProtocol
    let socialAuthService: SocialAuthServiceProtocol
    let authRepository: AuthRepositoryProtocol
    let onboardingRepository: OnboardingRepositoryProtocol

    // MARK: - Initialization (Constructor Injection)

    init(
        keychainDataSource: KeychainDataSourceProtocol,
        userDefaultsDataSource: UserDefaultsDataSourceProtocol,
        networkService: NetworkServiceProtocol,
        socialAuthService: SocialAuthServiceProtocol,
        authRepository: AuthRepositoryProtocol,
        onboardingRepository: OnboardingRepositoryProtocol
    ) {
        self.keychainDataSource = keychainDataSource
        self.userDefaultsDataSource = userDefaultsDataSource
        self.networkService = networkService
        self.socialAuthService = socialAuthService
        self.authRepository = authRepository
        self.onboardingRepository = onboardingRepository
    }

    // MARK: - Factory Methods (Production)

    /// Production 환경용 DIContainer 생성
    static func makeProduction() -> DIContainer {
        // Data Sources
        let keychainDataSource = KeychainDataSource()
        let userDefaultsDataSource = UserDefaultsDataSource()

        // Network (AuthInterceptor는 TokenRefresher가 필요하므로 나중에 설정)
        let networkService = NetworkService(interceptor: nil)

        // Remote Data Source
        let authRemoteDataSource = AuthRemoteDataSource(networkService: networkService)

        // Social Auth
        let socialAuthService = SocialAuthService()

        // Repositories
        let authRepository = AuthRepositoryImpl(
            remoteDataSource: authRemoteDataSource,
            keychainDataSource: keychainDataSource,
            userDefaultsDataSource: userDefaultsDataSource
        )

        let onboardingRepository = OnboardingRepositoryImpl(
            userDefaultsDataSource: userDefaultsDataSource
        )

        let container = DIContainer(
            keychainDataSource: keychainDataSource,
            userDefaultsDataSource: userDefaultsDataSource,
            networkService: networkService,
            socialAuthService: socialAuthService,
            authRepository: authRepository,
            onboardingRepository: onboardingRepository
        )

        // Interceptor 설정 (순환 의존성 해결 및 로깅 추가)
        let authInterceptor = AuthInterceptor(
            tokenStorage: keychainDataSource,
            tokenRefresher: container
        )
        let loggerInterceptor = FirebaseLoggerInterceptor()
        
        // 여러 인터셉터를 하나로 결합
        let combinedInterceptor = Interceptor(interceptors: [authInterceptor, loggerInterceptor])
        
        (networkService as? NetworkService)?.setInterceptor(combinedInterceptor)

        return container
    }

    /// Test 환경용 DIContainer 생성
    static func makeTest() -> DIContainer {
        let keychainDataSource = MockKeychainDataSource()
        let userDefaultsDataSource = MockUserDefaultsDataSource()
        let networkService = MockNetworkService()
        let socialAuthService = MockSocialAuthService()
        let authRepository = MockAuthRepository()
        let onboardingRepository = MockOnboardingRepository()

        return DIContainer(
            keychainDataSource: keychainDataSource,
            userDefaultsDataSource: userDefaultsDataSource,
            networkService: networkService,
            socialAuthService: socialAuthService,
            authRepository: authRepository,
            onboardingRepository: onboardingRepository
        )
    }

    // MARK: - Shared Instance (for backward compatibility)

    private static var _shared: DIContainer?

    static var shared: DIContainer {
        if _shared == nil {
            _shared = makeProduction()
        }
        return _shared!
    }

    /// 테스트용 shared 인스턴스 교체
    static func setShared(_ container: DIContainer) {
        _shared = container
    }

    /// shared 인스턴스 리셋 (테스트 후 정리용)
    static func resetShared() {
        _shared = nil
    }
    
    /// Preview용 DIContainer 생성
    static var preview: DIContainer {
        makeTest()  // Mock 데이터 사용
    }

    // MARK: - Use Cases

    func makeAutoLoginUseCase() -> AutoLoginUseCase {
        AutoLoginUseCase(
            authRepository: authRepository,
            onboardingRepository: onboardingRepository
        )
    }

    func makeRefreshTokenUseCase() -> RefreshTokenUseCase {
        RefreshTokenUseCase(authRepository: authRepository)
    }

    func makeCheckOnboardingUseCase() -> CheckOnboardingUseCase {
        CheckOnboardingUseCase(onboardingRepository: onboardingRepository)
    }

    func makeLoginUseCase() -> LoginUseCase {
        LoginUseCase(authRepository: authRepository)
    }

    func makeRegisterUseCase() -> RegisterUseCase {
        RegisterUseCase(authRepository: authRepository)
    }


    func makeSocialLoginUseCase() -> SocialLoginUseCase {
        SocialLoginUseCase(authRepository: authRepository)
    }

    func makeForgotPasswordUseCase() -> ForgotPasswordUseCase {
        ForgotPasswordUseCase(authRepository: authRepository)
    }

    func makeLogoutUseCase() -> LogoutUseCase {
        LogoutUseCase(authRepository: authRepository)
    }

    // MARK: - View Models

    func makeSplashViewModel() -> SplashViewModel {
        SplashViewModel(
            autoLoginUseCase: makeAutoLoginUseCase(),
            checkOnboardingUseCase: makeCheckOnboardingUseCase()
        )
    }

    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(
            loginUseCase: makeLoginUseCase(),
            socialLoginUseCase: makeSocialLoginUseCase(),
            socialAuthService: socialAuthService
        )
    }

    func makeRegisterViewModel() -> RegisterViewModel {
        RegisterViewModel(
            registerUseCase: makeRegisterUseCase()
        )
    }

    func makeOnboardingViewModel() -> OnboardingViewModel {
        OnboardingViewModel(onboardingRepository: onboardingRepository)
    }

    func makeForgotPasswordViewModel() -> ForgotPasswordViewModel {
        ForgotPasswordViewModel(forgotPasswordUseCase: makeForgotPasswordUseCase())
    }
}

// MARK: - TokenRefresherProtocol

extension DIContainer: TokenRefresherProtocol {
    func refreshToken() async throws {
        try await makeRefreshTokenUseCase().execute()
    }
}
