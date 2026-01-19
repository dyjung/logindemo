//
//  KeychainDataSource.swift
//  LoginDemo
//
//  Keychain 데이터 소스 구현
//

import Foundation

/// Keychain 데이터 소스 구현체
final class KeychainDataSource: KeychainDataSourceProtocol, @unchecked Sendable {
    // MARK: - Properties

    private let keychain = KeychainHelper.shared

    // MARK: - KeychainDataSourceProtocol

    func saveAccessToken(_ token: String) {
        keychain.save(token, for: .accessToken)
    }

    func getAccessToken() -> String? {
        keychain.getString(for: .accessToken)
    }

    func saveRefreshToken(_ token: String) {
        keychain.save(token, for: .refreshToken)
    }

    func getRefreshToken() -> String? {
        keychain.getString(for: .refreshToken)
    }

    func saveUserId(_ userId: String) {
        keychain.save(userId, for: .userId)
    }

    func getUserId() -> String? {
        keychain.getString(for: .userId)
    }

    func clearAll() {
        keychain.deleteAll()
    }

    var hasValidToken: Bool {
        getAccessToken() != nil
    }

    func getDeviceId() -> String? {
        if let deviceId = keychain.getString(for: .deviceId) {
            return deviceId
        }
        
        let newDeviceId = UUID().uuidString
        keychain.save(newDeviceId, for: .deviceId)
        return newDeviceId
    }
}
