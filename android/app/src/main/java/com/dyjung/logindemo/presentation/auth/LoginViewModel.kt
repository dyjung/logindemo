package com.dyjung.logindemo.presentation.auth

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

/**
 * ViewModel for Login screen.
 * Handles email/password validation and login logic.
 */
@HiltViewModel
class LoginViewModel @Inject constructor(
    // TODO: Inject LoginUseCase, SocialLoginUseCase
) : ViewModel() {

    private val _uiState = MutableStateFlow(LoginUiState())
    val uiState: StateFlow<LoginUiState> = _uiState.asStateFlow()

    fun onEmailChange(email: String) {
        _uiState.update { state ->
            state.copy(
                email = email,
                emailError = validateEmail(email)
            )
        }
    }

    fun onPasswordChange(password: String) {
        _uiState.update { state ->
            state.copy(
                password = password,
                passwordError = validatePassword(password)
            )
        }
    }

    fun login(onSuccess: () -> Unit) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }

            try {
                // TODO: Call LoginUseCase
                // Simulate login for now
                kotlinx.coroutines.delay(1000)
                onSuccess()
            } catch (e: Exception) {
                _uiState.update { it.copy(error = e.message) }
            } finally {
                _uiState.update { it.copy(isLoading = false) }
            }
        }
    }

    private fun validateEmail(email: String): String? {
        return when {
            email.isBlank() -> null // Don't show error for empty
            !android.util.Patterns.EMAIL_ADDRESS.matcher(email).matches() ->
                "올바른 이메일 형식이 아닙니다"
            else -> null
        }
    }

    private fun validatePassword(password: String): String? {
        return when {
            password.isBlank() -> null // Don't show error for empty
            password.length < 8 -> "비밀번호는 8자 이상이어야 합니다"
            else -> null
        }
    }
}

/**
 * UI state for Login screen.
 */
data class LoginUiState(
    val email: String = "",
    val password: String = "",
    val emailError: String? = null,
    val passwordError: String? = null,
    val isLoading: Boolean = false,
    val error: String? = null
) {
    val isLoginEnabled: Boolean
        get() = email.isNotBlank() &&
                password.isNotBlank() &&
                emailError == null &&
                password.length >= 8
}
