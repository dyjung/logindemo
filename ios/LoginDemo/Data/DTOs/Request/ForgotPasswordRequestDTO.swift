//
//  ForgotPasswordRequestDTO.swift
//  LoginDemo
//
//  비밀번호 재설정 요청 DTO
//

import Foundation

/// 비밀번호 재설정 요청 DTO
struct ForgotPasswordRequestDTO: Encodable {
    /// 이메일 주소
    let email: String
}
