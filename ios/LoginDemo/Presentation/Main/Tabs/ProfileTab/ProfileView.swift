//
//  ProfileView.swift
//  LoginDemo
//
//  프로필 탭 화면
//

import SwiftUI

/// 프로필 탭 화면
struct ProfileView: View {
    private let appState: AppState
    private let container: DIContainer

    init(appState: AppState, container: DIContainer) {
        self.appState = appState
        self.container = container
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 프로필 헤더
                    profileHeader

                    // 통계 섹션
                    statsSection

                    // 메뉴 섹션들
                    menuSections

                    // 로그아웃 버튼
                    logoutButton
                }
                .padding(16)
            }
            .background(Color.backgroundColor)
            .navigationTitle("프로필")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("설정")
                }
            }
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(Color.primaryColor.opacity(0.2))
                .frame(width: 80, height: 80)
                .overlay(
                    Text(appState.currentUser?.nickname.prefix(1).uppercased() ?? "U")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryColor)
                )
                .accessibilityHidden(true)

            VStack(spacing: 4) {
                Text(appState.currentUser?.nickname ?? "사용자")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.appTextPrimary)

                Text(appState.currentUser?.email ?? "email@example.com")
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
            }

            Button(action: {}) {
                Text("프로필 수정")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primaryColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.primaryColor.opacity(0.1))
                    .cornerRadius(20)
            }
            .accessibilityHint("탭하여 프로필 정보 수정")
        }
        .padding(.vertical, 16)
        .accessibilityElement(children: .contain)
    }

    private var statsSection: some View {
        HStack(spacing: 0) {
            StatItem(value: "12", label: "리뷰")
            Divider().frame(height: 40)
            StatItem(value: "48", label: "저장됨")
            Divider().frame(height: 40)
            StatItem(value: "5", label: "여행")
        }
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    private var menuSections: some View {
        VStack(spacing: 16) {
            // 활동 섹션
            MenuSection(title: "내 활동") {
                MenuItem(icon: "star.fill", title: "내 리뷰", color: .yellow)
                MenuItem(icon: "photo.fill", title: "내 사진", color: .blue)
                MenuItem(icon: "bookmark.fill", title: "북마크", color: .orange)
            }

            // 설정 섹션
            MenuSection(title: "설정") {
                MenuItem(icon: "bell.fill", title: "알림 설정", color: .red)
                MenuItem(icon: "lock.fill", title: "개인정보 보호", color: .gray)
                MenuItem(icon: "questionmark.circle.fill", title: "도움말", color: .green)
            }
        }
    }

    private var logoutButton: some View {
        Button(action: {
            Task {
                await logout()
            }
        }) {
            Text("로그아웃")
                .font(.headline)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .padding(.top, 8)
        .accessibilityLabel("로그아웃")
        .accessibilityHint("탭하여 로그아웃")
    }

    private func logout() async {
        let logoutUseCase = container.makeLogoutUseCase()
        try? await logoutUseCase.execute()
        appState.handleLogout()
    }
}

// MARK: - Components

private struct StatItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.appTextPrimary)
            Text(label)
                .font(.caption)
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label) \(value)개")
    }
}

private struct MenuSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.appTextPrimary)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                content()
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
}

private struct MenuItem: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        Button(action: {}) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 24)
                    .accessibilityHidden(true)

                Text(title)
                    .foregroundColor(.appTextPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
                    .accessibilityHidden(true)
            }
            .padding(16)
        }
        .accessibilityLabel(title)
        .accessibilityHint("탭하여 \(title) 화면으로 이동")
    }
}

#Preview {
    let appState: AppState = {
        let state = AppState()
        state.currentUser = User(
            id: "1",
            email: "test@example.com",
            nickname: "테스트 사용자",
            status: .active,
            provider: nil,
            createdAt: Date(),
            lastLogin: nil,
            updatedAt: nil
        )
        return state
    }()

    ProfileView(appState: appState, container: .shared)
}
