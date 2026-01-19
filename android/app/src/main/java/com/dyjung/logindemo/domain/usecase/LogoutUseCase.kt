package com.dyjung.logindemo.domain.usecase

import com.dyjung.logindemo.domain.repository.AuthRepository
import javax.inject.Inject

/**
 * 로그아웃 Use Case
 */
class LogoutUseCase @Inject constructor(
    private val authRepository: AuthRepository
) {
    suspend operator fun invoke() {
        authRepository.logout()
    }
}
