package com.dyjung.logindemo.presentation.auth

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.outlined.Lock
import androidx.compose.material3.*
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.runtime.*
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.dyjung.logindemo.domain.model.AuthProvider
import com.dyjung.logindemo.presentation.components.PrimaryButton
import com.dyjung.logindemo.presentation.components.SocialLoginButton
import com.dyjung.logindemo.presentation.theme.AppColors

/**
 * 로그인 화면
 * iOS의 LoginView에 대응
 */
@Composable
fun LoginScreen(
    onLoginSuccess: () -> Unit,
    onNavigateToRegister: () -> Unit,
    onNavigateToForgotPassword: () -> Unit = {},
    onNavigateToMain: () -> Unit = {},  // 개발용 메인 바로가기
    viewModel: LoginViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    var passwordVisible by remember { mutableStateOf(false) }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(AppColors.BackgroundLight)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
        Spacer(modifier = Modifier.height(40.dp))

        // 헤더 섹션
        HeaderSection()

        Spacer(modifier = Modifier.height(32.dp))

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
            supportingText = uiState.emailError?.let { { Text(it, color = AppColors.Error) } },
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
                        contentDescription = if (passwordVisible) "비밀번호 숨기기" else "비밀번호 보기"
                    )
                }
            },
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = AppColors.Primary,
                focusedLabelColor = AppColors.Primary
            )
        )

        Spacer(modifier = Modifier.height(8.dp))

        // 자동 로그인 체크박스
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Checkbox(
                checked = uiState.autoLoginEnabled,
                onCheckedChange = viewModel::onAutoLoginChange,
                colors = CheckboxDefaults.colors(
                    checkedColor = AppColors.Primary
                )
            )
            Text(
                text = "자동 로그인",
                style = MaterialTheme.typography.bodyMedium,
                color = AppColors.TextSecondary
            )
        }

        Spacer(modifier = Modifier.height(24.dp))

        // 로그인 버튼
        PrimaryButton(
            text = "로그인",
            onClick = { viewModel.login(onLoginSuccess) },
            isLoading = uiState.isLoading,
            isEnabled = uiState.isLoginEnabled
        )

        Spacer(modifier = Modifier.height(16.dp))

        // 비밀번호 찾기
        TextButton(onClick = onNavigateToForgotPassword) {
            Text(
                text = "비밀번호를 잊으셨나요?",
                color = AppColors.Primary,
                style = MaterialTheme.typography.bodyMedium
            )
        }

        Spacer(modifier = Modifier.height(32.dp))

        // 소셜 로그인 구분선
        SocialLoginDivider()

        Spacer(modifier = Modifier.height(24.dp))

        // 소셜 로그인 버튼들
        SocialLoginSection(
            onSocialLogin = { provider ->
                viewModel.socialLogin(provider, onLoginSuccess)
            },
            isLoading = uiState.isLoading,
            loadingProvider = uiState.socialLoginInProgress
        )

        // 소셜 로그인 진행 중 표시
        if (uiState.socialLoginInProgress != null) {
            Spacer(modifier = Modifier.height(16.dp))
            Row(
                horizontalArrangement = Arrangement.Center,
                verticalAlignment = Alignment.CenterVertically
            ) {
                CircularProgressIndicator(
                    modifier = Modifier.size(16.dp),
                    strokeWidth = 2.dp,
                    color = AppColors.Primary
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "${uiState.socialLoginInProgress?.displayName} 로그인 중...",
                    style = MaterialTheme.typography.bodySmall,
                    color = AppColors.TextSecondary
                )
            }
        }

        Spacer(modifier = Modifier.height(32.dp))

        // 회원가입 링크
        Row(
            horizontalArrangement = Arrangement.Center,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "계정이 없으신가요?",
                style = MaterialTheme.typography.bodyMedium,
                color = AppColors.TextSecondary
            )
            TextButton(onClick = onNavigateToRegister) {
                Text(
                    text = "회원가입",
                    color = AppColors.Primary,
                    fontWeight = FontWeight.SemiBold
                )
            }
        }

            Spacer(modifier = Modifier.height(24.dp))
        }

        // 메인으로 바로가기 단축키 (개발용)
        Row(
            modifier = Modifier
                .align(Alignment.BottomEnd)
                .padding(end = 16.dp, bottom = 24.dp)
                .clip(RoundedCornerShape(20.dp))
                .background(Color.Gray.copy(alpha = 0.7f))
                .clickable { onNavigateToMain() }
                .padding(horizontal = 12.dp, vertical = 8.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Icon(
                imageVector = Icons.AutoMirrored.Filled.ArrowForward,
                contentDescription = null,
                tint = Color.White,
                modifier = Modifier.size(16.dp)
            )
            Text(
                text = "메인으로",
                style = MaterialTheme.typography.labelMedium,
                fontWeight = FontWeight.Medium,
                color = Color.White
            )
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
private fun HeaderSection() {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // 프로필 아이콘
        Box(
            modifier = Modifier
                .size(80.dp)
                .background(AppColors.Primary.copy(alpha = 0.1f), CircleShape),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = Icons.Default.Person,
                contentDescription = null,
                modifier = Modifier.size(48.dp),
                tint = AppColors.Primary
            )
        }

        Spacer(modifier = Modifier.height(16.dp))

        Text(
            text = "환영합니다",
            style = MaterialTheme.typography.headlineSmall,
            fontWeight = FontWeight.Bold,
            color = AppColors.TextPrimary
        )

        Spacer(modifier = Modifier.height(4.dp))

        Text(
            text = "계정에 로그인하세요",
            style = MaterialTheme.typography.bodyMedium,
            color = AppColors.TextSecondary
        )
    }
}

