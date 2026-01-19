package com.dyjung.logindemo.domain.usecase

import com.dyjung.logindemo.domain.repository.AuthRepository
import javax.inject.Inject

/**
 * 이메일 중복 확인 Use Case
 */
class CheckEmailUseCase @Inject constructor(
    private val authRepository: AuthRepository
) {
    suspend operator fun invoke(email: String): Boolean {
        return authRepository.checkEmailAvailability(email)
    }
}
