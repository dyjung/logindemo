package com.dyjung.logindemo.presentation.onboarding

import androidx.compose.animation.animateColorAsState
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.dyjung.logindemo.domain.model.OnboardingPage
import com.dyjung.logindemo.presentation.components.PrimaryButton
import com.dyjung.logindemo.presentation.theme.AppColors

/**
 * 온보딩 화면
 * iOS의 OnboardingView에 대응
 */
@OptIn(ExperimentalFoundationApi::class)
@Composable
fun OnboardingScreen(
    onComplete: () -> Unit,
    viewModel: OnboardingViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val pages = viewModel.pages
    val pagerState = rememberPagerState(pageCount = { pages.size })

    // 페이지 변경 시 ViewModel 업데이트
    LaunchedEffect(pagerState.currentPage) {
        viewModel.setCurrentPage(pagerState.currentPage)
    }

    val isLastPage = pagerState.currentPage == pages.size - 1

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(AppColors.BackgroundLight)
    ) {
        // 건너뛰기 버튼
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp)
        ) {
            if (!isLastPage) {
                TextButton(
                    onClick = { viewModel.skipOnboarding(onComplete) },
                    modifier = Modifier.align(Alignment.CenterEnd)
                ) {
                    Text(
                        text = "건너뛰기",
                        color = AppColors.TextSecondary
                    )
                }
            }
        }

        // 페이지 콘텐츠
        HorizontalPager(
            state = pagerState,
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth()
        ) { page ->
            OnboardingPageContent(page = pages[page])
        }

        // 페이지 인디케이터
        PageIndicator(
            pageCount = pages.size,
            currentPage = pagerState.currentPage,
            modifier = Modifier.padding(vertical = 24.dp)
        )

        // 버튼
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 24.dp)
                .padding(bottom = 32.dp)
        ) {
            if (isLastPage) {
                PrimaryButton(
                    text = "시작하기",
                    onClick = { viewModel.completeOnboarding(onComplete) }
                )
            } else {
                TextButton(
                    onClick = {
                        viewModel.nextPage()
                    },
                    modifier = Modifier.align(Alignment.Center)
                ) {
                    Text(
                        text = "다음",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.SemiBold,
                        color = AppColors.Primary
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Icon(
                        imageVector = Icons.AutoMirrored.Filled.ArrowForward,
                        contentDescription = null,
                        tint = AppColors.Primary
                    )
                }
            }
        }
    }

    // 페이지 전환 효과
    LaunchedEffect(uiState.currentPage) {
        if (uiState.currentPage != pagerState.currentPage) {
            pagerState.animateScrollToPage(uiState.currentPage)
        }
    }
}

@Composable
private fun OnboardingPageContent(page: OnboardingPage) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 32.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        // 이미지 플레이스홀더 (실제 앱에서는 이미지 리소스 사용)
        Box(
            modifier = Modifier
                .size(200.dp)
                .clip(CircleShape)
                .background(AppColors.Primary.copy(alpha = 0.1f)),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = "${page.id + 1}",
                style = MaterialTheme.typography.displayLarge,
                color = AppColors.Primary,
                fontWeight = FontWeight.Bold
            )
        }

        Spacer(modifier = Modifier.height(48.dp))

        Text(
            text = page.title,
            style = MaterialTheme.typography.headlineMedium,
            fontWeight = FontWeight.Bold,
            textAlign = TextAlign.Center,
            color = AppColors.TextPrimary
        )

        Spacer(modifier = Modifier.height(16.dp))

        Text(
            text = page.description,
            style = MaterialTheme.typography.bodyLarge,
            textAlign = TextAlign.Center,
            color = AppColors.TextSecondary,
            lineHeight = MaterialTheme.typography.bodyLarge.lineHeight * 1.5
        )
    }
}

@Composable
private fun PageIndicator(
    pageCount: Int,
    currentPage: Int,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.Center
    ) {
        repeat(pageCount) { index ->
            val color by animateColorAsState(
                targetValue = if (index == currentPage)
                    AppColors.Primary
                else
                    Color.Gray.copy(alpha = 0.3f),
                label = "indicator_color"
            )

            Box(
                modifier = Modifier
                    .padding(horizontal = 4.dp)
                    .size(8.dp)
                    .clip(CircleShape)
                    .background(color)
            )
        }
    }
}

// MARK: - Preview

@Preview(showBackground = true, showSystemUi = true)
@Composable
private fun OnboardingScreenPreview() {
    MaterialTheme {
        OnboardingScreenContent(
            pages = OnboardingPage.defaultPages,
            currentPage = 0,
            onSkip = {},
            onNext = {},
            onComplete = {}
        )
    }
}

@Composable
private fun OnboardingScreenContent(
    pages: List<OnboardingPage>,
    currentPage: Int,
    onSkip: () -> Unit,
    onNext: () -> Unit,
    onComplete: () -> Unit
) {
    val isLastPage = currentPage == pages.size - 1

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(AppColors.BackgroundLight)
    ) {
        // 건너뛰기 버튼
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp)
        ) {
            if (!isLastPage) {
                TextButton(
                    onClick = onSkip,
                    modifier = Modifier.align(Alignment.CenterEnd)
                ) {
                    Text(
                        text = "건너뛰기",
                        color = AppColors.TextSecondary
                    )
                }
            }
        }

        // 페이지 콘텐츠
        Box(
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth()
        ) {
            OnboardingPageContent(page = pages[currentPage])
        }

        // 페이지 인디케이터
        PageIndicator(
            pageCount = pages.size,
            currentPage = currentPage,
            modifier = Modifier.padding(vertical = 24.dp)
        )

        // 버튼
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 24.dp)
                .padding(bottom = 32.dp)
        ) {
            if (isLastPage) {
                PrimaryButton(
                    text = "시작하기",
                    onClick = onComplete
                )
            } else {
                TextButton(
                    onClick = onNext,
                    modifier = Modifier.align(Alignment.Center)
                ) {
                    Text(
                        text = "다음",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.SemiBold,
                        color = AppColors.Primary
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Icon(
                        imageVector = Icons.AutoMirrored.Filled.ArrowForward,
                        contentDescription = null,
                        tint = AppColors.Primary
                    )
                }
            }
        }
    }
}
