//
//  SocialAuthService.swift
//  LoginDemo
//
//  소셜 인증 서비스 구현
//

import AuthenticationServices
import Foundation

/// 소셜 인증 서비스 구현체
@MainActor
final class SocialAuthService: NSObject, SocialAuthServiceProtocol, Sendable {
    // MARK: - Properties

    private var appleSignInContinuation: CheckedContinuation<SocialAuthResult, Error>?
    private var authorizationController: ASAuthorizationController?

    // MARK: - SocialAuthServiceProtocol

    /// 카카오 로그인
    /// - Returns: 소셜 인증 결과
    /// - Note: 실제 구현 시 KakaoSDK를 사용하여 구현
    nonisolated func signInWithKakao() async throws -> SocialAuthResult {
        // TODO: 실제 카카오 SDK 연동
        // 1. KakaoSDK.shared.isKakaoTalkLoginAvailable() 확인
        // 2. 카카오톡 앱 또는 웹 로그인 진행
        // 3. OAuth 토큰 획득 후 반환

        // 현재는 개발용 Mock 구현
        // 실제 앱에서는 KakaoSDK를 import하고 아래와 같이 구현:
        // if (UserApi.isKakaoTalkLoginAvailable()) {
        //     let oauthToken = try await UserApi.shared.loginWithKakaoTalk()
        //     return SocialAuthResult(oauthToken: oauthToken.accessToken, provider: .kakao, ...)
        // }

        try await Task.sleep(nanoseconds: 500_000_000) // 0.5초 딜레이 (네트워크 시뮬레이션)

        return SocialAuthResult(
            oauthToken: "mock_kakao_oauth_token_\(UUID().uuidString)",
            provider: .kakao,
            email: nil,
            name: nil
        )
    }

    /// 네이버 로그인
    /// - Returns: 소셜 인증 결과
    /// - Note: 실제 구현 시 NaverThirdPartyLogin SDK를 사용하여 구현
    nonisolated func signInWithNaver() async throws -> SocialAuthResult {
        // TODO: 실제 네이버 SDK 연동
        // 1. NaverThirdPartyLoginConnection.getSharedInstance() 초기화
        // 2. requestThirdPartyLogin() 호출
        // 3. OAuth 토큰 획득 후 반환

        // 현재는 개발용 Mock 구현
        // 실제 앱에서는 NaverThirdPartyLogin을 import하고 구현

        try await Task.sleep(nanoseconds: 500_000_000) // 0.5초 딜레이 (네트워크 시뮬레이션)

        return SocialAuthResult(
            oauthToken: "mock_naver_oauth_token_\(UUID().uuidString)",
            provider: .naver,
            email: nil,
            name: nil
        )
    }

    /// Apple 로그인
    /// - Returns: 소셜 인증 결과
    func signInWithApple() async throws -> SocialAuthResult {
        return try await withCheckedThrowingContinuation { continuation in
            self.appleSignInContinuation = continuation

            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            
            // Controller를 인스턴스 변수에 저장하여 delegate 참조 유지
            self.authorizationController = controller
            controller.performRequests()
        }
    }

    /// 구글 로그인
    /// - Returns: 소셜 인증 결과
    /// - Note: 실제 구현 시 GoogleSignIn SDK를 사용하여 구현
    nonisolated func signInWithGoogle() async throws -> SocialAuthResult {
        // TODO: 실제 구글 SDK 연동
        try await Task.sleep(nanoseconds: 500_000_000)

        return SocialAuthResult(
            oauthToken: "mock_google_oauth_token_\(UUID().uuidString)",
            provider: .google,
            email: nil,
            name: nil
        )
    }

    /// 로그아웃
    /// - Parameter provider: 로그아웃할 제공자
    nonisolated func signOut(provider: AuthProvider) async {
        switch provider {
        case .kakao:
            // TODO: KakaoSDK 로그아웃
            // UserApi.shared.logout()
            break
        case .naver:
            // TODO: NaverSDK 로그아웃
            // NaverThirdPartyLoginConnection.getSharedInstance()?.requestDeleteToken()
            break
        case .apple, .google:
            // Apple/Google은 클라이언트측 별도 로그아웃 과정이 복잡하거나 필요 없음 (세션 만료 방식)
            break
        case .email:
            // 이메일 로그인은 소셜 로그아웃 불필요
            break
        }
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension SocialAuthService: ASAuthorizationControllerDelegate {
    nonisolated func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        Task { @MainActor in
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                appleSignInContinuation?.resume(throwing: SocialAuthError.authenticationFailed("Apple ID 자격 증명을 가져올 수 없습니다"))
                appleSignInContinuation = nil
                return
            }

            guard let identityToken = appleIDCredential.identityToken,
                  let tokenString = String(data: identityToken, encoding: .utf8) else {
                appleSignInContinuation?.resume(throwing: SocialAuthError.authenticationFailed("Identity Token을 가져올 수 없습니다"))
                appleSignInContinuation = nil
                return
            }

            // 사용자 정보 추출
            var email: String?
            var fullName: String?

            if let emailValue = appleIDCredential.email {
                email = emailValue
            }

            if let nameComponents = appleIDCredential.fullName {
                let formatter = PersonNameComponentsFormatter()
                fullName = formatter.string(from: nameComponents)
            }

            let result = SocialAuthResult(
                oauthToken: tokenString,
                provider: .apple,
                email: email,
                name: fullName
            )

            appleSignInContinuation?.resume(returning: result)
            appleSignInContinuation = nil
            authorizationController = nil
        }
    }

    nonisolated func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        Task { @MainActor in
            if let authError = error as? ASAuthorizationError {
                switch authError.code {
                case .canceled:
                    appleSignInContinuation?.resume(throwing: SocialAuthError.userCancelled)
                case .failed:
                    appleSignInContinuation?.resume(throwing: SocialAuthError.authenticationFailed("인증에 실패했습니다"))
                case .invalidResponse:
                    appleSignInContinuation?.resume(throwing: SocialAuthError.authenticationFailed("잘못된 응답입니다"))
                case .notHandled:
                    appleSignInContinuation?.resume(throwing: SocialAuthError.authenticationFailed("요청이 처리되지 않았습니다"))
                case .notInteractive:
                    appleSignInContinuation?.resume(throwing: SocialAuthError.authenticationFailed("인터랙티브 모드가 필요합니다"))
                case .unknown:
                    appleSignInContinuation?.resume(throwing: SocialAuthError.authenticationFailed("알 수 없는 오류가 발생했습니다"))
                @unknown default:
                    appleSignInContinuation?.resume(throwing: SocialAuthError.authenticationFailed(error.localizedDescription))
                }
            } else {
                appleSignInContinuation?.resume(throwing: SocialAuthError.authenticationFailed(error.localizedDescription))
            }
            appleSignInContinuation = nil
            authorizationController = nil
        }
    }
}
