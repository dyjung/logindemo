//
//  MockAuthRepository.swift
//  LoginDemoTests
//
//  테스트용 Mock 인증 리포지토리
//

import Foundation
@testable import LoginDemo

/// 테스트용 Mock 인증 리포지토리
final class MockAuthRepository: AuthRepositoryProtocol, @unchecked Sendable {
    // MARK: - Mock Results

    var loginResult: Result<(User, AuthToken), Error> = .failure(AuthError.unknown)
    var registerResult: Result<(User, AuthToken), Error> = .failure(AuthError.unknown)
    var socialLoginResult: Result<(User, AuthToken), Error> = .failure(AuthError.unknown)
    var refreshTokenResult: Result<AuthToken, Error> = .failure(AuthError.unknown)
    var checkEmailResult: Result<Bool, Error> = .success(true)
    var forgotPasswordResult: Result<Void, Error> = .success(())
    var logoutResult: Result<Void, Error> = .success(())
    var storedToken: AuthToken?
    var mockIsAutoLoginEnabled: Bool = false
    var mockHasValidToken: Bool = false

    // MARK: - Call Tracking

    var loginCallCount = 0
    var registerCallCount = 0
    var socialLoginCallCount = 0
    var refreshTokenCallCount = 0
    var checkEmailCallCount = 0
    var forgotPasswordCallCount = 0
    var logoutCallCount = 0

    var lastLoginEmail: String?
    var lastLoginPassword: String?
    var lastLoginAutoLogin: Bool?

    // MARK: - AuthRepositoryProtocol

    func login(email: String, password: String, autoLogin: Bool) async throws -> (User, AuthToken) {
        loginCallCount += 1
        lastLoginEmail = email
        lastLoginPassword = password
        lastLoginAutoLogin = autoLogin

        switch loginResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }

    func register(
        email: String,
        password: String,
        name: String,
        agreedToTerms: Bool,
        agreedToPrivacy: Bool
    ) async throws -> (User, AuthToken) {
        registerCallCount += 1

        switch registerResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }

    func socialLogin(
        provider: AuthProvider,
        oauthToken: String,
        autoLogin: Bool
    ) async throws -> (User, AuthToken) {
        socialLoginCallCount += 1

        switch socialLoginResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }

    func refreshToken() async throws -> AuthToken {
        refreshTokenCallCount += 1

        switch refreshTokenResult {
        case .success(let token):
            return token
        case .failure(let error):
            throw error
        }
    }

    func checkEmailAvailability(email: String) async throws -> Bool {
        checkEmailCallCount += 1

        switch checkEmailResult {
        case .success(let available):
            return available
        case .failure(let error):
            throw error
        }
    }

    func forgotPassword(email: String) async throws {
        forgotPasswordCallCount += 1

        switch forgotPasswordResult {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }

    func logout() async throws {
        logoutCallCount += 1

        switch logoutResult {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }

    func getStoredToken() -> AuthToken? {
        storedToken
    }

    var isAutoLoginEnabled: Bool {
        mockIsAutoLoginEnabled
    }

    var hasValidToken: Bool {
        mockHasValidToken
    }

    // MARK: - Reset

    func reset() {
        loginCallCount = 0
        registerCallCount = 0
        socialLoginCallCount = 0
        refreshTokenCallCount = 0
        checkEmailCallCount = 0
        forgotPasswordCallCount = 0
        logoutCallCount = 0
        lastLoginEmail = nil
        lastLoginPassword = nil
        lastLoginAutoLogin = nil
    }
}
