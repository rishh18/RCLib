// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

// RCLib is a class responsible for managing data fetching and local data retrieval.
// It utilizes URLSession to fetch JSON data from a URL and stores it locally using InteractionManager.
public class RCLib {
    
    // Instance of DataFetcher that handles the actual network request and JSON parsing.
    private let dataFetcher: DataFetcher
    
    // Shared singleton instance of RCLib for easy access across the app.
    public static let shared = RCLib()
    
    // Initializer for RCLib, allowing custom URLSession injection for testing or other purposes.
    // Defaults to URLSession.shared.
    public init(session: URLSession = .shared) {
        self.dataFetcher = DataFetcher(session: session)
    }
    
    // Method to fetch JSON data from a specified URL.
    // The fetched data is decoded into a Codable type (T) and stored locally using the provided key.
    // Completion handler returns the result of the fetch operation, either success with the decoded data or failure with an error.
    public func fetchJSON<T: Codable>(from url: URL, forKey key: String, completion: @escaping (Result<T, Error>) -> Void) {
        dataFetcher.fetchJSON(from: url, forKey: key, completion: completion)
    }
    
    // Method to retrieve cached data from local storage for a given key.
    // The data is retrieved and decoded into the specified Codable type (T).
    public func retrieveCachedData<T: Codable>(forKey key: String, type: T.Type) -> T? {
        return InteractionManager.shared.retrieveValue(forKey: key, type: type)
    }
}

