package com.dyjung.logindemo.presentation.splash

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.dyjung.logindemo.domain.usecase.AutoLoginUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

/**
 * 스플래시 화면 ViewModel
 * iOS의 SplashViewModel에 대응
 */
@HiltViewModel
class SplashViewModel @Inject constructor(
    private val autoLoginUseCase: AutoLoginUseCase
) : ViewModel() {

    private val _navigationEvent = MutableStateFlow<SplashNavigationEvent?>(null)
    val navigationEvent: StateFlow<SplashNavigationEvent?> = _navigationEvent.asStateFlow()

    init {
        checkInitialState()
    }

    private fun checkInitialState() {
        viewModelScope.launch {
            // 최소 스플래시 표시 시간
            delay(1500)

            val result = autoLoginUseCase()

            _navigationEvent.value = when (result) {
                is AutoLoginUseCase.Result.Success -> SplashNavigationEvent.NavigateToMain
                is AutoLoginUseCase.Result.NeedsOnboarding -> SplashNavigationEvent.NavigateToOnboarding
                is AutoLoginUseCase.Result.NeedsLogin -> SplashNavigationEvent.NavigateToLogin
            }
        }
    }

    fun onNavigationHandled() {
        _navigationEvent.value = null
    }
}

sealed class SplashNavigationEvent {
    data object NavigateToOnboarding : SplashNavigationEvent()
    data object NavigateToLogin : SplashNavigationEvent()
    data object NavigateToMain : SplashNavigationEvent()
}
