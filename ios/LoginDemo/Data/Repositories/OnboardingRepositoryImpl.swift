//
//  OnboardingRepositoryImpl.swift
//  LoginDemo
//
//  온보딩 리포지토리 구현체
//

import Foundation

/// 온보딩 관련 데이터 접근 리포지토리 구현체
final class OnboardingRepositoryImpl: OnboardingRepositoryProtocol, @unchecked Sendable {
    // MARK: - Properties

    private var userDefaultsDataSource: UserDefaultsDataSourceProtocol

    // MARK: - Initialization

    init(userDefaultsDataSource: UserDefaultsDataSourceProtocol) {
        self.userDefaultsDataSource = userDefaultsDataSource
    }

    // MARK: - OnboardingRepositoryProtocol

    var hasCompletedOnboarding: Bool {
        userDefaultsDataSource.hasCompletedOnboarding
    }

    var isFirstLaunch: Bool {
        userDefaultsDataSource.isFirstLaunch
    }

    func markOnboardingCompleted() {
        userDefaultsDataSource.hasCompletedOnboarding = true
    }

    func markFirstLaunchCompleted() {
        userDefaultsDataSource.isFirstLaunch = false
    }

    func getOnboardingPages() -> [OnboardingPage] {
        OnboardingPage.defaultPages
    }
}
