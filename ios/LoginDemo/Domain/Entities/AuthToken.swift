//
//  AuthToken.swift
//  LoginDemo
//
//  인증 토큰 정보를 나타내는 도메인 엔티티
//

import Foundation

/// 인증 토큰 정보를 나타내는 엔티티
struct AuthToken: Equatable, Sendable {
    /// API 인증용 Access Token
    let accessToken: String

    /// 토큰 갱신용 Refresh Token
    let refreshToken: String

    /// Access Token 만료 시간 (초)
    let expiresIn: TimeInterval
}
