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
    
    static let lightblue = UIColor(red: 63.0/255.0, green: 128.0/255.0, blue: 230.0/255.0, alpha: 0.5)
    
    //COLORS: IGNORING DARK & LIGHT MODE
    
    //backgrounds e.g. different shades of gray
    //static let bg1 =
    //static let bg2 =
    //static let bg3 =
    
    //helps with gradients
    //static let lightAccent =
    //static let darkAccent =
    
    //static let stroke =      //most of the time stroke = accent, but not always
    
    //static let mainText =     //used for cells, event detail view, etc.
    //static let supportText =     //used where mainText would match background
    
    //WHENEVER YOU NEED UICOLOR TO BE A COLOR, CAST IT: Color(bg1)
    //WHENEVER YOU NEED UICOLOR TO BE A CGCOLOR, CONVERT IT: bg1.cgColor
}
