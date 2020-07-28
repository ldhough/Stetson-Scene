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
    //WHENEVER YOU NEED UICOLOR TO BE A COLOR, CAST IT: Color(bg1)
    //WHENEVER YOU NEED UICOLOR TO BE A CGCOLOR, CONVERT IT: bg1.cgColor
    
    
    static let bg1 = UIColor(red: 36.0/255.0, green: 36.0/255.0, blue: 37.0/255.0, alpha: 1.0)
    static let bg2 = UIColor(red: 55.0/255.0, green: 55.0/255.0, blue: 56.0/255.0, alpha: 1.0)

    static let accent1 = UIColor(red: 117.0/255.0, green: 116.0/255.0, blue: 222.0/255.0, alpha: 1.0)
    //static let accent2 = UIColor(red: 73.0/255.0, green: 147.0/255.0, blue: 177.0/255.0, alpha: 1.0)
    
    static let stroke = bg2

    static let text1 = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    static let text2 = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    
    
    //MARK: LIGHT THEMES
    //static let bg1 = UIColor(red: 246.0/255.0, green: 245.0/255.0, blue: 250.0/255.0, alpha: 1.0)
    //static let bg2 = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    //static let stroke = accent1
    //static let text1 = UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 60.0/255.0, alpha: 1.0)
    //static let text2 = UIColor(red: 100.0/255.0, green: 100.0/255.0, blue: 100.0/255.0, alpha: 1.0)
    //ACCENT1
    //red = UIColor(red: 235.0/255.0, green: 77.0/255.0, blue: 61.0/255.0, alpha: 1.0)
    //orange = UIColor(red: 240.0/255.0, green: 154.0/255.0, blue: 56.0/255.0, alpha: 1.0)
    //yellow = UIColor(red: 247.0/255.0, green: 206.0/255.0, blue: 70.0/255.0, alpha: 1.0)
    //green = UIColor(red: 101.0/255.0, green: 196.0/255.0, blue: 102.0/255.0, alpha: 1.0)
    //lightblue = UIColor(red: 120.0/255.0, green: 198.0/255.0, blue: 245.0/255.0, alpha: 1.0)
    //darkblue = UIColor(red: 52.0/255.0, green: 120.0/255.0, blue: 246.0/255.0, alpha: 1.0)
    //darkpurple = UIColor(red: 88.0/255.0, green: 86.0/255.0, blue: 207.0/255.0, alpha: 1.0)
    //lightpurple = UIColor(red: 163.0/255.0, green: 87.0/255.0, blue: 215.0/255.0, alpha: 1.0)
    //pink = UIColor(red: 239.0/255.0, green: 90.0/255.0, blue: 108.0/255.0, alpha: 1.0)
    
    //MARK: DARK THEMES
    //static let bg1 = UIColor(red: 36.0/255.0, green: 36.0/255.0, blue: 37.0/255.0, alpha: 1.0)
    //static let bg2 = UIColor(red: 55.0/255.0, green: 55.0/255.0, blue: 56.0/255.0, alpha: 1.0)
    //static let stroke = bg2
    //static let text1 = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    //static let text2 = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    //ACCENT1
    //red = UIColor(red: 235.0/255.0, green: 84.0/255.0, blue: 69.0/255.0, alpha: 1.0)
    //orange = UIColor(red: 241.0/255.0, green: 163.0/255.0, blue: 60.0/255.0, alpha: 1.0)
    //yellow = UIColor(red: 248.0/255.0, green: 216.0/255.0, blue: 74.0/255.0, alpha: 1.0)
    //green = UIColor(red: 98.0/255.0, green: 205.0/255.0, blue: 107.0/255.0, alpha: 1.0)
    //lightblue =UIColor(red: 128.0/255.0, green: 207.0/255.0, blue: 250.0/255.0, alpha: 1.0)
    //darkblue = UIColor(red: 19.0/255.0, green: 162.0/255.0, blue: 250.0/255.0, alpha: 1.0)
    //darkpurple = UIColor(red: 117.0/255.0, green: 116.0/255.0, blue: 222.0/255.0, alpha: 1.0)
    //lightpurple = UIColor(red: 178.0/255.0, green: 96.0/255.0, blue: 234.0/255.0, alpha: 1.0)
    //pink = UIColor(red: 244.0/255.0, green: 100.0/255.0, blue: 128.0/255.0, alpha: 1.0)
}
