//
//  View+Keyboard.swift
//  LoginDemo
//
//  키보드 관련 View 확장
//

import SwiftUI

extension View {
    /// 탭 제스처로 키보드 닫기
    func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
    }

    /// 키보드 닫기 버튼 추가 (툴바)
    func keyboardDismissButton() -> some View {
        self.toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("완료") {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                }
            }
        }
    }
}
