//
//  FindIdResponseDTO.swift
//  LoginDemo
//

import Foundation

/// 이메일 찾기 응답 DTO
struct FindIdResponseDTO: Decodable {
    /// 마스킹된 이메일 
    let maskedEmail: String
    
    /// 최초 가입일
    let createdAt: String
    
    /// 연결된 인증 방법 목록
    let linkedMethods: [String]
}
