package com.dyjung.logindemo.presentation.auth

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.dyjung.logindemo.core.validation.Validators
import com.dyjung.logindemo.domain.usecase.ForgotPasswordUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

/**
 * 비밀번호 찾기 화면 ViewModel
 * iOS의 ForgotPasswordViewModel에 대응
 */
@HiltViewModel
class ForgotPasswordViewModel @Inject constructor(
    private val forgotPasswordUseCase: ForgotPasswordUseCase
) : ViewModel() {

    private val _uiState = MutableStateFlow(ForgotPasswordUiState())
    val uiState: StateFlow<ForgotPasswordUiState> = _uiState.asStateFlow()

    fun onEmailChanged(email: String) {
        _uiState.update { state ->
            val emailError = if (email.isEmpty()) {
                null
            } else if (!Validators.isValidEmail(email)) {
                "올바른 이메일 형식이 아닙니다"
            } else {
                null
            }

            state.copy(
                email = email,
                emailError = emailError,
                // 성공/에러 메시지 초기화
                successMessage = null,
                errorMessage = null
            )
        }
    }

    fun sendResetEmail() {
        val currentState = _uiState.value
        if (!currentState.isSendEnabled) return

        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, errorMessage = null, successMessage = null) }

            try {
                forgotPasswordUseCase(currentState.email)
                _uiState.update {
                    it.copy(
                        isLoading = false,
                        successMessage = "비밀번호 재설정 이메일이 발송되었습니다.\n이메일을 확인해주세요."
                    )
                }
            } catch (e: Exception) {
                _uiState.update {
                    it.copy(
                        isLoading = false,
                        errorMessage = e.message ?: "이메일 발송에 실패했습니다"
                    )
                }
            }
        }
    }

    fun clearError() {
        _uiState.update { it.copy(errorMessage = null) }
    }

    fun reset() {
        _uiState.value = ForgotPasswordUiState()
    }
}

data class ForgotPasswordUiState(
    val email: String = "",
    val emailError: String? = null,
    val isLoading: Boolean = false,
    val successMessage: String? = null,
    val errorMessage: String? = null
) {
    val isSendEnabled: Boolean
        get() = email.isNotEmpty() && emailError == null && !isLoading
}
