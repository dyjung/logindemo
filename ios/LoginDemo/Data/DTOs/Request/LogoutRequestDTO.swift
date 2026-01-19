//
//  LogoutRequestDTO.swift
//  LoginDemo
//

import Foundation

/// 로그아웃 요청 DTO
struct LogoutRequestDTO: Encodable {
    /// 리프레시 토큰 (무효화용)
    let refreshToken: String?
    
    /// 모든 디바이스에서 로그아웃 여부
    let allDevices: Bool?
}
