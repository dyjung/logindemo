//
//  LoginDemoApp.swift
//  LoginDemo
//
//  앱 진입점
//

import SwiftUI

@main
struct LoginDemoApp: App {
    // MARK: - Properties

    @State private var appState = AppState()
    private let container = DIContainer.shared

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            RootView(appState: appState, container: container)
        }
    }
}
