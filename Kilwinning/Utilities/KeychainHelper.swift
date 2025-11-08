import Foundation
import Security

/// Helper class for secure storage of sensitive data in the Keychain
class KeychainHelper {

    static let shared = KeychainHelper()

    private let service = "com.kilwinning.app"

    private init() {}

    // MARK: - Token Management

    /// Save authentication token to Keychain
    func saveToken(_ token: String) -> Bool {
        guard let data = token.data(using: .utf8) else { return false }

        // Delete any existing token first
        deleteToken()

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "auth_token",
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    /// Retrieve authentication token from Keychain
    func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "auth_token",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }

        return token
    }

    /// Delete authentication token from Keychain
    func deleteToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "auth_token"
        ]

        SecItemDelete(query as CFDictionary)
    }

    // MARK: - User Data

    /// Save user ID to Keychain
    func saveUserId(_ userId: Int) -> Bool {
        let data = String(userId).data(using: .utf8)!

        // Delete existing
        deleteUserId()

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "user_id",
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    /// Retrieve user ID from Keychain
    func getUserId() -> Int? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "user_id",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let userIdString = String(data: data, encoding: .utf8),
              let userId = Int(userIdString) else {
            return nil
        }

        return userId
    }

    /// Delete user ID from Keychain
    func deleteUserId() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "user_id"
        ]

        SecItemDelete(query as CFDictionary)
    }

    /// Clear all Keychain data
    func clearAll() {
        deleteToken()
        deleteUserId()
    }

    // MARK: - Session Timeout

    /// Save session timestamp
    func saveSessionTimestamp() -> Bool {
        let timestamp = Date().timeIntervalSince1970
        let data = String(timestamp).data(using: .utf8)!

        // Delete existing
        deleteSessionTimestamp()

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "session_timestamp",
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    /// Check if session is expired (8 hours timeout)
    func isSessionExpired() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "session_timestamp",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let timestampString = String(data: data, encoding: .utf8),
              let timestamp = Double(timestampString) else {
            return true // Consider expired if can't read
        }

        let sessionDate = Date(timeIntervalSince1970: timestamp)
        let eightHoursInSeconds: TimeInterval = 8 * 60 * 60

        return Date().timeIntervalSince(sessionDate) > eightHoursInSeconds
    }

    private func deleteSessionTimestamp() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "session_timestamp"
        ]

        SecItemDelete(query as CFDictionary)
    }
}
