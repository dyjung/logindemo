//
//  LoginViewModel.swift
//  LoginDemo
//
//  로그인 화면 ViewModel
//

import Foundation
import Observation

/// 로그인 화면 ViewModel
@Observable
@MainActor
final class LoginViewModel {
    // MARK: - Properties

    /// 이메일 입력값
    var email: String = "" {
        didSet { validateEmail() }
    }

    /// 비밀번호 입력값
    var password: String = "" {
        didSet { validatePassword() }
    }

    /// 자동 로그인 활성화 여부
    var autoLoginEnabled: Bool = false

    /// 이메일 오류 메시지
    private(set) var emailError: String?

    /// 비밀번호 오류 메시지
    private(set) var passwordError: String?

    /// 로딩 상태
    private(set) var isLoading: Bool = false

    /// 소셜 로그인 진행 중인 제공자
    private(set) var socialLoginInProgress: AuthProvider?

    /// 에러
    var error: Error?

    /// 로그인 버튼 활성화 여부
    var isLoginEnabled: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        emailError == nil &&
        password.count >= 8 &&
        !isLoading
    }

    private let loginUseCase: LoginUseCase
    private let socialLoginUseCase: SocialLoginUseCase
    private let socialAuthService: SocialAuthServiceProtocol
    
    // Task 추적 (취소 가능)
    private var loginTask: Task<Void, Never>?
    private var socialLoginTask: Task<Void, Never>?

    // MARK: - Initialization

    init(
        loginUseCase: LoginUseCase,
        socialLoginUseCase: SocialLoginUseCase,
        socialAuthService: SocialAuthServiceProtocol
    ) {
        self.loginUseCase = loginUseCase
        self.socialLoginUseCase = socialLoginUseCase
        self.socialAuthService = socialAuthService
    }

    // MARK: - Methods

    /// 이메일/비밀번호 로그인
    /// - Parameter appState: 앱 상태
    func login(appState: AppState) async {
        guard isLoginEnabled else { return }
        
        // 이전 Task 취소
        loginTask?.cancel()

        isLoading = true
        error = nil
        
        loginTask = Task {
            do {
                guard !Task.isCancelled else { return }
                
                let user = try await loginUseCase.execute(
                    email: email,
                    password: password,
                    autoLogin: autoLoginEnabled
                )
                
                guard !Task.isCancelled else { return }
                appState.handleLoginSuccess(user: user)
            } catch {
                guard !Task.isCancelled else { return }
                self.error = error
            }
            
            isLoading = false
        }
        
        await loginTask?.value
    }

    /// 소셜 로그인
    /// - Parameters:
    ///   - provider: 소셜 로그인 제공자
    ///   - appState: 앱 상태
    func performSocialLogin(provider: AuthProvider, appState: AppState) async {
        // 이전 Task 취소
        socialLoginTask?.cancel()
        
        isLoading = true
        socialLoginInProgress = provider
        error = nil
        
        socialLoginTask = Task {
            do {
                guard !Task.isCancelled else { return }
                
                // 1. 소셜 인증 서비스에서 OAuth 토큰 획득
                let authResult: SocialAuthResult
                switch provider {
                case .kakao:
                    authResult = try await socialAuthService.signInWithKakao()
                case .naver:
                    authResult = try await socialAuthService.signInWithNaver()
                case .apple:
                    authResult = try await socialAuthService.signInWithApple()
                case .google:
                    authResult = try await socialAuthService.signInWithGoogle()
                case .email:
                    throw SocialAuthError.unsupportedProvider
                }
                
                guard !Task.isCancelled else { return }

                // 2. 획득한 OAuth 토큰으로 서버 로그인
                let user = try await socialLoginUseCase.execute(
                    provider: provider,
                    oauthToken: authResult.oauthToken,
                    autoLogin: autoLoginEnabled
                )
                
                guard !Task.isCancelled else { return }
                appState.handleLoginSuccess(user: user)
            } catch let socialError as SocialAuthError {
                guard !Task.isCancelled else { return }
                // 사용자 취소의 경우 에러 표시하지 않음
                if case .userCancelled = socialError {
                    // 취소 시 무시
                } else {
                    self.error = socialError
                }
            } catch {
                guard !Task.isCancelled else { return }
                self.error = error
            }

            isLoading = false
            socialLoginInProgress = nil
        }
        
        await socialLoginTask?.value
    }

    // MARK: - Validation

    private func validateEmail() {
        let result = EmailValidator.validate(email)
        emailError = result.errorMessage
    }

    private func validatePassword() {
        let result = PasswordValidator.validate(password)
        passwordError = result.errorMessage
    }

    /// 입력값 초기화
    func reset() {
        email = ""
        password = ""
        autoLoginEnabled = false
        emailError = nil
        passwordError = nil
        error = nil
    }
    
    /// 리소스 정리 (화면 전환 시 호출)
    func cleanup() {
        loginTask?.cancel()
        loginTask = nil
        socialLoginTask?.cancel()
        socialLoginTask = nil
        isLoading = false
        socialLoginInProgress = nil
    }
}
