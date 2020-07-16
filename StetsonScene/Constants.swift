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
    static let width = UIScreen.main.bounds.width
    static let height = UIScreen.main.bounds.height
    
    //COLORS: IGNORING DARK & LIGHT MODE
    
    //backgrounds e.g. different shades of gray
    static let bg1 = UIColor(red: 246.0/255.0, green: 245.0/255.0, blue: 250.0/255.0, alpha: 1.0) //light gray
    static let bg2 = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0) //white
    //static let bg3 =
    
    //helps with gradients
    static let accent1 = UIColor(red: 105.0/255.0, green: 194.0/255.0, blue: 236.0/255.0, alpha: 1.0) //light
    static let accent2 = UIColor(red: 73.0/255.0, green: 147.0/255.0, blue: 177.0/255.0, alpha: 1.0) //dark
    
    //static let stroke =      //most of the time stroke = accent, but not always
    
    static let text1 = UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 60.0/255.0, alpha: 1.0) //used for cells, event detail view, etc.
    static let text2 = UIColor(red: 100.0/255.0, green: 100.0/255.0, blue: 100.0/255.0, alpha: 1.0) //used where mainText would match background
    
    //WHENEVER YOU NEED UICOLOR TO BE A COLOR, CAST IT: Color(bg1)
    //WHENEVER YOU NEED UICOLOR TO BE A CGCOLOR, CONVERT IT: bg1.cgColor
    
    //LIGHT THEME BLUE COLOR PALETTE
//    static let bg1 = UIColor(red: 246.0/255.0, green: 245.0/255.0, blue: 250.0/255.0, alpha: 1.0) //light gray
//    static let bg2 = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0) //white
//    static let accent1 = UIColor(red: 105.0/255.0, green: 194.0/255.0, blue: 236.0/255.0, alpha: 1.0) //light
//    static let accent2 = UIColor(red: 73.0/255.0, green: 147.0/255.0, blue: 177.0/255.0, alpha: 1.0) //dark
//    static let text1 = UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 60.0/255.0, alpha: 1.0)
//    static let text2 = UIColor(red: 100.0/255.0, green: 100.0/255.0, blue: 100.0/255.0, alpha: 1.0)
}
