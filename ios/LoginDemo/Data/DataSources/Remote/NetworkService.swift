//
//  NetworkService.swift
//  LoginDemo
//
//  Alamofire 기반 네트워크 서비스 구현
//

import Foundation
import Alamofire

/// Alamofire 기반 네트워크 서비스
final class NetworkService: NetworkServiceProtocol, @unchecked Sendable {
    // MARK: - Properties

    private var session: Session
    private let configuration: URLSessionConfiguration

    // MARK: - Initialization

    init(interceptor: RequestInterceptor? = nil) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = APIConstants.requestTimeout
        configuration.timeoutIntervalForResource = APIConstants.resourceTimeout
        self.configuration = configuration

        self.session = Session(
            configuration: configuration,
            interceptor: interceptor
        )
    }

    // MARK: - Interceptor Setup (for deferred injection)

    /// 순환 의존성 해결을 위해 interceptor를 나중에 설정
    func setInterceptor(_ interceptor: RequestInterceptor) {
        // 기존 Session을 명시적으로 해제하여 메모리 누수 방지
        session.session.invalidateAndCancel()
        
        self.session = Session(
            configuration: configuration,
            interceptor: interceptor
        )
    }

    // MARK: - NetworkServiceProtocol

    func request<T: Decodable>(_ router: URLRequestConvertible) async throws -> T {
        do {
            let response = try await session.request(router)
                .validate(statusCode: 200..<300)
                .serializingDecodable(T.self)
                .value

            return response
        } catch let afError as AFError {
            throw mapError(afError)
        } catch {
            throw AuthError.unknown
        }
    }

    func requestWithoutResponse(_ router: URLRequestConvertible) async throws {
        do {
            _ = try await session.request(router)
                .validate(statusCode: 200..<300)
                .serializingData()
                .value
        } catch let afError as AFError {
            throw mapError(afError)
        } catch {
            throw AuthError.unknown
        }
    }

    // MARK: - Private Methods

    private func mapError(_ afError: AFError) -> Error {
        switch afError {
        case .responseValidationFailed(let reason):
            if case .unacceptableStatusCode(let code) = reason {
                switch code {
                case 401:
                    return AuthError.invalidCredentials
                case 409:
                    return AuthError.emailAlreadyExists
                case 429:
                    return AuthError.rateLimitExceeded
                case 500...599:
                    return AuthError.serverError
                default:
                    return AuthError.unknown
                }
            }
            return AuthError.unknown

        case .sessionTaskFailed(let error):
            let nsError = error as NSError
            if nsError.code == NSURLErrorNotConnectedToInternet ||
               nsError.code == NSURLErrorNetworkConnectionLost {
                return AuthError.networkUnavailable
            }
            if nsError.code == NSURLErrorTimedOut {
                return NetworkError.timeout
            }
            return AuthError.unknown

        case .responseSerializationFailed:
            return NetworkError.decodingError

        default:
            return AuthError.unknown
        }
    }
}
