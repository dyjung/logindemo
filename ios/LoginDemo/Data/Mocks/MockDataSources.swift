//
//  MockDataSources.swift
//  LoginDemo
//
//  테스트용 Mock DataSource 구현
//

import Foundation
import Alamofire

// MARK: - MockKeychainDataSource

/// 테스트용 Keychain DataSource Mock
final class MockKeychainDataSource: KeychainDataSourceProtocol {
    var accessToken: String?
    var refreshToken: String?
    var userId: String?

    var hasValidToken: Bool {
        accessToken != nil
    }

    func saveAccessToken(_ token: String) {
        accessToken = token
    }

    func getAccessToken() -> String? {
        accessToken
    }

    func saveRefreshToken(_ token: String) {
        refreshToken = token
    }

    func getRefreshToken() -> String? {
        refreshToken
    }

    func saveUserId(_ userId: String) {
        self.userId = userId
    }

    func getUserId() -> String? {
        userId
    }

    func getDeviceId() -> String? {
        "mock_device_id"
    }

    func clearAll() {
        accessToken = nil
        refreshToken = nil
        userId = nil
    }
}

// MARK: - MockUserDefaultsDataSource

/// 테스트용 UserDefaults DataSource Mock
final class MockUserDefaultsDataSource: UserDefaultsDataSourceProtocol {
    var autoLoginEnabled: Bool = false
    var hasCompletedOnboarding: Bool = false
    var isFirstLaunch: Bool = true
    var lastLoginEmail: String?

    func clearAll() {
        autoLoginEnabled = false
        hasCompletedOnboarding = false
        isFirstLaunch = true
        lastLoginEmail = nil
    }
}

// MARK: - MockNetworkService

/// 테스트용 Network Service Mock
final class MockNetworkService: NetworkServiceProtocol {
    var mockResponse: Any?
    var mockError: Error?

    func request<T: Decodable>(_ router: URLRequestConvertible) async throws -> T {
        if let error = mockError {
            throw error
        }
        if let response = mockResponse as? T {
            return response
        }
        throw AuthError.unknown
    }

    func requestWithoutResponse(_ router: URLRequestConvertible) async throws {
        if let error = mockError {
            throw error
        }
    }
}
