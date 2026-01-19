//
//  SavedView.swift
//  LoginDemo
//
//  저장됨 탭 화면
//

import SwiftUI

/// 저장됨 탭 화면
struct SavedView: View {
    @State private var selectedSegment = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 세그먼트 컨트롤
                Picker("저장 유형 선택", selection: $selectedSegment) {
                    Text("장소").tag(0)
                    Text("여행").tag(1)
                    Text("컬렉션").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .accessibilityLabel("저장 유형 선택")

                // 콘텐츠
                switch selectedSegment {
                case 0:
                    savedPlacesView
                case 1:
                    savedTripsView
                default:
                    collectionsView
                }
            }
            .background(Color.backgroundColor)
            .navigationTitle("저장됨")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("새 항목 추가")
                }
            }
        }
    }

    private var savedPlacesView: some View {
        Group {
            if true { // 저장된 장소가 있는 경우
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(0..<8) { index in
                            SavedPlaceRow(index: index)
                        }
                    }
                    .padding(16)
                }
            } else {
                emptyStateView(
                    icon: "heart",
                    title: "저장된 장소가 없습니다",
                    subtitle: "마음에 드는 장소를 저장해보세요"
                )
            }
        }
    }

    private var savedTripsView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(0..<3) { index in
                    TripCard(index: index)
                }
            }
            .padding(16)
        }
    }

    private var collectionsView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(0..<6) { index in
                    CollectionCard(index: index)
                }
            }
            .padding(16)
        }
    }

    private func emptyStateView(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.appTextSecondary)
            Text(title)
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)
            Spacer()
        }
    }
}

// MARK: - Components

private struct SavedPlaceRow: View {
    let index: Int

    private var placeName: String { "저장된 장소 \(index + 1)" }
    private var location: String { "서울특별시 강남구" }
    private var rating: String { "4.\(7 - index % 5)" }

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.primaryColor.opacity(0.2))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "heart.fill")
                        .font(.title2)
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
                }
            }

            Spacer()

            Button(action: {}) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
            }
            .accessibilityLabel("저장 해제")
            .accessibilityHint("탭하여 저장 목록에서 제거")
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(placeName), \(location), 평점 \(rating)점")
    }
}

private struct TripCard: View {
    let index: Int

    private var tripName: String { "여행 계획 \(index + 1)" }
    private var tripDate: String { "2024년 \(index + 1)월 여행" }
    private var placeCount: Int { 3 + index }

    var body: some View {
        Button(action: {
            // 여행 상세 페이지로 이동 (향후 구현)
        }) {
            VStack(alignment: .leading, spacing: 12) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.primaryColor.opacity(0.3))
                    .frame(height: 150)
                    .overlay(
                        Image(systemName: "airplane")
                            .font(.largeTitle)
                            .foregroundColor(.primaryColor)
                    )
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(tripName)
                        .font(.headline)
                        .foregroundColor(.appTextPrimary)

                    Text(tripDate)
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)

                    HStack {
                        Image(systemName: "mappin")
                            .font(.caption)
                            .accessibilityHidden(true)
                        Text("\(placeCount)개 장소")
                            .font(.caption)
                    }
                    .foregroundColor(.appTextSecondary)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(tripName), \(tripDate), \(placeCount)개 장소 포함")
        .accessibilityHint("탭하여 여행 상세 보기")
    }
}

private struct CollectionCard: View {
    let index: Int

    private var collectionName: String { "컬렉션 \(index + 1)" }
    private var itemCount: Int { 5 + index }

    var body: some View {
        Button(action: {
            // 컬렉션 상세 페이지로 이동 (향후 구현)
        }) {
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.primaryColor.opacity(0.2 + Double(index) * 0.1))
                    .frame(height: 100)
                    .overlay(
                        Image(systemName: "folder.fill")
                            .font(.title)
                            .foregroundColor(.primaryColor)
                    )
                    .accessibilityHidden(true)

                Text(collectionName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.appTextPrimary)

                Text("\(itemCount)개 항목")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(collectionName), \(itemCount)개 항목")
        .accessibilityHint("탭하여 컬렉션 보기")
    }
}

#Preview {
    SavedView()
}
