//
//  InformationView.swift
//  StetsonScene
//
//  Created by Madison Gipson on 7/15/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation
import SwiftUI

struct InformationView : View {
    
    @EnvironmentObject var config: Configuration
    
    var body: some View {
        VStack {
            VStack(spacing: 20) {
                Text(config.page).fontWeight(.heavy).font(.system(size: 50)).frame(maxWidth: .infinity, alignment: .leading).foregroundColor(Color.label)
                Text("Pink").fontWeight(.medium).font(.system(size: 20)).foregroundColor(Color(UIColor.systemPink))
                    .onTapGesture{
                        self.config.accent = Color(UIColor.systemPink)
                        self.config.accentUIColor = UIColor.systemPink
                }
                Text("Red").fontWeight(.medium).font(.system(size: 20)).foregroundColor(Color(UIColor.systemRed))
                    .onTapGesture{
                        self.config.accent = Color(UIColor.systemRed)
                        self.config.accentUIColor = UIColor.systemRed
                }
                Text("Orange").fontWeight(.medium).font(.system(size: 20)).foregroundColor(Color(UIColor.systemOrange))
                    .onTapGesture{
                        self.config.accent = Color(UIColor.systemOrange)
                        self.config.accentUIColor = UIColor.systemOrange
                }
                Text("Yellow").fontWeight(.medium).font(.system(size: 20)).foregroundColor(Color(UIColor.systemYellow))
                    .onTapGesture{
                        self.config.accent = Color(UIColor.systemYellow)
                        self.config.accentUIColor = UIColor.systemYellow
                }
                Text("Green").fontWeight(.medium).font(.system(size: 20)).foregroundColor(Color(UIColor.systemGreen))
                    .onTapGesture{
                        self.config.accent = Color(UIColor.systemGreen)
                        self.config.accentUIColor = UIColor.systemGreen
                }
                Text("Teal").fontWeight(.medium).font(.system(size: 20)).foregroundColor(Color(UIColor.systemTeal))
                    .onTapGesture{
                        self.config.accent = Color(UIColor.systemTeal)
                        self.config.accentUIColor = UIColor.systemTeal
                }
                Text("Blue").fontWeight(.medium).font(.system(size: 20)).foregroundColor(Color(UIColor.systemBlue))
                    .onTapGesture{
                        self.config.accent = Color(UIColor.systemBlue)
                        self.config.accentUIColor = UIColor.systemBlue
                }
                Text("Indigo").fontWeight(.medium).font(.system(size: 20)).foregroundColor(Color(UIColor.systemIndigo))
                    .onTapGesture{
                        self.config.accent = Color(UIColor.systemIndigo)
                        self.config.accentUIColor = UIColor.systemIndigo
                }
                Text("Purple").fontWeight(.medium).font(.system(size: 20)).foregroundColor(Color(UIColor.systemPurple))
                    .onTapGesture{
                        self.config.accent = Color(UIColor.systemPurple)
                        self.config.accentUIColor = UIColor.systemPurple
                }
            }
            Spacer()
        }.padding([.vertical, .horizontal])
    }
}

