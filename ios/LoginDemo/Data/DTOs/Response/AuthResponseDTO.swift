//
//  AuthResponseDTO.swift
//  LoginDemo
//
//  인증 응답 DTO (로그인, 회원가입)
//

import Foundation

/// 인증 응답 DTO (로그인, 회원가입)
struct AuthResponseDTO: Codable {
    /// Access Token (JWT)
    let accessToken: String

    /// Refresh Token
    let refreshToken: String

    /// Access Token 만료 시간 (초)
    let expiresIn: Int

    /// 사용자 정보
    let user: UserDTO
}
