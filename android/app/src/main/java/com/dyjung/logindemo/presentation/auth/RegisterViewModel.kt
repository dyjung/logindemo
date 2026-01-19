package com.dyjung.logindemo.presentation.auth

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.dyjung.logindemo.core.validation.EmailValidator
import com.dyjung.logindemo.core.validation.NameValidator
import com.dyjung.logindemo.core.validation.PasswordValidator
import com.dyjung.logindemo.domain.usecase.CheckEmailUseCase
import com.dyjung.logindemo.domain.usecase.RegisterUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

/**
 * 회원가입 화면 ViewModel
 * iOS의 RegisterViewModel에 대응
 */
@HiltViewModel
class RegisterViewModel @Inject constructor(
    private val registerUseCase: RegisterUseCase,
    private val checkEmailUseCase: CheckEmailUseCase
) : ViewModel() {

    private val _uiState = MutableStateFlow(RegisterUiState())
    val uiState: StateFlow<RegisterUiState> = _uiState.asStateFlow()

    private var emailCheckJob: Job? = null

    fun onEmailChange(email: String) {
        val validation = EmailValidator.validate(email)
        _uiState.update { state ->
            state.copy(
                email = email,
                emailError = validation.errorMessage,
                isEmailAvailable = null
            )
        }

        // 이메일 형식이 올바른 경우 중복 확인
        if (validation.isValid && email.isNotBlank()) {
            checkEmailAvailability(email)
        }
    }

    private fun checkEmailAvailability(email: String) {
        emailCheckJob?.cancel()

        emailCheckJob = viewModelScope.launch {
            // 0.5초 디바운스
            delay(500)

            _uiState.update { it.copy(isCheckingEmail = true) }

            try {
                val available = checkEmailUseCase(email)
                _uiState.update { state ->
                    state.copy(
                        isEmailAvailable = available,
                        emailError = if (!available) "이미 사용 중인 이메일입니다" else null,
                        isCheckingEmail = false
                    )
                }
            } catch (e: Exception) {
                _uiState.update { it.copy(isCheckingEmail = false) }
            }
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

        // 비밀번호 확인 필드도 재검증
        if (_uiState.value.confirmPassword.isNotBlank()) {
            validateConfirmPassword()
        }
    }

    fun onConfirmPasswordChange(confirmPassword: String) {
        _uiState.update { it.copy(confirmPassword = confirmPassword) }
        validateConfirmPassword()
    }

    private fun validateConfirmPassword() {
        val validation = PasswordValidator.validateConfirmation(
            _uiState.value.password,
            _uiState.value.confirmPassword
        )
        _uiState.update { it.copy(confirmPasswordError = validation.errorMessage) }
    }

    fun onNameChange(name: String) {
        val validation = NameValidator.validate(name)
        _uiState.update { state ->
            state.copy(
                name = name,
                nameError = validation.errorMessage
            )
        }
    }

    fun onTermsChange(agreed: Boolean) {
        _uiState.update { it.copy(agreedToTerms = agreed) }
    }

    fun onPrivacyChange(agreed: Boolean) {
        _uiState.update { it.copy(agreedToPrivacy = agreed) }
    }

    fun toggleAllAgreements() {
        val newValue = !(_uiState.value.agreedToTerms && _uiState.value.agreedToPrivacy)
        _uiState.update {
            it.copy(
                agreedToTerms = newValue,
                agreedToPrivacy = newValue
            )
        }
    }

    fun register(onSuccess: () -> Unit) {
        if (!_uiState.value.isRegisterEnabled) return

        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }

            try {
                registerUseCase(
                    email = _uiState.value.email,
                    password = _uiState.value.password,
                    name = _uiState.value.name,
                    agreedToTerms = _uiState.value.agreedToTerms,
                    agreedToPrivacy = _uiState.value.agreedToPrivacy
                )
                onSuccess()
            } catch (e: Exception) {
                _uiState.update { it.copy(error = e.message ?: "회원가입에 실패했습니다") }
            } finally {
                _uiState.update { it.copy(isLoading = false) }
            }
        }
    }

    fun clearError() {
        _uiState.update { it.copy(error = null) }
    }

    override fun onCleared() {
        super.onCleared()
        emailCheckJob?.cancel()
    }
}

/**
 * 회원가입 화면 UI 상태
 */
data class RegisterUiState(
    val email: String = "",
    val password: String = "",
    val confirmPassword: String = "",
    val name: String = "",
    val agreedToTerms: Boolean = false,
    val agreedToPrivacy: Boolean = false,
    val emailError: String? = null,
    val isEmailAvailable: Boolean? = null,
    val passwordError: String? = null,
    val confirmPasswordError: String? = null,
    val nameError: String? = null,
    val isLoading: Boolean = false,
    val isCheckingEmail: Boolean = false,
    val error: String? = null
) {
    val isRegisterEnabled: Boolean
        get() = email.isNotBlank() &&
                emailError == null &&
                isEmailAvailable == true &&
                password.isNotBlank() &&
                passwordError == null &&
                confirmPassword.isNotBlank() &&
                confirmPasswordError == null &&
                name.isNotBlank() &&
                nameError == null &&
                agreedToTerms &&
                agreedToPrivacy &&
                !isLoading
}
