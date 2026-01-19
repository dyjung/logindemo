//
//  SplashView.swift
//  LoginDemo
//
//  스플래시 화면
//

import SwiftUI

/// 앱 시작 시 표시되는 스플래시 화면
struct SplashView: View {
    // MARK: - Properties

    @State private var viewModel: SplashViewModel
    private let appState: AppState

    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0

    // MARK: - Initialization

    init(viewModel: SplashViewModel, appState: AppState) {
        self._viewModel = State(initialValue: viewModel)
        self.appState = appState
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // 배경
            Color.backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // 로고
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.primaryColor)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .accessibilityLabel("LoginDemo 로고")

                // 앱 이름
                Text("LoginDemo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.appTextPrimary)
                    .opacity(logoOpacity)
                    .accessibilityLabel("LoginDemo")

                // 로딩 인디케이터
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .primaryColor))
                        .scaleEffect(1.2)
                        .padding(.top, 32)
                        .accessibilityLabel("로딩 중")
                }
            }
        }
        .onAppear {
            // 로고 애니메이션
            withAnimation(.easeOut(duration: 0.6)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }

            // 앱 초기화 시작
            Task {
                await viewModel.initialize(appState: appState)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let appState = AppState()
    let container = DIContainer.preview

    return SplashView(
        viewModel: container.makeSplashViewModel(),
        appState: appState
    )
}
