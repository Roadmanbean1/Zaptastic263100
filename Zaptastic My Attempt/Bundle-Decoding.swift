//
//  Bundle-Decoding.swift
//  Zaptastic My Attempt
//
//  Created by Ben  Thoburn on 02/02/2022.
//

import Foundation

//extension Bundle {
//    func decode<T: Decodable>(_ type: T.Type, from file: String) -> T{
//        guard let url = self.url(forResource: file, withExtension: nil) else {
//            fatalError("Failed to locate \(file) in bundle.")
//        }
//        guard let data = try? Data(contentsOf: url) else{
//            fatalError("Failed to load \(file) from bundle.")
//        }
//
//        let decoder = JSONDecoder()
//
//        guard let loaded = try? decoder.decode(T.self, from: data) else{
//            fatalError("Failed to decode \(file) from bundle.")
//        }
//
//        return loaded
//    }
//}


extension Bundle {
    
    func decode<T: Decodable>(_ type: T.Type, from filename: String) -> T? {
        guard let json = url(forResource: filename, withExtension: nil) else {
            print("Failed to locate \(filename) in app bundle.")
            return nil
        }
        do {
            let jsonData = try Data(contentsOf: json)
            let decoder = JSONDecoder()
            let result = try decoder.decode(T.self, from: jsonData)
            return result
        } catch {
            print("Failed to load and decode JSON \(error)")
            return nil
        }
    }
}
