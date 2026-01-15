package com.dyjung.logindemo.presentation.splash

import androidx.lifecycle.ViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

/**
 * ViewModel for Splash screen.
 * Handles auto-login and onboarding state check.
 */
@HiltViewModel
class SplashViewModel @Inject constructor(
    // TODO: Inject AutoLoginUseCase, CheckOnboardingUseCase
) : ViewModel() {
    // TODO: Implement auto-login logic
}
