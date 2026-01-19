package com.dyjung.logindemo.domain.model

/**
 * 장소 엔티티
 * iOS의 Place 모델에 대응
 */
data class Place(
    val id: String,
    val name: String,
    val location: String,
    val rating: Double,
    val reviewCount: Int,
    val imageUrl: String? = null,
    val category: PlaceCategory = PlaceCategory.GENERAL
)

/**
 * 장소 카테고리
 */
enum class PlaceCategory {
    RESTAURANT,
    CAFE,
    ATTRACTION,
    HOTEL,
    GENERAL
}

/**
 * 추천 장소 (홈 화면용)
 */
data class RecommendedPlace(
    val place: Place,
    val recommendReason: String? = null
)
