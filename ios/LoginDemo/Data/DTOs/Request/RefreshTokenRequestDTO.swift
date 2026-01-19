//
//  RefreshTokenRequestDTO.swift
//  LoginDemo
//
//  토큰 갱신 요청 DTO
//

import Foundation

/// 토큰 갱신 요청 DTO
struct RefreshTokenRequestDTO: Encodable {
    /// Refresh Token
    let refreshToken: String
}
