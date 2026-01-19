//
//  NetworkServiceProtocol.swift
//  LoginDemo
//
//  네트워크 서비스 프로토콜
//

import Foundation
import Alamofire

/// 네트워크 서비스 프로토콜
protocol NetworkServiceProtocol: Sendable {
    /// HTTP 요청 실행 및 디코딩
    /// - Parameter router: URLRequestConvertible 라우터
    /// - Returns: 디코딩된 응답
    func request<T: Decodable>(_ router: URLRequestConvertible) async throws -> T

    /// HTTP 요청 실행 (응답 없음)
    /// - Parameter router: URLRequestConvertible 라우터
    func requestWithoutResponse(_ router: URLRequestConvertible) async throws
}
