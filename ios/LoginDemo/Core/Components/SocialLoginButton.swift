//
//  SocialLoginButton.swift
//  LoginDemo
//
//  소셜 로그인 버튼 컴포넌트
//

import SwiftUI

/// 소셜 로그인 버튼
struct SocialLoginButton: View {
    // MARK: - Properties

    let provider: AuthProvider
    let action: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 56, height: 56)

                providerIcon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(iconColor)
            }
        }
        .accessibilityLabel("\(provider.displayName) 로그인")
        .accessibilityHint("탭하여 \(provider.displayName) 계정으로 로그인")
    }

    // MARK: - Private

    private var backgroundColor: Color {
        switch provider {
        case .kakao:
            return .kakaoYellow
        case .naver:
            return .naverGreen
        case .apple:
            return .black
        case .google:
            return .white
        case .email:
            return .primaryColor
        }
    }

    private var iconColor: Color {
        switch provider {
        case .kakao:
            return .black
        case .naver, .apple:
            return .white
        case .google:
            return .red // Google has its own colors, but let's use red for now as icon color if needed, or white if it's a solid icon.
        case .email:
            return .white
        }
    }

    private var providerIcon: Image {
        switch provider {
        case .kakao:
            // 카카오 아이콘 (임시로 시스템 아이콘 사용)
            return Image(systemName: "message.fill")
        case .naver:
            // 네이버 아이콘 (임시로 시스템 아이콘 사용)
            return Image(systemName: "n.circle.fill")
        case .apple:
            return Image(systemName: "apple.logo")
        case .google:
            // 구글 아이콘 (임시로 시스템 아이콘 사용)
            return Image(systemName: "g.circle.fill")
        case .email:
            return Image(systemName: "envelope.fill")
        }
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 16) {
        SocialLoginButton(provider: .kakao) {}
        SocialLoginButton(provider: .naver) {}
        SocialLoginButton(provider: .apple) {}
    }
    .padding()
}
