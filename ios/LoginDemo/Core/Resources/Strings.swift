//
//  Strings.swift
//  LoginDemo
//
//  문자열 리소스 키 관리
//

import Foundation

/// 앱에서 사용하는 문자열 리소스 키
enum Strings {
    // MARK: - Error Messages
    
    enum Error {
        static let invalidEmail = "error.invalid_email"
        static let invalidPassword = "error.invalid_password"
        static let passwordMismatch = "error.password_mismatch"
        static let invalidName = "error.invalid_name"
        static let emailAlreadyExists = "error.email_already_exists"
    }
    
    // MARK: - Auth
    
    enum Auth {
        static let login = "auth.login"
        static let register = "auth.register"
        static let logout = "auth.logout"
        static let email = "auth.email"
        static let password = "auth.password"
        static let passwordConfirm = "auth.password_confirm"
        static let name = "auth.name"
        static let autoLogin = "auth.auto_login"
        static let forgotPassword = "auth.forgot_password"
        static let noAccount = "auth.no_account"
        static let haveAccount = "auth.have_account"
    }
    
    // MARK: - Onboarding
    
    enum Onboarding {
        static let skip = "onboarding.skip"
        static let start = "onboarding.start"
        static let next = "onboarding.next"
    }
    
    // MARK: - Common
    
    enum Common {
        static let ok = "common.ok"
        static let cancel = "common.cancel"
        static let retry = "common.retry"
        static let loading = "common.loading"
    }
}
