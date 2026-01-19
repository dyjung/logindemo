//
//  AuthInterceptor.swift
//  LoginDemo
//
//  Alamofire 인증 인터셉터
//

import Foundation
import Alamofire

/// 인증 토큰 관리를 위한 Alamofire 인터셉터
final class AuthInterceptor: RequestInterceptor {
    // MARK: - Properties

    private let tokenStorage: KeychainDataSourceProtocol
    private weak var tokenRefresher: TokenRefresherProtocol?
    private let lock = NSLock()
    private var isRefreshing = false
    private var requestsToRetry: [(RetryResult) -> Void] = []
    
    // 메모리 누수 방지를 위한 최대 재시도 대기 요청 수
    private let maxRetryRequests = 50

    // MARK: - Initialization

    init(tokenStorage: KeychainDataSourceProtocol, tokenRefresher: TokenRefresherProtocol?) {
        self.tokenStorage = tokenStorage
        self.tokenRefresher = tokenRefresher
    }

    // MARK: - RequestAdapter

    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        var request = urlRequest

        // 인증이 필요하지 않은 엔드포인트 확인
        let path = urlRequest.url?.path ?? ""
        let publicPaths = [
            APIPath.login,
            APIPath.register,
            APIPath.refresh,
            APIPath.passwordReset,
            APIPath.verifyToken,
            APIPath.initApp
        ]
        let isPublicPath = publicPaths.contains { path.contains($0) }

        // 인증이 필요한 요청에만 토큰 추가
        if !isPublicPath, let accessToken = tokenStorage.getAccessToken() {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        completion(.success(request))
    }

    // MARK: - RequestRetrier

    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401 else {
            completion(.doNotRetry)
            return
        }

        // 토큰 갱신 요청 자체가 실패한 경우 재시도하지 않음
        let path = request.request?.url?.path ?? ""
        if path.contains(APIPath.refresh) {
            completion(.doNotRetryWithError(AuthError.tokenRefreshFailed))
            return
        }

        lock.lock()
        defer { lock.unlock() }

        // 대기 중인 요청이 너무 많으면 거부 (메모리 누수 방지)
        if requestsToRetry.count >= maxRetryRequests {
            completion(.doNotRetryWithError(AuthError.tokenRefreshFailed))
            return
        }

        // 이미 갱신 중인 경우 대기열에 추가
        requestsToRetry.append(completion)

        guard !isRefreshing else { return }

        isRefreshing = true

        Task { [weak self] in
            guard let self = self else { return }

            do {
                try await self.tokenRefresher?.refreshToken()

                self.lock.lock()
                self.requestsToRetry.forEach { $0(.retry) }
                self.requestsToRetry.removeAll()
                self.isRefreshing = false
                self.lock.unlock()
            } catch {
                self.lock.lock()
                self.requestsToRetry.forEach { $0(.doNotRetryWithError(error)) }
                self.requestsToRetry.removeAll()
                self.isRefreshing = false
                self.lock.unlock()
            }
        }
    }
}
