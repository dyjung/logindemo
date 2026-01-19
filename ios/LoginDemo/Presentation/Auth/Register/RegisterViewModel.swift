//
//  RegisterViewModel.swift
//  LoginDemo
//
//  회원가입 화면 ViewModel
//

import Foundation
import Observation

/// 회원가입 화면 ViewModel
@Observable
@MainActor
final class RegisterViewModel {
    // MARK: - Properties

    /// 이메일 입력값
    var email: String = "" {
        didSet { handleEmailChange() }
    }

    /// 비밀번호 입력값
    var password: String = "" {
        didSet { validatePassword() }
    }

    /// 비밀번호 확인 입력값
    var confirmPassword: String = "" {
        didSet { validateConfirmPassword() }
    }

    /// 닉네임 입력값 (기존 name)
    var nickname: String = "" {
        didSet { validateNickname() }
    }

    /// 이용약관 동의 여부
    var agreedToTerms: Bool = false

    /// 개인정보처리방침 동의 여부
    var agreedToPrivacy: Bool = false

    /// 마케팅 수신 동의 여부
    var marketingConsent: Bool = false

    /// 이메일 오류 메시지
    private(set) var emailError: String?

    /// 비밀번호 오류 메시지
    private(set) var passwordError: String?

    /// 비밀번호 확인 오류 메시지
    private(set) var confirmPasswordError: String?

    /// 닉네임 오류 메시지 (기존 nameError)
    private(set) var nicknameError: String?

    /// 로딩 상태
    private(set) var isLoading: Bool = false

    /// 에러
    var error: Error?

    /// 회원가입 버튼 활성화 여부
    var isRegisterEnabled: Bool {
        !email.isEmpty &&
        emailError == nil &&
        !password.isEmpty &&
        passwordError == nil &&
        !confirmPassword.isEmpty &&
        confirmPasswordError == nil &&
        !nickname.isEmpty &&
        nicknameError == nil &&
        agreedToTerms &&
        agreedToPrivacy &&
        !isLoading
    }

    private let registerUseCase: RegisterUseCase

    // MARK: - Initialization

    init(registerUseCase: RegisterUseCase) {
        self.registerUseCase = registerUseCase
    }

    // MARK: - Resource Cleanup

    /// 리소스 정리 (화면 전환 시 호출)
    func cleanup() {
        isLoading = false
    }

    // MARK: - Methods

    /// 회원가입 실행
    /// - Parameter appState: 앱 상태
    func register(appState: AppState) async {
        guard isRegisterEnabled else { return }

        isLoading = true
        error = nil

        do {
            let user = try await registerUseCase.execute(
                email: email,
                password: password,
                nickname: nickname,
                marketingConsent: marketingConsent
            )

            appState.handleLoginSuccess(user: user)
        } catch {
            self.error = error
        }

        isLoading = false
    }

    /// 전체 동의 토글
    func toggleAllAgreements() {
        let newValue = !(agreedToTerms && agreedToPrivacy && marketingConsent)
        agreedToTerms = newValue
        agreedToPrivacy = newValue
        marketingConsent = newValue
    }

    // MARK: - Validation

    private func handleEmailChange() {
        validateEmail()
    }

    private func validateEmail() {
        let result = EmailValidator.validate(email)
        emailError = result.errorMessage
    }

    private func validatePassword() {
        let result = PasswordValidator.validate(password)
        passwordError = result.errorMessage

        // 비밀번호 확인 필드도 재검증
        if !confirmPassword.isEmpty {
            validateConfirmPassword()
        }
    }

    private func validateConfirmPassword() {
        let result = PasswordValidator.validateConfirmation(
            password: password,
            confirmation: confirmPassword
        )
        confirmPasswordError = result.errorMessage
    }

    private func validateNickname() {
        if nickname.count < 2 {
            nicknameError = "닉네임은 2자 이상이어야 합니다"
        } else {
            nicknameError = nil
        }
    }

    /// 입력값 초기화
    func reset() {
        email = ""
        password = ""
        confirmPassword = ""
        nickname = ""
        agreedToTerms = false
        agreedToPrivacy = false
        marketingConsent = false
        emailError = nil
        passwordError = nil
        confirmPasswordError = nil
        nicknameError = nil
        error = nil
    }
}
