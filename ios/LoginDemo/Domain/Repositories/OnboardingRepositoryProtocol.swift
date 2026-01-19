//
//  OnboardingRepositoryProtocol.swift
//  LoginDemo
//
//  온보딩 관련 리포지토리 프로토콜
//

import Foundation

/// 온보딩 관련 데이터 접근을 위한 리포지토리 프로토콜
protocol OnboardingRepositoryProtocol: Sendable {
    /// 온보딩 완료 여부
    var hasCompletedOnboarding: Bool { get }

    /// 최초 실행 여부
    var isFirstLaunch: Bool { get }

    /// 온보딩 완료 상태 저장
    func markOnboardingCompleted()

    /// 최초 실행 상태 업데이트
    func markFirstLaunchCompleted()

    /// 온보딩 페이지 목록 조회
    func getOnboardingPages() -> [OnboardingPage]
}
