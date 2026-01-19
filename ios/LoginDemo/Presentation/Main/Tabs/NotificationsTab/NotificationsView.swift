//
//  NotificationsView.swift
//  LoginDemo
//
//  알림 탭 화면
//

import SwiftUI

/// 알림 탭 화면
struct NotificationsView: View {
    @State private var notifications: [NotificationItem] = NotificationItem.samples

    var body: some View {
        NavigationStack {
            Group {
                if notifications.isEmpty {
                    emptyStateView
                } else {
                    notificationsList
                }
            }
            .background(Color.backgroundColor)
            .navigationTitle("알림")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("모두 읽음") {
                        markAllAsRead()
                    }
                    .font(.subheadline)
                    .accessibilityLabel("모든 알림 읽음 처리")
                    .accessibilityHint("탭하여 모든 알림을 읽음으로 표시")
                }
            }
        }
    }

    private var notificationsList: some View {
        List {
            ForEach(notifications) { notification in
                NotificationRow(notification: notification)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(
                        notification.isRead ? Color.clear : Color.primaryColor.opacity(0.05)
                    )
            }
            .onDelete(perform: deleteNotification)
        }
        .listStyle(.plain)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "bell.slash")
                .font(.system(size: 60))
                .foregroundColor(.appTextSecondary)
            Text("알림이 없습니다")
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            Text("새로운 소식이 있으면 알려드릴게요")
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)
            Spacer()
        }
    }

    private func markAllAsRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
    }

    private func deleteNotification(at offsets: IndexSet) {
        notifications.remove(atOffsets: offsets)
    }
}

// MARK: - Notification Model

private struct NotificationItem: Identifiable {
    let id = UUID()
    let type: NotificationType
    let title: String
    let message: String
    let timeAgo: String
    var isRead: Bool

    enum NotificationType {
        case review, recommendation, trip, promo

        var icon: String {
            switch self {
            case .review: return "star.fill"
            case .recommendation: return "heart.fill"
            case .trip: return "airplane"
            case .promo: return "tag.fill"
            }
        }

        var color: Color {
            switch self {
            case .review: return .yellow
            case .recommendation: return .red
            case .trip: return .blue
            case .promo: return .green
            }
        }
    }

    static var samples: [NotificationItem] {
        [
            NotificationItem(
                type: .review,
                title: "리뷰 감사합니다!",
                message: "작성하신 리뷰가 도움이 되고 있어요",
                timeAgo: "10분 전",
                isRead: false
            ),
            NotificationItem(
                type: .recommendation,
                title: "새로운 추천",
                message: "근처에 인기 있는 레스토랑을 발견했어요",
                timeAgo: "1시간 전",
                isRead: false
            ),
            NotificationItem(
                type: .trip,
                title: "여행 리마인더",
                message: "다음 주 서울 여행 준비되셨나요?",
                timeAgo: "3시간 전",
                isRead: true
            ),
            NotificationItem(
                type: .promo,
                title: "특별 할인",
                message: "호텔 예약 20% 할인 쿠폰이 도착했어요",
                timeAgo: "1일 전",
                isRead: true
            ),
            NotificationItem(
                type: .review,
                title: "리뷰 응답",
                message: "업체에서 리뷰에 답변을 남겼어요",
                timeAgo: "2일 전",
                isRead: true
            )
        ]
    }
}

// MARK: - Components

private struct NotificationRow: View {
    let notification: NotificationItem

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(notification.type.color.opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: notification.type.icon)
                        .foregroundColor(notification.type.color)
                )
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(notification.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.appTextPrimary)

                    Spacer()

                    Text(notification.timeAgo)
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }

                Text(notification.message)
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
                    .lineLimit(2)
            }

            if !notification.isRead {
                Circle()
                    .fill(Color.primaryColor)
                    .frame(width: 8, height: 8)
                    .accessibilityHidden(true)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(notification.title), \(notification.message), \(notification.timeAgo)")
        .accessibilityValue(notification.isRead ? "읽음" : "읽지 않음")
        .accessibilityHint("스와이프하여 삭제")
    }
}

#Preview {
    NotificationsView()
}
