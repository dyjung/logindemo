package com.dyjung.logindemo.core.validation

import android.util.Patterns

/**
 * 유효성 검사 유틸리티
 */
object Validators {
    fun isValidEmail(email: String): Boolean {
        return Patterns.EMAIL_ADDRESS.matcher(email).matches()
    }

    fun isValidPassword(password: String): Boolean {
        return password.length >= 8
    }

    fun isValidName(name: String): Boolean {
        return name.length in 2..20
    }
}

/**
 * 유효성 검사 결과
 */
data class ValidationResult(
    val isValid: Boolean,
    val errorMessage: String? = null
)

/**
 * 이메일 유효성 검사
 */
object EmailValidator {
    fun validate(email: String): ValidationResult {
        return when {
            email.isBlank() -> ValidationResult(true) // 빈 값은 에러 표시 안 함
            !Patterns.EMAIL_ADDRESS.matcher(email).matches() ->
                ValidationResult(false, "올바른 이메일 형식이 아닙니다")
            else -> ValidationResult(true)
        }
    }
}

/**
 * 비밀번호 유효성 검사
 */
object PasswordValidator {
    private const val MIN_LENGTH = 8

    fun validate(password: String): ValidationResult {
        return when {
            password.isBlank() -> ValidationResult(true) // 빈 값은 에러 표시 안 함
            password.length < MIN_LENGTH ->
                ValidationResult(false, "비밀번호는 ${MIN_LENGTH}자 이상이어야 합니다")
            else -> ValidationResult(true)
        }
    }

    fun validateConfirmation(password: String, confirmation: String): ValidationResult {
        return when {
            confirmation.isBlank() -> ValidationResult(true)
            password != confirmation ->
                ValidationResult(false, "비밀번호가 일치하지 않습니다")
            else -> ValidationResult(true)
        }
    }
}

/**
 * 이름 유효성 검사
 */
object NameValidator {
    private const val MIN_LENGTH = 2
    private const val MAX_LENGTH = 20

    fun validate(name: String): ValidationResult {
        return when {
            name.isBlank() -> ValidationResult(true)
            name.length < MIN_LENGTH ->
                ValidationResult(false, "이름은 ${MIN_LENGTH}자 이상이어야 합니다")
            name.length > MAX_LENGTH ->
                ValidationResult(false, "이름은 ${MAX_LENGTH}자 이하여야 합니다")
            else -> ValidationResult(true)
        }
    }
}
