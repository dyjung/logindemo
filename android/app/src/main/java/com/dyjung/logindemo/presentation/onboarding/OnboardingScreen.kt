package com.dyjung.logindemo.presentation.onboarding

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp

/**
 * Onboarding screen composable.
 * Shows app introduction pages.
 */
@Composable
fun OnboardingScreen(
    onComplete: () -> Unit
) {
    var currentPage by remember { mutableIntStateOf(0) }
    val pages = listOf(
        OnboardingPage("환영합니다", "앱을 시작해보세요"),
        OnboardingPage("쉬운 로그인", "간편하게 로그인하세요"),
        OnboardingPage("시작하기", "지금 바로 시작해보세요")
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(
            text = pages[currentPage].title,
            style = MaterialTheme.typography.headlineLarge,
            textAlign = TextAlign.Center
        )

        Spacer(modifier = Modifier.height(16.dp))

        Text(
            text = pages[currentPage].description,
            style = MaterialTheme.typography.bodyLarge,
            textAlign = TextAlign.Center,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )

        Spacer(modifier = Modifier.height(48.dp))

        // Page indicators
        Row(
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            repeat(pages.size) { index ->
                Box(
                    modifier = Modifier
                        .size(if (index == currentPage) 12.dp else 8.dp)
                ) {
                    Surface(
                        modifier = Modifier.fillMaxSize(),
                        shape = MaterialTheme.shapes.small,
                        color = if (index == currentPage)
                            MaterialTheme.colorScheme.primary
                        else
                            MaterialTheme.colorScheme.surfaceVariant
                    ) {}
                }
            }
        }

        Spacer(modifier = Modifier.height(48.dp))

        Button(
            onClick = {
                if (currentPage < pages.size - 1) {
                    currentPage++
                } else {
                    onComplete()
                }
            },
            modifier = Modifier.fillMaxWidth()
        ) {
            Text(
                text = if (currentPage < pages.size - 1) "다음" else "시작하기"
            )
        }

        if (currentPage < pages.size - 1) {
            TextButton(onClick = onComplete) {
                Text("건너뛰기")
            }
        }
    }
}

private data class OnboardingPage(
    val title: String,
    val description: String
)
