//
//  PasswordResetResponseDTO.swift
//  LoginDemo
//

import Foundation

/// 비밀번호 재설정 응답 DTO
struct PasswordResetResponseDTO: Decodable {
    /// 재설정 메일 발송 여부
    let sent: Bool
    
    /// 메시지
    let message: String
    
    /// 재요청 가능 시간 (초)
    let retryAfter: Int?
}
