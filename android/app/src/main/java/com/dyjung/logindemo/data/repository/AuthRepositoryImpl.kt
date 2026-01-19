package com.dyjung.logindemo.data.repository

import com.dyjung.logindemo.data.datasource.local.SecureStorage
import com.dyjung.logindemo.data.datasource.local.UserPreferences
import com.dyjung.logindemo.domain.model.AuthProvider
import com.dyjung.logindemo.domain.model.User
import com.dyjung.logindemo.domain.repository.AuthRepository
import kotlinx.coroutines.delay
import java.util.Date
import java.util.UUID
import javax.inject.Inject
import javax.inject.Singleton

/**
 * AuthRepository 구현체
 * TODO: 실제 네트워크 서비스 연동
 */
@Singleton
class AuthRepositoryImpl @Inject constructor(
    private val secureStorage: SecureStorage,
    private val userPreferences: UserPreferences
) : AuthRepository {

    override suspend fun login(email: String, password: String, autoLogin: Boolean): User {
        // TODO: 실제 API 호출로 대체
        delay(1000) // 시뮬레이션

        val user = User(
            id = UUID.randomUUID().toString(),
            email = email,
            name = email.substringBefore("@"),
            provider = AuthProvider.EMAIL,
            createdAt = Date()
        )

        if (autoLogin) {
            userPreferences.setAutoLoginEnabled(true)
            secureStorage.saveAccessToken("mock_access_token")
            secureStorage.saveRefreshToken("mock_refresh_token")
        }

        return user
    }

    override suspend fun socialLogin(
        provider: AuthProvider,
        oauthToken: String,
        autoLogin: Boolean
    ): User {
        // TODO: 실제 API 호출로 대체
        delay(1000)

        val user = User(
            id = UUID.randomUUID().toString(),
            email = "${provider.value}@example.com",
            name = "${provider.displayName} 사용자",
            provider = provider,
            createdAt = Date()
        )

        if (autoLogin) {
            userPreferences.setAutoLoginEnabled(true)
            secureStorage.saveAccessToken("mock_access_token")
            secureStorage.saveRefreshToken("mock_refresh_token")
        }

        return user
    }

    override suspend fun register(
        email: String,
        password: String,
        name: String,
        agreedToTerms: Boolean,
        agreedToPrivacy: Boolean
    ): User {
        // TODO: 실제 API 호출로 대체
        delay(1500)

        return User(
            id = UUID.randomUUID().toString(),
            email = email,
            name = name,
            provider = AuthProvider.EMAIL,
            createdAt = Date()
        )
    }

    override suspend fun checkEmailAvailability(email: String): Boolean {
        // TODO: 실제 API 호출로 대체
        delay(500)
        return !email.contains("taken")
    }

    override suspend fun sendPasswordResetEmail(email: String) {
        // TODO: 실제 API 호출로 대체
        delay(1000)
    }

    override suspend fun refreshToken() {
        // TODO: 실제 API 호출로 대체
        delay(500)
    }

    override suspend fun autoLogin(): User? {
        if (!userPreferences.isAutoLoginEnabled()) return null

        val accessToken = secureStorage.getAccessToken() ?: return null

        // TODO: 실제 토큰 검증 API 호출
        delay(500)

        return User(
            id = "auto_login_user",
            email = "user@example.com",
            name = "자동 로그인 사용자",
            provider = null,
            createdAt = Date()
        )
    }

    override suspend fun logout() {
        secureStorage.clearAll()
        userPreferences.setAutoLoginEnabled(false)
    }

    override val isAutoLoginEnabled: Boolean
        get() = userPreferences.isAutoLoginEnabled()
}
