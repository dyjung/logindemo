//
//  LoginUseCase.swift
//  LoginDemo
//
//  이메일/비밀번호 로그인 UseCase
//

import Foundation

/// 이메일/비밀번호 로그인을 처리하는 UseCase
final class LoginUseCase: Sendable {
    // MARK: - Properties

    private let authRepository: AuthRepositoryProtocol

    // MARK: - Initialization

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    // MARK: - Execute

    /// 로그인 실행
    /// - Parameters:
    ///   - email: 사용자 이메일
    ///   - password: 비밀번호
    ///   - autoLogin: 자동 로그인 활성화 여부
    /// - Returns: 로그인한 사용자 정보
    func execute(email: String, password: String, autoLogin: Bool) async throws -> User {
        // 입력값 검증
        guard email.isValidEmail else {
            throw AuthError.invalidInput(message: "올바른 이메일 형식이 아닙니다")
        }

        guard password.isValidPassword else {
            throw AuthError.invalidInput(message: "비밀번호는 8자 이상이어야 합니다")
        }

        // 로그인 실행
        let (user, _) = try await authRepository.login(
            email: email,
            password: password,
            autoLogin: autoLogin
        )

        return user
    }
}
