//
//  AuthRemoteDataSource.swift
//  LoginDemo
//
//  인증 관련 원격 데이터 소스
//

import Foundation

/// 인증 관련 API 호출을 담당하는 데이터 소스
final class AuthRemoteDataSource: @unchecked Sendable {
    // MARK: - Properties

    private let networkService: NetworkServiceProtocol

    // MARK: - Initialization

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    // MARK: - Public Methods

    /// 앱 초기화 (GET /v1/init)
    /// - Parameter refreshToken: 자동 로그인용 리프레시 토큰 (선택)
    /// - Returns: InitAppResponseDTO
    func initApp(refreshToken: String?) async throws -> InitAppResponseDTO {
        let router = AuthRouter.initApp(refreshToken: refreshToken)
        return try await networkService.request(router)
    }

    /// 통합 로그인 (EMAIL, SOCIAL)
    func login(dto: LoginRequestDTO) async throws -> AuthResponseDTO {
        let router = AuthRouter.login(dto: dto)
        return try await networkService.request(router)
    }

    /// 통합 회원가입
    func register(dto: RegisterRequestDTO) async throws -> AuthResponseDTO {
        let router = AuthRouter.register(dto: dto)
        return try await networkService.request(router)
    }

    /// 토큰 갱신
    func refreshToken(dto: TokenRefreshRequestDTO) async throws -> TokenRefreshResponseDTO {
        return try await networkService.request(AuthRouter.refreshToken(dto: dto))
    }

    /// 이메일(아이디) 찾기
    func findId(provider: String, socialAccessToken: String) async throws -> FindIdResponseDTO {
        let router = AuthRouter.findId(provider: provider, socialAccessToken: socialAccessToken)
        return try await networkService.request(router)
    }

    /// 비밀번호 재설정 요청
    func passwordReset(email: String) async throws -> PasswordResetResponseDTO {
        let router = AuthRouter.passwordReset(email: email)
        return try await networkService.request(router)
    }

    /// 비밀번호 변경 확정
    func passwordConfirm(dto: PasswordConfirmRequestDTO) async throws -> PasswordConfirmResponseDTO {
        let router = AuthRouter.passwordConfirm(dto: dto)
        return try await networkService.request(router)
    }

    /// 로그아웃
    func logout(dto: LogoutRequestDTO) async throws -> LogoutResponseDTO {
        let router = AuthRouter.logout(dto: dto)
        return try await networkService.request(router)
    }

    /// 토큰 검증
    func verifyToken() async throws -> TokenVerifyResponseDTO {
        let router = AuthRouter.verifyToken
        return try await networkService.request(router)
    }
}
