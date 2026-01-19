//
//  SplashViewModel.swift
//  LoginDemo
//
//  스플래시 화면 ViewModel
//

import Foundation
import Observation

/// 스플래시 화면 ViewModel
@Observable
@MainActor
final class SplashViewModel {
    // MARK: - Properties

    /// 로딩 상태
    private(set) var isLoading: Bool = true

    /// 에러
    private(set) var error: Error?

    private let autoLoginUseCase: AutoLoginUseCase
    private let checkOnboardingUseCase: CheckOnboardingUseCase

    // MARK: - Initialization

    init(
        autoLoginUseCase: AutoLoginUseCase,
        checkOnboardingUseCase: CheckOnboardingUseCase
    ) {
        self.autoLoginUseCase = autoLoginUseCase
        self.checkOnboardingUseCase = checkOnboardingUseCase
    }

    // MARK: - Methods

    /// 앱 초기화 및 라우팅 결정
    /// - Parameter appState: 앱 상태
    func initialize(appState: AppState) async {
        isLoading = true

        // 최소 스플래시 표시 시간 (1.5초)
        async let minimumDelay: Void = Task.sleep(for: .milliseconds(1500))

        // 자동 로그인 시도
        async let autoLoginResult = autoLoginUseCase.execute()

        // 두 작업 완료 대기
        _ = try? await minimumDelay
        let result = await autoLoginResult

        // 결과에 따라 화면 전환
        switch result {
        case .success(let user):
            appState.handleLoginSuccess(user: user)

        case .needsOnboarding:
            appState.currentScreen = .onboarding

        case .needsLogin:
            appState.currentScreen = .login

        case .needsForceUpdate:
            // TODO: 강제 업데이트 화면으로 이동
            appState.currentScreen = .login

        case .maintenance(let message):
            // TODO: 점검 화면으로 이동
            _ = message
            appState.currentScreen = .login
        }

        isLoading = false
    }
}
