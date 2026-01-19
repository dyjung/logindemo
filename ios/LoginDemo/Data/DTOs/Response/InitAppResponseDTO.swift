//
//  InitAppResponseDTO.swift
//  LoginDemo
//
//  앱 초기화 응답 DTO (TypeSpec 기준)
//

import Foundation

/// 앱 초기화 응답 DTO
struct InitAppResponseDTO: Codable, Sendable {
    /// 앱 설정 정보
    let config: AppConfigDTO

    /// 강제 업데이트 필요 여부
    let forceUpdate: Bool

    /// 서비스 점검 중 여부
    let isMaintenance: Bool

    /// 사용자 컨텍스트 (접속 국가/통화/언어 정보)
    let userContext: UserContextDTO

    /// 자동 로그인 결과 (X-Refresh-Token 헤더가 제공된 경우에만 포함)
    let autoLogin: AutoLoginResultDTO?
}

/// 앱 설정 DTO
struct AppConfigDTO: Codable, Sendable {
    /// 최소 지원 버전
    let minVersion: String

    /// 점검 모드 여부
    let maintenanceMode: Bool

    /// 공지 메시지
    let noticeMessage: String?
}

/// 사용자 컨텍스트 DTO
struct UserContextDTO: Codable, Sendable {
    /// 접속 국가 코드 (ISO 3166-1 alpha-2)
    let country: String

    /// 통화 코드 (ISO 4217)
    let currency: String

    /// 언어 코드 (ISO 639-1)
    let language: String

    /// 최근 위치 정보
    let location: GeoLocationDTO?
}

/// 위치 정보 DTO
struct GeoLocationDTO: Codable, Sendable {
    /// 위도
    let latitude: Double

    /// 경도
    let longitude: Double
}

/// 자동 로그인 결과 DTO
struct AutoLoginResultDTO: Codable, Sendable {
    /// 자동 로그인 성공 여부
    let success: Bool

    /// 사용자 정보 (success=true일 때만 포함)
    let user: UserDTO?

    /// 새로 발급된 액세스 토큰 (success=true일 때만 포함)
    let accessToken: String?

    /// 리프레시 토큰 (success=true일 때만 포함, 토큰 Rotation 적용시 새 토큰)
    let refreshToken: String?

    /// 실패 사유 코드 (success=false일 때만 포함)
    let failureReason: String?
}
