//
//  CustomInfoViewModel.swift
//  wa.me
//
//  Created by Danial Fajar on 05/01/2024.
//

import RxSwift
import RxCocoa

protocol CustomInfoViewModelType {
    var showMsg: BehaviorRelay<String?> { get }
    var customFields: BehaviorRelay<[CustomField]> { get }
    
    func getCustomFields()
    func saveCustomFields()
    func encodeData(data: [CustomField]?) -> String?
}

class CustomInfoViewModel: CustomInfoViewModelType {
    
    let showMsg = BehaviorRelay<String?>(value: nil)
    
    let customFields = BehaviorRelay<[CustomField]>(value: [])
    
    private var db: DBHelper!
    
    init(db: DBHelper) {
        self.db = db
    }
    
    func getCustomFields() {
        guard let customField = db?.readCustomField() else { return }
        
        if customField.fields?.count ?? 0 > 0 {
            self.customFields.accept(customField.fields ?? [])
        } else {
            let customFields = [CustomField(fieldName: "Name", fieldValue: ""), CustomField(fieldName: "Gender", fieldValue: ""),
                                CustomField(fieldName: "Race", fieldValue: ""), CustomField(fieldName: "Nationality", fieldValue: ""),
                                CustomField(fieldName: "Occupation", fieldValue: "")]
            self.customFields.accept(customFields)
        }
    }
    
    func saveCustomFields() {
        guard let customFields = self.encodeData(data: customFields.value) else { return }
        db?.insert(fields: customFields)
        showMsg.accept("Successfully save data")
    }
    
    func encodeData(data: [CustomField]?) -> String? {
        guard let JSONEncode = try? JSONEncoder().encode(data) else { return nil }
        return String(data: JSONEncode, encoding: .utf8)
    }
}
