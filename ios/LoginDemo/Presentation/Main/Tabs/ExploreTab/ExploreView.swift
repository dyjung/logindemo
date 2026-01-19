//
//  ExploreView.swift
//  LoginDemo
//
//  탐색 탭 화면
//

import SwiftUI

/// 탐색 탭 화면
struct ExploreView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 추천 섹션
                    VStack(alignment: .leading, spacing: 12) {
                        Text("오늘의 추천")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.appTextPrimary)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(0..<5) { index in
                                    RecommendationCard(index: index)
                                }
                            }
                        }
                    }

                    // 인기 장소 섹션
                    VStack(alignment: .leading, spacing: 12) {
                        Text("인기 장소")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.appTextPrimary)

                        LazyVStack(spacing: 12) {
                            ForEach(0..<10) { index in
                                PlaceRow(index: index)
                            }
                        }
                    }
                }
                .padding(16)
            }
            .background(Color.backgroundColor)
            .navigationTitle("탐색")
        }
    }
}

// MARK: - Components

private struct RecommendationCard: View {
    let index: Int

    private var placeName: String { "추천 장소 \(index + 1)" }
    private var rating: String { "4.\(5 - index % 5)" }
    private var reviewCount: Int { 100 + index * 50 }

    var body: some View {
        Button(action: {
            // 상세 페이지로 이동 (향후 구현)
        }) {
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.primaryColor.opacity(0.3))
                    .frame(width: 200, height: 120)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.primaryColor)
                    )
                    .accessibilityHidden(true)

                Text(placeName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.appTextPrimary)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                        .accessibilityHidden(true)
                    Text(rating)
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                    Text("(\(reviewCount))")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
            }
            .frame(width: 200)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(placeName), 평점 \(rating)점, 리뷰 \(reviewCount)개")
        .accessibilityHint("탭하여 상세 정보 보기")
    }
}

private struct PlaceRow: View {
    let index: Int

    private var placeName: String { "인기 장소 \(index + 1)" }
    private var location: String { "서울특별시" }
    private var rating: String { "4.\(8 - index % 5)" }
    private var reviewCount: Int { 200 + index * 30 }

    var body: some View {
        Button(action: {
            // 상세 페이지로 이동 (향후 구현)
        }) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.primaryColor.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundColor(.primaryColor)
                    )
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(placeName)
                        .font(.headline)
                        .foregroundColor(.appTextPrimary)

                    Text(location)
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                            .accessibilityHidden(true)
                        Text(rating)
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                        Text("• 리뷰 \(reviewCount)개")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.appTextSecondary)
                    .accessibilityHidden(true)
            }
            .padding(12)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(placeName), \(location), 평점 \(rating)점, 리뷰 \(reviewCount)개")
        .accessibilityHint("탭하여 상세 정보 보기")
    }
}

#Preview {
    ExploreView()
}
