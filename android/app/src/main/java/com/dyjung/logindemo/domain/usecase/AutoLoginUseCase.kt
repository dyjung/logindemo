package com.dyjung.logindemo.domain.usecase

import com.dyjung.logindemo.domain.model.User
import com.dyjung.logindemo.domain.repository.AuthRepository
import com.dyjung.logindemo.domain.repository.OnboardingRepository
import javax.inject.Inject

/**
 * 자동 로그인 Use Case
 */
class AutoLoginUseCase @Inject constructor(
    private val authRepository: AuthRepository,
    private val onboardingRepository: OnboardingRepository
) {
    /**
     * 자동 로그인 결과
     */
    sealed class Result {
        /** 자동 로그인 성공 */
        data class Success(val user: User) : Result()
        /** 온보딩 필요 */
        data object NeedsOnboarding : Result()
        /** 로그인 필요 */
        data object NeedsLogin : Result()
    }

    suspend operator fun invoke(): Result {
        // 첫 실행 또는 온보딩 미완료 시
        if (onboardingRepository.isFirstLaunch() || !onboardingRepository.hasCompletedOnboarding()) {
            return Result.NeedsOnboarding
        }

        // 자동 로그인 시도
        val user = authRepository.autoLogin()
        return if (user != null) {
            Result.Success(user)
        } else {
            Result.NeedsLogin
        }
    }
}
