//
//  RefreshTokenUseCase.swift
//  LoginDemo
//
//  토큰 갱신 UseCase
//

import Foundation

/// 인증 토큰 갱신을 처리하는 UseCase
final class RefreshTokenUseCase: Sendable {
    // MARK: - Properties

    private let authRepository: AuthRepositoryProtocol

    // MARK: - Initialization

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    // MARK: - Execute

    /// 토큰 갱신 실행
    func execute() async throws {
        _ = try await authRepository.refreshToken()
    }
}
