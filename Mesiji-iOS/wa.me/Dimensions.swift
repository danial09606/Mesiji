//
//  Dimension.swift
//  wa.me
//
//  Created by Danial Fajar on 07/01/2024.
//

import UIKit

public struct Dimensions {
    public static let screenWidth: CGFloat = UIScreen.main.bounds.width
    public static let screenHeight: CGFloat = UIScreen.main.bounds.height
    
    public static let itemSize = CGSize(width: Dimensions.screenWidth / 1.05 - 66, height: 120)
}
