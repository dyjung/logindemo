//
//  Platform.swift
//  LoginDemo
//
//  앱 실행 플랫폼 열거형
//

import Foundation

/// 앱 실행 플랫폼 타입
enum Platform: String, Codable, Sendable {
    case iOS = "iOS"
    case android = "Android"
    case web = "Web"
}
