//
//  CustomDataModel.swift
//  wa.me
//
//  Created by Danial Fajar on 05/01/2024.
//

import Foundation

struct CustomDataModel: Codable {
    var fields: [CustomField]?
    
    init(fields: [CustomField]? = nil) {
        self.fields = fields
    }
}

struct CustomField: Codable {
    var fieldName: String
    var fieldValue: String
    
    init(fieldName: String, fieldValue: String) {
        self.fieldName = fieldName
        self.fieldValue = fieldValue
    }
}
