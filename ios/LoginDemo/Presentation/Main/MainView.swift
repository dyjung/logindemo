//
//  MainView.swift
//  LoginDemo
//
//  메인 화면 (로그인 후) - 탭 기반 네비게이션
//

import SwiftUI

/// 메인 탭 열거형
enum MainTab: Int, CaseIterable {
    case explore = 0
    case search
    case saved
    case notifications
    case profile

    var title: String {
        switch self {
        case .explore: return "탐색"
        case .search: return "검색"
        case .saved: return "저장됨"
        case .notifications: return "알림"
        case .profile: return "프로필"
        }
    }

    var icon: String {
        switch self {
        case .explore: return "safari"
        case .search: return "magnifyingglass"
        case .saved: return "heart"
        case .notifications: return "bell"
        case .profile: return "person"
        }
    }

    var selectedIcon: String {
        switch self {
        case .explore: return "safari.fill"
        case .search: return "magnifyingglass"
        case .saved: return "heart.fill"
        case .notifications: return "bell.fill"
        case .profile: return "person.fill"
        }
    }
}

/// 로그인 후 표시되는 메인 화면 (탭 기반)
struct MainView: View {
    // MARK: - Properties

    private let appState: AppState
    private let container: DIContainer
    @State private var selectedTab: MainTab = .explore

    // MARK: - Initialization

    init(appState: AppState, container: DIContainer) {
        self.appState = appState
        self.container = container
    }

    // MARK: - Body

    var body: some View {
        TabView(selection: $selectedTab) {
            // 탐색 탭
            ExploreView()
                .tabItem {
                    Label(
                        MainTab.explore.title,
                        systemImage: selectedTab == .explore
                            ? MainTab.explore.selectedIcon
                            : MainTab.explore.icon
                    )
                }
                .tag(MainTab.explore)

            // 검색 탭
            SearchView()
                .tabItem {
                    Label(
                        MainTab.search.title,
                        systemImage: selectedTab == .search
                            ? MainTab.search.selectedIcon
                            : MainTab.search.icon
                    )
                }
                .tag(MainTab.search)

            // 저장됨 탭
            SavedView()
                .tabItem {
                    Label(
                        MainTab.saved.title,
                        systemImage: selectedTab == .saved
                            ? MainTab.saved.selectedIcon
                            : MainTab.saved.icon
                    )
                }
                .tag(MainTab.saved)

            // 알림 탭
            NotificationsView()
                .tabItem {
                    Label(
                        MainTab.notifications.title,
                        systemImage: selectedTab == .notifications
                            ? MainTab.notifications.selectedIcon
                            : MainTab.notifications.icon
                    )
                }
                .tag(MainTab.notifications)

            // 프로필 탭
            ProfileView(appState: appState, container: container)
                .tabItem {
                    Label(
                        MainTab.profile.title,
                        systemImage: selectedTab == .profile
                            ? MainTab.profile.selectedIcon
                            : MainTab.profile.icon
                    )
                }
                .tag(MainTab.profile)
        }
        .tint(.primaryColor)
    }
}

// MARK: - Preview

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

    MainView(appState: appState, container: .shared)
}
