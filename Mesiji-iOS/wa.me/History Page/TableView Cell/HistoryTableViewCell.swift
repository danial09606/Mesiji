//
//  HistoryTableViewCell.swift
//  wa.me
//
//  Created by Danial Fajar on 05/01/2024.
//

import UIKit

protocol HistoryTableViewCellDelegate: AnyObject {
    func doSend(phoneNo: String, message: String)
}

class HistoryTableViewCell: UITableViewCell {
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    lazy var sendButton: UIButton = {
        let newButton = UIButton()
        newButton.layer.cornerRadius = 8.0
        newButton.backgroundColor = .blue
        newButton.titleLabel?.textColor = .white
        newButton.setTitle("Chat", for: .normal)
        newButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        return newButton
    }()
    
    lazy var labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 4
        return stackView
    }()
    
    lazy var phoneLbl: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .bold)
        return label
    }()
    
    lazy var messageLbl: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    weak var delegate: HistoryTableViewCellDelegate?
    
    static let identifier = "HistoryTableViewCell"
    
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
        sendButton.addTarget(self, action: #selector(doSend(_:)), for: .touchUpInside)
    }
    
    // MARK: Setup Methods
    private func setupSubviews() {
        labelStackView.addArrangedSubview(phoneLbl)
        labelStackView.addArrangedSubview(messageLbl)
        
        contentStackView.addArrangedSubview(labelStackView)
        contentStackView.addArrangedSubview(sendButton)
        addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            
            sendButton.heightAnchor.constraint(equalToConstant: 30),
            sendButton.widthAnchor.constraint(equalToConstant: 50),
            
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }

    // MARK: ConfigureCell
    func bind(viewModel: HistoryTVCVM) {
        phoneLbl.text = viewModel.phoneNumber
        messageLbl.text = viewModel.message
    }
    
    @objc func doSend(_ sender: UIButton) {
        guard let phoneNo = phoneLbl.text,
              let message = messageLbl.text else { return }
        delegate?.doSend(phoneNo: phoneNo, message: message)
    }
}
