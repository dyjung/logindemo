//
//  OnboardingView.swift
//  LoginDemo
//
//  온보딩 화면
//

import SwiftUI

/// 앱 최초 실행 시 표시되는 온보딩 화면
struct OnboardingView: View {
    // MARK: - Properties

    @State private var viewModel: OnboardingViewModel
    private let appState: AppState

    // MARK: - Initialization

    init(viewModel: OnboardingViewModel, appState: AppState) {
        self._viewModel = State(initialValue: viewModel)
        self.appState = appState
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.backgroundColor
                .ignoresSafeArea()

            VStack {
                // 건너뛰기 버튼
                if !viewModel.isLastPage {
                    HStack {
                        Spacer()
                        Button("건너뛰기") {
                            viewModel.skipOnboarding(appState: appState)
                        }
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                        .padding()
                        .accessibilityLabel("온보딩 건너뛰기")
                        .accessibilityHint("탭하여 온보딩을 건너뛰고 로그인 화면으로 이동")
                    }
                } else {
                    Spacer()
                        .frame(height: 44)
                }

                // 페이지 콘텐츠
                TabView(selection: $viewModel.currentPage) {
                    ForEach(viewModel.pages) { page in
                        OnboardingPageView(page: page)
                            .tag(page.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // 페이지 인디케이터
                pageIndicator

                // 버튼
                if viewModel.isLastPage {
                    PrimaryButton(title: "시작하기") {
                        viewModel.completeOnboarding(appState: appState)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                } else {
                    Button(action: { viewModel.nextPage() }) {
                        HStack {
                            Text("다음")
                            Image(systemName: "arrow.right")
                        }
                        .font(.headline)
                        .foregroundColor(.primaryColor)
                    }
                    .accessibilityLabel("다음 페이지")
                    .padding(.bottom, 32)
                }
            }
        }
    }

    // MARK: - Subviews

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(viewModel.pages) { page in
                Circle()
                    .fill(page.id == viewModel.currentPage ? Color.primaryColor : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.currentPage)
            }
        }
        .padding(.vertical, 24)
        .accessibilityLabel("페이지 \(viewModel.currentPage + 1) / \(viewModel.pages.count)")
    }
}

// MARK: - Preview

#Preview {
    OnboardingView(
        viewModel: DIContainer.preview.makeOnboardingViewModel(),
        appState: AppState()
    )
}
