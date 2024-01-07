//
//  String+Extension.swift
//  wa.me
//
//  Created by Danial Fajar on 05/01/2024.
//

import Foundation

extension String {
    var stripped: String {
        let chars = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890")
        return self.filter { chars.contains($0) }
    }
}

extension String {
    func decodeJSONData<T: Codable>() -> T? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
