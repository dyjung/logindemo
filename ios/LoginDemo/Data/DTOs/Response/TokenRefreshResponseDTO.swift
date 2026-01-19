//
//  TokenRefreshResponseDTO.swift
//  LoginDemo
//
//  토큰 갱신 응답 DTO
//

import Foundation

/// 토큰 갱신 응답 DTO
struct TokenRefreshResponseDTO: Codable, Sendable {
    /// 새 액세스 토큰
    let accessToken: String

    /// 새 리프레시 토큰 (토큰 Rotation 적용시 새 토큰 발급, 미적용시 null)
    let refreshToken: String?
}
