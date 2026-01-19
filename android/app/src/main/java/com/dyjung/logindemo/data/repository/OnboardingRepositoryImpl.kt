package com.dyjung.logindemo.data.repository

import com.dyjung.logindemo.data.datasource.local.UserPreferences
import com.dyjung.logindemo.domain.repository.OnboardingRepository
import javax.inject.Inject
import javax.inject.Singleton

/**
 * OnboardingRepository 구현체
 */
@Singleton
class OnboardingRepositoryImpl @Inject constructor(
    private val userPreferences: UserPreferences
) : OnboardingRepository {

    override fun hasCompletedOnboarding(): Boolean {
        return userPreferences.hasCompletedOnboarding()
    }

    override fun completeOnboarding() {
        userPreferences.setOnboardingCompleted(true)
        userPreferences.setFirstLaunch(false)
    }

    override fun isFirstLaunch(): Boolean {
        return userPreferences.isFirstLaunch()
    }

    override fun markFirstLaunchComplete() {
        userPreferences.setFirstLaunch(false)
    }
}
