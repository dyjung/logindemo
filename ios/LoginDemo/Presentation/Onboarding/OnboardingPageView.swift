//
//  OnboardingPageView.swift
//  LoginDemo
//
//  온보딩 단일 페이지 컴포넌트
//

import SwiftUI

/// 온보딩 단일 페이지
struct OnboardingPageView: View {
    // MARK: - Properties

    let page: OnboardingPage

    // MARK: - Body

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // 이미지 (에셋이 있으면 사용, 없으면 시스템 아이콘)
            if let uiImage = UIImage(named: page.imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 250)
                    .accessibilityHidden(true)
            } else {
                Image(systemName: placeholderIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.primaryColor)
                    .frame(height: 250)
                    .accessibilityHidden(true)
            }

            // 제목
            Text(page.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.appTextPrimary)
                .multilineTextAlignment(.center)

            // 설명
            Text(page.description)
                .font(.body)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 24)

            Spacer()
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(page.title). \(page.description)")
    }

    // MARK: - Private

    private var placeholderIcon: String {
        switch page.id {
        case 0:
            return "hand.wave.fill"
        case 1:
            return "person.2.fill"
        case 2:
            return "arrow.right.circle.fill"
        default:
            return "star.fill"
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingPageView(page: OnboardingPage.defaultPages[0])
}
