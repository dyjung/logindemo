//
//  UserStatus.swift
//  LoginDemo
//
//  사용자 계정 상태 열거형
//

import Foundation

/// 사용자 계정 상태
enum UserStatus: String, Codable, Sendable {
    /// 활성 상태
    case active = "ACTIVE"

    /// 휴면 상태
    case sleep = "SLEEP"

    /// 정지 상태
    case suspended = "SUSPENDED"

    /// 삭제됨
    case deleted = "DELETED"
}
