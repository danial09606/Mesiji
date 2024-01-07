//
//  CountryModel.swift
//  wa.me
//
//  Created by Danial Fajar on 06/01/2024.
//

import Foundation

struct CountryModel: Codable {
    var countryName: String
    var countryCode: String
    var countryPhoneCode: String
    
    init(countryName: String, countryCode: String, countryPhoneCode: String) {
        self.countryName = countryName
        self.countryCode = countryCode
        self.countryPhoneCode = countryPhoneCode
    }
}
