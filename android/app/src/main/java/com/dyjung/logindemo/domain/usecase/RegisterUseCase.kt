package com.dyjung.logindemo.domain.usecase

import com.dyjung.logindemo.domain.model.User
import com.dyjung.logindemo.domain.repository.AuthRepository
import javax.inject.Inject

/**
 * 회원가입 Use Case
 */
class RegisterUseCase @Inject constructor(
    private val authRepository: AuthRepository
) {
    suspend operator fun invoke(
        email: String,
        password: String,
        name: String,
        agreedToTerms: Boolean,
        agreedToPrivacy: Boolean
    ): User {
        return authRepository.register(email, password, name, agreedToTerms, agreedToPrivacy)
    }
}
