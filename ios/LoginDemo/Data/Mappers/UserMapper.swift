//
//  UserMapper.swift
//  LoginDemo
//
//  UserDTO를 User 엔티티로 변환하는 매퍼
//

import Foundation

/// UserDTO ↔ User 매핑
struct UserMapper {
    /// ISO8601 날짜 포맷터
    private static let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    /// 초 단위 없는 ISO8601 날짜 포맷터 (fallback)
    private static let dateFormatterWithoutFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    /// UserDTO를 User 엔티티로 변환
    /// - Parameter dto: UserDTO
    /// - Returns: User 엔티티
    static func toEntity(_ dto: UserDTO) -> User {
        let createdAt = parseDate(dto.createdAt)
        let lastLogin = dto.lastLogin.flatMap { parseDate($0) }
        let updatedAt = dto.updatedAt.flatMap { parseDate($0) }
        let status = UserStatus(rawValue: dto.status) ?? .active

        return User(
            id: dto.id,
            email: dto.email,
            nickname: dto.nickname,
            status: status,
            provider: nil,
            createdAt: createdAt,
            lastLogin: lastLogin,
            updatedAt: updatedAt
        )
    }

    /// ISO8601 문자열을 Date로 변환
    private static func parseDate(_ dateString: String) -> Date {
        return dateFormatter.date(from: dateString)
            ?? dateFormatterWithoutFractionalSeconds.date(from: dateString)
            ?? Date()
    }
}
