//
//  HistoryViewModel.swift
//  wa.me
//
//  Created by Danial Fajar on 05/01/2024.
//

import UIKit
import RxSwift
import RxCocoa

protocol HistoryViewModelType {
    var showError: BehaviorRelay<String?> { get }
    var historyData: BehaviorRelay<[HistoryDataModel]> { get }
    var deleteSubject: PublishSubject<HistoryDataModel> { get }
    
    func getHistory()
    func sendMessage(phoneNo: String, message: String)
    func createAction(title: String, color: UIColor, observer: AnyObserver<HistoryDataModel>) -> (HistoryDataModel) -> UISwipeActionsConfiguration
    func delete(history: HistoryDataModel)
}

class HistoryViewModel: HistoryViewModelType {
    
    let showError = BehaviorRelay<String?>(value: nil)
    
    let historyData = BehaviorRelay<[HistoryDataModel]>(value: [])
    
    let deleteSubject = PublishSubject<HistoryDataModel>()
    
    private var db: DBHelper!
    
    init(db: DBHelper) {
        self.db = db
    }
    
    func getHistory() {
        guard let history = db?.readHistory() else { return }
        self.historyData.accept(history)
    }
    
    func sendMessage(phoneNo: String, message: String) {
        guard let escapedString = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }

        guard let url = URL(string: "whatsapp://send?phone=\(phoneNo)&text=\(escapedString)") else { return }
        
        if UIApplication.shared.canOpenURL(url as URL) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }else{
            showError.accept("Can't open WhatsApp. Please make sure you have installed Whatsapp.")
        }
    }
    
    func createAction(title: String, color: UIColor, observer: AnyObserver<HistoryDataModel>) -> (HistoryDataModel) -> UISwipeActionsConfiguration {
        { item in
            let action = UIContextualAction(style: .normal, title: title) { _, _, completionHandler in
                observer.onNext(item)
                completionHandler(true)
            }
            action.backgroundColor = color
            let config = UISwipeActionsConfiguration(actions: [action])
            config.performsFirstActionWithFullSwipe = false
            return config
        }
    }
    
    func delete(history: HistoryDataModel) {
        guard let data = db.deleteHistoryData(phoneNumber: history.phoneNumber) else { return }
        historyData.accept(data)
    }
}
