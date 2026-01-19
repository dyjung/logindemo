//
//  SocialAuthServiceProtocol.swift
//  LoginDemo
//
//  소셜 인증 서비스 프로토콜
//

import Foundation

/// 소셜 로그인 결과
struct SocialAuthResult: Sendable {
    /// OAuth 액세스 토큰
    let oauthToken: String

    /// 인증 제공자
    let provider: AuthProvider

    /// 사용자 이메일 (선택적)
    let email: String?

    /// 사용자 이름 (선택적)
    let name: String?
}

/// 소셜 인증 에러
enum SocialAuthError: LocalizedError, Sendable {
    /// 사용자가 인증을 취소함
    case userCancelled

    /// 인증 실패
    case authenticationFailed(String)

    /// 지원하지 않는 제공자
    case unsupportedProvider

    /// SDK 초기화 실패
    case sdkNotInitialized

    /// 네트워크 에러
    case networkError

    var errorDescription: String? {
        switch self {
        case .userCancelled:
            return "로그인이 취소되었습니다"
        case .authenticationFailed(let message):
            return "인증에 실패했습니다: \(message)"
        case .unsupportedProvider:
            return "지원하지 않는 로그인 방식입니다"
        case .sdkNotInitialized:
            return "소셜 로그인 초기화에 실패했습니다"
        case .networkError:
            return "네트워크 연결을 확인해주세요"
        }
    }
}

/// 소셜 인증 서비스 프로토콜
protocol SocialAuthServiceProtocol: Sendable {
    /// 카카오 로그인
    /// - Returns: 소셜 인증 결과
    func signInWithKakao() async throws -> SocialAuthResult

    /// 네이버 로그인
    /// - Returns: 소셜 인증 결과
    func signInWithNaver() async throws -> SocialAuthResult

    /// Apple 로그인
    /// - Returns: 소셜 인증 결과
    func signInWithApple() async throws -> SocialAuthResult

    /// 구글 로그인
    /// - Returns: 소셜 인증 결과
    func signInWithGoogle() async throws -> SocialAuthResult

    /// 로그아웃
    /// - Parameter provider: 로그아웃할 제공자
    func signOut(provider: AuthProvider) async
}
