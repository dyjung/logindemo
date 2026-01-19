//
//  AuthError.swift
//  LoginDemo
//
//  인증 관련 에러 정의
//

import Foundation
import Alamofire

/// 인증 관련 에러
enum AuthError: Error, LocalizedError {
    /// 잘못된 자격 증명 (이메일/비밀번호)
    case invalidCredentials

    /// 이미 존재하는 이메일
    case emailAlreadyExists

    /// 토큰 만료
    case tokenExpired

    /// 토큰 갱신 실패
    case tokenRefreshFailed

    /// 네트워크 연결 없음
    case networkUnavailable

    /// 요청 제한 초과
    case rateLimitExceeded

    /// 서버 에러
    case serverError

    /// 유효하지 않은 입력
    case invalidInput(message: String)

    /// 알 수 없는 에러
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "이메일 또는 비밀번호가 올바르지 않습니다"
        case .emailAlreadyExists:
            return "이미 사용 중인 이메일입니다"
        case .tokenExpired:
            return "로그인이 만료되었습니다. 다시 로그인해주세요"
        case .tokenRefreshFailed:
            return "인증 정보를 갱신할 수 없습니다. 다시 로그인해주세요"
        case .networkUnavailable:
            return "네트워크 연결을 확인해주세요"
        case .rateLimitExceeded:
            return "요청이 너무 많습니다. 잠시 후 다시 시도해주세요"
        case .serverError:
            return "서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요"
        case .invalidInput(let message):
            return message
        case .unknown:
            return "알 수 없는 오류가 발생했습니다"
        }
    }
}

// MARK: - AFError 변환

extension AFError {
    /// AFError를 AuthError로 변환
    var toAuthError: AuthError {
        switch self {
        case .responseValidationFailed(let reason):
            if case .unacceptableStatusCode(let code) = reason {
                switch code {
                case 401:
                    return .invalidCredentials
                case 409:
                    return .emailAlreadyExists
                case 429:
                    return .rateLimitExceeded
                case 500...599:
                    return .serverError
                default:
                    return .unknown
                }
            }
            return .unknown

        case .sessionTaskFailed(let error):
            let nsError = error as NSError
            if nsError.code == NSURLErrorNotConnectedToInternet ||
               nsError.code == NSURLErrorNetworkConnectionLost {
                return .networkUnavailable
            }
            return .unknown

        default:
            return .unknown
        }
    }
}
