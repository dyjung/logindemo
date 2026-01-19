//
//  EmailCheckResponseDTO.swift
//  LoginDemo
//
//  이메일 중복 확인 응답 DTO
//

import Foundation

/// 이메일 중복 확인 응답 DTO
struct EmailCheckResponseDTO: Decodable {
    /// 이메일 사용 가능 여부
    let available: Bool
}
