//
//  User.swift
//  LoginDemo
//
//  사용자 정보를 나타내는 도메인 엔티티
//

import Foundation

/// 사용자 정보를 나타내는 핵심 엔티티
struct User: Equatable, Sendable {
    /// 사용자 고유 식별자
    let id: String

    /// 이메일 주소 (nil = 소셜 계정만 있는 경우)
    let email: String?

    /// 닉네임
    let nickname: String

    /// 계정 상태
    let status: UserStatus

    /// 인증 제공자 (nil = 이메일 가입)
    let provider: AuthProvider?

    /// 계정 생성 일시
    let createdAt: Date

    /// 마지막 로그인 시간
    let lastLogin: Date?

    /// 마지막 업데이트 시간
    let updatedAt: Date?
}
