//
//  UserDTO.swift
//  LoginDemo
//
//  사용자 정보 응답 DTO
//

import Foundation

/// 사용자 정보 DTO
struct UserDTO: Codable {
    /// 사용자 고유 ID
    let id: String

    /// 이메일 주소 (소셜 계정만 있는 경우 없을 수 있음)
    let email: String?

    /// 닉네임
    let nickname: String

    /// 계정 상태 (ACTIVE, SLEEP, SUSPENDED, DELETED)
    let status: String

    /// 최초 가입일
    let createdAt: String

    /// 마지막 로그인 시간
    let lastLogin: String?

    /// 마지막 업데이트 시간
    let updatedAt: String?
}
