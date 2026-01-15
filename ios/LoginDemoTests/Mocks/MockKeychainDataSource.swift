//
//  MockKeychainDataSource.swift
//  LoginDemoTests
//
//  테스트용 Mock Keychain 데이터 소스
//

import Foundation
@testable import LoginDemo

/// 테스트용 Mock Keychain 데이터 소스
final class MockKeychainDataSource: KeychainDataSourceProtocol, @unchecked Sendable {
    // MARK: - Storage

    private var accessToken: String?
    private var refreshToken: String?
    private var userId: String?

    // MARK: - Call Tracking

    var saveAccessTokenCallCount = 0
    var saveRefreshTokenCallCount = 0
    var saveUserIdCallCount = 0
    var clearAllCallCount = 0

    // MARK: - KeychainDataSourceProtocol

    func saveAccessToken(_ token: String) {
        saveAccessTokenCallCount += 1
        accessToken = token
    }

    func getAccessToken() -> String? {
        accessToken
    }

    func saveRefreshToken(_ token: String) {
        saveRefreshTokenCallCount += 1
        refreshToken = token
    }

    func getRefreshToken() -> String? {
        refreshToken
    }

    func saveUserId(_ userId: String) {
        saveUserIdCallCount += 1
        self.userId = userId
    }

    func getUserId() -> String? {
        userId
    }

    func clearAll() {
        clearAllCallCount += 1
        accessToken = nil
        refreshToken = nil
        userId = nil
    }

    var hasValidToken: Bool {
        accessToken != nil
    }

    // MARK: - Test Helpers

    func reset() {
        accessToken = nil
        refreshToken = nil
        userId = nil
        saveAccessTokenCallCount = 0
        saveRefreshTokenCallCount = 0
        saveUserIdCallCount = 0
        clearAllCallCount = 0
    }

    func setTokens(access: String?, refresh: String?) {
        accessToken = access
        refreshToken = refresh
    }
}
