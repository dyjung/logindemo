//
//  LogoutResponseDTO.swift
//  LoginDemo
//
//  로그아웃 응답 DTO
//

import Foundation

/// 로그아웃 응답 DTO
struct LogoutResponseDTO: Codable, Sendable {
    /// 성공 여부
    let success: Bool

    /// 메시지
    let message: String
}
