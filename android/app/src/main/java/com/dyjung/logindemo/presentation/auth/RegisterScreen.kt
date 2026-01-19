package com.dyjung.logindemo.presentation.auth

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.outlined.Lock
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.dyjung.logindemo.presentation.components.PrimaryButton
import com.dyjung.logindemo.presentation.theme.AppColors

/**
 * 회원가입 화면
 * iOS의 RegisterView에 대응
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RegisterScreen(
    onRegisterSuccess: () -> Unit,
    onNavigateBack: () -> Unit,
    viewModel: RegisterViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    var passwordVisible by remember { mutableStateOf(false) }
    var confirmPasswordVisible by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("회원가입") },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                            contentDescription = "뒤로가기"
                        )
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = AppColors.BackgroundLight
                )
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(AppColors.BackgroundLight)
                .padding(paddingValues)
                .verticalScroll(rememberScrollState())
                .padding(24.dp)
        ) {
            // 이메일 필드
            OutlinedTextField(
                value = uiState.email,
                onValueChange = viewModel::onEmailChange,
                label = { Text("이메일") },
                placeholder = { Text("example@email.com") },
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email),
                singleLine = true,
                modifier = Modifier.fillMaxWidth(),
                isError = uiState.emailError != null,
                supportingText = {
                    when {
                        uiState.isCheckingEmail -> Text("확인 중...", color = AppColors.TextSecondary)
                        uiState.emailError != null -> Text(uiState.emailError!!, color = AppColors.Error)
                        uiState.isEmailAvailable == true -> Text("사용 가능한 이메일입니다", color = Color(0xFF34C759))
                    }
                },
                trailingIcon = {
                    when {
                        uiState.isCheckingEmail -> CircularProgressIndicator(
                            modifier = Modifier.size(20.dp),
                            strokeWidth = 2.dp
                        )
                        uiState.isEmailAvailable == true -> Icon(
                            imageVector = Icons.Default.Check,
                            contentDescription = null,
                            tint = Color(0xFF34C759)
                        )
                    }
                },
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = AppColors.Primary,
                    focusedLabelColor = AppColors.Primary
                )
            )

            Spacer(modifier = Modifier.height(16.dp))

            // 비밀번호 필드
            OutlinedTextField(
                value = uiState.password,
                onValueChange = viewModel::onPasswordChange,
                label = { Text("비밀번호") },
                placeholder = { Text("8자 이상 입력") },
                visualTransformation = if (passwordVisible)
                    VisualTransformation.None
                else
                    PasswordVisualTransformation(),
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
                singleLine = true,
                modifier = Modifier.fillMaxWidth(),
                isError = uiState.passwordError != null,
                supportingText = uiState.passwordError?.let { { Text(it, color = AppColors.Error) } },
                trailingIcon = {
                    IconButton(onClick = { passwordVisible = !passwordVisible }) {
                        Icon(
                            imageVector = if (passwordVisible)
                                Icons.Outlined.Lock
                            else
                                Icons.Filled.Lock,
                            contentDescription = null
                        )
                    }
                },
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = AppColors.Primary,
                    focusedLabelColor = AppColors.Primary
                )
            )

            Spacer(modifier = Modifier.height(16.dp))

            // 비밀번호 확인 필드
            OutlinedTextField(
                value = uiState.confirmPassword,
                onValueChange = viewModel::onConfirmPasswordChange,
                label = { Text("비밀번호 확인") },
                placeholder = { Text("비밀번호를 다시 입력") },
                visualTransformation = if (confirmPasswordVisible)
                    VisualTransformation.None
                else
                    PasswordVisualTransformation(),
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
                singleLine = true,
                modifier = Modifier.fillMaxWidth(),
                isError = uiState.confirmPasswordError != null,
                supportingText = uiState.confirmPasswordError?.let { { Text(it, color = AppColors.Error) } },
                trailingIcon = {
                    IconButton(onClick = { confirmPasswordVisible = !confirmPasswordVisible }) {
                        Icon(
                            imageVector = if (confirmPasswordVisible)
                                Icons.Outlined.Lock
                            else
                                Icons.Filled.Lock,
                            contentDescription = null
                        )
                    }
                },
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = AppColors.Primary,
                    focusedLabelColor = AppColors.Primary
                )
            )

            Spacer(modifier = Modifier.height(16.dp))

            // 이름 필드
            OutlinedTextField(
                value = uiState.name,
                onValueChange = viewModel::onNameChange,
                label = { Text("이름") },
                placeholder = { Text("이름을 입력하세요") },
                singleLine = true,
                modifier = Modifier.fillMaxWidth(),
                isError = uiState.nameError != null,
                supportingText = uiState.nameError?.let { { Text(it, color = AppColors.Error) } },
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = AppColors.Primary,
                    focusedLabelColor = AppColors.Primary
                )
            )

            Spacer(modifier = Modifier.height(24.dp))

            // 약관 동의 섹션
            TermsSection(
                agreedToTerms = uiState.agreedToTerms,
                agreedToPrivacy = uiState.agreedToPrivacy,
                onTermsChange = viewModel::onTermsChange,
                onPrivacyChange = viewModel::onPrivacyChange,
                onToggleAll = viewModel::toggleAllAgreements
            )

            Spacer(modifier = Modifier.height(32.dp))

            // 회원가입 버튼
            PrimaryButton(
                text = "회원가입",
                onClick = { viewModel.register(onRegisterSuccess) },
                isLoading = uiState.isLoading,
                isEnabled = uiState.isRegisterEnabled
            )

            Spacer(modifier = Modifier.height(24.dp))
        }
    }

    // 에러 다이얼로그
    uiState.error?.let { error ->
        AlertDialog(
            onDismissRequest = viewModel::clearError,
            title = { Text("오류") },
            text = { Text(error) },
            confirmButton = {
                TextButton(onClick = viewModel::clearError) {
                    Text("확인")
                }
            }
        )
    }
}

@Composable
private fun TermsSection(
    agreedToTerms: Boolean,
    agreedToPrivacy: Boolean,
    onTermsChange: (Boolean) -> Unit,
    onPrivacyChange: (Boolean) -> Unit,
    onToggleAll: () -> Unit
) {
    val allAgreed = agreedToTerms && agreedToPrivacy

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(Color.White, MaterialTheme.shapes.medium)
            .padding(16.dp)
    ) {
        // 전체 동의
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Checkbox(
                checked = allAgreed,
                onCheckedChange = { onToggleAll() },
                colors = CheckboxDefaults.colors(checkedColor = AppColors.Primary)
            )
            Text(
                text = "전체 동의",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold
            )
        }

        HorizontalDivider(
            modifier = Modifier.padding(vertical = 8.dp),
            color = AppColors.DividerLight
        )

        // 이용약관 동의
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Checkbox(
                checked = agreedToTerms,
                onCheckedChange = onTermsChange,
                colors = CheckboxDefaults.colors(checkedColor = AppColors.Primary)
            )
            Text(
                text = "[필수] 이용약관 동의",
                style = MaterialTheme.typography.bodyMedium
            )
            Spacer(modifier = Modifier.weight(1f))
            TextButton(onClick = { /* 약관 보기 */ }) {
                Text("보기", color = AppColors.TextSecondary)
            }
        }

        // 개인정보처리방침 동의
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Checkbox(
                checked = agreedToPrivacy,
                onCheckedChange = onPrivacyChange,
                colors = CheckboxDefaults.colors(checkedColor = AppColors.Primary)
            )
            Text(
                text = "[필수] 개인정보처리방침 동의",
                style = MaterialTheme.typography.bodyMedium
            )
            Spacer(modifier = Modifier.weight(1f))
            TextButton(onClick = { /* 방침 보기 */ }) {
                Text("보기", color = AppColors.TextSecondary)
            }
        }
    }
}

