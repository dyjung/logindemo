package com.dyjung.logindemo.domain.repository

/**
 * 온보딩 관련 Repository 인터페이스
 */
interface OnboardingRepository {
    /**
     * 온보딩 완료 여부 확인
     * @return 온보딩 완료 여부
     */
    fun hasCompletedOnboarding(): Boolean

    /**
     * 온보딩 완료 처리
     */
    fun completeOnboarding()

    /**
     * 첫 실행 여부 확인
     * @return 첫 실행 여부
     */
    fun isFirstLaunch(): Boolean

    /**
     * 첫 실행 표시 완료
     */
    fun markFirstLaunchComplete()
}
