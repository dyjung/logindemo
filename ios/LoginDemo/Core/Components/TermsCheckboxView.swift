//
//  TermsCheckboxView.swift
//  LoginDemo
//
//  약관 동의 체크박스 컴포넌트
//

import SwiftUI

/// 약관 동의 체크박스
struct TermsCheckboxView: View {
    // MARK: - Properties

    let title: String
    @Binding var isChecked: Bool
    let isRequired: Bool
    let onViewTerms: (() -> Void)?

    // MARK: - Initialization

    init(
        title: String,
        isChecked: Binding<Bool>,
        isRequired: Bool = true,
        onViewTerms: (() -> Void)? = nil
    ) {
        self.title = title
        self._isChecked = isChecked
        self.isRequired = isRequired
        self.onViewTerms = onViewTerms
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            // 체크박스
            Button(action: { isChecked.toggle() }) {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .foregroundColor(isChecked ? .primaryColor : .appTextSecondary)
                    .font(.title3)
            }
            .accessibilityLabel(isChecked ? "\(title) 동의됨" : "\(title) 동의 안됨")
            .accessibilityHint("탭하여 동의 상태 변경")
            .accessibilityAddTraits(.isButton)

            // 제목
            HStack(spacing: 4) {
                if isRequired {
                    Text("[필수]")
                        .font(.caption)
                        .foregroundColor(.primaryColor)
                }

                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.appTextPrimary)
            }

            Spacer()

            // 보기 버튼
            if let onViewTerms = onViewTerms {
                Button(action: onViewTerms) {
                    Text("보기")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
                .accessibilityLabel("\(title) 내용 보기")
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isChecked.toggle()
        }
    }
}

/// 전체 동의 체크박스
struct AllTermsCheckboxView: View {
    // MARK: - Properties

    @Binding var agreedToTerms: Bool
    @Binding var agreedToPrivacy: Bool

    private var isAllAgreed: Bool {
        agreedToTerms && agreedToPrivacy
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            // 전체 동의
            HStack(spacing: 12) {
                Button(action: toggleAll) {
                    Image(systemName: isAllAgreed ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isAllAgreed ? .primaryColor : .appTextSecondary)
                        .font(.title2)
                }
                .accessibilityLabel(isAllAgreed ? "전체 동의됨" : "전체 동의 안됨")
                .accessibilityHint("탭하여 전체 동의 상태 변경")

                Text("전체 동의")
                    .font(.headline)
                    .foregroundColor(.appTextPrimary)

                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                toggleAll()
            }

            Divider()

            // 개별 약관
            VStack(spacing: 12) {
                TermsCheckboxView(
                    title: "이용약관 동의",
                    isChecked: $agreedToTerms,
                    isRequired: true
                ) {
                    // TODO: 이용약관 상세 보기
                }

                TermsCheckboxView(
                    title: "개인정보처리방침 동의",
                    isChecked: $agreedToPrivacy,
                    isRequired: true
                ) {
                    // TODO: 개인정보처리방침 상세 보기
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - Private Methods

    private func toggleAll() {
        let newValue = !isAllAgreed
        agreedToTerms = newValue
        agreedToPrivacy = newValue
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        TermsCheckboxView(
            title: "이용약관 동의",
            isChecked: .constant(true),
            isRequired: true
        ) {}

        TermsCheckboxView(
            title: "마케팅 수신 동의",
            isChecked: .constant(false),
            isRequired: false
        ) {}

        AllTermsCheckboxView(
            agreedToTerms: .constant(true),
            agreedToPrivacy: .constant(false)
        )
    }
    .padding()
}
