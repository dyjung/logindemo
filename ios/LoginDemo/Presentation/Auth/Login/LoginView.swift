//
//  LoginView.swift
//  LoginDemo
//
//  로그인 화면
//

import SwiftUI

/// 로그인 화면
struct LoginView: View {
    // MARK: - Properties

    @State private var viewModel: LoginViewModel
    private let appState: AppState
    private let container: DIContainer

    // MARK: - Initialization

    init(viewModel: LoginViewModel, appState: AppState, container: DIContainer) {
        self._viewModel = State(initialValue: viewModel)
        self.appState = appState
        self.container = container
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 32) {
                    // 헤더
                    headerSection

                    // 로그인 폼
                    LoginFormView(
                        email: $viewModel.email,
                        password: $viewModel.password,
                        autoLoginEnabled: $viewModel.autoLoginEnabled,
                        emailError: viewModel.emailError,
                        passwordError: viewModel.passwordError,
                        isLoading: viewModel.isLoading
                    )

                    // 로그인 버튼
                    PrimaryButton(
                        title: "로그인",
                        isLoading: viewModel.isLoading,
                        isEnabled: viewModel.isLoginEnabled
                    ) {
                        Task {
                            await viewModel.login(appState: appState)
                        }
                    }

                    // 비밀번호 찾기
                    NavigationLink(destination: ForgotPasswordView(
                        viewModel: container.makeForgotPasswordViewModel()
                    )) {
                        Text("비밀번호를 잊으셨나요?")
                            .font(.subheadline)
                            .foregroundColor(.primaryColor)
                    }
                    .accessibilityLabel("비밀번호 찾기")
                    .accessibilityHint("탭하여 비밀번호 재설정 화면으로 이동")

                    // 소셜 로그인 섹션
                    socialLoginSection

                    // 회원가입 링크
                    signUpSection
                }
                .padding(24)
            }

            // 메인으로 바로가기 더미 버튼 (개발용)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        appState.currentScreen = .main
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.right.circle.fill")
                            Text("메인으로")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.7))
                        .cornerRadius(20)
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .background(Color.backgroundColor)
        .navigationTitle("로그인")
        .navigationBarTitleDisplayMode(.inline)
        .hideKeyboardOnTap()
        .errorAlert($viewModel.error, retryAction: {
            Task {
                await viewModel.login(appState: appState)
            }
        })
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.primaryColor)
                .accessibilityHidden(true)

            Text("환영합니다")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.appTextPrimary)

            Text("계정에 로그인하세요")
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)
        }
        .padding(.top, 20)
    }

    private var socialLoginSection: some View {
        VStack(spacing: 16) {
            // 구분선
            HStack {
                Rectangle()
                    .fill(Color(.systemGray4))
                    .frame(height: 1)

                Text("또는")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
                    .padding(.horizontal, 8)

                Rectangle()
                    .fill(Color(.systemGray4))
                    .frame(height: 1)
            }

            // 소셜 로그인 버튼들
            HStack(spacing: 16) {
                // 카카오
                SocialLoginButton(provider: .kakao) {
                    Task {
                        await viewModel.performSocialLogin(provider: .kakao, appState: appState)
                    }
                }
                .disabled(viewModel.isLoading)
                .opacity(viewModel.socialLoginInProgress == .kakao ? 0.6 : 1.0)

                // 네이버
                SocialLoginButton(provider: .naver) {
                    Task {
                        await viewModel.performSocialLogin(provider: .naver, appState: appState)
                    }
                }
                .disabled(viewModel.isLoading)
                .opacity(viewModel.socialLoginInProgress == .naver ? 0.6 : 1.0)

                // Apple
                SocialLoginButton(provider: .apple) {
                    Task {
                        await viewModel.performSocialLogin(provider: .apple, appState: appState)
                    }
                }
                .disabled(viewModel.isLoading)
                .opacity(viewModel.socialLoginInProgress == .apple ? 0.6 : 1.0)
            }

            // 소셜 로그인 진행 중 표시
            if viewModel.socialLoginInProgress != nil {
                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("\(viewModel.socialLoginInProgress?.displayName ?? "") 로그인 중...")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
            }
        }
    }

    private var signUpSection: some View {
        HStack {
            Text("계정이 없으신가요?")
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)

            NavigationLink(destination: RegisterView(
                viewModel: container.makeRegisterViewModel(),
                appState: appState
            )) {
                Text("회원가입")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryColor)
            }
            .accessibilityLabel("회원가입")
            .accessibilityHint("탭하여 회원가입 화면으로 이동")
        }
        .padding(.top, 8)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        LoginView(
            viewModel: DIContainer.preview.makeLoginViewModel(),
            appState: AppState(),
            container: .preview
        )
    }
}
