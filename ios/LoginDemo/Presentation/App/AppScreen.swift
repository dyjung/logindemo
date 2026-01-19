//
//  AppScreen.swift
//  LoginDemo
//
//  앱 화면 상태 열거형
//

import Foundation

/// 앱의 현재 화면 상태
enum AppScreen: Equatable {
    /// 스플래시 화면 (앱 초기화 중)
    case splash

    /// 온보딩 화면 (최초 실행 시)
    case onboarding

    /// 로그인 화면
    case login

    /// 메인 화면 (로그인 완료 후)
    case main
}
