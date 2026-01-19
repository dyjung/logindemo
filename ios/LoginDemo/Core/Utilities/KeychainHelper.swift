//
//  KeychainHelper.swift
//  LoginDemo
//
//  Keychain 접근 헬퍼 클래스
//

import Foundation
import Security

/// Keychain 접근을 위한 헬퍼 클래스
final class KeychainHelper {
    // MARK: - Keychain Keys

    /// Keychain 저장 키
    enum KeychainKey: String {
        case accessToken = "com.dyjung.LoginDemo.accessToken"
        case refreshToken = "com.dyjung.LoginDemo.refreshToken"
        case userId = "com.dyjung.LoginDemo.userId"
        case deviceId = "com.dyjung.LoginDemo.deviceId"
    }

    // MARK: - Singleton

    static let shared = KeychainHelper()

    private init() {}

    // MARK: - Public Methods

    /// 문자열 값 저장
    /// - Parameters:
    ///   - value: 저장할 값
    ///   - key: Keychain 키
    /// - Returns: 저장 성공 여부
    @discardableResult
    func save(_ value: String, for key: KeychainKey) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        return save(data, for: key)
    }

    /// Data 저장
    /// - Parameters:
    ///   - data: 저장할 데이터
    ///   - key: Keychain 키
    /// - Returns: 저장 성공 여부
    @discardableResult
    func save(_ data: Data, for key: KeychainKey) -> Bool {
        // 기존 항목 삭제
        delete(key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    /// 문자열 값 조회
    /// - Parameter key: Keychain 키
    /// - Returns: 저장된 문자열 (없으면 nil)
    func getString(for key: KeychainKey) -> String? {
        guard let data = getData(for: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// Data 조회
    /// - Parameter key: Keychain 키
    /// - Returns: 저장된 데이터 (없으면 nil)
    func getData(for key: KeychainKey) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    /// 항목 삭제
    /// - Parameter key: Keychain 키
    /// - Returns: 삭제 성공 여부
    @discardableResult
    func delete(_ key: KeychainKey) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    /// 모든 저장된 항목 삭제
    func deleteAll() {
        KeychainKey.allCases.forEach { delete($0) }
    }
}

// MARK: - CaseIterable

extension KeychainHelper.KeychainKey: CaseIterable {}
