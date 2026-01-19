//
//  SocialLoginRequestDTO.swift
//  LoginDemo
//
//  소셜 로그인 요청 DTO
//

import Foundation

/// 소셜 로그인 요청 DTO
struct SocialLoginRequestDTO: Encodable {
    /// 소셜 로그인 제공자로부터 받은 OAuth 토큰
    let oauthToken: String

    /// 자동 로그인 활성화 여부
    let autoLogin: Bool
}
