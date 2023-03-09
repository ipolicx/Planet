//
//  KeychainHelper.swift
//  Planet
//
//  Created by Kai on 3/8/23.
//

import Foundation
import os


class KeychainHelper: NSObject {
    static let shared = KeychainHelper()
    
    func saveData(_ data: Data, forKey key: String, withICloudSync sync: Bool = false) throws {
        let saveQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrSynchronizable as String: sync ? kCFBooleanTrue! : kCFBooleanFalse!
        ]
        SecItemDelete(saveQuery as CFDictionary)
        let status = SecItemAdd(saveQuery as CFDictionary, nil)
        if status != errSecSuccess {
            throw PlanetError.KeychainSavingKeyError
        }
    }

    func loadData(forKey key: String, withICloudSync sync: Bool = false) throws -> Data {
        let loadQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecAttrSynchronizable as String: sync ? kCFBooleanTrue! : kCFBooleanFalse!
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(loadQuery as CFDictionary, &item)
        guard status == errSecSuccess else {
            throw PlanetError.KeychainLoadingKeyError
        }
        guard let data = item as? Data else {
            throw PlanetError.KeychainLoadingKeyError
        }
        return data
    }
    
    func saveValue(_ value: String, forKey key: String, withICloudSync sync: Bool = false) throws {
        guard value.count > 0, let data = value.data(using: .utf8) else {
            throw PlanetError.KeychainSavingKeyError
        }
        let saveQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrSynchronizable as String: sync ? kCFBooleanTrue! : kCFBooleanFalse!
        ]
        SecItemDelete(saveQuery as CFDictionary)
        let status = SecItemAdd(saveQuery as CFDictionary, nil)
        if status != errSecSuccess {
            throw PlanetError.KeychainSavingKeyError
        }
    }

    func loadValue(forKey key: String, withICloudSync sync: Bool = false) throws -> String {
        let loadQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecAttrSynchronizable as String: sync ? kCFBooleanTrue! : kCFBooleanFalse!
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(loadQuery as CFDictionary, &item)
        guard status == errSecSuccess else {
            throw PlanetError.KeychainLoadingKeyError
        }
        guard let data = item as? Data else {
            throw PlanetError.KeychainLoadingKeyError
        }
        guard let value = String(data: data, encoding: .utf8) else {
            throw PlanetError.KeychainLoadingKeyError
        }
        return value
    }
    
    func delete(forKey key: String, withICloudSync sync: Bool = false) throws {
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key,
            kSecAttrSynchronizable as String: sync ? kCFBooleanTrue! : kCFBooleanFalse!
        ]
        let status = SecItemDelete(deleteQuery as CFDictionary)
        if status != errSecSuccess {
            throw PlanetError.KeychainDeletingKeyError
        }
    }
}
