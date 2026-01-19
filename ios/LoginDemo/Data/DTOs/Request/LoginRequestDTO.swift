//
//  LoginRequestDTO.swift
//  LoginDemo
//
//  로그인 요청 DTO
//

import Foundation

/// 통합 로그인 요청 DTO
struct LoginRequestDTO: Encodable {
    /// 인증 제공자 (EMAIL, KAKAO, NAVER, APPLE, GOOGLE)
    let provider: String

    /// 사용자 이메일 (EMAIL 로그인 시 필수)
    let email: String?

    /// 비밀번호 (EMAIL 로그인 시 필수)
    let password: String?

    /// 소셜 액세스 토큰 (소셜 로그인 시 필수)
    let socialAccessToken: String?

    /// 디바이스 정보
    let deviceInfo: DeviceInfoDTO?
}
