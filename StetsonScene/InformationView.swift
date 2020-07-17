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
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    var body: some View {
            VStack(spacing: 0) {
                //HEADER
                Text(viewRouter.page).fontWeight(.heavy).font(.system(size: 50)).frame(maxWidth: .infinity, alignment: .leading).foregroundColor(Color(Constants.text1)).padding([.vertical, .horizontal])
                
                //SETTINGS AND HELP TABS
                HStack {
                    //Settings Tab (order of attributes matters)
                    Text("Settings").fontWeight(.light).font(.system(size: 20))
                        .foregroundColor(viewRouter.subPage == "Settings" ? Color(Constants.bg2) : Color(Constants.accent1)).padding(.vertical, 10)
                    .frame(width: Constants.width*0.45)
                    .background(viewRouter.subPage == "Settings" ? Color(Constants.accent1) : Color(Constants.bg2))
                    .cornerRadius(radius: 10, corners: [.topLeft, .topRight])
                    .onTapGesture { self.viewRouter.subPage = "Settings" }
                    
                    //Help Tab
                    Text("Help").fontWeight(.light).font(.system(size: 20))
                    .foregroundColor(viewRouter.subPage == "Help" ? Color(Constants.bg2) : Color(Constants.accent1)).padding(.vertical, 10)
                    .frame(width: Constants.width*0.45)
                    .background(viewRouter.subPage == "Help" ? Color(Constants.accent1): Color(Constants.bg2))
                    .cornerRadius(radius: 10, corners: [.topLeft, .topRight])
                    .onTapGesture { self.viewRouter.subPage = "Help" }
                }
                
                //SMALL SPACER
                Rectangle().frame(width: Constants.width, height: 8).foregroundColor(Color(Constants.accent1))
                
                //SETTINGS OR HELP VIEW
                if viewRouter.subPage == "Settings" {
                    Text("Settings")
                } else if viewRouter.subPage == "Help" {
                    Text("Help")
                }
                
        }
    }
}

