//
//  MockUserDefaultsDataSource.swift
//  LoginDemoTests
//
//  테스트용 Mock UserDefaults 데이터 소스
//

import Foundation
@testable import LoginDemo

/// 테스트용 Mock UserDefaults 데이터 소스
final class MockUserDefaultsDataSource: UserDefaultsDataSourceProtocol, @unchecked Sendable {
    // MARK: - Storage

    var isFirstLaunch: Bool = true
    var hasCompletedOnboarding: Bool = false
    var autoLoginEnabled: Bool = false
    var lastLoginEmail: String?

    // MARK: - Call Tracking

    var clearAllCallCount = 0

    // MARK: - UserDefaultsDataSourceProtocol

    func clearAll() {
        clearAllCallCount += 1
        isFirstLaunch = true
        hasCompletedOnboarding = false
        autoLoginEnabled = false
        lastLoginEmail = nil
    }

    // MARK: - Test Helpers

    func reset() {
        isFirstLaunch = true
        hasCompletedOnboarding = false
        autoLoginEnabled = false
        lastLoginEmail = nil
        clearAllCallCount = 0
    }
}
