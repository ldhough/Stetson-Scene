//
//  SearchEventFormView.swift
//  StetsonScene
//
//  Created by Lannie Hough on 1/25/20.
//  Copyright © 2020 Lannie Hough. All rights reserved.
//

import Foundation
import SwiftUI

///View presents a scrollwheel (Picker) from which the user can select relevant event types
struct SearchEventFormView: View {
    @ObservedObject var eventModelController:EventModelController
    @State var selectionList:[Bool] = []
    @State var selectAllDeselectAll:Bool = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            if self.colorScheme == .dark {
                Constants.darkGray
            } else {
                Color.white
            }
        VStack {
                Button(action: {
                    self.eventModelController.haptic()
                    var index:Int = 0
                    if self.selectAllDeselectAll == false {
                        for _ in self.eventModelController.displayEventTypeList {
                            self.eventModelController.displayEventTypeList[index] = true //test
                            index += 1
                        }
                        self.eventModelController.setDefaultEventList()
                    } else {
                        for _ in self.eventModelController.displayEventTypeList {
                            self.eventModelController.displayEventTypeList[index] = false
                            index += 1
                        }
                        self.eventModelController.setDefaultEventList()
                    }
                    self.selectAllDeselectAll.toggle()
                    self.eventModelController.lastSelectDeselect = self.selectAllDeselectAll
                    self.eventModelController.setSelectAllDeselectAll()
                }) {
                    Text(self.selectAllDeselectAll == false ? "Select All" : "Deselect All").font(.system(size: 16, weight: .light, design: .default)).foregroundColor(self.colorScheme == .dark ? Constants.brightYellow : Color.white)
                }.buttonStyle(MainButtonStyle(colorScheme: self._colorScheme)).padding(.horizontal, Constants.screenSize.width*0.1)
            List/*(eventModelController.eventTypeList, id:\.self)*/ { //eventType in
                ForEach(eventModelController.eventTypeList, id:\.self) { eventType in
                    ZStack {
                        if self.colorScheme == .dark {
                            Constants.darkGray
                        } else {
                            Color.white
                        }
                        HStack {
                            Text(eventType).font(.system(size: 16, weight: .light, design: .default))
                            Spacer()
                            ZStack {
                                Image(systemName: "square").foregroundColor(self.colorScheme == .dark ? Color.white : Constants.medlightGray).opacity(0.5).scaleEffect(1.5).onTapGesture {
                                    let indexS:Int = self.eventModelController.eventTypeList.firstIndex(of: eventType)!
                                    self.eventModelController.displayEventTypeList[indexS].toggle()
                                    print("is a button")
                                    self.eventModelController.setDefaultEventList()
                                }
                                if self.eventModelController.displayEventTypeList[self.eventModelController.eventTypeList.firstIndex(of: eventType)!] == true {
                                    Image(systemName: "checkmark").foregroundColor(Constants.brightYellow).scaleEffect(1)
                                    //Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
//                Button(action: {
//                    let indexS:Int = self.eventModelController.eventTypeList.firstIndex(of: eventType)!
//                    self.eventModelController.displayEventTypeList[indexS].toggle()
//                    print("is a button")
//                    self.eventModelController.setDefaultEventList()
//                }) {
//                    ZStack {
//                        if self.colorScheme == .dark {
//                            self.darkGray
//                        } else {
//                            Color.white
//                        }
//                    HStack {
//                        Text(eventType).font(.system(size: 16, weight: .light, design: .default))
//                        Spacer()
//                        ZStack {
//                            Image(systemName: "square").foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
//                            if self.eventModelController.displayEventTypeList[self.eventModelController.eventTypeList.firstIndex(of: eventType)!] == true {
//                                Image(systemName: "circle.fill").foregroundColor(self.colorScheme == .dark ? self.brightYellow : self.brightYellow).scaleEffect(0.5)
//                                //Image(systemName: "checkmark")
//                            }
//                        }
//                    }
//                    }
//                } //Button end
            }.listRowBackground(self.colorScheme == .dark ? Constants.darkGray : Color.white) //ForEach end
            }//.listRowBackground(self.colorScheme == .dark ? self.darkGray : Color.white) //List end
        } //VStack end
        }
    }
}

//struct SearchEventFormView_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchEventFormView()
//    }
//}
