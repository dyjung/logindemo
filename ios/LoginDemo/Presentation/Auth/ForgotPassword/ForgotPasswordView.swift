//
//  ForgotPasswordView.swift
//  LoginDemo
//
//  비밀번호 찾기 화면
//

import SwiftUI

/// 비밀번호 찾기 화면
struct ForgotPasswordView: View {
    // MARK: - Properties

    @State private var viewModel: ForgotPasswordViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - Initialization

    init(viewModel: ForgotPasswordViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // 헤더
                headerSection

                // 이메일 입력
                emailSection

                // 전송 버튼
                PrimaryButton(
                    title: "재설정 이메일 보내기",
                    isLoading: viewModel.isLoading,
                    isEnabled: viewModel.isSendEnabled
                ) {
                    Task {
                        await viewModel.sendResetEmail()
                    }
                }

                // 성공 메시지
                if let message = viewModel.successMessage {
                    successMessageView(message)
                }

                Spacer()
            }
            .padding(24)
        }
        .background(Color.backgroundColor)
        .navigationTitle("비밀번호 찾기")
        .navigationBarTitleDisplayMode(.inline)
        .hideKeyboardOnTap()
        .errorAlert($viewModel.error)
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.primaryColor)
                .accessibilityHidden(true)

            Text("비밀번호를 잊으셨나요?")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.appTextPrimary)

            Text("가입한 이메일 주소를 입력하시면\n비밀번호 재설정 링크를 보내드립니다.")
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }

    private var emailSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField("이메일", text: $viewModel.email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(viewModel.emailError != nil ? Color.errorColor : Color.clear, lineWidth: 1)
                )
                .disabled(viewModel.isLoading)
                .accessibilityLabel("이메일 입력")
                .accessibilityHint("비밀번호 재설정 이메일을 받을 주소를 입력하세요")

            if let error = viewModel.emailError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.errorColor)
                    .accessibilityLabel("오류: \(error)")
            }
        }
    }

    private func successMessageView(_ message: String) -> some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.appTextPrimary)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ForgotPasswordView(
            viewModel: DIContainer.shared.makeForgotPasswordViewModel()
        )
    }
}
