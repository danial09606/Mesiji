//
//  CustomInfoView.swift
//  wa.me
//
//  Created by Danial Fajar on 05/01/2024.
//

import UIKit

class CustomInfoView: UIView {
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.register(CustomInfoTableViewCell.self, forCellReuseIdentifier: CustomInfoTableViewCell.identifier)
        return tableView
    }()
    
    lazy var saveButton: UIButton = {
        let newButton = UIButton()
        newButton.layer.cornerRadius = 8.0
        newButton.backgroundColor = .blue
        newButton.titleLabel?.textColor = .white
        newButton.setTitle("Save", for: .normal)
        return newButton
    }()
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 15
        return stackView
    }()
    
    // MARK: Private
    // MARK: - Initializer and Lifecycle Methods -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup
    private func setupSubviews() {
        contentStackView.addArrangedSubview(tableView)
        contentStackView.addArrangedSubview(saveButton)
        addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            
            tableView.widthAnchor.constraint(equalTo: contentStackView.widthAnchor),
            saveButton.widthAnchor.constraint(equalTo: contentStackView.widthAnchor, multiplier: 0.85),
            saveButton.heightAnchor.constraint(equalToConstant: 44),
            
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStackView.topAnchor.constraint(equalTo: topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15)
        ])
    }
}
