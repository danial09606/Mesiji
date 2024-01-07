//
//  SplashScreenViewController.swift
//  wa.me
//
//  Created by Danial Fajar on 07/01/2024.
//

import UIKit
import GoogleMobileAds

class SplashScreenViewController: UIViewController {

    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var isMobileAdsStartCalled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        GoogleMobileAdsConsentManager.shared.gatherConsent(from: self) {
          [weak self] consentError in
            guard let self else { return }

            if let consentError { print("Error: \(consentError.localizedDescription)") }

            if GoogleMobileAdsConsentManager.shared.canRequestAds {
              self.startGoogleMobileAdsSDK()
            }
            
            self.startMainScreen()
        }

        if GoogleMobileAdsConsentManager.shared.canRequestAds {
            startGoogleMobileAdsSDK()
        }
    }

    private func startGoogleMobileAdsSDK() {
       DispatchQueue.main.async {
           guard !self.isMobileAdsStartCalled else { return }

           self.isMobileAdsStartCalled = true

           // Initialize the Google Mobile Ads SDK.
           GADMobileAds.sharedInstance().start()

           // Load an ad.
           AppOpenAdManager.shared.loadAd()
        }
    }

    func startMainScreen() {
        AppOpenAdManager.shared.appOpenAdManagerDelegate = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate
            sceneDelegate?.initRootController()
            self.activityIndicator.stopAnimating()
            
            AppOpenAdManager.shared.showAdIfAvailable(viewController: self)
        }
    }

    // MARK: AppOpenAdManagerDelegate
    func appOpenAdManagerAdDidComplete(_ appOpenAdManager: AppOpenAdManager) {
        startMainScreen()
    }
}
