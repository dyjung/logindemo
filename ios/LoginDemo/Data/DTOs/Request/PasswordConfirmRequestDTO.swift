//
//  PasswordConfirmRequestDTO.swift
//  LoginDemo
//

import Foundation

/// 비밀번호 변경 확정 요청 DTO
struct PasswordConfirmRequestDTO: Encodable {
    /// 재설정 토큰
    let token: String
    
    /// 새 비밀번호
    let newPassword: String
}
