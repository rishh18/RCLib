// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

// RCLib is a class responsible for managing data fetching and local data retrieval.
// It utilizes URLSession to fetch JSON data from a URL and stores it locally using InteractionManager.
public class RCLib {
    
    // Instance of DataFetcher that handles the actual network request and JSON parsing.
    private let dataFetcher: DataFetcher
    
    // Initializer for RCLib, allowing custom URLSession injection for testing or other purposes.
    // Defaults to URLSession.shared.
    public init<T: Codable>(url: URL, key: String, session: URLSession = .shared, completion: @escaping (Result<T, Error>) -> Void) {
        self.dataFetcher = DataFetcher(session: session)
        dataFetcher.fetchJSON(from: url, forKey: key, completion: completion)
    }
    
    // Method to retrieve cached data from local storage for a given key.
    // The data is retrieved and decoded into the specified Codable type (T).
    public func retrieveCachedData<T: Codable>(forKey key: String, type: T.Type) -> T? {
        return InteractionManager.shared.retrieveValue(forKey: key, type: type)
    }
}
