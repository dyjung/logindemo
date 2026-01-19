//
//  AuthRepositoryImpl.swift
//  LoginDemo
//
//  인증 리포지토리 구현체
//

import Foundation

/// 인증 관련 데이터 접근 리포지토리 구현체
final class AuthRepositoryImpl: AuthRepositoryProtocol, @unchecked Sendable {
    // MARK: - Properties

    private let remoteDataSource: AuthRemoteDataSource
    private var keychainDataSource: KeychainDataSourceProtocol
    private var userDefaultsDataSource: UserDefaultsDataSourceProtocol

    // MARK: - Initialization

    init(
        remoteDataSource: AuthRemoteDataSource,
        keychainDataSource: KeychainDataSourceProtocol,
        userDefaultsDataSource: UserDefaultsDataSourceProtocol
    ) {
        self.remoteDataSource = remoteDataSource
        self.keychainDataSource = keychainDataSource
        self.userDefaultsDataSource = userDefaultsDataSource
    }

    // MARK: - AuthRepositoryProtocol

    func login(email: String, password: String, autoLogin: Bool) async throws -> (User, AuthToken) {
        let dto = LoginRequestDTO(
            provider: AuthProvider.email.rawValue,
            email: email,
            password: password,
            socialAccessToken: nil,
            deviceInfo: getDeviceInfo()
        )

        let response = try await remoteDataSource.login(dto: dto)

        let user = UserMapper.toEntity(response.user)
        let token = AuthTokenMapper.toEntity(response)

        // 토큰 저장
        saveTokens(token)
        keychainDataSource.saveUserId(user.id)

        // 자동 로그인 설정
        userDefaultsDataSource.autoLoginEnabled = autoLogin
        userDefaultsDataSource.lastLoginEmail = email

        return (user, token)
    }

    func register(
        email: String,
        password: String,
        nickname: String,
        marketingConsent: Bool
    ) async throws -> (User, AuthToken) {
        let dto = RegisterRequestDTO(
            provider: AuthProvider.email.rawValue,
            email: email,
            password: password,
            nickname: nickname,
            socialAccessToken: nil,
            marketingConsent: marketingConsent,
            deviceInfo: getDeviceInfo()
        )

        let response = try await remoteDataSource.register(dto: dto)

        let user = UserMapper.toEntity(response.user)
        let token = AuthTokenMapper.toEntity(response)

        // 토큰 저장
        saveTokens(token)
        keychainDataSource.saveUserId(user.id)

        // 회원가입 후 자동 로그인 활성화
        userDefaultsDataSource.autoLoginEnabled = true
        userDefaultsDataSource.lastLoginEmail = email

        return (user, token)
    }

    func socialLogin(
        provider: AuthProvider,
        oauthToken: String,
        autoLogin: Bool
    ) async throws -> (User, AuthToken) {
        let dto = LoginRequestDTO(
            provider: provider.rawValue,
            email: nil,
            password: nil,
            socialAccessToken: oauthToken,
            deviceInfo: getDeviceInfo()
        )

        let response = try await remoteDataSource.login(dto: dto)

        let user = UserMapper.toEntity(response.user)
        let token = AuthTokenMapper.toEntity(response)

        // 토큰 저장
        saveTokens(token)
        keychainDataSource.saveUserId(user.id)

        // 자동 로그인 설정
        userDefaultsDataSource.autoLoginEnabled = autoLogin

        return (user, token)
    }

    func refreshToken() async throws -> AuthToken {
        guard let refreshToken = keychainDataSource.getRefreshToken() else {
            throw AuthError.tokenRefreshFailed
        }

        let dto = TokenRefreshRequestDTO(
            refreshToken: refreshToken,
            deviceInfo: getDeviceInfo()
        )

        let response = try await remoteDataSource.refreshToken(dto: dto)
        let token = AuthTokenMapper.toEntity(response, existingRefreshToken: refreshToken)

        // 새 토큰 저장
        saveTokens(token)

        return token
    }

    func passwordReset(email: String) async throws {
        _ = try await remoteDataSource.passwordReset(email: email)
    }

    func logout() async throws {
        // 서버에 로그아웃 요청
        let refreshToken = keychainDataSource.getRefreshToken()
        let dto = LogoutRequestDTO(refreshToken: refreshToken, allDevices: false)
        _ = try? await remoteDataSource.logout(dto: dto)

        // 로컬 데이터 삭제
        keychainDataSource.clearAll()
        userDefaultsDataSource.autoLoginEnabled = false
    }

    func initApp() async throws -> InitAppResponseDTO {
        // 저장된 리프레시 토큰으로 자동 로그인 시도
        let refreshToken = keychainDataSource.getRefreshToken()
        let response = try await remoteDataSource.initApp(refreshToken: refreshToken)

        // 자동 로그인 성공 시 토큰 저장
        if let autoLogin = response.autoLogin, autoLogin.success {
            if let accessToken = autoLogin.accessToken {
                keychainDataSource.saveAccessToken(accessToken)
            }
            if let newRefreshToken = autoLogin.refreshToken {
                keychainDataSource.saveRefreshToken(newRefreshToken)
            }
        }

        return response
    }

    func getStoredToken() -> AuthToken? {
        guard let accessToken = keychainDataSource.getAccessToken(),
              let refreshToken = keychainDataSource.getRefreshToken() else {
            return nil
        }

        return AuthToken(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresIn: 0 // 로컬 저장 시 만료 시간 정보 없음
        )
    }

    var isAutoLoginEnabled: Bool {
        userDefaultsDataSource.autoLoginEnabled
    }

    var hasValidToken: Bool {
        keychainDataSource.hasValidToken
    }

    // MARK: - Private Methods

    private func getDeviceInfo() -> DeviceInfoDTO {
        return DeviceInfoDTO(
            deviceId: keychainDataSource.getDeviceId() ?? "unknown",
            platform: "iOS",
            appVersion: "1.0.0"
        )
    }

    private func saveTokens(_ token: AuthToken) {
        keychainDataSource.saveAccessToken(token.accessToken)
        keychainDataSource.saveRefreshToken(token.refreshToken)
    }
}
