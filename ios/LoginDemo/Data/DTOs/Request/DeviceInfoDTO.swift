//
//  DeviceInfoDTO.swift
//  LoginDemo
//
//  디바이스 정보 DTO
//

import Foundation

/// 디바이스 정보 DTO
struct DeviceInfoDTO: Encodable {
    /// 디바이스 ID
    let deviceId: String
    
    /// 플랫폼 (iOS, Android, Web)
    let platform: String
    
    /// 앱 버전
    let appVersion: String
}
