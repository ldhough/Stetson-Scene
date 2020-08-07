//
//  FilterEventTypeView.swift
//  StetsonScene
//
//  Created by Lannie Hough on 7/29/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import SwiftUI

struct FilterEventTypeView: View {
    @ObservedObject var evm: EventViewModel
    @EnvironmentObject var config: Configuration
    @State var updateSelect:Int = 1
    @State var selectAllDeselectAll:Bool
    @Binding var eventTypesSelected:Set<String> {
        didSet {
            evm.eventSearchEngine.eventTypeSet = self.eventTypesSelected
            print(self.eventTypesSelected.count)
            print(self.evm.eventTypeList.count/2)
            if self.eventTypesSelected.count > self.evm.eventTypeList.count/2 {
                print("deselect all")
                self.selectAllDeselectAll = false
            } else {
                print("select all")
                self.selectAllDeselectAll = true
            }
        }
    }
    
    var body: some View {
        VStack {
            Button(action: {
                if self.selectAllDeselectAll {
                    for element in self.evm.eventTypeList {
                        self.eventTypesSelected.insert(element)
                    }
                } else {
                    self.eventTypesSelected = []
                }
                //self.selectAllDeselectAll.toggle()
            }) {
                Text(self.selectAllDeselectAll ? "Select All" : "Deselect All"
                ).font(.system(size: 16, weight: .light, design: .default)).foregroundColor(config.accent)
            }.buttonStyle(MainButtonStyle(accentColor: config.accent)).padding(.horizontal, Constants.width*0.1)
            List {
                ForEach(evm.eventTypeList, id:\.self) { eventType in
                    ZStack {
                        HStack {
                            Text(eventType).font(.system(size: 16, weight: .light, design: .default))
                            Spacer()
                            ZStack {
                                Image(systemName: "square").foregroundColor(Color.secondarySystemBackground).scaleEffect(1.5).onTapGesture {
                                        if self.eventTypesSelected.contains(eventType) {
                                            self.eventTypesSelected.remove(eventType)
                                        } else {
                                            self.eventTypesSelected.insert(eventType)
                                        }
//                                    print(self.eventTypesSelected.count)
//                                    print(self.evm.eventTypeList.count/2)
//                                    if self.eventTypesSelected.count > self.evm.eventTypeList.count/2 {
//                                        print("code executing")
//                                        self.selectAllDeselectAll = !false
//                                        //return false
//                                    }
                                    //self.selectAllDeselectAll = true
                                    //return true
                                    self.updateSelect += 1
                                    }
                                if self.eventTypesSelected.contains(eventType) {
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

//Main Button Style e.g. Custom Search button on Event View
struct MainButtonStyle: ButtonStyle {
    //@EnvironmentObject var config:Configuration
    let accentColor:Color
    func makeBody(configuration: Self.Configuration) -> some View {
        return configuration.label
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(.horizontal, 7).padding(.vertical, 7)
            .background(Color.secondarySystemBackground) // changes background of buttons in top section
            .foregroundColor(self.accentColor)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .font(.system(size: 16, weight: .light, design: .default))
    }
}

