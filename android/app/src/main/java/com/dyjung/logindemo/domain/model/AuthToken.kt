package com.dyjung.logindemo.domain.model

/**
 * 인증 토큰 정보를 나타내는 엔티티
 */
data class AuthToken(
    /** API 인증용 Access Token */
    val accessToken: String,
    /** 토큰 갱신용 Refresh Token */
    val refreshToken: String,
    /** Access Token 만료 시간 (초) */
    val expiresIn: Long,
    /** 토큰 타입 (예: "Bearer") */
    val tokenType: String
)
