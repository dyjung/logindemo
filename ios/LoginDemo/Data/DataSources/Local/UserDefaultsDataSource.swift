//
//  UserDefaultsDataSource.swift
//  LoginDemo
//
//  UserDefaults 데이터 소스 구현
//

import Foundation

/// UserDefaults 데이터 소스 구현체
final class UserDefaultsDataSource: UserDefaultsDataSourceProtocol, @unchecked Sendable {
    // MARK: - Keys

    private enum Keys {
        static let isFirstLaunch = "isFirstLaunch"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let autoLoginEnabled = "autoLoginEnabled"
        static let lastLoginEmail = "lastLoginEmail"
    }

    // MARK: - Properties

    private let defaults: UserDefaults

    // MARK: - Initialization

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        // 최초 실행 시 기본값 설정
        if defaults.object(forKey: Keys.isFirstLaunch) == nil {
            defaults.set(true, forKey: Keys.isFirstLaunch)
        }
    }

    // MARK: - UserDefaultsDataSourceProtocol

    var isFirstLaunch: Bool {
        get { defaults.bool(forKey: Keys.isFirstLaunch) }
        set { defaults.set(newValue, forKey: Keys.isFirstLaunch) }
    }

    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: Keys.hasCompletedOnboarding) }
        set { defaults.set(newValue, forKey: Keys.hasCompletedOnboarding) }
    }

    var autoLoginEnabled: Bool {
        get { defaults.bool(forKey: Keys.autoLoginEnabled) }
        set { defaults.set(newValue, forKey: Keys.autoLoginEnabled) }
    }

    var lastLoginEmail: String? {
        get { defaults.string(forKey: Keys.lastLoginEmail) }
        set { defaults.set(newValue, forKey: Keys.lastLoginEmail) }
    }

    func clearAll() {
        defaults.removeObject(forKey: Keys.isFirstLaunch)
        defaults.removeObject(forKey: Keys.hasCompletedOnboarding)
        defaults.removeObject(forKey: Keys.autoLoginEnabled)
        defaults.removeObject(forKey: Keys.lastLoginEmail)
    }
}
