//
//  CustomInfoViewController.swift
//  wa.me
//
//  Created by Danial Fajar on 05/01/2024.
//

import UIKit
import RxSwift
import RxCocoa
import GoogleMobileAds

class CustomInfoViewController: UIViewController {
    
    var dbHelper: DBHelper!
    var viewModel: CustomInfoViewModelType!
    var disposeBag: DisposeBag!
    var interstitial: GADInterstitialAd?
    var nvc: UINavigationController!
    
    lazy var rootView: CustomInfoView = {
        return view as! CustomInfoView
    }()
    
    required init(disposeBag: DisposeBag, viewModel: CustomInfoViewModelType, interstitial: GADInterstitialAd?, nvc: UINavigationController) {
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
        view = CustomInfoView(frame: UIScreen.main.bounds)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addRightNavBarButton()
        viewModel.getCustomFields()
        bindData()
    }
    
    private func addRightNavBarButton() {
        let btnAdd = UIButton.init(type: .custom)
        btnAdd.setImage(UIImage(systemName: "plus"), for: .normal)
        btnAdd.addTarget(self, action: #selector(doAdd), for: .touchUpInside)
        
        let rightBarButton = UIBarButtonItem(customView: btnAdd)
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    private func bindData() {
        viewModel.showMsg
            .observe(on: MainScheduler.asyncInstance)
            .bind{ [weak self] text in
                guard let self,
                      let text else { return }
                self.alertMsg(self.nvc, message: text)
        }.disposed(by: disposeBag)
        
        viewModel.customFields
            .filter({ !$0.isEmpty })
            .bind(to: rootView.tableView.rx
                    .items(cellIdentifier: CustomInfoTableViewCell.identifier,
                           cellType: CustomInfoTableViewCell.self)) { index, field, cell in
                let vm = CustomInfoTVCVM(title: field.fieldName, value: field.fieldValue, textFieldTag: index)
                cell.delegate = self
                cell.bind(viewModel: vm)
            }
            .disposed(by: disposeBag)
        
        rootView.saveButton.rx.tap.bind { [weak self] in
            guard let self else { return }
            self.view.endEditing(true)
            if self.getCustomInfoUsage() >= 3 {
                showPopup(ads: interstitial)
                setCustomInfoUsage(noOfClicks: 0)
            } else {
                self.viewModel.saveCustomFields()
                
                setCustomInfoUsage(noOfClicks: getCustomInfoUsage()+1)
            }
        }.disposed(by: disposeBag)
    }
    
    private func addPopup() {
        let alert = UIAlertController(title: "Add", message: "Please enter field title", preferredStyle: .alert)
        alert.addTextField()
        
        let submitAction = UIAlertAction(title: "Add", style: .default) { [weak self, weak alert] action in
            guard let value = alert?.textFields?[0].text,
                  var data = self?.viewModel.customFields.value else { return }
            
            data.append(CustomField(fieldName: value, fieldValue: ""))
            self?.viewModel.customFields.accept(data)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(submitAction)
        
        nvc.present(alert, animated: true)
    }
    
    @objc func doAdd(_ sender: UIBarButtonItem) {
        addPopup()
    }
}

extension CustomInfoViewController: CustomInfoTableViewCellDelegate {
    func textFieldShouldEndEditing(text: String, tag: Int) {
        var data = self.viewModel.customFields.value
        data[tag].fieldValue = text
        self.viewModel.customFields.accept(data)
    }
}
