//
//  TokenRefresherProtocol.swift
//  LoginDemo
//
//  토큰 갱신을 위한 프로토콜
//

import Foundation

/// 토큰 갱신을 위한 프로토콜
protocol TokenRefresherProtocol: AnyObject, Sendable {
    /// 토큰 갱신 실행
    func refreshToken() async throws
}
