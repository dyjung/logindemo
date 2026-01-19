//
//  FirebaseLoggerInterceptor.swift
//  LoginDemo
//
//  네트워크 요청 및 응답 로깅 인터셉터
//  (사용자 요청에 따라 Interpreter라는 명칭 대신 Interceptor로 구현하되, Firebase 로깅을 위한 구조 제공)
//

import Foundation
import Alamofire
import OSLog

/// 네트워크 로그를 출력하는 인터셉터
/// 추후 Firebase Analytics나 Crashlytics로 로그를 전송하도록 확장 가능합니다.
final class FirebaseLoggerInterceptor: RequestInterceptor, Sendable {
    
    private let logger = os.Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.example.LoginDemo", category: "Network")
    
    // MARK: - RequestAdapter
    
    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        let url = urlRequest.url?.absoluteString ?? "Unknown URL"
        let method = urlRequest.httpMethod ?? "Unknown Method"
        
        logger.info("🚀 [REQUEST] \(method) \(url)")
        
        if let headers = urlRequest.allHTTPHeaderFields, !headers.isEmpty {
            logger.debug("📋 Headers: \(headers)")
        }
        
        if let body = urlRequest.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            logger.debug("📦 Body: \(bodyString)")
        }
        
        completion(.success(urlRequest))
    }
    
    // MARK: - RequestRetrier
    
    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        if let response = request.task?.response as? HTTPURLResponse {
            let statusCode = response.statusCode
            let url = request.request?.url?.absoluteString ?? "Unknown URL"
            
            if (200...299).contains(statusCode) {
                logger.info("✅ [RESPONSE] (\(statusCode)) \(url)")
            } else {
                logger.error("❌ [RESPONSE] (\(statusCode)) \(url)")
            }
        } else {
            logger.error("⚠️ [ERROR] \(error.localizedDescription)")
        }
        
        completion(.doNotRetry)
    }
}
