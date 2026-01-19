package com.dyjung.logindemo.presentation

import androidx.compose.runtime.Composable
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.dyjung.logindemo.presentation.auth.ForgotPasswordScreen
import com.dyjung.logindemo.presentation.auth.LoginScreen
import com.dyjung.logindemo.presentation.auth.RegisterScreen
import com.dyjung.logindemo.presentation.main.MainScreen
import com.dyjung.logindemo.presentation.onboarding.OnboardingScreen
import com.dyjung.logindemo.presentation.splash.SplashScreen

/**
 * 앱 네비게이션 목적지
 * iOS의 AppScreen에 대응
 */
sealed class AppScreen(val route: String) {
    data object Splash : AppScreen("splash")
    data object Onboarding : AppScreen("onboarding")
    data object Login : AppScreen("login")
    data object Register : AppScreen("register")
    data object ForgotPassword : AppScreen("forgot_password")
    data object Main : AppScreen("main")
}

/**
 * 앱의 루트 Composable
 * iOS의 RootView에 대응
 */
@Composable
fun LoginDemoApp() {
    val navController = rememberNavController()

    NavHost(
        navController = navController,
        startDestination = AppScreen.Splash.route
    ) {
        // 스플래시 화면
        composable(AppScreen.Splash.route) {
            SplashScreen(
                onNavigateToOnboarding = {
                    navController.navigate(AppScreen.Onboarding.route) {
                        popUpTo(AppScreen.Splash.route) { inclusive = true }
                    }
                },
                onNavigateToLogin = {
                    navController.navigate(AppScreen.Login.route) {
                        popUpTo(AppScreen.Splash.route) { inclusive = true }
                    }
                },
                onNavigateToMain = {
                    navController.navigate(AppScreen.Main.route) {
                        popUpTo(AppScreen.Splash.route) { inclusive = true }
                    }
                }
            )
        }

        // 온보딩 화면
        composable(AppScreen.Onboarding.route) {
            OnboardingScreen(
                onComplete = {
                    navController.navigate(AppScreen.Login.route) {
                        popUpTo(AppScreen.Onboarding.route) { inclusive = true }
                    }
                }
            )
        }

        // 로그인 화면
        composable(AppScreen.Login.route) {
            LoginScreen(
                onLoginSuccess = {
                    navController.navigate(AppScreen.Main.route) {
                        popUpTo(AppScreen.Login.route) { inclusive = true }
                    }
                },
                onNavigateToRegister = {
                    navController.navigate(AppScreen.Register.route)
                },
                onNavigateToForgotPassword = {
                    navController.navigate(AppScreen.ForgotPassword.route)
                },
                onNavigateToMain = {
                    // 개발용 메인 바로가기 (로그인 건너뛰기)
                    navController.navigate(AppScreen.Main.route) {
                        popUpTo(AppScreen.Login.route) { inclusive = true }
                    }
                }
            )
        }

        // 회원가입 화면
        composable(AppScreen.Register.route) {
            RegisterScreen(
                onRegisterSuccess = {
                    navController.navigate(AppScreen.Main.route) {
                        popUpTo(AppScreen.Login.route) { inclusive = true }
                    }
                },
                onNavigateBack = {
                    navController.popBackStack()
                }
            )
        }

        // 비밀번호 찾기 화면
        composable(AppScreen.ForgotPassword.route) {
            ForgotPasswordScreen(
                onNavigateBack = {
                    navController.popBackStack()
                }
            )
        }

        // 메인 화면
        composable(AppScreen.Main.route) {
            MainScreen(
                onLogout = {
                    navController.navigate(AppScreen.Login.route) {
                        popUpTo(AppScreen.Main.route) { inclusive = true }
                    }
                }
            )
        }
    }
}
