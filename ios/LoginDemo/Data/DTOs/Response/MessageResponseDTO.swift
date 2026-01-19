//
//  MessageResponseDTO.swift
//  LoginDemo
//
//  일반 메시지 응답 DTO
//

import Foundation

/// 일반 메시지 응답 DTO
struct MessageResponseDTO: Decodable {
    /// 응답 메시지
    let message: String
}
