//
//  OnboardingViewModel.swift
//  LoginDemo
//
//  온보딩 화면 ViewModel
//

import Foundation
import Observation

/// 온보딩 화면 ViewModel
@Observable
@MainActor
final class OnboardingViewModel {
    // MARK: - Properties

    /// 현재 페이지 인덱스
    var currentPage: Int = 0

    /// 온보딩 페이지 목록
    private(set) var pages: [OnboardingPage] = []

    /// 마지막 페이지 여부
    var isLastPage: Bool {
        currentPage == pages.count - 1
    }

    private let onboardingRepository: OnboardingRepositoryProtocol

    // MARK: - Initialization

    init(onboardingRepository: OnboardingRepositoryProtocol) {
        self.onboardingRepository = onboardingRepository
        self.pages = onboardingRepository.getOnboardingPages()
    }

    // MARK: - Methods

    /// 다음 페이지로 이동
    func nextPage() {
        guard currentPage < pages.count - 1 else { return }
        currentPage += 1
    }

    /// 이전 페이지로 이동
    func previousPage() {
        guard currentPage > 0 else { return }
        currentPage -= 1
    }

    /// 온보딩 완료 처리
    /// - Parameter appState: 앱 상태
    func completeOnboarding(appState: AppState) {
        onboardingRepository.markOnboardingCompleted()
        onboardingRepository.markFirstLaunchCompleted()
        appState.handleOnboardingComplete()
    }

    /// 온보딩 건너뛰기
    /// - Parameter appState: 앱 상태
    func skipOnboarding(appState: AppState) {
        completeOnboarding(appState: appState)
    }
}
