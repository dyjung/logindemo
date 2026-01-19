package com.dyjung.logindemo.presentation.splash

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.dyjung.logindemo.presentation.theme.AppColors

/**
 * 스플래시 화면
 * iOS의 SplashView에 대응
 */
@Composable
fun SplashScreen(
    onNavigateToOnboarding: () -> Unit,
    onNavigateToLogin: () -> Unit,
    onNavigateToMain: () -> Unit,
    viewModel: SplashViewModel = hiltViewModel()
) {
    val navigationEvent by viewModel.navigationEvent.collectAsState()

    // 네비게이션 이벤트 처리
    LaunchedEffect(navigationEvent) {
        when (navigationEvent) {
            SplashNavigationEvent.NavigateToOnboarding -> {
                onNavigateToOnboarding()
                viewModel.onNavigationHandled()
            }
            SplashNavigationEvent.NavigateToLogin -> {
                onNavigateToLogin()
                viewModel.onNavigationHandled()
            }
            SplashNavigationEvent.NavigateToMain -> {
                onNavigateToMain()
                viewModel.onNavigationHandled()
            }
            null -> { /* 대기 중 */ }
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(AppColors.BackgroundLight),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // 앱 로고/이름
            Text(
                text = "LoginDemo",
                style = MaterialTheme.typography.headlineLarge,
                fontWeight = FontWeight.Bold,
                color = AppColors.Primary
            )

            Spacer(modifier = Modifier.height(24.dp))

            // 로딩 인디케이터
            CircularProgressIndicator(
                color = AppColors.Primary,
                strokeWidth = 3.dp
            )

            Spacer(modifier = Modifier.height(16.dp))

            Text(
                text = "로딩 중...",
                style = MaterialTheme.typography.bodyMedium,
                color = AppColors.TextSecondary
            )
        }
    }
}

// MARK: - Preview

@Preview(showBackground = true, showSystemUi = true)
@Composable
private fun SplashScreenPreview() {
    MaterialTheme {
        SplashScreenContent()
    }
}

@Composable
private fun SplashScreenContent() {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(AppColors.BackgroundLight),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "LoginDemo",
                style = MaterialTheme.typography.headlineLarge,
                fontWeight = FontWeight.Bold,
                color = AppColors.Primary
            )

            Spacer(modifier = Modifier.height(24.dp))

            CircularProgressIndicator(
                color = AppColors.Primary,
                strokeWidth = 3.dp
            )

            Spacer(modifier = Modifier.height(16.dp))

            Text(
                text = "로딩 중...",
                style = MaterialTheme.typography.bodyMedium,
                color = AppColors.TextSecondary
            )
        }
    }
}
