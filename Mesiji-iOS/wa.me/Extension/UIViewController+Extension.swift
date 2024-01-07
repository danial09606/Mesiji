//
//  UIViewController+Extension.swift
//  wa.me
//
//  Created by Danial Fajar on 05/01/2024.
//

import UIKit
import RxSwift
import GoogleMobileAds

extension UIViewController {
    func alertMsg(_ nvc: UINavigationController, message: String){
        let alert = UIAlertController(title: "Mesiji", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        nvc.present(alert, animated: true)
    }
    
    func goToCustomInfoPage(_ nvc: UINavigationController, disposeBag: DisposeBag, viewModel: CustomInfoViewModelType, interstitial: GADInterstitialAd?) {
        let vc = CustomInfoViewController(disposeBag: disposeBag, viewModel: viewModel, interstitial: interstitial, nvc: nvc)
        nvc.pushViewController(vc, animated: true)
    }
    
    func goToHistoryPage(_ nvc: UINavigationController, disposeBag: DisposeBag, viewModel: HistoryViewModelType, interstitial: GADInterstitialAd?) {
        let vc = HistoryViewController(disposeBag: disposeBag, viewModel: viewModel, interstitial: interstitial, nvc: nvc)
        nvc.pushViewController(vc, animated: true)
    }
    
}

extension UIViewController {
    func getCustomInfoUsage() -> Int {
        return UserDefaults.standard.integer(forKey: "clickCustomInfo")
    }
    
    func setCustomInfoUsage(noOfClicks: Int) {
        UserDefaults.standard.setValue(noOfClicks, forKey: "clickCustomInfo")
    }
    
    func getSendUsage() -> Int {
        return UserDefaults.standard.integer(forKey: "clickSend")
    }
    
    func setSendUsage(noOfClicks: Int) {
        UserDefaults.standard.setValue(noOfClicks, forKey: "clickSend")
    }
}

extension UIViewController {
    func showPopup(ads: GADInterstitialAd?) {
        if ads != nil {
            ads?.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
    }
}
