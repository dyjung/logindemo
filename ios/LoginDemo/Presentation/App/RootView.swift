//
//  RootView.swift
//  LoginDemo
//
//  앱의 루트 뷰 - 조건부 화면 렌더링
//

import SwiftUI

/// 앱의 루트 뷰
/// AppState에 따라 적절한 화면을 표시합니다.
struct RootView: View {
    // MARK: - Properties

    @State private var appState: AppState
    private let container: DIContainer
    
    // ViewModel 캐싱 (메모리 누수 방지)
    @State private var splashViewModel: SplashViewModel?
    @State private var onboardingViewModel: OnboardingViewModel?
    @State private var loginViewModel: LoginViewModel?

    // MARK: - Initialization

    init(appState: AppState, container: DIContainer) {
        self._appState = State(initialValue: appState)
        self.container = container
    }

    // MARK: - Body

    var body: some View {
        Group {
            switch appState.currentScreen {
            case .splash:
                if let viewModel = splashViewModel {
                    SplashView(
                        viewModel: viewModel,
                        appState: appState
                    )
                } else {
                    ProgressView()
                }

            case .onboarding:
                if let viewModel = onboardingViewModel {
                    OnboardingView(
                        viewModel: viewModel,
                        appState: appState
                    )
                } else {
                    ProgressView()
                }

            case .login:
                if let viewModel = loginViewModel {
                    NavigationStack {
                        LoginView(
                            viewModel: viewModel,
                            appState: appState,
                            container: container
                        )
                    }
                } else {
                    ProgressView()
                }

            case .main:
                MainView(appState: appState, container: container)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.currentScreen)
        .errorAlert($appState.globalError)
        .onAppear {
            setupViewModel(for: appState.currentScreen)
        }
        .onChange(of: appState.currentScreen) { oldScreen, newScreen in
            // 화면 전환 시 처리
            cleanupViewModel(for: oldScreen)
            setupViewModel(for: newScreen)
        }
    }
    
    // MARK: - Helper Methods
    
    /// 화면에 필요한 ViewModel 생성
    private func setupViewModel(for screen: AppScreen) {
        switch screen {
        case .splash:
            if splashViewModel == nil {
                splashViewModel = container.makeSplashViewModel()
            }
        case .onboarding:
            if onboardingViewModel == nil {
                onboardingViewModel = container.makeOnboardingViewModel()
            }
        case .login:
            if loginViewModel == nil {
                loginViewModel = container.makeLoginViewModel()
            }
        case .main:
            break
        }
    }
    
    /// 화면에 해당하는 ViewModel 정리
    private func cleanupViewModel(for screen: AppScreen) {
        switch screen {
        case .splash:
            splashViewModel = nil
        case .onboarding:
            onboardingViewModel = nil
        case .login:
            loginViewModel?.cleanup()  // Task 취소
            loginViewModel = nil
        case .main:
            break // MainView는 ViewModel을 캐싱하지 않음
        }
    }
}

// MARK: - Preview

#Preview {
    RootView(appState: AppState(), container: .preview)
}
