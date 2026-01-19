//
//  UserDefaultsDataSourceProtocol.swift
//  LoginDemo
//
//  UserDefaults 데이터 소스 프로토콜
//

import Foundation

/// UserDefaults 데이터 접근을 위한 프로토콜
protocol UserDefaultsDataSourceProtocol: Sendable {
    /// 최초 실행 여부
    var isFirstLaunch: Bool { get set }

    /// 온보딩 완료 여부
    var hasCompletedOnboarding: Bool { get set }

    /// 자동 로그인 활성화 여부
    var autoLoginEnabled: Bool { get set }

    /// 마지막 로그인 이메일
    var lastLoginEmail: String? { get set }

    /// 모든 설정 초기화
    func clearAll()
}
