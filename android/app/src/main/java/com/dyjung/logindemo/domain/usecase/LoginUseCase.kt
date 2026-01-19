package com.dyjung.logindemo.domain.usecase

import com.dyjung.logindemo.domain.model.User
import com.dyjung.logindemo.domain.repository.AuthRepository
import javax.inject.Inject

/**
 * 로그인 Use Case
 */
class LoginUseCase @Inject constructor(
    private val authRepository: AuthRepository
) {
    suspend operator fun invoke(
        email: String,
        password: String,
        autoLogin: Boolean
    ): User {
        return authRepository.login(email, password, autoLogin)
    }
}
