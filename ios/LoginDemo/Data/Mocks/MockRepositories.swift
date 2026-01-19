//
//  MockRepositories.swift
//  LoginDemo
//
//  테스트용 Mock Repository 구현
//

import Foundation

// MARK: - MockAuthRepository

/// 테스트용 Auth Repository Mock
final class MockAuthRepository: AuthRepositoryProtocol, @unchecked Sendable {
    // MARK: - Mock Data

    var mockUser: User?
    var mockToken: AuthToken?
    var mockError: Error?
    var mockEmailAvailable: Bool = true

    private var _isAutoLoginEnabled: Bool = false
    private var _hasValidToken: Bool = false

    // MARK: - AuthRepositoryProtocol

    func login(email: String, password: String, autoLogin: Bool) async throws -> (User, AuthToken) {
        if let error = mockError { throw error }
        guard let user = mockUser, let token = mockToken else {
            throw AuthError.invalidCredentials
        }
        _isAutoLoginEnabled = autoLogin
        _hasValidToken = true
        return (user, token)
    }

    func register(
        email: String,
        password: String,
        nickname: String,
        marketingConsent: Bool
    ) async throws -> (User, AuthToken) {
        if let error = mockError { throw error }
        let user = User(
            id: UUID().uuidString,
            email: email,
            nickname: nickname,
            status: .active,
            provider: nil,
            createdAt: Date(),
            lastLogin: nil,
            updatedAt: nil
        )
        let token = AuthToken(
            accessToken: "mock_access_token",
            refreshToken: "mock_refresh_token",
            expiresIn: 3600
        )
        _hasValidToken = true
        return (user, token)
    }

    func socialLogin(
        provider: AuthProvider,
        oauthToken: String,
        autoLogin: Bool
    ) async throws -> (User, AuthToken) {
        if let error = mockError { throw error }
        guard let user = mockUser, let token = mockToken else {
            throw AuthError.unknown
        }
        _isAutoLoginEnabled = autoLogin
        _hasValidToken = true
        return (user, token)
    }

    func refreshToken() async throws -> AuthToken {
        if let error = mockError { throw error }
        guard let token = mockToken else {
            throw AuthError.tokenRefreshFailed
        }
        return token
    }

    func passwordReset(email: String) async throws {
        if let error = mockError { throw error }
    }

    func initApp() async throws -> InitAppResponseDTO {
        if let error = mockError { throw error }

        let autoLogin: AutoLoginResultDTO? = mockUser.map { user in
            AutoLoginResultDTO(
                success: true,
                user: UserDTO(
                    id: user.id,
                    email: user.email,
                    nickname: user.nickname,
                    status: user.status.rawValue,
                    createdAt: ISO8601DateFormatter().string(from: user.createdAt),
                    lastLogin: user.lastLogin.map { ISO8601DateFormatter().string(from: $0) },
                    updatedAt: user.updatedAt.map { ISO8601DateFormatter().string(from: $0) }
                ),
                accessToken: mockToken?.accessToken,
                refreshToken: mockToken?.refreshToken,
                failureReason: nil
            )
        }

        return InitAppResponseDTO(
            config: AppConfigDTO(
                minVersion: "1.0.0",
                maintenanceMode: false,
                noticeMessage: nil
            ),
            forceUpdate: false,
            isMaintenance: false,
            userContext: UserContextDTO(
                country: "KR",
                currency: "KRW",
                language: "ko",
                location: nil
            ),
            autoLogin: autoLogin
        )
    }

    func logout() async throws {
        if let error = mockError { throw error }
        _isAutoLoginEnabled = false
        _hasValidToken = false
    }

    func getStoredToken() -> AuthToken? {
        mockToken
    }

    var isAutoLoginEnabled: Bool {
        _isAutoLoginEnabled
    }

    var hasValidToken: Bool {
        _hasValidToken
    }

    // MARK: - Test Helpers

    func setAutoLoginEnabled(_ enabled: Bool) {
        _isAutoLoginEnabled = enabled
    }

    func setHasValidToken(_ valid: Bool) {
        _hasValidToken = valid
    }
}

// MARK: - MockOnboardingRepository

/// 테스트용 Onboarding Repository Mock
final class MockOnboardingRepository: OnboardingRepositoryProtocol, @unchecked Sendable {
    // MARK: - Mock Data

    private var _hasCompletedOnboarding: Bool = false
    private var _isFirstLaunch: Bool = true

    // MARK: - OnboardingRepositoryProtocol

    var hasCompletedOnboarding: Bool {
        _hasCompletedOnboarding
    }

    var isFirstLaunch: Bool {
        _isFirstLaunch
    }

    func markOnboardingCompleted() {
        _hasCompletedOnboarding = true
    }

    func markFirstLaunchCompleted() {
        _isFirstLaunch = false
    }

    func getOnboardingPages() -> [OnboardingPage] {
        OnboardingPage.defaultPages
    }

    // MARK: - Test Helpers

    func setHasCompletedOnboarding(_ completed: Bool) {
        _hasCompletedOnboarding = completed
    }

    func setIsFirstLaunch(_ firstLaunch: Bool) {
        _isFirstLaunch = firstLaunch
    }
}
