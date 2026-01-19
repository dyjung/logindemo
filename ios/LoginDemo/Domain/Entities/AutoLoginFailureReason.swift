//
//  AutoLoginFailureReason.swift
//  LoginDemo
//
//  자동 로그인 실패 사유 열거형
//

import Foundation

/// 자동 로그인 실패 사유
enum AutoLoginFailureReason: String, Codable, Sendable {
    /// 토큰 없음
    case noToken = "NO_TOKEN"

    /// 토큰 만료
    case tokenExpired = "TOKEN_EXPIRED"

    /// 토큰 무효
    case tokenInvalid = "TOKEN_INVALID"

    /// 계정 휴면 상태
    case accountSleep = "ACCOUNT_SLEEP"

    /// 계정 정지 상태
    case accountSuspended = "ACCOUNT_SUSPENDED"

    /// 계정 삭제됨
    case accountDeleted = "ACCOUNT_DELETED"
}
