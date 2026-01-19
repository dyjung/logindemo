//
//  AuthProvider.swift
//  LoginDemo
//
//  인증 제공자 열거형
//

import Foundation

/// 인증 제공자 타입
enum AuthProvider: String, Codable, Sendable, CaseIterable {
    /// 이메일 로그인
    case email = "EMAIL"

    /// 카카오 로그인
    case kakao = "KAKAO"

    /// 네이버 로그인
    case naver = "NAVER"

    /// Apple 로그인
    case apple = "APPLE"
    
    /// Google 로그인
    case google = "GOOGLE"

    /// 표시용 이름
    var displayName: String {
        switch self {
        case .email:
            return "이메일"
        case .kakao:
            return "카카오"
        case .naver:
            return "네이버"
        case .apple:
            return "Apple"
        case .google:
            return "Google"
        }
    }
}
