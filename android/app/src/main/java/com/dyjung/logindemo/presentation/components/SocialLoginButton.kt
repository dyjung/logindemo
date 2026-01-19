package com.dyjung.logindemo.presentation.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Email
import androidx.compose.material3.Icon
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.width
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.role
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import com.dyjung.logindemo.domain.model.AuthProvider
import com.dyjung.logindemo.presentation.theme.AppColors

/**
 * 소셜 로그인 버튼
 * iOS의 SocialLoginButton에 대응
 */
@Composable
fun SocialLoginButton(
    provider: AuthProvider,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    isEnabled: Boolean = true
) {
    val (backgroundColor, contentColor, contentDescription) = when (provider) {
        AuthProvider.KAKAO -> Triple(
            AppColors.KakaoYellow,
            AppColors.KakaoText,
            "카카오로 로그인"
        )
        AuthProvider.NAVER -> Triple(
            AppColors.NaverGreen,
            Color.White,
            "네이버로 로그인"
        )
        AuthProvider.APPLE -> Triple(
            AppColors.AppleBlack,
            Color.White,
            "Apple로 로그인"
        )
        AuthProvider.EMAIL -> Triple(
            Color.Gray,
            Color.White,
            "이메일로 로그인"
        )
    }

    Box(
        modifier = modifier
            .size(56.dp)
            .clip(CircleShape)
            .background(backgroundColor)
            .then(
                if (provider == AuthProvider.APPLE) {
                    Modifier.border(1.dp, Color.Gray.copy(alpha = 0.3f), CircleShape)
                } else Modifier
            )
            .clickable(enabled = isEnabled, onClick = onClick)
            .semantics {
                this.contentDescription = contentDescription
                this.role = Role.Button
            },
        contentAlignment = Alignment.Center
    ) {
        // Provider 별 아이콘 (실제 앱에서는 리소스 아이콘 사용)
        val iconText = when (provider) {
            AuthProvider.KAKAO -> "K"
            AuthProvider.NAVER -> "N"
            AuthProvider.APPLE -> "A"
            AuthProvider.EMAIL -> "E"
        }

        androidx.compose.material3.Text(
            text = iconText,
            color = contentColor,
            style = androidx.compose.material3.MaterialTheme.typography.titleLarge,
            fontWeight = androidx.compose.ui.text.font.FontWeight.Bold
        )
    }
}

// MARK: - Preview

@Preview(showBackground = true)
@Composable
private fun SocialLoginButtonsPreview() {
    MaterialTheme {
        Row(
            horizontalArrangement = Arrangement.Center
        ) {
            SocialLoginButton(
                provider = AuthProvider.KAKAO,
                onClick = {}
            )
            Spacer(modifier = Modifier.width(16.dp))
            SocialLoginButton(
                provider = AuthProvider.NAVER,
                onClick = {}
            )
            Spacer(modifier = Modifier.width(16.dp))
            SocialLoginButton(
                provider = AuthProvider.APPLE,
                onClick = {}
            )
        }
    }
}