@Composable
private fun SocialLoginDivider() {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically
    ) {
        HorizontalDivider(
            modifier = Modifier.weight(1f),
            color = AppColors.DividerLight
        )
        Text(
            text = "또는",
            modifier = Modifier.padding(horizontal = 16.dp),
            style = MaterialTheme.typography.bodySmall,
            color = AppColors.TextSecondary
        )
        HorizontalDivider(
            modifier = Modifier.weight(1f),
            color = AppColors.DividerLight
        )
    }
}

@Composable
private fun SocialLoginSection(
    onSocialLogin: (AuthProvider) -> Unit,
    isLoading: Boolean,
    loadingProvider: AuthProvider?
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.Center
    ) {
        SocialLoginButton(
            provider = AuthProvider.KAKAO,
            onClick = { onSocialLogin(AuthProvider.KAKAO) },
            isEnabled = !isLoading,
            modifier = Modifier.alpha(if (loadingProvider == AuthProvider.KAKAO) 0.6f else 1f)
        )

        Spacer(modifier = Modifier.width(16.dp))

        SocialLoginButton(
            provider = AuthProvider.NAVER,
            onClick = { onSocialLogin(AuthProvider.NAVER) },
            isEnabled = !isLoading,
            modifier = Modifier.alpha(if (loadingProvider == AuthProvider.NAVER) 0.6f else 1f)
        )

        Spacer(modifier = Modifier.width(16.dp))

        SocialLoginButton(
            provider = AuthProvider.APPLE,
            onClick = { onSocialLogin(AuthProvider.APPLE) },
            isEnabled = !isLoading,
            modifier = Modifier.alpha(if (loadingProvider == AuthProvider.APPLE) 0.6f else 1f)
        )
    }
}

// MARK: - Preview

@Preview(showBackground = true, showSystemUi = true)
@Composable
private fun LoginScreenPreview() {
    MaterialTheme {
        LoginScreenContent(
            uiState = LoginUiState(),
            passwordVisible = false,
            onPasswordVisibleChange = {},
            onEmailChange = {},
            onPasswordChange = {},
            onAutoLoginChange = {},
            onLogin = {},
            onNavigateToRegister = {},
            onNavigateToForgotPassword = {},
            onNavigateToMain = {},
            onClearError = {}
        )
    }
}

/**
 * Preview용 LoginScreen 컨텐츠 (ViewModel 없이)
 */
