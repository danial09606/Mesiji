//
//  CustomInfoTableViewCell.swift
//  wa.me
//
//  Created by Danial Fajar on 05/01/2024.
//

import UIKit

protocol CustomInfoTableViewCellDelegate: AnyObject {
    func textFieldShouldEndEditing(text: String, tag: Int)
}

class CustomInfoTableViewCell: UITableViewCell {
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 12
        return stackView
    }()
    
    lazy var titleLbl: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 2
        return label
    }()
    
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter Value"
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = 8.0
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 44))
        textField.leftViewMode = .always
        return textField
    }()
    
    static let identifier = "CustomInfoTableViewCell"
    
    weak var delegate: CustomInfoTableViewCellDelegate?
    
    // MARK: - Initializer and Lifecycle Methods -
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: Bundle.main)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        contentView.isUserInteractionEnabled = false
        
        setupSubviews()
        
        textField.delegate = self
    }
    
    // MARK: Setup Methods
    private func setupSubviews() {
        contentStackView.addArrangedSubview(titleLbl)
        contentStackView.addArrangedSubview(textField)
        addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 40),
            
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }

    // MARK: ConfigureCell
    func bind(viewModel: CustomInfoTVCVM) {
        titleLbl.text = viewModel.title
        textField.text = viewModel.value
        textField.tag = viewModel.textFieldTag
    }
}

extension CustomInfoTableViewCell: UITextFieldDelegate {
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        guard let text = textField.text else { return false }
        delegate?.textFieldShouldEndEditing(text: text, tag: textField.tag)
        return true
    }
}
