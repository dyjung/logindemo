package com.dyjung.logindemo.domain.repository

import com.dyjung.logindemo.domain.model.AuthProvider
import com.dyjung.logindemo.domain.model.User

/**
 * 인증 관련 Repository 인터페이스
 */
interface AuthRepository {
    /**
     * 이메일/비밀번호 로그인
     * @param email 이메일
     * @param password 비밀번호
     * @param autoLogin 자동 로그인 활성화 여부
     * @return 로그인된 사용자 정보
     */
    suspend fun login(email: String, password: String, autoLogin: Boolean): User

    /**
     * 소셜 로그인
     * @param provider 소셜 로그인 제공자
     * @param oauthToken OAuth 토큰
     * @param autoLogin 자동 로그인 활성화 여부
     * @return 로그인된 사용자 정보
     */
    suspend fun socialLogin(provider: AuthProvider, oauthToken: String, autoLogin: Boolean): User

    /**
     * 회원가입
     * @param email 이메일
     * @param password 비밀번호
     * @param name 이름
     * @param agreedToTerms 이용약관 동의 여부
     * @param agreedToPrivacy 개인정보처리방침 동의 여부
     * @return 가입된 사용자 정보
     */
    suspend fun register(
        email: String,
        password: String,
        name: String,
        agreedToTerms: Boolean,
        agreedToPrivacy: Boolean
    ): User

    /**
     * 이메일 중복 확인
     * @param email 확인할 이메일
     * @return 사용 가능 여부
     */
    suspend fun checkEmailAvailability(email: String): Boolean

    /**
     * 비밀번호 재설정 이메일 발송
     * @param email 이메일
     */
    suspend fun sendPasswordResetEmail(email: String)

    /**
     * 토큰 갱신
     */
    suspend fun refreshToken()

    /**
     * 자동 로그인 시도
     * @return 저장된 사용자 정보 (없으면 null)
     */
    suspend fun autoLogin(): User?

    /**
     * 로그아웃
     */
    suspend fun logout()

    /**
     * 자동 로그인 활성화 여부
     */
    val isAutoLoginEnabled: Boolean
}