@Composable
private fun LoginScreenContent(
    uiState: LoginUiState,
    passwordVisible: Boolean,
    onPasswordVisibleChange: (Boolean) -> Unit,
    onEmailChange: (String) -> Unit,
    onPasswordChange: (String) -> Unit,
    onAutoLoginChange: (Boolean) -> Unit,
    onLogin: () -> Unit,
    onNavigateToRegister: () -> Unit,
    onNavigateToForgotPassword: () -> Unit,
    onNavigateToMain: () -> Unit,
    onClearError: () -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(AppColors.BackgroundLight)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(modifier = Modifier.height(40.dp))
            HeaderSection()
            Spacer(modifier = Modifier.height(32.dp))

            OutlinedTextField(
                value = uiState.email,
                onValueChange = onEmailChange,
                label = { Text("이메일") },
                placeholder = { Text("example@email.com") },
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email),
                singleLine = true,
                modifier = Modifier.fillMaxWidth(),
                isError = uiState.emailError != null,
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = AppColors.Primary,
                    focusedLabelColor = AppColors.Primary
                )
            )

            Spacer(modifier = Modifier.height(16.dp))

            OutlinedTextField(
                value = uiState.password,
                onValueChange = onPasswordChange,
                label = { Text("비밀번호") },
                placeholder = { Text("8자 이상 입력") },
                visualTransformation = if (passwordVisible)
                    VisualTransformation.None
                else
                    PasswordVisualTransformation(),
                singleLine = true,
                modifier = Modifier.fillMaxWidth(),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = AppColors.Primary,
                    focusedLabelColor = AppColors.Primary
                )
            )

            Spacer(modifier = Modifier.height(8.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Checkbox(
                    checked = uiState.autoLoginEnabled,
                    onCheckedChange = onAutoLoginChange,
                    colors = CheckboxDefaults.colors(checkedColor = AppColors.Primary)
                )
                Text(
                    text = "자동 로그인",
                    style = MaterialTheme.typography.bodyMedium,
                    color = AppColors.TextSecondary
                )
            }

            Spacer(modifier = Modifier.height(24.dp))

            PrimaryButton(
                text = "로그인",
                onClick = onLogin,
                isLoading = uiState.isLoading,
                isEnabled = uiState.isLoginEnabled
            )

            Spacer(modifier = Modifier.height(16.dp))

            TextButton(onClick = onNavigateToForgotPassword) {
                Text(
                    text = "비밀번호를 잊으셨나요?",
                    color = AppColors.Primary
                )
            }

            Spacer(modifier = Modifier.height(32.dp))
            SocialLoginDivider()
            Spacer(modifier = Modifier.height(24.dp))

            SocialLoginSection(
                onSocialLogin = {},
                isLoading = false,
                loadingProvider = null
            )

            Spacer(modifier = Modifier.height(32.dp))

            Row(
                horizontalArrangement = Arrangement.Center,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "계정이 없으신가요?",
                    style = MaterialTheme.typography.bodyMedium,
                    color = AppColors.TextSecondary
                )
                TextButton(onClick = onNavigateToRegister) {
                    Text(
                        text = "회원가입",
                        color = AppColors.Primary,
                        fontWeight = FontWeight.SemiBold
                    )
                }
            }

            Spacer(modifier = Modifier.height(24.dp))
        }

        // 메인으로 바로가기 단축키
        Row(
            modifier = Modifier
                .align(Alignment.BottomEnd)
                .padding(end = 16.dp, bottom = 24.dp)
                .clip(RoundedCornerShape(20.dp))
                .background(Color.Gray.copy(alpha = 0.7f))
                .clickable { onNavigateToMain() }
                .padding(horizontal = 12.dp, vertical = 8.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Icon(
                imageVector = Icons.AutoMirrored.Filled.ArrowForward,
                contentDescription = null,
                tint = Color.White,
                modifier = Modifier.size(16.dp)
            )
            Text(
                text = "메인으로",
                style = MaterialTheme.typography.labelMedium,
                fontWeight = FontWeight.Medium,
                color = Color.White
            )
        }
    }
}
