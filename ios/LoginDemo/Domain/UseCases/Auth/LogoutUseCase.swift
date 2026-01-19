//
//  LogoutUseCase.swift
//  LoginDemo
//
//  로그아웃 UseCase
//

import Foundation

/// 로그아웃을 처리하는 UseCase
final class LogoutUseCase: Sendable {
    // MARK: - Properties

    private let authRepository: AuthRepositoryProtocol

    // MARK: - Initialization

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    // MARK: - Execute

    /// 로그아웃 실행
    func execute() async throws {
        try await authRepository.logout()
    }
}
