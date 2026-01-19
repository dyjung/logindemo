//
//  AppState.swift
//  LoginDemo
//
//  앱 전역 상태 관리
//

import Foundation
import Observation

/// 앱 전역 상태를 관리하는 Observable 클래스
@Observable
@MainActor
final class AppState {
    // MARK: - Properties

    /// 현재 표시 화면
    var currentScreen: AppScreen = .splash

    /// 인증 상태
    var isAuthenticated: Bool = false

    /// 온보딩 완료 여부
    var hasCompletedOnboarding: Bool = false

    /// 현재 로그인한 사용자
    var currentUser: User?

    /// 전역 에러
    var globalError: Error?

    /// 로딩 상태
    var isLoading: Bool = false

    // MARK: - Methods

    /// 로그인 성공 처리
    /// - Parameter user: 로그인한 사용자
    func handleLoginSuccess(user: User) {
        currentUser = user
        isAuthenticated = true
        navigateToScreen(.main)
    }

    /// 로그아웃 처리
    func handleLogout() {
        currentUser = nil
        isAuthenticated = false
        navigateToScreen(.login)
    }

    /// 온보딩 완료 처리
    func handleOnboardingComplete() {
        hasCompletedOnboarding = true
        navigateToScreen(.login)
    }
    
    /// 화면 전환 (내부용)
    private func navigateToScreen(_ screen: AppScreen) {
        currentScreen = screen
    }

    /// 앱 초기화 완료 후 화면 결정
    /// - Parameters:
    ///   - isFirstLaunch: 최초 실행 여부
    ///   - hasCompletedOnboarding: 온보딩 완료 여부
    ///   - isAutoLoginSuccess: 자동 로그인 성공 여부
    ///   - user: 자동 로그인된 사용자 (선택)
    func handleAppInitialized(
        isFirstLaunch: Bool,
        hasCompletedOnboarding: Bool,
        isAutoLoginSuccess: Bool,
        user: User?
    ) {
        self.hasCompletedOnboarding = hasCompletedOnboarding

        if isFirstLaunch || !hasCompletedOnboarding {
            currentScreen = .onboarding
        } else if isAutoLoginSuccess, let user = user {
            currentUser = user
            isAuthenticated = true
            currentScreen = .main
        } else {
            currentScreen = .login
        }
    }
}
