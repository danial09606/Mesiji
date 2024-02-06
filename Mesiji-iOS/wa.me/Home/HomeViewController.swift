//
//  ViewController.swift
//  wa.me
//
//  Created by Danial Fajar on 05/01/2024.
//

import UIKit
import RxSwift
import RxCocoa
import DropDown
import GoogleMobileAds
import AppTrackingTransparency

class HomeViewController: UIViewController {
    
    var dbHelper: DBHelper!
    var viewModel: HomeViewModel!
    var adsRequest: GADRequest!
    
    var nvc: UINavigationController!
    
    let disposeBag = DisposeBag()
    
    lazy var rootView: HomeView = {
        return view as! HomeView
    }()
    
    private var interstitial: GADInterstitialAd?
    
    required init() {
        super.init(nibName: nil, bundle: nil)
        
        dbHelper = DBHelper()
        viewModel = HomeViewModel(db: dbHelper)
        adsRequest = GADRequest()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        view = HomeView(frame: UIScreen.main.bounds)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAds()
        setupGesture()
        addRightNavBarButton()
        bindData()
        viewModel.getCountryListFromPlist()
        
        nvc = self.navigationController
    }
    
    private func setupGesture(){
        let Tap = UITapGestureRecognizer(target: self, action: #selector(openDropDownList))
        rootView.countryTxtField.addGestureRecognizer(Tap)
    }
    
    private func addRightNavBarButton() {
        let btnHistory = UIButton.init(type: .custom)
        btnHistory.setImage(UIImage(systemName: "clock"), for: .normal)
        btnHistory.addTarget(self, action: #selector(doHistory), for: .touchUpInside)
        
        let btnCustomInfo = UIButton.init(type: .custom)
        btnCustomInfo.setImage(UIImage(systemName: "doc.text.image"), for: .normal)
        btnCustomInfo.addTarget(self, action: #selector(doCustomInfo), for: .touchUpInside)
        
        let stackview = UIStackView.init(arrangedSubviews: [btnCustomInfo, btnHistory])
        stackview.distribution = .equalSpacing
        stackview.axis = .horizontal
        stackview.alignment = .center
        stackview.spacing = 8
           
        let rightBarButton = UIBarButtonItem(customView: stackview)
        
        self.navigationItem.rightBarButtonItem = rightBarButton
    }

    private func bindData() {
        viewModel.showError
            .observe(on: MainScheduler.asyncInstance)
            .bind{ [weak self] text in
                guard let self,
                      let text else { return }
                self.alertMsg(self.nvc, message: text)
        }.disposed(by: disposeBag)
        
        viewModel.isSelectPersonalInfo
            .bind { [weak self] value in
                guard let self, value else { 
                    self?.rootView.messageTxtView.text = "Enter Message.."
                    self?.rootView.messageTxtView.textColor = .lightGray
                    self?.rootView.messageTitleLbl.isHidden = true
                    return
                }
                self.rootView.messageTxtView.text = self.viewModel.getCustomInfo()
                self.rootView.messageTxtView.textColor = .label
                self.rootView.messageTitleLbl.isHidden = false
        }.disposed(by: disposeBag)
        
        viewModel.countryData
            .bind { [weak self] value in
                guard let self, let value else { return }
                self.rootView.countryTxtField.text = "Malaysia"
                self.rootView.countryCodeTxtField.text = "+60"
                self.rootView.countryFlagDropdown.dataSource = value.compactMap({$0.countryCode})
                self.rootView.countryFlagDropdown.customCellConfiguration = {
                    (index: Index, item: String, cell: DropDownCell) -> Void in
                    guard let cell = cell as? CountryTableViewCell else { return }
                    
                    let vm = CountryTVCVM(countryName: value[index].countryName, countryPhoneCode: "+\(value[index].countryPhoneCode)")
                    cell.bind(viewModel: vm)
                }
        }.disposed(by: disposeBag)
        
        rootView.countryFlagDropdown.rx.selectionAction.onNext { [unowned self] index, item in
            guard let countryName = self.viewModel.countryData.value?[index].countryName,
                  let countryPhoneCode = self.viewModel.countryData.value?[index].countryPhoneCode else { return }
            
            self.rootView.countryTxtField.text = countryName
            self.rootView.countryCodeTxtField.text = "+\(countryPhoneCode)"
        }
        
        rootView.tickButton.rx.tap.bind { [weak self] in
            guard let self else { return }
            self.rootView.tickButton.isSelected = !self.rootView.tickButton.isSelected
            self.viewModel.isSelectPersonalInfo.accept(self.rootView.tickButton.isSelected)
        }.disposed(by: disposeBag)
        
        rootView.sendButton.rx.tap.bind { [weak self] in
            guard let self else { return }
            
            if self.getSendUsage() >= 4 {
                self.showPopup(ads: self.interstitial)
                self.setSendUsage(noOfClicks: 0)
            } else {
                self.viewModel.sendMessage(countryCode: self.rootView.countryCodeTxtField.text, phoneNo: self.rootView.phoneTxtField.text, message: self.rootView.messageTxtView.text)
                
                self.setSendUsage(noOfClicks: self.getSendUsage()+1)
            }
        }.disposed(by: disposeBag)
        
        rootView.rightButton.rx.tap.bind{ [weak self] in
            guard let self else { return }
            self.rootView.phoneTxtField.text = UIPasteboard.general.string
        }.disposed(by: disposeBag)
    }
    
    private func loadAds() {
        DispatchQueue.main.async { self.rootView.bannerView.load(self.adsRequest) }
        
        GADInterstitialAd.load(withAdUnitID: Constants.Credentials.adsPopupUnitID, request: adsRequest, completionHandler: { [weak self] ad, error in
            
            guard let self else { return }
            
            if let error = error {
              print("Failed to load interstitial ad with error: \(error.localizedDescription)")
              return
            }
            
            self.interstitial = ad
            self.interstitial?.fullScreenContentDelegate = self
        })
    }
    
    private func requestAd() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                if status == .authorized {
                    self.loadAds()
                }
            }
        } else {
            self.loadAds()
        }
    }
    
    private func setupAds() {
        
        GADMobileAds.sharedInstance()
        
        rootView.bannerView.adUnitID = Constants.Credentials.adsBannerUnitID
        rootView.bannerView.rootViewController = self
        rootView.bannerView.delegate = self
        
        requestAd()
    }
    
    @objc func doCustomInfo(_ sender: UIBarButtonItem) {
        goToCustomInfoPage(nvc, disposeBag: disposeBag, viewModel: CustomInfoViewModel(db: dbHelper), interstitial: interstitial)
    }
    
    @objc func doHistory(_ sender: UIBarButtonItem) {
        goToHistoryPage(nvc, disposeBag: disposeBag, viewModel: HistoryViewModel(db: dbHelper), interstitial: interstitial)
    }
    
    @objc func openDropDownList(){
        view.endEditing(true)
        rootView.countryFlagDropdown.show()
    }
}

extension HomeViewController: GADBannerViewDelegate, GADFullScreenContentDelegate {
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("bannerViewDidReceiveAd")
        rootView.bannerView.isHidden = false
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        print("bannerViewDidRecordImpression")
    }

    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillPresentScreen")
    }

    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillDIsmissScreen")
    }

    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewDidDismissScreen")
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad will present full screen content.")
    }
    
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad will dismiss full screen content.")
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        requestAd()
    }
}
