package com.dyjung.logindemo.domain.usecase

import com.dyjung.logindemo.domain.repository.OnboardingRepository
import javax.inject.Inject

/**
 * 온보딩 상태 확인 Use Case
 */
class CheckOnboardingUseCase @Inject constructor(
    private val onboardingRepository: OnboardingRepository
) {
    operator fun invoke(): Boolean {
        return onboardingRepository.hasCompletedOnboarding()
    }
}
