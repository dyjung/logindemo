//
//  ForgotPasswordUseCase.swift
//  LoginDemo
//
//  비밀번호 재설정 UseCase
//

import Foundation

/// 비밀번호 재설정 이메일 발송을 처리하는 UseCase
final class ForgotPasswordUseCase: Sendable {
    // MARK: - Properties

    private let authRepository: AuthRepositoryProtocol

    // MARK: - Initialization

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    // MARK: - Execute

    /// 비밀번호 재설정 이메일 발송
    /// - Parameter email: 이메일 주소
    func execute(email: String) async throws {
        guard email.isValidEmail else {
            throw AuthError.invalidInput(message: "올바른 이메일 형식이 아닙니다")
        }

        try await authRepository.passwordReset(email: email)
    }
}
