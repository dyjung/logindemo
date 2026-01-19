package com.dyjung.logindemo.domain.usecase

import com.dyjung.logindemo.domain.model.AuthProvider
import com.dyjung.logindemo.domain.model.User
import com.dyjung.logindemo.domain.repository.AuthRepository
import javax.inject.Inject

/**
 * 소셜 로그인 Use Case
 */
class SocialLoginUseCase @Inject constructor(
    private val authRepository: AuthRepository
) {
    suspend operator fun invoke(
        provider: AuthProvider,
        oauthToken: String,
        autoLogin: Boolean
    ): User {
        return authRepository.socialLogin(provider, oauthToken, autoLogin)
    }
}
