//
//  ErrorResponseDTO.swift
//  LoginDemo
//
//  API 에러 응답 DTO
//

import Foundation

/// API 에러 응답 DTO
struct ErrorResponseDTO: Decodable {
    /// HTTP 상태 코드
    let statusCode: Int

    /// 에러 코드
    let errorCode: String

    /// 에러 메시지
    let message: String

    /// 상세 정보 (선택)
    let details: [String: String]?
}
