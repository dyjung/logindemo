package com.dyjung.logindemo.domain.model

import java.util.Date

/**
 * 사용자 정보를 나타내는 도메인 엔티티
 */
data class User(
    /** 사용자 고유 식별자 */
    val id: String,
    /** 이메일 주소 */
    val email: String,
    /** 사용자 이름 */
    val name: String,
    /** 인증 제공자 (null = 이메일 가입) */
    val provider: AuthProvider?,
    /** 계정 생성 일시 */
    val createdAt: Date
)
