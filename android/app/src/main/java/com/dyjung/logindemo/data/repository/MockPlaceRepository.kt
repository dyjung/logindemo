package com.dyjung.logindemo.data.repository

import com.dyjung.logindemo.domain.model.Place
import com.dyjung.logindemo.domain.model.PlaceCategory
import com.dyjung.logindemo.domain.model.RecommendedPlace
import com.dyjung.logindemo.domain.repository.PlaceRepository
import kotlinx.coroutines.delay
import javax.inject.Inject

/**
 * Mock PlaceRepository 구현체
 * 실제 서버 연동 전 더미 데이터 제공
 * 서버 구현 완료 시 RealPlaceRepository로 교체
 */
class MockPlaceRepository @Inject constructor() : PlaceRepository {

    // 더미 추천 장소 데이터
    private val mockRecommendedPlaces = (0 until 5).map { index ->
        RecommendedPlace(
            place = Place(
                id = "rec_$index",
                name = "추천 장소 ${index + 1}",
                location = "서울특별시",
                rating = 4.5 - (index % 5) * 0.1,
                reviewCount = 100 + index * 50,
                category = PlaceCategory.entries[index % PlaceCategory.entries.size]
            ),
            recommendReason = when (index) {
                0 -> "오늘의 인기 장소"
                1 -> "높은 평점"
                2 -> "최근 핫플레이스"
                3 -> "주변 추천"
                else -> "에디터 추천"
            }
        )
    }

    // 더미 인기 장소 데이터
    private val mockPopularPlaces = (0 until 10).map { index ->
        Place(
            id = "pop_$index",
            name = "인기 장소 ${index + 1}",
            location = when (index % 4) {
                0 -> "서울특별시 강남구"
                1 -> "서울특별시 마포구"
                2 -> "서울특별시 종로구"
                else -> "서울특별시 용산구"
            },
            rating = 4.8 - (index % 5) * 0.1,
            reviewCount = 200 + index * 30,
            category = PlaceCategory.entries[index % PlaceCategory.entries.size]
        )
    }

    override suspend fun getRecommendedPlaces(): Result<List<RecommendedPlace>> {
        // 네트워크 지연 시뮬레이션
        delay(500)
        return Result.success(mockRecommendedPlaces)
    }

    override suspend fun getPopularPlaces(): Result<List<Place>> {
        // 네트워크 지연 시뮬레이션
        delay(300)
        return Result.success(mockPopularPlaces)
    }

    override suspend fun getPlaceDetail(placeId: String): Result<Place> {
        delay(200)

        val place = mockPopularPlaces.find { it.id == placeId }
            ?: mockRecommendedPlaces.find { it.place.id == placeId }?.place

        return if (place != null) {
            Result.success(place)
        } else {
            Result.failure(NoSuchElementException("Place not found: $placeId"))
        }
    }

    override suspend fun searchPlaces(query: String): Result<List<Place>> {
        delay(300)

        val results = mockPopularPlaces.filter {
            it.name.contains(query, ignoreCase = true) ||
            it.location.contains(query, ignoreCase = true)
        }

        return Result.success(results)
    }
}
