package com.dyjung.logindemo.domain.usecase

import com.dyjung.logindemo.domain.repository.AuthRepository
import javax.inject.Inject

/**
 * 비밀번호 재설정 Use Case
 */
class ForgotPasswordUseCase @Inject constructor(
    private val authRepository: AuthRepository
) {
    suspend operator fun invoke(email: String) {
        authRepository.sendPasswordResetEmail(email)
    }
}
