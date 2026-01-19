//
//  MockSocialAuthService.swift
//  LoginDemo
//
//  테스트용 소셜 인증 서비스 Mock
//

import Foundation

/// 테스트용 소셜 인증 서비스 Mock
final class MockSocialAuthService: SocialAuthServiceProtocol, @unchecked Sendable {
    // MARK: - Mock Configuration

    /// Mock 응답 딜레이 (초)
    var mockDelay: TimeInterval = 0.5

    /// 카카오 로그인 결과
    var kakaoResult: Result<SocialAuthResult, Error> = .success(
        SocialAuthResult(
            oauthToken: "mock_kakao_token",
            provider: .kakao,
            email: "kakao@example.com",
            name: "카카오 사용자"
        )
    )

    /// 네이버 로그인 결과
    var naverResult: Result<SocialAuthResult, Error> = .success(
        SocialAuthResult(
            oauthToken: "mock_naver_token",
            provider: .naver,
            email: "naver@example.com",
            name: "네이버 사용자"
        )
    )

    /// Apple 로그인 결과
    var appleResult: Result<SocialAuthResult, Error> = .success(
        SocialAuthResult(
            oauthToken: "mock_apple_token",
            provider: .apple,
            email: "apple@example.com",
            name: "Apple 사용자"
        )
    )

    /// 구글 로그인 결과
    var googleResult: Result<SocialAuthResult, Error> = .success(
        SocialAuthResult(
            oauthToken: "mock_google_token",
            provider: .google,
            email: "google@example.com",
            name: "구글 사용자"
        )
    )

    // MARK: - Call Tracking

    private(set) var signInWithKakaoCalled = false
    private(set) var signInWithNaverCalled = false
    private(set) var signInWithAppleCalled = false
    private(set) var signInWithGoogleCalled = false
    private(set) var signOutCalledWith: AuthProvider?

    // MARK: - SocialAuthServiceProtocol

    func signInWithKakao() async throws -> SocialAuthResult {
        signInWithKakaoCalled = true
        try await Task.sleep(nanoseconds: UInt64(mockDelay * 1_000_000_000))

        switch kakaoResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }

    func signInWithNaver() async throws -> SocialAuthResult {
        signInWithNaverCalled = true
        try await Task.sleep(nanoseconds: UInt64(mockDelay * 1_000_000_000))

        switch naverResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }

    func signInWithApple() async throws -> SocialAuthResult {
        signInWithAppleCalled = true
        try await Task.sleep(nanoseconds: UInt64(mockDelay * 1_000_000_000))

        switch appleResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }

    func signInWithGoogle() async throws -> SocialAuthResult {
        signInWithGoogleCalled = true
        try await Task.sleep(nanoseconds: UInt64(mockDelay * 1_000_000_000))

        switch googleResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        }
    }

    func signOut(provider: AuthProvider) async {
        signOutCalledWith = provider
    }

    // MARK: - Reset

    func reset() {
        signInWithKakaoCalled = false
        signInWithNaverCalled = false
        signInWithAppleCalled = false
        signInWithGoogleCalled = false
        signOutCalledWith = nil
    }
}
