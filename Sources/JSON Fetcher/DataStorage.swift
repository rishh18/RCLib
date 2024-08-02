//
//  File.swift
//  
//
//  Created by Rishabh Tripathi on 29/07/24.
//

import Foundation

public class DataStorage {

    private let userDefaults = UserDefaults.standard
    public init() {}
    
    public func saveData(_ data: Data, forKey key: String) {
        userDefaults.set(data, forKey: key)
    }
    
    public func loadData(forKey key: String) -> Data? {
        return userDefaults.data(forKey: key)
    }
}
