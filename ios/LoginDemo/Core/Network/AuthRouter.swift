//
//  AuthRouter.swift
//  LoginDemo
//
//  인증 API 라우터 (Alamofire URLRequestConvertible)
//

import Foundation
import Alamofire

/// 인증 관련 API 라우터
enum AuthRouter: URLRequestConvertible {
    /// 앱 초기화 (GET /v1/init)
    case initApp(refreshToken: String?)

    /// 통합 로그인 (EMAIL, SOCIAL)
    case login(dto: LoginRequestDTO)

    /// 통합 회원가입
    case register(dto: RegisterRequestDTO)

    /// 토큰 갱신
    case refreshToken(dto: TokenRefreshRequestDTO)

    /// 이메일(아이디) 찾기
    case findId(provider: String, socialAccessToken: String)

    /// 비밀번호 재설정 요청
    case passwordReset(email: String)

    /// 비밀번호 변경 확정
    case passwordConfirm(dto: PasswordConfirmRequestDTO)

    /// 로그아웃
    case logout(dto: LogoutRequestDTO)

    /// 토큰 검증
    case verifyToken

    // MARK: - HTTP Method

    var method: HTTPMethod {
        switch self {
        case .initApp, .findId, .verifyToken:
            return .get
        case .login, .register, .refreshToken, .passwordReset, .logout:
            return .post
        case .passwordConfirm:
            return .patch
        }
    }

    // MARK: - Path

    var path: String {
        switch self {
        case .initApp:
            return APIPath.initApp
        case .login:
            return APIPath.login
        case .register:
            return APIPath.register
        case .refreshToken:
            return APIPath.refresh
        case .findId:
            return APIPath.findId
        case .passwordReset:
            return APIPath.passwordReset
        case .passwordConfirm:
            return APIPath.passwordConfirm
        case .logout:
            return APIPath.logout
        case .verifyToken:
            return APIPath.verifyToken
        }
    }

    // MARK: - Parameters

    var parameters: Parameters? {
        switch self {
        case .initApp:
            return nil  // GET 요청, 헤더로 전송
        case .login(let dto):
            return try? dto.asDictionary()
        case .register(let dto):
            return try? dto.asDictionary()
        case .refreshToken(let dto):
            return try? dto.asDictionary()
        case .findId(let provider, let socialAccessToken):
            return [
                "provider": provider,
                "socialAccessToken": socialAccessToken
            ]
        case .passwordReset(let email):
            return ["email": email]
        case .passwordConfirm(let dto):
            return try? dto.asDictionary()
        case .logout(let dto):
            return try? dto.asDictionary()
        case .verifyToken:
            return nil
        }
    }

    // MARK: - Encoding

    var encoding: ParameterEncoding {
        switch method {
        case .get:
            return URLEncoding.default
        default:
            return JSONEncoding.default
        }
    }

    // MARK: - Additional Headers

    var additionalHeaders: HTTPHeaders? {
        switch self {
        case .initApp(let refreshToken):
            var headers = HTTPHeaders()
            if let token = refreshToken {
                headers.add(name: "X-Refresh-Token", value: token)
            }
            return headers
        default:
            return nil
        }
    }

    // MARK: - URLRequestConvertible

    func asURLRequest() throws -> URLRequest {
        let url = try APIConstants.baseURL.asURL().appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.method = method
        request.timeoutInterval = APIConstants.requestTimeout

        // Common Headers (TypeSpec CommonClientHeaders)
        request.setValue("1.0.0", forHTTPHeaderField: "X-App-Version")
        request.setValue("iOS", forHTTPHeaderField: "X-Platform")
        request.setValue(UUID().uuidString, forHTTPHeaderField: "X-Request-Id")

        // Additional Headers (per route)
        if let additionalHeaders = additionalHeaders {
            for header in additionalHeaders {
                request.setValue(header.value, forHTTPHeaderField: header.name)
            }
        }

        // Content-Type 설정
        if method != .get {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // 파라미터 인코딩
        if let parameters = parameters {
            request = try encoding.encode(request, with: parameters)
        }

        return request
    }
}

// MARK: - Encodable Extension
private extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: NSError(domain: "Network", code: -1)))
        }
        return dictionary
    }
}
