//
//  RegisterView.swift
//  LoginDemo
//
//  회원가입 화면
//

import SwiftUI

/// 회원가입 화면
struct RegisterView: View {
    // MARK: - Properties

    @State private var viewModel: RegisterViewModel
    private let appState: AppState
    @Environment(\.dismiss) private var dismiss

    // MARK: - Initialization

    init(viewModel: RegisterViewModel, appState: AppState) {
        self._viewModel = State(initialValue: viewModel)
        self.appState = appState
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 헤더
                headerSection

                // 입력 필드들
                formSection

                // 약관 동의
                AllTermsCheckboxView(
                    agreedToTerms: $viewModel.agreedToTerms,
                    agreedToPrivacy: $viewModel.agreedToPrivacy
                )

                // 회원가입 버튼
                PrimaryButton(
                    title: "회원가입",
                    isLoading: viewModel.isLoading,
                    isEnabled: viewModel.isRegisterEnabled
                ) {
                    Task {
                        await viewModel.register(appState: appState)
                    }
                }

                Spacer()
            }
            .padding(24)
        }
        .background(Color.backgroundColor)
        .navigationTitle("회원가입")
        .navigationBarTitleDisplayMode(.inline)
        .hideKeyboardOnTap()
        .errorAlert($viewModel.error)
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("새 계정 만들기")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.appTextPrimary)

            Text("아래 정보를 입력하여 가입하세요")
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)
        }
        .padding(.top, 20)
    }

    private var formSection: some View {
        VStack(spacing: 16) {
            // 이메일
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    TextField("이메일", text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .disabled(viewModel.isLoading)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(viewModel.emailError != nil ? Color.errorColor : Color.clear, lineWidth: 1)
                )
                .accessibilityLabel("이메일 입력")
                .accessibilityValue(viewModel.email.isEmpty ? "비어 있음" : viewModel.email)

                if let error = viewModel.emailError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.errorColor)
                        .accessibilityLabel("이메일 오류: \(error)")
                }
            }

            // 비밀번호
            SecureTextField(
                "비밀번호 (8자 이상)",
                text: $viewModel.password,
                errorMessage: viewModel.passwordError
            )
            .disabled(viewModel.isLoading)

            // 비밀번호 확인
            SecureTextField(
                "비밀번호 확인",
                text: $viewModel.confirmPassword,
                errorMessage: viewModel.confirmPasswordError
            )
            .disabled(viewModel.isLoading)

            // 닉네임 (기존 이름)
            VStack(alignment: .leading, spacing: 4) {
                TextField("닉네임", text: $viewModel.nickname)
                    .textContentType(.name)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(viewModel.nicknameError != nil ? Color.errorColor : Color.clear, lineWidth: 1)
                    )
                    .disabled(viewModel.isLoading)
                    .accessibilityLabel("닉네임 입력")
                    .accessibilityValue(viewModel.nickname.isEmpty ? "비어 있음" : viewModel.nickname)

                if let error = viewModel.nicknameError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.errorColor)
                        .accessibilityLabel("닉네임 오류: \(error)")
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        RegisterView(
            viewModel: DIContainer.shared.makeRegisterViewModel(),
            appState: AppState()
        )
    }
}
