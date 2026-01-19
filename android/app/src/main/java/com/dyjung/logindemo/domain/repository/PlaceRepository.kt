package com.dyjung.logindemo.domain.repository

import com.dyjung.logindemo.domain.model.Place
import com.dyjung.logindemo.domain.model.RecommendedPlace

/**
 * 장소 Repository 인터페이스
 * DI를 통해 Mock/Real 구현체로 교체 가능
 */
interface PlaceRepository {
    /**
     * 오늘의 추천 장소 목록 가져오기
     */
    suspend fun getRecommendedPlaces(): Result<List<RecommendedPlace>>

    /**
     * 인기 장소 목록 가져오기
     */
    suspend fun getPopularPlaces(): Result<List<Place>>

    /**
     * 장소 상세 정보 가져오기
     */
    suspend fun getPlaceDetail(placeId: String): Result<Place>

    /**
     * 장소 검색
     */
    suspend fun searchPlaces(query: String): Result<List<Place>>
}
