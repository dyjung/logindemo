//
//  AuthRepositoryProtocol.swift
//  LoginDemo
//
//  인증 관련 리포지토리 프로토콜
//

import Foundation

/// 인증 관련 데이터 접근을 위한 리포지토리 프로토콜
protocol AuthRepositoryProtocol: Sendable {
    /// 이메일/비밀번호 로그인
    /// - Parameters:
    ///   - email: 사용자 이메일
    ///   - password: 비밀번호
    ///   - autoLogin: 자동 로그인 활성화 여부
    /// - Returns: 인증된 사용자 정보와 토큰
    func login(email: String, password: String, autoLogin: Bool) async throws -> (User, AuthToken)

    /// 회원가입
    /// - Parameters:
    ///   - email: 사용자 이메일
    ///   - password: 비밀번호
    ///   - nickname: 닉네임
    ///   - marketingConsent: 마케팅 수신 동의 여부
    /// - Returns: 생성된 사용자 정보와 토큰
    func register(
        email: String,
        password: String,
        nickname: String,
        marketingConsent: Bool
    ) async throws -> (User, AuthToken)

    /// 소셜 로그인
    /// - Parameters:
    ///   - provider: 소셜 로그인 제공자
    ///   - oauthToken: OAuth 토큰
    ///   - autoLogin: 자동 로그인 활성화 여부
    /// - Returns: 인증된 사용자 정보와 토큰
    func socialLogin(
        provider: AuthProvider,
        oauthToken: String,
        autoLogin: Bool
    ) async throws -> (User, AuthToken)

    /// 토큰 갱신
    /// - Returns: 새로운 인증 토큰
    func refreshToken() async throws -> AuthToken

    /// 비밀번호 재설정 이메일 발송
    /// - Parameter email: 이메일 주소
    func passwordReset(email: String) async throws

    /// 로그아웃
    func logout() async throws

    /// 앱 초기화 (GET /v1/init)
    /// - Returns: 앱 설정, 강제 업데이트, 점검 상태, 사용자 컨텍스트, 자동 로그인 결과 포함
    func initApp() async throws -> InitAppResponseDTO

    /// 저장된 인증 토큰 조회
    /// - Returns: 저장된 토큰 (없으면 nil)
    func getStoredToken() -> AuthToken?

    /// 자동 로그인 활성화 여부
    var isAutoLoginEnabled: Bool { get }

    /// 저장된 Access Token 존재 여부
    var hasValidToken: Bool { get }
}
