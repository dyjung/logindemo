//
//  MockNetworkService.swift
//  LoginDemoTests
//
//  테스트용 Mock 네트워크 서비스
//

import Foundation
import Alamofire
@testable import LoginDemo

/// 테스트용 Mock 네트워크 서비스
final class MockNetworkService: NetworkServiceProtocol, @unchecked Sendable {
    // MARK: - Mock Results

    var mockResult: Any?
    var mockError: Error?

    // MARK: - Call Tracking

    var requestCallCount = 0
    var requestWithoutResponseCallCount = 0
    var lastRouter: URLRequestConvertible?

    // MARK: - NetworkServiceProtocol

    func request<T: Decodable>(_ router: URLRequestConvertible) async throws -> T {
        requestCallCount += 1
        lastRouter = router

        if let error = mockError {
            throw error
        }

        guard let result = mockResult as? T else {
            throw AuthError.unknown
        }

        return result
    }

    func requestWithoutResponse(_ router: URLRequestConvertible) async throws {
        requestWithoutResponseCallCount += 1
        lastRouter = router

        if let error = mockError {
            throw error
        }
    }

    // MARK: - Test Helpers

    func reset() {
        mockResult = nil
        mockError = nil
        requestCallCount = 0
        requestWithoutResponseCallCount = 0
        lastRouter = nil
    }
}
