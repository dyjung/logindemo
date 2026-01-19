//
//  SecureTextField.swift
//  LoginDemo
//
//  비밀번호 입력 필드 컴포넌트 (보기/숨기기 토글)
//

import SwiftUI

/// 비밀번호 입력 필드 (보기/숨기기 토글 지원)
struct SecureTextField: View {
    // MARK: - Properties

    let placeholder: String
    @Binding var text: String
    @State private var isSecure: Bool = true
    let errorMessage: String?

    // MARK: - Initialization

    init(
        _ placeholder: String,
        text: Binding<String>,
        errorMessage: String? = nil
    ) {
        self.placeholder = placeholder
        self._text = text
        self.errorMessage = errorMessage
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Group {
                    if isSecure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .textContentType(.password)
                .autocapitalization(.none)
                .disableAutocorrection(true)

                Button(action: { isSecure.toggle() }) {
                    Image(systemName: isSecure ? "eye.slash" : "eye")
                        .foregroundColor(.appTextSecondary)
                }
                .accessibilityLabel(isSecure ? "비밀번호 보기" : "비밀번호 숨기기")
                .accessibilityHint("탭하여 비밀번호 표시 전환")
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(errorMessage != nil ? Color.errorColor : Color.clear, lineWidth: 1)
            )

            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.errorColor)
                    .accessibilityLabel("오류: \(error)")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(placeholder) 입력 필드")
        .accessibilityValue(text.isEmpty ? "비어 있음" : "입력됨")
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        SecureTextField("비밀번호", text: .constant(""))
        SecureTextField("비밀번호", text: .constant("password123"))
        SecureTextField("비밀번호", text: .constant("short"), errorMessage: "비밀번호는 8자 이상이어야 합니다")
    }
    .padding()
}
