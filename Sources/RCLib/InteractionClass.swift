//
//  File.swift
//
//
//  Created by Rishabh Tripathi on 03/08/24.
//

import Foundation

// InteractionManager is a singleton class that provides an interface for storing and retrieving data.
// It leverages DataStorage for local persistence using UserDefaults.
internal class InteractionManager {
    
    // Singleton instance of InteractionManager.
    static let shared = InteractionManager()
    
    // Instance of DataStorage that handles the actual storage and retrieval of data.
    private let storageManager = DataStorage()
    
    // Private initializer to prevent external instantiation, ensuring only one instance exists.
    private init() {}
    
    // Method to store any Codable value with a specified key.
    // The value is encoded into data and stored using DataStorage.
    func storeValue<T: Codable>(_ value: T, forKey key: String) {
        storageManager.store(value, forKey: key)
    }
    
    // Method to retrieve a stored Codable value for a given key.
    // The value is decoded from data retrieved by DataStorage.
    func retrieveValue<T: Codable>(forKey key: String, type: T.Type) -> T? {
        return storageManager.retrieve(forKey: key, type: type)
    }
}

// DataStorage is responsible for encoding and decoding Codable values to and from UserDefaults.
internal class DataStorage {
    
    // Reference to UserDefaults.standard for storing and retrieving data.
    private let userDefaults = UserDefaults.standard
    
    // Method to store any Codable value with a specified key.
    // The value is encoded into data and saved in UserDefaults.
    func store<T: Codable>(_ value: T, forKey key: String) {
        let data = try? JSONEncoder().encode(value)
        userDefaults.set(data, forKey: key)
    }
    
    // Method to retrieve a stored Codable value for a given key.
    // The data is retrieved from UserDefaults and decoded into the specified Codable type.
    func retrieve<T: Codable>(forKey key: String, type: T.Type) -> T? {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }
        do {
            // Attempt to decode the data into the specified Codable type.
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            // Handle any errors that occurred during decoding.
            print("Failed to decode data for key \(key): \(error)")
            return nil
        }
    }
}
