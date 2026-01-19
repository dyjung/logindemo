package com.dyjung.logindemo.domain.model

/**
 * 인증 제공자 타입
 */
enum class AuthProvider(val value: String) {
    /** 이메일 로그인 */
    EMAIL("email"),
    /** 카카오 로그인 */
    KAKAO("kakao"),
    /** 네이버 로그인 */
    NAVER("naver"),
    /** Apple 로그인 */
    APPLE("apple");

    /** 표시용 이름 */
    val displayName: String
        get() = when (this) {
            EMAIL -> "이메일"
            KAKAO -> "카카오"
            NAVER -> "네이버"
            APPLE -> "Apple"
        }

    companion object {
        fun fromValue(value: String): AuthProvider? =
            entries.find { it.value == value }
    }
}
