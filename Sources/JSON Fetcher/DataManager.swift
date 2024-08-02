//
//  File.swift
//  
//
//  Created by Rishabh Tripathi on 29/07/24.
//

//import Foundation
//
//public class DataManager {
//    public static let shared = DataManager()
//    
//    private let dataStorage = DataStorage.shared
//    
//    private init() {}
//    
//    public func fetchData(from urlString: String, withKey key: String, completion: @escaping (Result<Void, Error>) -> Void) {
//        JSON_Fetcher.shared.fetchJSON(from: urlString) { result in
//            switch result {
//            case .success(let json):
//                self.dataStorage.saveData(json, forKey: key)
//                completion(.success(()))
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
//    
//    public func getData(forKey key: String) -> [String: Any]? {
//        return dataStorage.loadData(forKey: key)
//    }
//    
//    public func getString(forKey key: String, valueKey: String) -> String? {
//        guard let data = dataStorage.loadData(forKey: key) else { return nil }
//        return data[valueKey] as? String
//    }
//}
