//
//  File.swift
//
//
//  Created by Rishabh Tripathi on 03/08/24.
//

import Foundation

public class InteractionManager {
    
    // Singleton instance
    public static let shared = InteractionManager()
    
    private let storageManager = DataStorage()
    
    private init() {}
    
    // Method to store any value
    public func storeValue<T: Codable>(_ value: T, forKey key: String) {
        storageManager.store(value, forKey: key)
    }
    
    // Method to retrieve any value
    public func retrieveValue<T: Codable>(forKey key: String, type: T.Type) -> T? {
        return storageManager.retrieve(forKey: key, type: type)
    }
}
