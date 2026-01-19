//
//  AuthTokenMapper.swift
//  LoginDemo
//
//  AuthResponseDTO를 AuthToken 엔티티로 변환하는 매퍼
//

import Foundation

/// AuthResponseDTO ↔ AuthToken 매핑
struct AuthTokenMapper {
    /// AuthResponseDTO를 AuthToken 엔티티로 변환
    /// - Parameter dto: AuthResponseDTO
    /// - Returns: AuthToken 엔티티
    static func toEntity(_ dto: AuthResponseDTO) -> AuthToken {
        AuthToken(
            accessToken: dto.accessToken,
            refreshToken: dto.refreshToken,
            expiresIn: TimeInterval(dto.expiresIn)
        )
    }

    /// TokenRefreshResponseDTO를 AuthToken 엔티티로 변환
    /// - Parameters:
    ///   - dto: TokenRefreshResponseDTO
    ///   - existingRefreshToken: 기존 리프레시 토큰 (새 토큰이 없는 경우 사용)
    /// - Returns: AuthToken 엔티티
    static func toEntity(_ dto: TokenRefreshResponseDTO, existingRefreshToken: String) -> AuthToken {
        AuthToken(
            accessToken: dto.accessToken,
            refreshToken: dto.refreshToken ?? existingRefreshToken,
            expiresIn: 0 // TokenRefreshResponse에는 expiresIn이 없음
        )
    }
}
