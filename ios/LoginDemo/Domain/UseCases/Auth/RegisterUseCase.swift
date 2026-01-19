//
//  RegisterUseCase.swift
//  LoginDemo
//
//  회원가입 UseCase
//

import Foundation

/// 회원가입을 처리하는 UseCase
final class RegisterUseCase: Sendable {
    // MARK: - Properties

    private let authRepository: AuthRepositoryProtocol

    // MARK: - Initialization

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    // MARK: - Execute

    /// 회원가입 실행
    /// - Parameters:
    ///   - email: 사용자 이메일
    ///   - password: 비밀번호
    ///   - nickname: 닉네임
    ///   - marketingConsent: 마케팅 수신 동의 여부
    /// - Returns: 생성된 사용자 정보
    func execute(
        email: String,
        password: String,
        nickname: String,
        marketingConsent: Bool
    ) async throws -> User {
        // 입력값 검증
        guard email.isValidEmail else {
            throw AuthError.invalidInput(message: "올바른 이메일 형식이 아닙니다")
        }

        guard password.isValidPassword else {
            throw AuthError.invalidInput(message: "비밀번호는 8자 이상이어야 합니다")
        }

        guard nickname.count >= 2 else {
            throw AuthError.invalidInput(message: "닉네임은 2자 이상이어야 합니다")
        }

        // 회원가입 실행
        let (user, _) = try await authRepository.register(
            email: email,
            password: password,
            nickname: nickname,
            marketingConsent: marketingConsent
        )

        return user
    }
}
