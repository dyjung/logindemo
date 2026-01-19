package com.dyjung.logindemo.presentation.auth

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.dyjung.logindemo.core.validation.EmailValidator
import com.dyjung.logindemo.core.validation.PasswordValidator
import com.dyjung.logindemo.domain.model.AuthProvider
import com.dyjung.logindemo.domain.usecase.LoginUseCase
import com.dyjung.logindemo.domain.usecase.SocialLoginUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

/**
 * 로그인 화면 ViewModel
 * iOS의 LoginViewModel에 대응
 */
@HiltViewModel
class LoginViewModel @Inject constructor(
    private val loginUseCase: LoginUseCase,
    private val socialLoginUseCase: SocialLoginUseCase
) : ViewModel() {

    private val _uiState = MutableStateFlow(LoginUiState())
    val uiState: StateFlow<LoginUiState> = _uiState.asStateFlow()

    // Task 추적 (취소 가능) - iOS와 동일한 패턴
    private var loginJob: Job? = null
    private var socialLoginJob: Job? = null

    fun onEmailChange(email: String) {
        val validation = EmailValidator.validate(email)
        _uiState.update { state ->
            state.copy(
                email = email,
                emailError = validation.errorMessage
            )
        }
    }

    fun onPasswordChange(password: String) {
        val validation = PasswordValidator.validate(password)
        _uiState.update { state ->
            state.copy(
                password = password,
                passwordError = validation.errorMessage
            )
        }
    }

    fun onAutoLoginChange(enabled: Boolean) {
        _uiState.update { it.copy(autoLoginEnabled = enabled) }
    }

    fun login(onSuccess: () -> Unit) {
        if (!_uiState.value.isLoginEnabled) return

        // 이전 Job 취소
        loginJob?.cancel()

        loginJob = viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }

            try {
                loginUseCase(
                    email = _uiState.value.email,
                    password = _uiState.value.password,
                    autoLogin = _uiState.value.autoLoginEnabled
                )
                onSuccess()
            } catch (e: Exception) {
                _uiState.update { it.copy(error = e.message ?: "로그인에 실패했습니다") }
            } finally {
                _uiState.update { it.copy(isLoading = false) }
            }
        }
    }

    fun socialLogin(provider: AuthProvider, onSuccess: () -> Unit) {
        // 이전 Job 취소
        socialLoginJob?.cancel()

        socialLoginJob = viewModelScope.launch {
            _uiState.update {
                it.copy(
                    isLoading = true,
                    socialLoginInProgress = provider,
                    error = null
                )
            }

            try {
                // TODO: 실제 OAuth 토큰 획득 로직 추가
                val mockOAuthToken = "mock_oauth_token_${provider.value}"

                socialLoginUseCase(
                    provider = provider,
                    oauthToken = mockOAuthToken,
                    autoLogin = _uiState.value.autoLoginEnabled
                )
                onSuccess()
            } catch (e: Exception) {
                _uiState.update { it.copy(error = e.message ?: "소셜 로그인에 실패했습니다") }
            } finally {
                _uiState.update {
                    it.copy(isLoading = false, socialLoginInProgress = null)
                }
            }
        }
    }

    fun clearError() {
        _uiState.update { it.copy(error = null) }
    }

    /**
     * 리소스 정리 (iOS의 cleanup()에 대응)
     * Note: viewModelScope는 자동으로 취소되므로 Android에서는 보통 불필요
     */
    override fun onCleared() {
        super.onCleared()
        loginJob?.cancel()
        socialLoginJob?.cancel()
    }
}

/**
 * 로그인 화면 UI 상태
 */
data class LoginUiState(
    val email: String = "",
    val password: String = "",
    val autoLoginEnabled: Boolean = false,
    val emailError: String? = null,
    val passwordError: String? = null,
    val isLoading: Boolean = false,
    val socialLoginInProgress: AuthProvider? = null,
    val error: String? = null
) {
    val isLoginEnabled: Boolean
        get() = email.isNotBlank() &&
                password.isNotBlank() &&
                emailError == null &&
                password.length >= 8 &&
                !isLoading
}
