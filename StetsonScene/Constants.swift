//
//  Constants.swift
//  StetsonScene
//
//  Created by Madison Gipson on 5/11/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

struct Constants {
    //@Environment(\.colorScheme) var colorScheme
    static let darkGray = Color(red: 30/255, green: 33/255, blue: 36/255)
    static let medGray = Color(red: 40/255, green: 43/255, blue: 46/255)
    static let medlightGray = Color(red: 146/255, green: 146/255, blue: 146/255)
    static let lightGray = Color(red: 203/255, green: 203/255, blue: 203/255)
    static let brightYellow = Color(red: 255/255, green: 196/255, blue: 0/255)
    //Colors used in gradient
    static let dark = Color(red: 249/255, green: 120/255, blue: 70/255)
    static let darkmed = Color(red: 249/255, green: 136/255, blue: 70/255)
    static let med = Color(red: 249/255, green: 158/255, blue: 70/255)
    static let lightmed = Color(red: 249/255, green: 174/255, blue: 70/255)
    static let light = Color(red: 249/255, green: 196/255, blue: 70/255)
    //CGColors for AR
    static let darkGrayCG = UIColor(red: 30/255, green: 33/255, blue: 36/255, alpha: 1.0).cgColor
    static let medGrayCG = UIColor(red: 35/255, green: 39/255, blue: 42/255, alpha: 0.9).cgColor
    static let medlightGrayCG = UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1.0).cgColor
    static let lightGrayCG = UIColor(red: 203/255, green: 203/255, blue: 203/255, alpha: 1.0).cgColor
    static let brightYellowCG = UIColor(red: 255/255, green: 196/255, blue: 0/255, alpha: 1.0).cgColor
    //UIColors for AR
    static let brightYellowUI = UIColor(red: 255/255, green: 196/255, blue: 0/255,  alpha: 1.0)
    static let darkGrayUI = UIColor(red: 30/255, green: 33/255, blue: 36/255, alpha: 1.0)
    static let medGrayUI = UIColor(red: 40/255, green: 43/255, blue: 46/255, alpha: 1.0)
    static let screenSize = UIScreen.main.bounds
}
