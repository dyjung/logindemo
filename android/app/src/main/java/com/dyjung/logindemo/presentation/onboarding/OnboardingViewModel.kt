package com.dyjung.logindemo.presentation.onboarding

import androidx.lifecycle.ViewModel
import com.dyjung.logindemo.domain.model.OnboardingPage
import com.dyjung.logindemo.domain.repository.OnboardingRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import javax.inject.Inject

/**
 * 온보딩 화면 ViewModel
 * iOS의 OnboardingViewModel에 대응
 */
@HiltViewModel
class OnboardingViewModel @Inject constructor(
    private val onboardingRepository: OnboardingRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(OnboardingUiState())
    val uiState: StateFlow<OnboardingUiState> = _uiState.asStateFlow()

    val pages: List<OnboardingPage> = OnboardingPage.defaultPages

    val isLastPage: Boolean
        get() = _uiState.value.currentPage == pages.size - 1

    fun setCurrentPage(page: Int) {
        _uiState.update { it.copy(currentPage = page) }
    }

    fun nextPage() {
        if (!isLastPage) {
            _uiState.update { it.copy(currentPage = it.currentPage + 1) }
        }
    }

    fun skipOnboarding(onComplete: () -> Unit) {
        completeOnboarding(onComplete)
    }

    fun completeOnboarding(onComplete: () -> Unit) {
        onboardingRepository.completeOnboarding()
        onComplete()
    }
}

data class OnboardingUiState(
    val currentPage: Int = 0
)
