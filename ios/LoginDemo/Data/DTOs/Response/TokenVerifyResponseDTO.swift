//
//  TokenVerifyResponseDTO.swift
//  LoginDemo
//

import Foundation

/// 토큰 검증 응답 DTO
struct TokenVerifyResponseDTO: Decodable {
    /// 유효 여부
    let valid: Bool
    
    /// 사용자 정보 (유효 시)
    let user: UserDTO?
}
