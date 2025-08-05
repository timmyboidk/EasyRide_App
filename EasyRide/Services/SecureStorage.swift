import Foundation
import Security

class SecureStorage {
    static let shared = SecureStorage()
    
    private init() {}
    
    // MARK: - Token Storage Keys
    private enum Keys {
        static let accessToken = "EasyRide.AccessToken"
        static let refreshToken = "EasyRide.RefreshToken"
        static let userCredentials = "EasyRide.UserCredentials"
    }
    
    // MARK: - Public Methods
    
    func storeAccessToken(_ token: String) {
        store(token, forKey: Keys.accessToken)
    }
    
    func getAccessToken() -> String? {
        return retrieve(forKey: Keys.accessToken)
    }
    
    func storeRefreshToken(_ token: String) {
        store(token, forKey: Keys.refreshToken)
    }
    
    func getRefreshToken() -> String? {
        return retrieve(forKey: Keys.refreshToken)
    }
    
    func storeUserCredentials(phoneNumber: String, password: String) {
        let credentials = UserCredentials(phoneNumber: phoneNumber, password: password)
        if let data = try? JSONEncoder().encode(credentials) {
            store(data, forKey: Keys.userCredentials)
        }
    }
    
    func getUserCredentials() -> UserCredentials? {
        guard let data: Data = retrieve(forKey: Keys.userCredentials),
              let credentials = try? JSONDecoder().decode(UserCredentials.self, from: data) else {
            return nil
        }
        return credentials
    }
    
    func clearAllTokens() {
        delete(forKey: Keys.accessToken)
        delete(forKey: Keys.refreshToken)
        delete(forKey: Keys.userCredentials)
    }
    
    // MARK: - Generic Keychain Operations
    
    private func store<T>(_ value: T, forKey key: String) where T: Codable {
        guard let data = try? JSONEncoder().encode(value) else { return }
        store(data, forKey: key)
    }
    
    private func store(_ data: Data, forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Delete existing item first
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            print("Failed to store item in keychain: \(status)")
        }
    }
    
    private func retrieve<T>(forKey key: String) -> T? where T: Codable {
        guard let data: Data = retrieve(forKey: key),
              let value = try? JSONDecoder().decode(T.self, from: data) else {
            return nil
        }
        return value
    }
    
    private func retrieve(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess {
            return result as? Data
        } else {
            return nil
        }
    }
    
    private func retrieve(forKey key: String) -> String? {
        guard let data: Data = retrieve(forKey: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    private func delete(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess && status != errSecItemNotFound {
            print("Failed to delete item from keychain: \(status)")
        }
    }
}

// MARK: - Supporting Types

struct UserCredentials: Codable {
    let phoneNumber: String
    let password: String
}