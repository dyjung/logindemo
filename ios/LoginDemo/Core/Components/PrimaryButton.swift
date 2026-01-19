//
//  PrimaryButton.swift
//  LoginDemo
//
//  기본 버튼 컴포넌트
//

import SwiftUI

/// 앱의 기본 버튼 스타일
struct PrimaryButton: View {
    // MARK: - Properties

    let title: String
    let isLoading: Bool
    let isEnabled: Bool
    let action: () -> Void

    // MARK: - Initialization

    init(
        title: String,
        isLoading: Bool = false,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.action = action
    }

    // MARK: - Body

    var body: some View {
        Button(action: {
            guard !isLoading && isEnabled else { return }
            action()
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                }

                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(buttonBackground)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(!isEnabled || isLoading)
        .accessibilityLabel("\(title) 버튼")
        .accessibilityHint(isEnabled ? "탭하여 \(title)" : "비활성화됨")
        .accessibilityAddTraits(isEnabled ? .isButton : [.isButton, .isStaticText])
    }

    // MARK: - Private

    private var buttonBackground: Color {
        if isEnabled && !isLoading {
            return .primaryColor
        } else {
            return .gray.opacity(0.5)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "로그인", action: {})
        PrimaryButton(title: "로딩 중", isLoading: true, action: {})
        PrimaryButton(title: "비활성화", isEnabled: false, action: {})
    }
    .padding()
}
