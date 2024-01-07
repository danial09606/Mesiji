//
//  HomeView.swift
//  wa.me
//
//  Created by Danial Fajar on 05/01/2024.
//

import UIKit
import DropDown
import GoogleMobileAds
import SkyFloatingLabelTextField

extension SkyFloatingLabelTextField {
    open override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let rightBounds = CGRect(x: bounds.size.width - bounds.size.height, y: 0, width: bounds.size.height, height: bounds.size.height)
        return rightBounds
    }
}

class HomeView: UIView {
    lazy var parentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 30
        return stackView
    }()
    
    lazy var titleLbl: UILabel = {
        let label = UILabel()
        label.text = "MESIJI"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Academy Engraved LET", size: 47)
        label.numberOfLines = 2
        return label
    }()
    
    lazy var rightButton: UIButton = {
        let rightButton  = UIButton(type: .custom)
        rightButton.tintColor = .lightGray
        rightButton.setImage(UIImage(systemName: "doc.on.clipboard"), for: .normal)
        return rightButton
    }()
    
    lazy var countryTxtField: SkyFloatingLabelTextField = {
        let textField = SkyFloatingLabelTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isUserInteractionEnabled = true
        textField.title = "Country"
        textField.font = .systemFont(ofSize: 14)
        return textField
    }()
    
    lazy var contactStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    lazy var countryCodeTxtField: SkyFloatingLabelTextField = {
        let textField = SkyFloatingLabelTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isUserInteractionEnabled = false
        textField.font = .systemFont(ofSize: 14)
        return textField
    }()
    
    lazy var phoneTxtField: SkyFloatingLabelTextField = {
        let textField = SkyFloatingLabelTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.title = "Phone Number"
        textField.placeholder = "Enter Phone Number"
        textField.keyboardType = .numberPad
        textField.font = .systemFont(ofSize: 14)
        textField.rightViewMode = .always
        textField.rightView = rightButton
        return textField
    }()
    
    lazy var messageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 0
        return stackView
    }()
    
    lazy var messageTitleLbl: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13)
        label.textColor = .gray
        label.text = "MESSAGE"
        label.isHidden = true
        label.numberOfLines = 0
        return label
    }()
    
    lazy var messageTxtView: UITextView = {
        let textField = UITextView()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.text = "Enter Message.."
        textField.textColor = .lightGray
        textField.font = .systemFont(ofSize: 14)
        return textField
    }()
    
    lazy var messageBottomBorder: UIView = {
        let newView = UIView()
        newView.translatesAutoresizingMaskIntoConstraints = false
        newView.backgroundColor = .lightGray
        return newView
    }()
    
    lazy var sendButton: UIButton = {
        let newButton = UIButton()
        newButton.layer.cornerRadius = 8.0
        newButton.backgroundColor = .blue
        newButton.titleLabel?.textColor = .white
        newButton.setTitle("Send", for: .normal)
        newButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return newButton
    }()
    
    lazy var tickButton: UIButton = {
        let newButton = UIButton()
        newButton.layer.cornerRadius = 8.0
        newButton.tintColor = .black
        newButton.contentHorizontalAlignment = .left
        newButton.setImage(UIImage(systemName: "circle"), for: .normal)
        newButton.setImage(UIImage(systemName: "circle.fill"), for: .selected)
        return newButton
    }()
    
    lazy var personalInfoLbl: UILabel = {
        let newLabel = UILabel()
        newLabel.text = "Include Custom Info"
        newLabel.font = UIFont.systemFont(ofSize: 14)
        newLabel.textColor = .label
        return newLabel
    }()
    
    lazy var innerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 0
        return stackView
    }()
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 15
        return stackView
    }()
    
    lazy var countryFlagDropdown: DropDown = {
        let dropdown = DropDown()
        dropdown.translatesAutoresizingMaskIntoConstraints = false
        dropdown.direction = .any
        dropdown.anchorView = countryTxtField
        dropdown.bottomOffset = CGPoint(x: 0, y: countryTxtField.bounds.height)
        dropdown.topOffset = CGPoint(x: 0, y: -countryTxtField.bounds.height)
        dropdown.cellNib = UINib(nibName: "CountryTableViewCell", bundle: nil)
        return dropdown
    }()
    
    lazy var bannerView: GADBannerView = {
        let newBannerView = GADBannerView(adSize: GADAdSizeBanner)
        newBannerView.isHidden = true
        newBannerView.translatesAutoresizingMaskIntoConstraints = false
        return newBannerView
    }()
    
    // MARK: Private
    // MARK: - Initializer and Lifecycle Methods -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        setupSubviews()
        
        messageTxtView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup
    private func setupSubviews() {
        innerStackView.addArrangedSubview(tickButton)
        innerStackView.addArrangedSubview(personalInfoLbl)
        
        contactStackView.addArrangedSubview(countryCodeTxtField)
        contactStackView.addArrangedSubview(phoneTxtField)
        
        parentStackView.addArrangedSubview(titleLbl)
        parentStackView.addArrangedSubview(contentStackView)
        parentStackView.addArrangedSubview(bannerView)
        
        messageStackView.addArrangedSubview(messageTitleLbl)
        messageStackView.addArrangedSubview(messageTxtView)
        messageStackView.addArrangedSubview(messageBottomBorder)
        
        contentStackView.addArrangedSubview(countryTxtField)
        contentStackView.addArrangedSubview(contactStackView)
        contentStackView.addArrangedSubview(messageStackView)
        contentStackView.addArrangedSubview(innerStackView)
        contentStackView.addArrangedSubview(sendButton)
        contentStackView.addArrangedSubview(bannerView)
        
        addSubview(parentStackView)
        
        NSLayoutConstraint.activate([
            
            countryCodeTxtField.widthAnchor.constraint(equalToConstant: 38),
            
            tickButton.heightAnchor.constraint(equalToConstant: 40),
            tickButton.widthAnchor.constraint(equalToConstant: 30),
            
            bannerView.heightAnchor.constraint(equalToConstant: 150),
            
            sendButton.heightAnchor.constraint(equalToConstant: 44),
            countryTxtField.heightAnchor.constraint(equalToConstant: 44),
            countryCodeTxtField.heightAnchor.constraint(equalToConstant: 44),
            phoneTxtField.heightAnchor.constraint(equalToConstant: 44),
            messageTxtView.heightAnchor.constraint(equalToConstant: 44),
            
            messageBottomBorder.heightAnchor.constraint(equalToConstant: 1.0),
            
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
            parentStackView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 25),
            parentStackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -15),
            
            parentStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            parentStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

extension HomeView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Enter Message.." {
            textView.text = nil
            textView.textColor = .label
            messageTitleLbl.isHidden = false
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter Message.."
            textView.textColor = .lightGray
            messageTitleLbl.isHidden = true
        }
    }
}
