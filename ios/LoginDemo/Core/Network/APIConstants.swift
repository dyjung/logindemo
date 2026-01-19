//
//  APIConstants.swift
//  LoginDemo
//
//  API 관련 상수 정의
//

import Foundation

/// API 관련 상수
enum APIConstants {
    /// 기본 API URL
    #if DEBUG
    static let baseURL = "http://72.62.245.151:3000/v1"
    #else
    static let baseURL = "http://72.62.245.151:3000/v1"
    #endif

    /// 요청 타임아웃 (초)
    static let requestTimeout: TimeInterval = 30

    /// 리소스 타임아웃 (초)
    static let resourceTimeout: TimeInterval = 60
}

/// API 엔드포인트 경로
enum APIPath {
    /// 로그인 (EMAIL, SOCIAL 통합)
    static let login = "/auth/login"

    /// 통합 회원가입
    static let register = "/auth/register"

    /// 토큰 갱신
    static let refresh = "/auth/refresh"

    /// 로그아웃
    static let logout = "/auth/logout"

    /// 이메일(아이디) 찾기
    static let findId = "/auth/find-id"

    /// 비밀번호 재설정 요청
    static let passwordReset = "/auth/password-reset"

    /// 비밀번호 변경 확정
    static let passwordConfirm = "/auth/password-confirm"

    /// 토큰 검증
    static let verifyToken = "/auth/verify"

    /// 앱 초기화 및 부트스트랩
    static let initApp = "/init"
}
