//
//  ForgotPasswordViewModel.swift
//  LoginDemo
//
//  비밀번호 찾기 ViewModel
//

import Foundation
import Observation

/// 비밀번호 찾기 화면 ViewModel
@Observable
@MainActor
final class ForgotPasswordViewModel {
    // MARK: - Properties

    /// 이메일 입력값
    var email: String = "" {
        didSet { validateEmail() }
    }

    /// 이메일 오류 메시지
    private(set) var emailError: String?

    /// 로딩 상태
    private(set) var isLoading: Bool = false

    /// 성공 메시지
    private(set) var successMessage: String?

    /// 에러
    var error: Error?

    /// 전송 버튼 활성화 여부
    var isSendEnabled: Bool {
        !email.isEmpty && emailError == nil && !isLoading
    }

    private let forgotPasswordUseCase: ForgotPasswordUseCase

    // MARK: - Initialization

    init(forgotPasswordUseCase: ForgotPasswordUseCase) {
        self.forgotPasswordUseCase = forgotPasswordUseCase
    }

    // MARK: - Methods

    /// 비밀번호 재설정 이메일 발송
    func sendResetEmail() async {
        guard isSendEnabled else { return }

        isLoading = true
        error = nil
        successMessage = nil

        do {
            try await forgotPasswordUseCase.execute(email: email)
            successMessage = "비밀번호 재설정 이메일이 발송되었습니다.\n이메일을 확인해주세요."
        } catch {
            self.error = error
        }

        isLoading = false
    }

    // MARK: - Validation

    private func validateEmail() {
        if email.isEmpty {
            emailError = nil
        } else if !email.isValidEmail {
            emailError = "올바른 이메일 형식이 아닙니다"
        } else {
            emailError = nil
        }
    }

    /// 상태 초기화
    func reset() {
        email = ""
        emailError = nil
        successMessage = nil
        error = nil
    }
}
