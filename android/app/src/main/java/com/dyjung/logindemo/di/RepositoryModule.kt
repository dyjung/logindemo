package com.dyjung.logindemo.di

import com.dyjung.logindemo.data.repository.AuthRepositoryImpl
import com.dyjung.logindemo.data.repository.MockPlaceRepository
import com.dyjung.logindemo.data.repository.OnboardingRepositoryImpl
import com.dyjung.logindemo.domain.repository.AuthRepository
import com.dyjung.logindemo.domain.repository.OnboardingRepository
import com.dyjung.logindemo.domain.repository.PlaceRepository
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

/**
 * Repository DI 모듈
 * iOS의 DIContainer.makeProduction()에 대응
 *
 * 서버 연동 시 Mock 구현체를 Real 구현체로 교체:
 * - MockPlaceRepository -> RealPlaceRepository
 */
@Module
@InstallIn(SingletonComponent::class)
abstract class RepositoryModule {

    @Binds
    @Singleton
    abstract fun bindAuthRepository(
        impl: AuthRepositoryImpl
    ): AuthRepository

    @Binds
    @Singleton
    abstract fun bindOnboardingRepository(
        impl: OnboardingRepositoryImpl
    ): OnboardingRepository

    /**
     * PlaceRepository 바인딩
     * 현재: MockPlaceRepository (더미 데이터)
     * 서버 연동 후: RealPlaceRepository로 교체
     */
    @Binds
    @Singleton
    abstract fun bindPlaceRepository(
        impl: MockPlaceRepository
    ): PlaceRepository
}
