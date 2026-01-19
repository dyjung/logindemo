//
//  SearchView.swift
//  LoginDemo
//
//  검색 탭 화면
//

import SwiftUI

/// 검색 탭 화면
struct SearchView: View {
    @State private var searchText: String = ""
    @State private var selectedCategory: SearchCategory = .all

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 검색 바
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.appTextSecondary)
                        .accessibilityHidden(true)

                    TextField("장소, 레스토랑, 호텔 검색...", text: $searchText)
                        .textFieldStyle(.plain)
                        .accessibilityLabel("검색")
                        .accessibilityHint("장소, 레스토랑, 호텔을 검색합니다")

                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.appTextSecondary)
                        }
                        .accessibilityLabel("검색어 지우기")
                    }
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // 카테고리 필터
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(SearchCategory.allCases, id: \.self) { category in
                            CategoryChip(
                                title: category.title,
                                icon: category.icon,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }

                // 검색 결과 또는 최근 검색
                if searchText.isEmpty {
                    recentSearchesView
                } else {
                    searchResultsView
                }
            }
            .background(Color.backgroundColor)
            .navigationTitle("검색")
        }
    }

    private var recentSearchesView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("최근 검색")
                    .font(.headline)
                    .foregroundColor(.appTextPrimary)
                Spacer()
                Button("모두 지우기") {
                    // 최근 검색 삭제
                }
                .font(.subheadline)
                .foregroundColor(.primaryColor)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            ForEach(0..<5) { index in
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.appTextSecondary)
                    Text("최근 검색어 \(index + 1)")
                        .foregroundColor(.appTextPrimary)
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "xmark")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }

            Spacer()
        }
    }

    private var searchResultsView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(0..<10) { index in
                    SearchResultRow(index: index, searchText: searchText)
                }
            }
            .padding(16)
        }
    }
}

// MARK: - Search Category

private enum SearchCategory: CaseIterable {
    case all, restaurants, hotels, attractions, activities

    var title: String {
        switch self {
        case .all: return "전체"
        case .restaurants: return "레스토랑"
        case .hotels: return "호텔"
        case .attractions: return "명소"
        case .activities: return "즐길거리"
        }
    }

    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .restaurants: return "fork.knife"
        case .hotels: return "bed.double"
        case .attractions: return "camera"
        case .activities: return "figure.hiking"
        }
    }
}

// MARK: - Components

private struct CategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .accessibilityHidden(true)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.primaryColor : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .appTextPrimary)
            .cornerRadius(20)
        }
        .accessibilityLabel("\(title) 카테고리")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        .accessibilityHint(isSelected ? "현재 선택됨" : "탭하여 선택")
    }
}

private struct SearchResultRow: View {
    let index: Int
    let searchText: String

    private var resultTitle: String { "\(searchText) 관련 결과 \(index + 1)" }

    var body: some View {
        Button(action: {
            // 상세 페이지로 이동 (향후 구현)
        }) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.primaryColor.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.primaryColor)
                    )
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(resultTitle)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.appTextPrimary)

                    Text("검색 결과 설명")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.appTextSecondary)
                    .font(.caption)
                    .accessibilityHidden(true)
            }
            .padding(12)
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(resultTitle)
        .accessibilityHint("탭하여 상세 정보 보기")
    }
}

#Preview {
    SearchView()
}
