//
//  PasswordConfirmResponseDTO.swift
//  LoginDemo
//

import Foundation

/// 비밀번호 변경 확정 응답 DTO
struct PasswordConfirmResponseDTO: Decodable {
    /// 성공 여부
    let success: Bool
    
    /// 메시지
    let message: String
}