// MARK: - Preview

@Preview(showBackground = true, showSystemUi = true)
@Composable
private fun RegisterScreenPreview() {
    MaterialTheme {
        RegisterScreenContent(
            onNavigateBack = {}
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun RegisterScreenContent(
    onNavigateBack: () -> Unit
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("회원가입") },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                            contentDescription = "뒤로가기"
                        )
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = AppColors.BackgroundLight
                )
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(AppColors.BackgroundLight)
                .padding(paddingValues)
                .verticalScroll(rememberScrollState())
                .padding(24.dp)
        ) {
            OutlinedTextField(
                value = "",
                onValueChange = {},
                label = { Text("이메일") },
                placeholder = { Text("example@email.com") },
                modifier = Modifier.fillMaxWidth(),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = AppColors.Primary,
                    focusedLabelColor = AppColors.Primary
                )
            )

            Spacer(modifier = Modifier.height(16.dp))

            OutlinedTextField(
                value = "",
                onValueChange = {},
                label = { Text("비밀번호") },
                placeholder = { Text("8자 이상 입력") },
                visualTransformation = PasswordVisualTransformation(),
                modifier = Modifier.fillMaxWidth(),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = AppColors.Primary,
                    focusedLabelColor = AppColors.Primary
                )
            )

            Spacer(modifier = Modifier.height(16.dp))

            OutlinedTextField(
                value = "",
                onValueChange = {},
                label = { Text("비밀번호 확인") },
                placeholder = { Text("비밀번호를 다시 입력") },
                visualTransformation = PasswordVisualTransformation(),
                modifier = Modifier.fillMaxWidth(),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = AppColors.Primary,
                    focusedLabelColor = AppColors.Primary
                )
            )

            Spacer(modifier = Modifier.height(16.dp))

            OutlinedTextField(
                value = "",
                onValueChange = {},
                label = { Text("이름") },
                placeholder = { Text("이름을 입력하세요") },
                modifier = Modifier.fillMaxWidth(),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = AppColors.Primary,
                    focusedLabelColor = AppColors.Primary
                )
            )

            Spacer(modifier = Modifier.height(24.dp))

            TermsSection(
                agreedToTerms = false,
                agreedToPrivacy = false,
                onTermsChange = {},
                onPrivacyChange = {},
                onToggleAll = {}
            )

            Spacer(modifier = Modifier.height(32.dp))

            PrimaryButton(
                text = "회원가입",
                onClick = {},
                isLoading = false,
                isEnabled = false
            )

            Spacer(modifier = Modifier.height(24.dp))
        }
    }
}
