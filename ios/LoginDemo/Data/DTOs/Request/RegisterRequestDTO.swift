//
//  RegisterRequestDTO.swift
//  LoginDemo
//
//  회원가입 요청 DTO
//

import Foundation

/// 통합 회원가입 요청 DTO
struct RegisterRequestDTO: Encodable {
    /// 인증 제공자 (EMAIL, KAKAO, NAVER, APPLE, GOOGLE)
    let provider: String

    /// 사용자 이메일 (EMAIL 가입 시 필수, 소셜은 선택)
    let email: String?

    /// 비밀번호 (EMAIL 가입 시 필수)
    let password: String?

    /// 닉네임
    let nickname: String

    /// 소셜 액세스 토큰 (소셜 가입 시 필수)
    let socialAccessToken: String?

    /// 마케팅 수신 동의
    let marketingConsent: Bool?

    /// 디바이스 정보
    let deviceInfo: DeviceInfoDTO?
}
