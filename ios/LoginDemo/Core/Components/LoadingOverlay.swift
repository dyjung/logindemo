//
//  LoadingOverlay.swift
//  LoginDemo
//
//  로딩 오버레이 컴포넌트
//

import SwiftUI

/// 로딩 상태를 표시하는 오버레이
struct LoadingOverlay: View {
    // MARK: - Properties

    let message: String?

    // MARK: - Initialization

    init(message: String? = nil) {
        self.message = message
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)

                if let message = message {
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
            }
            .padding(32)
            .background(Color(.systemGray5).opacity(0.9))
            .cornerRadius(16)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message ?? "로딩 중")
        .accessibilityAddTraits(.updatesFrequently)
    }
}

// MARK: - View Modifier

extension View {
    /// 로딩 오버레이 표시
    /// - Parameters:
    ///   - isLoading: 로딩 상태
    ///   - message: 로딩 메시지 (선택)
    func loadingOverlay(isLoading: Bool, message: String? = nil) -> some View {
        ZStack {
            self

            if isLoading {
                LoadingOverlay(message: message)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    Text("Content")
        .loadingOverlay(isLoading: true, message: "로그인 중...")
}
