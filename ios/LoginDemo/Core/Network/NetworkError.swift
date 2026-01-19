//
//  NetworkError.swift
//  LoginDemo
//
//  네트워크 에러 정의
//

import Foundation

/// 네트워크 관련 에러
enum NetworkError: Error, LocalizedError {
    /// 네트워크 연결 없음
    case noConnection

    /// 요청 타임아웃
    case timeout

    /// 서버 에러 (5xx)
    case serverError(statusCode: Int)

    /// 클라이언트 에러 (4xx)
    case clientError(statusCode: Int, message: String?)

    /// 인증 필요 (401)
    case unauthorized

    /// 접근 금지 (403)
    case forbidden

    /// 리소스 없음 (404)
    case notFound

    /// 요청 제한 초과 (429)
    case rateLimitExceeded

    /// 디코딩 에러
    case decodingError

    /// 알 수 없는 에러
    case unknown(Error?)

    var errorDescription: String? {
        switch self {
        case .noConnection:
            return "네트워크 연결을 확인해주세요"
        case .timeout:
            return "요청 시간이 초과되었습니다. 다시 시도해주세요"
        case .serverError:
            return "서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요"
        case .clientError(_, let message):
            return message ?? "요청을 처리할 수 없습니다"
        case .unauthorized:
            return "로그인이 필요합니다"
        case .forbidden:
            return "접근 권한이 없습니다"
        case .notFound:
            return "요청한 정보를 찾을 수 없습니다"
        case .rateLimitExceeded:
            return "요청이 너무 많습니다. 잠시 후 다시 시도해주세요"
        case .decodingError:
            return "데이터 처리 중 오류가 발생했습니다"
        case .unknown:
            return "알 수 없는 오류가 발생했습니다"
        }
    }
}
