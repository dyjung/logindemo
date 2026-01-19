//
//  EmailValidator.swift
//  LoginDemo
//
//  이메일 유효성 검사
//

import Foundation

/// 이메일 유효성 검사기
enum EmailValidator {
    /// 이메일 유효성 검사
    /// - Parameter email: 검사할 이메일
    /// - Returns: 검사 결과
    static func validate(_ email: String) -> ValidationResult {
        // 빈 문자열은 유효 (선택적 입력)
        if email.isEmpty {
            return .valid
        }
        
        // 이메일 형식 검사
        if !email.isValidEmail {
            return .invalid("올바른 이메일 형식이 아닙니다")
        }
        
        return .valid
    }
}
