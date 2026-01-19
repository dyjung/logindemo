package com.dyjung.logindemo.presentation.main

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.LocationOn
import androidx.compose.material.icons.filled.Star
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.dyjung.logindemo.domain.model.Place
import com.dyjung.logindemo.domain.model.PlaceCategory
import com.dyjung.logindemo.domain.model.RecommendedPlace
import com.dyjung.logindemo.presentation.theme.AppColors

/**
 * 탐색 화면
 * iOS의 ExploreView에 대응
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ExploreScreen(
    viewModel: ExploreViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("탐색") },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = AppColors.BackgroundLight
                )
            )
        },
        containerColor = AppColors.BackgroundLight
    ) { paddingValues ->
        if (uiState.isLoading && uiState.recommendedPlaces.isEmpty()) {
            // 로딩 상태
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(paddingValues),
                contentAlignment = Alignment.Center
            ) {
                CircularProgressIndicator(color = AppColors.Primary)
            }
        } else {
            LazyColumn(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(paddingValues),
                contentPadding = PaddingValues(16.dp),
                verticalArrangement = Arrangement.spacedBy(24.dp)
            ) {
                // 오늘의 추천 섹션
                item {
                    RecommendedSection(
                        places = uiState.recommendedPlaces,
                        onPlaceClick = { /* 상세 페이지 이동 */ }
                    )
                }

                // 인기 장소 섹션 헤더
                item {
                    Text(
                        text = "인기 장소",
                        style = MaterialTheme.typography.titleLarge,
                        fontWeight = FontWeight.Bold,
                        color = AppColors.TextPrimary
                    )
                }

                // 인기 장소 목록
                items(uiState.popularPlaces) { place ->
                    PlaceRow(
                        place = place,
                        onClick = { /* 상세 페이지 이동 */ }
                    )
                }
            }
        }
    }
}

/**
 * 오늘의 추천 섹션
 */
@Composable
private fun RecommendedSection(
    places: List<RecommendedPlace>,
    onPlaceClick: (RecommendedPlace) -> Unit
) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Text(
            text = "오늘의 추천",
            style = MaterialTheme.typography.titleLarge,
            fontWeight = FontWeight.Bold,
            color = AppColors.TextPrimary
        )

        LazyRow(
            horizontalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            items(places) { recommendedPlace ->
                RecommendationCard(
                    recommendedPlace = recommendedPlace,
                    onClick = { onPlaceClick(recommendedPlace) }
                )
            }
        }
    }
}

/**
 * 추천 장소 카드
 * iOS의 RecommendationCard에 대응
 */
@Composable
private fun RecommendationCard(
    recommendedPlace: RecommendedPlace,
    onClick: () -> Unit
) {
    val place = recommendedPlace.place

    Column(
        modifier = Modifier
            .width(200.dp)
            .clickable(onClick = onClick)
            .semantics {
                contentDescription = "${place.name}, 평점 ${place.rating}점, 리뷰 ${place.reviewCount}개"
            },
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        // 이미지 플레이스홀더
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(120.dp)
                .clip(RoundedCornerShape(12.dp))
                .background(AppColors.Primary.copy(alpha = 0.3f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = Icons.Default.LocationOn,
                contentDescription = null,
                modifier = Modifier.size(48.dp),
                tint = AppColors.Primary
            )
        }

        // 장소 이름
        Text(
            text = place.name,
            style = MaterialTheme.typography.titleSmall,
            fontWeight = FontWeight.SemiBold,
            color = AppColors.TextPrimary
        )

        // 평점 및 리뷰
        Row(
            horizontalArrangement = Arrangement.spacedBy(4.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = Icons.Default.Star,
                contentDescription = null,
                modifier = Modifier.size(14.dp),
                tint = Color(0xFFFFCC00)
            )
            Text(
                text = String.format("%.1f", place.rating),
                style = MaterialTheme.typography.bodySmall,
                color = AppColors.TextSecondary
            )
            Text(
                text = "(${place.reviewCount})",
                style = MaterialTheme.typography.bodySmall,
                color = AppColors.TextSecondary
            )
        }
    }
}

/**
 * 장소 행
 * iOS의 PlaceRow에 대응
 */
@Composable
private fun PlaceRow(
    place: Place,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .semantics {
                contentDescription = "${place.name}, ${place.location}, 평점 ${place.rating}점, 리뷰 ${place.reviewCount}개"
            },
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // 썸네일
            Box(
                modifier = Modifier
                    .size(80.dp)
                    .clip(RoundedCornerShape(8.dp))
                    .background(AppColors.Primary.copy(alpha = 0.2f)),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.LocationOn,
                    contentDescription = null,
                    modifier = Modifier.size(32.dp),
                    tint = AppColors.Primary
                )
            }

            Spacer(modifier = Modifier.width(12.dp))

            // 장소 정보
            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                Text(
                    text = place.name,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold,
                    color = AppColors.TextPrimary
                )

                Text(
                    text = place.location,
                    style = MaterialTheme.typography.bodyMedium,
                    color = AppColors.TextSecondary
                )

                Row(
                    horizontalArrangement = Arrangement.spacedBy(4.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        imageVector = Icons.Default.Star,
                        contentDescription = null,
                        modifier = Modifier.size(14.dp),
                        tint = Color(0xFFFFCC00)
                    )
                    Text(
                        text = String.format("%.1f", place.rating),
                        style = MaterialTheme.typography.bodySmall,
                        color = AppColors.TextSecondary
                    )
                    Text(
                        text = "• 리뷰 ${place.reviewCount}개",
                        style = MaterialTheme.typography.bodySmall,
                        color = AppColors.TextSecondary
                    )
                }
            }

            // 화살표
            Icon(
                imageVector = Icons.AutoMirrored.Filled.KeyboardArrowRight,
                contentDescription = null,
                tint = AppColors.TextSecondary
            )
        }
    }
}

// MARK: - Preview

@Preview(showBackground = true)
@Composable
private fun RecommendationCardPreview() {
    MaterialTheme {
        RecommendationCard(
            recommendedPlace = RecommendedPlace(
                place = Place(
                    id = "1",
                    name = "추천 장소 1",
                    location = "서울특별시",
                    rating = 4.5,
                    reviewCount = 100,
                    category = PlaceCategory.RESTAURANT
                ),
                recommendReason = "오늘의 인기 장소"
            ),
            onClick = {}
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun PlaceRowPreview() {
    MaterialTheme {
        PlaceRow(
            place = Place(
                id = "1",
                name = "인기 장소 1",
                location = "서울특별시 강남구",
                rating = 4.8,
                reviewCount = 200,
                category = PlaceCategory.CAFE
            ),
            onClick = {}
        )
    }
}
