//
//  CountryTableViewCell.swift
//  wa.me
//
//  Created by Danial Fajar on 06/01/2024.
//

import UIKit
import DropDown

class CountryTableViewCell: DropDownCell {

    @IBOutlet weak var countryName: UILabel!
    @IBOutlet weak var countryPhoneCode: UILabel!
    
    func bind(viewModel: CountryTVCVM) {
        countryName.text = viewModel.countryName
        countryPhoneCode.text = viewModel.countryPhoneCode
    }
}
