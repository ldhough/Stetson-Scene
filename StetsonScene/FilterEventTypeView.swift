//
//  FilterEventTypeView.swift
//  StetsonScene
//
//  Created by Lannie Hough on 7/29/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import SwiftUI

struct FilterEventTypeView: View {
    
    @EnvironmentObject var config: Configuration
    @State var selectAllDeselectAll:Bool = false
    
    var body: some View {
        ZStack {
            //Color.systemBackground
            VStack {
                Button(action: {
                    
                }) {
                    Text(self.selectAllDeselectAll == false ? "Select All" : "Deselect All").font(.system(size: 16, weight: .light, design: .default)).foregroundColor(config.accent)
                }.buttonStyle(MainButtonStyle(accentColor: config.accent)).padding(.horizontal, Constants.width*0.1)
                List {
                    ForEach(config.eventViewModel.eventTypeList, id:\.self) { eventType in
                        ZStack {
                            HStack {
                                Text(eventType).font(.system(size: 16, weight: .light, design: .default))
                                Spacer()
                                ZStack {
                                    Image(systemName: "square").foregroundColor(Color.secondarySystemBackground).scaleEffect(1.5).onTapGesture {
                                            
                                        }
                                    if true {
                                        Image(systemName: "checkmark").foregroundColor(self.config.accent).scaleEffect(1)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

//Main Button Style e.g. Custom Search button on Event View
struct MainButtonStyle: ButtonStyle {
    //@EnvironmentObject var config:Configuration
    let accentColor:Color
    func makeBody(configuration: Self.Configuration) -> some View {
        return configuration.label
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(.horizontal, 7).padding(.vertical, 7)
            .background(Color.tertiarySystemBackground) // changes background of buttons in top section
            .foregroundColor(self.accentColor)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .font(.system(size: 16, weight: .light, design: .default))
    }
}

