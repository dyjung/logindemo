package com.dyjung.logindemo.presentation

import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.dyjung.logindemo.presentation.auth.LoginScreen
import com.dyjung.logindemo.presentation.main.MainScreen
import com.dyjung.logindemo.presentation.onboarding.OnboardingScreen
import com.dyjung.logindemo.presentation.splash.SplashScreen

/**
 * Root composable for the app.
 * Handles navigation based on app state.
 */
@Composable
fun LoginDemoApp(
    viewModel: AppViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val navController = rememberNavController()

    NavHost(
        navController = navController,
        startDestination = AppScreen.Splash.route
    ) {
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

        composable(AppScreen.Onboarding.route) {
            OnboardingScreen(
                onComplete = {
                    navController.navigate(AppScreen.Login.route) {
                        popUpTo(AppScreen.Onboarding.route) { inclusive = true }
                    }
                }
            )
        }

        composable(AppScreen.Login.route) {
            LoginScreen(
                onLoginSuccess = {
                    navController.navigate(AppScreen.Main.route) {
                        popUpTo(AppScreen.Login.route) { inclusive = true }
                    }
                },
                onNavigateToRegister = {
                    // TODO: Navigate to register
                }
            )
        }

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

/**
 * App navigation destinations.
 */
sealed class AppScreen(val route: String) {
    data object Splash : AppScreen("splash")
    data object Onboarding : AppScreen("onboarding")
    data object Login : AppScreen("login")
    data object Main : AppScreen("main")
}
