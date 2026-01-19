//
//  Color+Theme.swift
//  LoginDemo
//
//  테마 색상 확장
//
//  Note: Xcode 자동 생성 색상 심볼과 충돌을 방지하기 위해
//  Asset Catalog의 색상과 다른 이름을 사용합니다.
//

import SwiftUI

extension Color {
    /// 기본 브랜드 색상
    static let primaryColor = Color("PrimaryColor")

    /// 배경 색상
    static let backgroundColor = Color("BackgroundColor")

    /// 기본 텍스트 색상
    /// - Note: Asset Catalog의 TextPrimary와 구분하기 위해 appTextPrimary 사용
    static let appTextPrimary = Color("TextPrimary")

    /// 보조 텍스트 색상
    /// - Note: Asset Catalog의 TextSecondary와 구분하기 위해 appTextSecondary 사용
    static let appTextSecondary = Color("TextSecondary")

    /// 에러 색상
    static let errorColor = Color("ErrorColor")

    /// 카카오 로그인 버튼 색상
    static let kakaoYellow = Color(red: 254/255, green: 229/255, blue: 0/255)

    /// 네이버 로그인 버튼 색상
    static let naverGreen = Color(red: 3/255, green: 199/255, blue: 90/255)
}
