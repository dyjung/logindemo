//
//  LoginFormView.swift
//  LoginDemo
//
//  로그인 폼 컴포넌트
//

import SwiftUI

/// 로그인 폼 (이메일, 비밀번호, 자동로그인)
struct LoginFormView: View {
    // MARK: - Properties

    @Binding var email: String
    @Binding var password: String
    @Binding var autoLoginEnabled: Bool
    let emailError: String?
    let passwordError: String?
    let isLoading: Bool

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            // 이메일 입력
            VStack(alignment: .leading, spacing: 4) {
                TextField("이메일", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(emailError != nil ? Color.errorColor : Color.clear, lineWidth: 1)
                    )
                    .disabled(isLoading)
                    .accessibilityLabel("이메일 입력")
                    .accessibilityValue(email.isEmpty ? "비어 있음" : email)
                    .accessibilityHint("이메일 주소를 입력하세요")

                if let error = emailError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.errorColor)
                        .accessibilityLabel("이메일 오류: \(error)")
                }
            }

            // 비밀번호 입력
            SecureTextField("비밀번호", text: $password, errorMessage: passwordError)
                .disabled(isLoading)

            // 자동 로그인 토글
            HStack {
                Toggle("자동 로그인", isOn: $autoLoginEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: .primaryColor))
                    .disabled(isLoading)
                    .accessibilityLabel("자동 로그인")
                    .accessibilityValue(autoLoginEnabled ? "켜짐" : "꺼짐")
                    .accessibilityHint("탭하여 자동 로그인 설정 변경")
            }
            .padding(.top, 8)
        }
    }
}

// MARK: - Preview

#Preview {
    LoginFormView(
        email: .constant("test@example.com"),
        password: .constant("password"),
        autoLoginEnabled: .constant(true),
        emailError: nil,
        passwordError: nil,
        isLoading: false
    )
    .padding()
}
