//
//  SocialLoginUseCase.swift
//  LoginDemo
//
//  소셜 로그인 UseCase
//

import Foundation

/// 소셜 로그인을 처리하는 UseCase
final class SocialLoginUseCase: Sendable {
    // MARK: - Properties

    private let authRepository: AuthRepositoryProtocol

    // MARK: - Initialization

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    // MARK: - Execute

    /// 소셜 로그인 실행
    /// - Parameters:
    ///   - provider: 소셜 로그인 제공자
    ///   - oauthToken: OAuth 토큰
    ///   - autoLogin: 자동 로그인 활성화 여부
    /// - Returns: 로그인한 사용자 정보
    func execute(provider: AuthProvider, oauthToken: String, autoLogin: Bool) async throws -> User {
        let (user, _) = try await authRepository.socialLogin(
            provider: provider,
            oauthToken: oauthToken,
            autoLogin: autoLogin
        )

        return user
    }
}
