//
//  UserRepositoryProtocol.swift
//  LoginDemo
//
//  사용자 관련 리포지토리 프로토콜
//

import Foundation

/// 사용자 정보 관련 데이터 접근을 위한 리포지토리 프로토콜
protocol UserRepositoryProtocol: Sendable {
    /// 현재 로그인한 사용자 정보 조회
    /// - Returns: 사용자 정보
    func getCurrentUser() async throws -> User

    /// 로컬에 저장된 사용자 정보 조회
    /// - Returns: 저장된 사용자 정보 (없으면 nil)
    func getStoredUser() -> User?

    /// 사용자 정보 저장
    /// - Parameter user: 저장할 사용자 정보
    func storeUser(_ user: User)

    /// 저장된 사용자 정보 삭제
    func clearStoredUser()
}
