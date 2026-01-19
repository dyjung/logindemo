//
//  ErrorAlert.swift
//  LoginDemo
//
//  에러 알림 컴포넌트
//

import SwiftUI

/// 에러 알림 표시를 위한 View Modifier
struct ErrorAlertModifier: ViewModifier {
    @Binding var error: Error?
    let title: String
    let retryAction: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .alert(
                title,
                isPresented: Binding(
                    get: { error != nil },
                    set: { if !$0 { error = nil } }
                ),
                presenting: error
            ) { _ in
                if let retryAction = retryAction {
                    Button("다시 시도", action: retryAction)
                }
                Button("확인", role: .cancel) {
                    error = nil
                }
            } message: { error in
                Text(error.localizedDescription)
            }
    }
}

extension View {
    /// 에러 알림 표시
    /// - Parameters:
    ///   - error: 표시할 에러 (nil이면 알림 숨김)
    ///   - title: 알림 제목
    ///   - retryAction: 다시 시도 버튼 액션 (선택)
    func errorAlert(
        _ error: Binding<Error?>,
        title: String = "오류",
        retryAction: (() -> Void)? = nil
    ) -> some View {
        modifier(ErrorAlertModifier(error: error, title: title, retryAction: retryAction))
    }
}

/// 에러 메시지 배너 컴포넌트
struct ErrorBanner: View {
    let message: String
    let onDismiss: (() -> Void)?

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.white)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.white)
                .lineLimit(2)

            Spacer()

            if let onDismiss = onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(Color.errorColor)
        .cornerRadius(10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("오류: \(message)")
    }
}

// MARK: - Preview

#Preview {
    VStack {
        ErrorBanner(message: "네트워크 연결을 확인해주세요", onDismiss: {})
            .padding()
    }
}
