//
//  KeychainDataSourceProtocol.swift
//  LoginDemo
//
//  Keychain 데이터 소스 프로토콜
//

import Foundation

/// Keychain 데이터 접근을 위한 프로토콜
protocol KeychainDataSourceProtocol: Sendable {
    /// Access Token 저장
    /// - Parameter token: Access Token
    func saveAccessToken(_ token: String)

    /// Access Token 조회
    /// - Returns: 저장된 Access Token (없으면 nil)
    func getAccessToken() -> String?

    /// Refresh Token 저장
    /// - Parameter token: Refresh Token
    func saveRefreshToken(_ token: String)

    /// Refresh Token 조회
    /// - Returns: 저장된 Refresh Token (없으면 nil)
    func getRefreshToken() -> String?

    /// 사용자 ID 저장
    /// - Parameter userId: 사용자 ID
    func saveUserId(_ userId: String)

    /// 사용자 ID 조회
    /// - Returns: 저장된 사용자 ID (없으면 nil)
    func getUserId() -> String?

    /// 모든 인증 정보 삭제
    func clearAll()

    /// 유효한 토큰 존재 여부
    var hasValidToken: Bool { get }

    /// 디바이스 ID 조회
    /// - Returns: 디바이스 ID (없으면 생성하여 저장 후 반환)
    func getDeviceId() -> String?
}
