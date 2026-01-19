//
//  CheckOnboardingUseCase.swift
//  LoginDemo
//
//  온보딩 상태 확인 UseCase
//

import Foundation

/// 온보딩 완료 상태를 확인하는 UseCase
final class CheckOnboardingUseCase: Sendable {
    // MARK: - Properties

    private let onboardingRepository: OnboardingRepositoryProtocol

    // MARK: - Initialization

    init(onboardingRepository: OnboardingRepositoryProtocol) {
        self.onboardingRepository = onboardingRepository
    }

    // MARK: - Execute

    /// 온보딩 상태 확인
    /// - Returns: (최초 실행 여부, 온보딩 완료 여부)
    func execute() -> (isFirstLaunch: Bool, hasCompletedOnboarding: Bool) {
        return (
            isFirstLaunch: onboardingRepository.isFirstLaunch,
            hasCompletedOnboarding: onboardingRepository.hasCompletedOnboarding
        )
    }
}
