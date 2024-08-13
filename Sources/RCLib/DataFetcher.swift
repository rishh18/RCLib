//
//  File.swift
//
//
//  Created by Rishabh Tripathi on 02/08/24.
//

import Foundation

// DataFetcher is responsible for making network requests to fetch JSON data and decoding it into a Codable type.
internal class DataFetcher {
    
    // The session used for making network requests, typically URLSession.shared.
    private let session: URLSession
    
    // Initializer that allows injecting a custom URLSession for testing or other purposes.
    internal init(session: URLSession = .shared) {
        self.session = session
    }
    
    // Method to fetch JSON data from a given URL.
    // The fetched data is decoded into a Codable type (T) and passed to the completion handler.
    // If an error occurs during the fetch or decoding process, it is returned through the completion handler.
    internal func fetchJSON<T: Codable>(from url: URL, forKey key: String, completion: @escaping (Result<T, Error>) -> Void) {
        // Create a data task to fetch data from the URL
        let task = session.dataTask(with: url) { data, response, error in
            // Handle error if it occurred during the fetch
            if let error = error {
                completion(.failure(error))
                return
            }
            // Ensure data is received
            guard let data = data, !data.isEmpty else {
                completion(.failure(NSError(domain: "DataFetcherError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            // Decode the received data into the specified Codable type
            let decoder = JSONDecoder()
            do {
                let decodedData = try decoder.decode(T.self, from: data)
                // Store the decoded data using the InteractionManager
                InteractionManager.shared.storeValue(decodedData, forKey: key)
                completion(.success(decodedData))
            } catch {
                // Handle decoding error
                completion(.failure(NSError(domain: "DataFetcherError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode data"])))
            }
        }
        // Start the data task
        task.resume()
    }
}
