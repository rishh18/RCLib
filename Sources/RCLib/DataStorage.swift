//
//  File.swift
//
//
//  Created by Rishabh Tripathi on 02/08/24.
//

import Foundation

public class DataStorage {
    
    private let userDefaults = UserDefaults.standard
    public init() {}
    
    // Method to store any value
    public func store<T: Codable>(_ value: T, forKey key: String) {
        let data = try? JSONEncoder().encode(value)
        userDefaults.set(data, forKey: key)
    }
    
    // Method to retrieve any value
    public func retrieve<T: Codable>(forKey key: String, type: T.Type) -> T? {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}

