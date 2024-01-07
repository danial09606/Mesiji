//
//  HistoryViewController.swift
//  wa.me
//
//  Created by Danial Fajar on 05/01/2024.
//

import UIKit
import RxSwift
import RxCocoa
import GoogleMobileAds

class HistoryViewController: UIViewController {
    
    var dbHelper: DBHelper!
    var viewModel: HistoryViewModelType!
    var disposeBag: DisposeBag!
    var interstitial: GADInterstitialAd?
    var nvc: UINavigationController!
    
    lazy var rootView: HistoryView = {
        return view as! HistoryView
    }()
    
    required init(disposeBag: DisposeBag, viewModel: HistoryViewModelType, interstitial: GADInterstitialAd?, nvc: UINavigationController) {
        super.init(nibName: nil, bundle: nil)
        
        self.disposeBag = disposeBag
        self.viewModel = viewModel
        self.interstitial = interstitial
        self.nvc = nvc
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        view = HistoryView(frame: UIScreen.main.bounds)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "History"
        
        viewModel.getHistory()
        bindData()
    }
    
    private func bindData() {
        viewModel.showError
            .observe(on: MainScheduler.asyncInstance)
            .bind{ [weak self] text in
                guard let self,
                      let text else { return }
                self.alertMsg(self.nvc, message: text)
        }.disposed(by: disposeBag)
        
        viewModel.historyData
            .bind(to: rootView.tableView.rx
                    .items(cellIdentifier: HistoryTableViewCell.identifier,
                           cellType: HistoryTableViewCell.self)) { index, data, cell in
                let vm = HistoryTVCVM(phoneNumber: data.phoneNumber, message: data.message)
                cell.delegate = self
                cell.bind(viewModel: vm)
            }
            .disposed(by: disposeBag)
        
        viewModel.historyData
            .bind { [weak self] value in
                guard let self else { return }
                
                if value.isEmpty {
                    self.rootView.tableView.backgroundView = self.setEmptyView()
                    self.rootView.tableView.separatorStyle = .none
                } else {
                    self.rootView.tableView.backgroundView = nil
                    self.rootView.tableView.separatorStyle = .singleLine
                }
        }.disposed(by: disposeBag)
        
        let deleteAction = viewModel.createAction(title: "Delete", color: .red, observer: viewModel.deleteSubject.asObserver())
        
        viewModel.historyData
            .map { Dictionary(uniqueKeysWithValues: $0.enumerated().map { (IndexPath(row: $0.offset, section: 0), deleteAction($0.element)) }) }
            .bind(to: rootView.tableView.rx.trailingSwipeActionsConfigurationForRowAt)
            .disposed(by: disposeBag)
        
        viewModel.deleteSubject
            .subscribe(onNext: { [weak self] item in
                guard let self else { return }
                self.viewModel.delete(history: item)
            })
            .disposed(by: disposeBag)
    }
    
    private func setEmptyView() -> UIView {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: rootView.tableView.bounds.size.width, height: rootView.tableView.bounds.size.height))
        messageLabel.text = "No History Data"
        messageLabel.textColor = .label
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 16)
        messageLabel.sizeToFit()

        return messageLabel
    }
}

extension HistoryViewController: HistoryTableViewCellDelegate {
    func doSend(phoneNo: String, message: String) {
        if getSendUsage() >= 6 {
            showPopup(ads: interstitial)
            setSendUsage(noOfClicks: 0)
        } else {
            viewModel.sendMessage(phoneNo: phoneNo, message: message)
            
            setSendUsage(noOfClicks: getSendUsage()+1)
        }
    }
}

class UITableViewDelegateProxy: DelegateProxy<UITableView, UITableViewDelegate>, DelegateProxyType, UITableViewDelegate {

    static func currentDelegate(for object: UITableView) -> UITableViewDelegate? {
        object.delegate
    }

    static func setCurrentDelegate(_ delegate: UITableViewDelegate?, to object: UITableView) {
        object.delegate = delegate
    }

    public static func registerKnownImplementations() {
        self.register { UITableViewDelegateProxy(parentObject: $0) }
    }

    init(parentObject: UITableView) {
        super.init(
            parentObject: parentObject,
            delegateProxy: UITableViewDelegateProxy.self
        )
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        relay.value[indexPath]
    }

    fileprivate let relay = BehaviorRelay<[IndexPath: UISwipeActionsConfiguration]>(value: [:])
}

extension Reactive where Base: UITableView {
    var delegate: UITableViewDelegateProxy {
        return UITableViewDelegateProxy.proxy(for: base)
    }

    var trailingSwipeActionsConfigurationForRowAt: Binder<[IndexPath: UISwipeActionsConfiguration]> {
        Binder(delegate) { del, value in
            del.relay.accept(value)
        }
    }
}
