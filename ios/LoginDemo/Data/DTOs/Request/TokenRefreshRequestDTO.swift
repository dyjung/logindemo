//
//  TokenRefreshRequestDTO.swift
//  LoginDemo
//

import Foundation

/// 토큰 갱신 요청 DTO
struct TokenRefreshRequestDTO: Encodable {
    /// 리프레시 토큰
    let refreshToken: String
    
    /// 디바이스 정보 (선택)
    let deviceInfo: DeviceInfoDTO?
}
