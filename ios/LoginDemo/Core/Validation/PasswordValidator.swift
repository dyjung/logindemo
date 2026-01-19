//
//  PasswordValidator.swift
//  LoginDemo
//
//  비밀번호 유효성 검사
//

import Foundation

/// 비밀번호 유효성 검사기
enum PasswordValidator {
    /// 비밀번호 최소 길이
    static let minimumLength = 8
    
    /// 비밀번호 유효성 검사
    /// - Parameter password: 검사할 비밀번호
    /// - Returns: 검사 결과
    static func validate(_ password: String) -> ValidationResult {
        // 빈 문자열은 유효 (선택적 입력)
        if password.isEmpty {
            return .valid
        }
        
        // 길이 검사
        if password.count < minimumLength {
            return .invalid("비밀번호는 \(minimumLength)자 이상이어야 합니다")
        }
        
        return .valid
    }
    
    /// 비밀번호 확인 검사
    /// - Parameters:
    ///   - password: 원본 비밀번호
    ///   - confirmation: 확인 비밀번호
    /// - Returns: 검사 결과
    static func validateConfirmation(password: String, confirmation: String) -> ValidationResult {
        // 빈 문자열은 유효 (선택적 입력)
        if confirmation.isEmpty {
            return .valid
        }
        
        // 일치 여부 검사
        if password != confirmation {
            return .invalid("비밀번호가 일치하지 않습니다")
        }
        
        return .valid
    }
}
