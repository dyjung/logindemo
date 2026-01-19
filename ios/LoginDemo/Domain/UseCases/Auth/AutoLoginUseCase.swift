//
//  AutoLoginUseCase.swift
//  LoginDemo
//
//  자동 로그인 UseCase
//

import Foundation

/// 자동 로그인 결과
enum AutoLoginResult {
    /// 자동 로그인 성공
    case success(User)

    /// 온보딩 필요 (최초 실행)
    case needsOnboarding

    /// 로그인 필요 (토큰 없음 또는 갱신 실패)
    case needsLogin

    /// 강제 업데이트 필요
    case needsForceUpdate

    /// 점검 중
    case maintenance(message: String?)
}

/// 자동 로그인을 처리하는 UseCase
final class AutoLoginUseCase: Sendable {
    // MARK: - Properties

    private let authRepository: AuthRepositoryProtocol
    private let onboardingRepository: OnboardingRepositoryProtocol

    // MARK: - Initialization

    init(
        authRepository: AuthRepositoryProtocol,
        onboardingRepository: OnboardingRepositoryProtocol
    ) {
        self.authRepository = authRepository
        self.onboardingRepository = onboardingRepository
    }

    // MARK: - Execute

    /// 자동 로그인 시도
    /// - Returns: 자동 로그인 결과
    func execute() async -> AutoLoginResult {
        // 1. 최초 실행 또는 온보딩 미완료 확인
        if onboardingRepository.isFirstLaunch || !onboardingRepository.hasCompletedOnboarding {
            return .needsOnboarding
        }

        // 2. 자동 로그인 비활성화 확인
        guard authRepository.isAutoLoginEnabled else {
            return .needsLogin
        }

        // 3. 앱 초기화 및 사용자 정보 확인
        do {
            let response = try await authRepository.initApp()

            // 3.1. 강제 업데이트 확인
            if response.forceUpdate {
                return .needsForceUpdate
            }

            // 3.2. 점검 모드 확인
            if response.isMaintenance {
                return .maintenance(message: response.config.noticeMessage)
            }

            // 3.3. 자동 로그인 결과 확인
            if let autoLogin = response.autoLogin {
                if autoLogin.success, let userDto = autoLogin.user {
                    let user = UserMapper.toEntity(userDto)
                    return .success(user)
                } else {
                    // 자동 로그인 실패 (토큰 만료 등)
                    return .needsLogin
                }
            } else {
                // 자동 로그인 정보 없음 (토큰 없음)
                return .needsLogin
            }
        } catch {
            // 초기화 실패 시 (네트워크 오류 등) 로그인 필요
            return .needsLogin
        }
    }
}
