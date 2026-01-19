//
//  ValidationResult.swift
//  LoginDemo
//
//  Validation 결과를 나타내는 타입
//

import Foundation

/// Validation 결과
enum ValidationResult: Equatable {
    /// 유효한 입력
    case valid
    
    /// 유효하지 않은 입력
    case invalid(String)
    
    /// 유효성 여부
    var isValid: Bool {
        switch self {
        case .valid:
            return true
        case .invalid:
            return false
        }
    }
    
    /// 에러 메시지 (유효하지 않은 경우에만)
    var errorMessage: String? {
        switch self {
        case .valid:
            return nil
        case .invalid(let message):
            return message
        }
    }
}
