// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public class RCLib {
    private let session: URLSession
    public static let shared = RCLib()
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    
    public func fetchJSON<T: Codable>(from url: URL, forKey key: String, completion: @escaping (Result<T, Error>) -> Void) {
        // Create a data task to fetch data from the URL
        let task = session.dataTask(with: url) { data, response, error in
            // Handle error if it occurred during the fetch
            if let error = error {
                completion(.failure(error))
                return
            }
            // Ensure data is received
            guard let data = data else {
                completion(.failure(NSError(domain: "NetworkManagerError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            // Decode the received data into the specified Codable type
            let decoder = JSONDecoder()
            if let decodedData = try? decoder.decode(T.self, from: data) {
                // Store the decoded data using the InteractionManager
                InteractionManager.shared.storeValue(decodedData, forKey: key)
                completion(.success(decodedData))
            } else {
                // Handle decoding error
                completion(.failure(NSError(domain: "NetworkManagerError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode data"])))
            }
        }
        // Start the data task
        task.resume()
    }
    
    // Method to retrieve cached data for a given key from local storage.
    public func retrieveCachedData<T: Codable>(forKey key: String, type: T.Type) -> T? {
        // Use InteractionManager to retrieve the data from local storage
        return InteractionManager.shared.retrieveValue(forKey: key, type: type)
    }
}
