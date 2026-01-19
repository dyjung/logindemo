//
//  OnboardingPage.swift
//  LoginDemo
//
//  온보딩 페이지 정보를 나타내는 도메인 엔티티
//

import Foundation

/// 온보딩 페이지 정보를 나타내는 엔티티
struct OnboardingPage: Identifiable, Equatable, Sendable {
    /// 페이지 순서 (0, 1, 2)
    let id: Int

    /// 이미지 에셋 이름
    let imageName: String

    /// 제목
    let title: String

    /// 설명
    let description: String
}

// MARK: - Default Pages

extension OnboardingPage {
    /// 기본 온보딩 페이지 목록
    static let defaultPages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            imageName: "onboarding_1",
            title: "환영합니다",
            description: "LoginDemo 앱에 오신 것을 환영합니다.\n간편하고 안전한 로그인을 경험해보세요."
        ),
        OnboardingPage(
            id: 1,
            imageName: "onboarding_2",
            title: "다양한 로그인 방식",
            description: "이메일, 카카오, 네이버, Apple 등\n원하는 방식으로 로그인하세요."
        ),
        OnboardingPage(
            id: 2,
            imageName: "onboarding_3",
            title: "시작할 준비가 되셨나요?",
            description: "지금 바로 시작하여\n모든 기능을 이용해보세요."
        )
    ]
}
