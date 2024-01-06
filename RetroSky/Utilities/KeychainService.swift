//
//  KeychainService.swift
//  RetroSky
//
//  Created by Eric Lemire on 2024/01/03.
//

import Foundation

/// A utility struct for handling the saving and retrieval of the API key in the keychain.
struct KeychainService {
    // Instance of KeychainSwift to interact with the iOS keychain.
    let keychain = KeychainSwift()

    /// Saves the given API key into the keychain.
    /// - Parameter apiKey: The API key to be saved.
    /// - Note: The key is stored with a unique identifier "com.retrosky.apiKey".
    func saveApiKey(_ apiKey: String) {
        // Stores the API key in the keychain with a predefined key.
        keychain.set(apiKey, forKey: "com.retrosky.apiKey")
    }

    /// Retrieves the API key from the keychain.
    /// - Returns: The retrieved API key, if it exists. Otherwise, returns nil.
    /// - Note: Retrieves the key using the unique identifier "com.retrosky.apiKey".
    func retrieveApiKey() -> String? {
        // Fetches the API key from the keychain using the predefined key.
        return keychain.get("com.retrosky.apiKey")
    }
}

