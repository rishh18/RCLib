// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public class JSON_Fetcher {
    public init() {}
    
    public func fetchJSON(from urlString: String, completion: @escaping (Result<Data, Error>) -> Void) {
            guard let url = URL(string: urlString) else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }
                
                completion(.success(data))
            }
            
            task.resume()
        }
}
 
