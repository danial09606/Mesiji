//
//  HistoryDataModel.swift
//  wa.me
//
//  Created by Danial Fajar on 05/01/2024.
//

import Foundation

struct HistoryDataModel: Codable {
    var id: String
    var phoneNumber: String
    var message: String
    
    init(id: String, phoneNumber: String, message: String) {
        self.id = id
        self.phoneNumber = phoneNumber
        self.message = message
    }
}
