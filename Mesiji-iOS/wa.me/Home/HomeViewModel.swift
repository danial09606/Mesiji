//
//  HomeViewModel.swift
//  wa.me
//
//  Created by Danial Fajar on 05/01/2024.
//

import RxSwift
import RxCocoa
import GoogleMobileAds

protocol HomeViewModelType {
    var showError: BehaviorRelay<String?> { get }
    var inputNumber: BehaviorRelay<String?> { get }
    var isSelectPersonalInfo: BehaviorRelay<Bool> { get }
    var countryData: BehaviorRelay<[CountryModel]?> { get }
    
    func sendMessage(countryCode: String?, phoneNo: String?, message: String?)
    func getCustomInfo() -> String?
    func saveMessageToHistory(phoneNumber: String, message: String)
    func getCountryListFromPlist()
}

class HomeViewModel: HomeViewModelType {
    
    let showError = BehaviorRelay<String?>(value: nil)
    
    let isSelectPersonalInfo = BehaviorRelay<Bool>(value: false)
    
    let inputNumber = BehaviorRelay<String?>(value: nil)
    
    let countryData = BehaviorRelay<[CountryModel]?>(value: nil)
    
    private var db: DBHelper!
    
    init(db: DBHelper) {
        self.db = db
    }
    
    func sendMessage(countryCode: String?, phoneNo: String?, message: String?) {
        guard let countryCode, !countryCode.isEmpty else { showError.accept("Please select country."); return }
        guard let phoneNo, !phoneNo.isEmpty else { showError.accept("Please enter phone number."); return }
        guard let escapedString = message?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }

        let phone = countryCode + phoneNo
        guard let url = URL(string: "whatsapp://send?phone=\(phone.stripped)&text=\(escapedString)") else { return }
        
        if UIApplication.shared.canOpenURL(url as URL) {
            UIApplication.shared.open(url as URL, options: [:]) { [weak self] status in
                guard let self, status else { return }
                self.saveMessageToHistory(phoneNumber: phone.stripped, message: message ?? "")
            }
        } else{
            showError.accept("Can't open WhatsApp. Please make sure you have installed Whatsapp.")
        }
    }
    
    func getCustomInfo() -> String? {
        guard let customField = db?.readCustomField(),
              customField.fields?.count ?? 0 > 0 else { return "" }
        
        var customInfo = ""
        
        customField.fields?.forEach({ field in
            customInfo += "\(field.fieldName): \(field.fieldValue)\n"
        })
    
        return customInfo
    }
    
    func saveMessageToHistory(phoneNumber: String, message: String) {
        db.insertHistory(phoneNumber: phoneNumber, message: message)
    }
    
    func getCountryListFromPlist() {
        if let path = Bundle.main.path(forResource: "CountryInfoList", ofType: "plist") {
            
            guard let countryCallingCodes = NSMutableArray(contentsOfFile: path) else { return }
            
            var countries: [CountryModel] = []
            
            for country in countryCallingCodes {
                guard let countryInfo = country as? [String:Any],
                      let countryName = countryInfo["name"] as? String,
                      let countryCode = countryInfo["code"] as? String,
                      let countryPhoneCode = countryInfo["phone_code"] as? String else { return }
                
                countries.append(CountryModel(countryName: countryName, countryCode: countryCode, countryPhoneCode: countryPhoneCode))
            }
            
            countryData.accept(countries)
        }
    }
}
