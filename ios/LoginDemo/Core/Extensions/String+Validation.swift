//
//  String+Validation.swift
//  LoginDemo
//
//  문자열 유효성 검사 확장
//

import Foundation

extension String {
    /// 이메일 형식 유효성 검사
    /// RFC 5322 기반 이메일 패턴 검증
    var isValidEmail: Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return range(of: pattern, options: .regularExpression) != nil
    }

    /// 비밀번호 유효성 검사 (최소 8자)
    var isValidPassword: Bool {
        count >= 8
    }

    /// 이름 유효성 검사 (공백이 아닌 문자 존재)
    var isValidName: Bool {
        !trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// 공백 제거 후 비어있는지 확인
    var isBlank: Bool {
        trimmingCharacters(in: .whitespaces).isEmpty
    }
}
