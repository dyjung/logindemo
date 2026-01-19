//
//  NameValidator.swift
//  LoginDemo
//
//  이름 유효성 검사
//

import Foundation

/// 이름 유효성 검사기
enum NameValidator {
    /// 이름 유효성 검사
    /// - Parameter name: 검사할 이름
    /// - Returns: 검사 결과
    static func validate(_ name: String) -> ValidationResult {
        // 빈 문자열은 유효 (선택적 입력)
        if name.isEmpty {
            return .valid
        }
        
        // 공백만 있는지 검사
        if !name.isValidName {
            return .invalid("이름을 입력해주세요")
        }
        
        return .valid
    }
}
