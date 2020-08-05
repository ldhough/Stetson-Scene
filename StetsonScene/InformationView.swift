//
//  InformationView.swift
//  StetsonScene
//
//  Created by Madison Gipson on 7/15/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation
import SwiftUI

enum AccentColors: String {
    case pink = "pink"
    case red = "red"
    case orange = "orange"
    case yellow = "yellow"
    case green = "green"
    case teal = "teal"
    case blue = "blue"
    case indigo = "indigo"
    case purple = "purple"
}

func setColor(_ color: String) -> (Color, UIColor) {
    switch color {
    case "pink":
        return (Color(UIColor.systemPink), UIColor.systemPink)
    case "red":
        return (Color(UIColor.systemRed), UIColor.systemRed)
    case "orange":
        return (Color(UIColor.systemOrange), UIColor.systemOrange)
    case "yellow":
        return (Color(UIColor.systemYellow), UIColor.systemYellow)
    case "green":
        return (Color(UIColor.systemGreen), UIColor.systemGreen)
    case "teal":
        return (Color(UIColor.systemTeal), UIColor.systemTeal)
    case "blue":
        return (Color(UIColor.systemBlue), UIColor.systemBlue)
    case "indigo":
        return (Color(UIColor.systemIndigo), UIColor.systemIndigo)
    case "purple":
        return (Color(UIColor.systemPurple), UIColor.systemPurple)
    default:
        return (Color(UIColor.systemPink), UIColor.systemPink)
    }
}

struct InformationView : View {
    
    @EnvironmentObject var config: Configuration
    
    var body: some View {
        VStack {
            VStack(spacing: 20) {
                Text(config.page).fontWeight(.heavy).font(.system(size: 50)).frame(maxWidth: .infinity, alignment: .leading).foregroundColor(Color.label)
                Text("Pink").fontWeight(.medium).font(.system(size: 20)).foregroundColor(Color(UIColor.systemPink))
                    .onTapGesture{
                        color = "pink"
                        let res = setColor(color)
                        self.config.accent = res.0
                        self.config.accentUIColor = res.1
                }
                Text("Red").fontWeight(.medium).font(.system(size: 20)).foregroundColor(Color(UIColor.systemRed))
                    .onTapGesture{
                        color = "red"
                        let res = setColor(color)
                        self.config.accent = res.0
                        self.config.accentUIColor = res.1
                }
                Text("Orange").fontWeight(.medium).font(.system(size: 20)).foregroundColor(Color(UIColor.systemOrange))
                    .onTapGesture{
                        color = "orange"
                        let res = setColor(color)
                        self.config.accent = res.0
                        self.config.accentUIColor = res.1
                }
                Text("Yellow").fontWeight(.medium).font(.system(size: 20)).foregroundColor(Color(UIColor.systemYellow))
                    .onTapGesture{
                        color = "yellow"
                        let res = setColor(color)
                        self.config.accent = res.0
                        self.config.accentUIColor = res.1
                }
                Text("Green").fontWeight(.medium).font(.system(size: 20)).foregroundColor(Color(UIColor.systemGreen))
                    .onTapGesture{
                        color = "green"
                        let res = setColor(color)
                        self.config.accent = res.0
                        self.config.accentUIColor = res.1
                }
                Text("Teal").fontWeight(.medium).font(.system(size: 20)).foregroundColor(Color(UIColor.systemTeal))
                    .onTapGesture{
                        color = "teal"
                        let res = setColor(color)
                        self.config.accent = res.0
                        self.config.accentUIColor = res.1
                }
                Text("Blue").fontWeight(.medium).font(.system(size: 20)).foregroundColor(Color(UIColor.systemBlue))
                    .onTapGesture{
                        color = "blue"
                        let res = setColor(color)
                        self.config.accent = res.0
                        self.config.accentUIColor = res.1
                }
                Text("Indigo").fontWeight(.medium).font(.system(size: 20)).foregroundColor(Color(UIColor.systemIndigo))
                    .onTapGesture{
                        color = "blue"
                        let res = setColor(color)
                        self.config.accent = res.0
                        self.config.accentUIColor = res.1
                }
                Text("Purple").fontWeight(.medium).font(.system(size: 20)).foregroundColor(Color(UIColor.systemPurple))
                    .onTapGesture{
                        color = "purple"
                        let res = setColor(color)
                        self.config.accent = res.0
                        self.config.accentUIColor = res.1
                }
            }
            Spacer()
        }.padding([.vertical, .horizontal])
    }
}

