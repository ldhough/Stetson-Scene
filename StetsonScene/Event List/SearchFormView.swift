////
////  SearchFormView.swift
////  StetsonScene
////
////  Created by Lannie Hough on 1/12/20.
////  Copyright © 2020 Lannie Hough. All rights reserved.
////
//
//import Foundation
//import SwiftUI
//
/////View presents a form with different criteria for searching for events.
//struct SearchFormView: View {
//    @Binding var showSearchForm:Bool
//    @State var number:Double = 1
//    var index = 0
//    //@State var isCulturalChecked:Bool = false
//    @ObservedObject var eventModelController:EventModelController
//    //@State var isCulturalChecked:Bool = false//eventModelController.filteringCultural
//    @State var isSpecificLoc:Bool = false
//    @State var specificLoc:String = ""
//    @State var value:Double = 30
//    //mon-sun
//    @State var weekdayArray:[Bool] = [false, false, false, false, false, false, false] //if all false, search for all weeks
//    @Environment(\.colorScheme) var colorScheme
//
//    
//    //Calls correct search method depending on whether or not Firebase needs to be queried for more data.
//    func search() {
//        //var intNumber = number as? Int
//        eventModelController.search(weeksToSearch: Int(number), hasToHaveCultural: self.eventModelController.filteringCultural, specifyTypes: true, specificLocation: isSpecificLoc, specificLocationIs: specificLoc, whichSubList: "Event List", daysToSearch: weekdayArray)
//    }
//    
//    func searchSuccess() { //not working rn
//        let generator = UINotificationFeedbackGenerator()
//        generator.notificationOccurred(.success)
//    }
//    
//    func shouldDisplaySelectAllOrDeselectAll() -> Bool {
//        var displayCount:Int = 0
//        var displayNotCount:Int = 0
//        for bl in self.eventModelController.displayEventTypeList {
//            if bl {
//                displayCount += 1
//            } else {
//                displayNotCount += 1
//            }
//        }
//        if displayCount >= displayNotCount {
//            return true
//        } else {
//            return false
//        }
//    }
//    
//    func returnDayOfWeekView() -> some View {
//        HStack {
//            Button(action: {
//                self.weekdayArray[1].toggle()
//            }) {
//                self.weekdayArray[1] == false ? Image(systemName: "m.square").foregroundColor(Constants.brightYellow).scaleEffect(1.5).padding(.bottom).padding(.horizontal, Constants.screenSize.width/28) : Image(systemName: "m.square.fill").foregroundColor(Constants.brightYellow).scaleEffect(1.5).padding(.bottom).padding(.horizontal, Constants.screenSize.width/28)
//            }
//            Button(action: {
//                self.weekdayArray[2].toggle()
//            }) {
//                self.weekdayArray[2] == false ? Image(systemName: "t.square").foregroundColor(Constants.brightYellow).scaleEffect(1.5).padding(.bottom).padding(.horizontal, Constants.screenSize.width/28) : Image(systemName: "t.square.fill").foregroundColor(Constants.brightYellow).scaleEffect(1.5).padding(.bottom).padding(.horizontal, Constants.screenSize.width/28)
//            }
//            Button(action: {
//                self.weekdayArray[3].toggle()
//            }) {
//                self.weekdayArray[3] == false ? Image(systemName: "w.square").foregroundColor(Constants.brightYellow).scaleEffect(1.5).padding(.bottom).padding(.horizontal, Constants.screenSize.width/28) : Image(systemName: "w.square.fill").foregroundColor(Constants.brightYellow).scaleEffect(1.5).padding(.bottom).padding(.horizontal, Constants.screenSize.width/28)
//            }
//            Button(action: {
//                self.weekdayArray[4].toggle()
//            }) {
//                self.weekdayArray[4] == false ? Image(systemName: "t.square").foregroundColor(Constants.brightYellow).scaleEffect(1.5).padding(.bottom).padding(.horizontal, Constants.screenSize.width/28) : Image(systemName: "t.square.fill").foregroundColor(Constants.brightYellow).scaleEffect(1.5).padding(.bottom).padding(.horizontal, Constants.screenSize.width/28)
//            }
//            Button(action: {
//                self.weekdayArray[5].toggle()
//            }) {
//                self.weekdayArray[5] == false ? Image(systemName: "f.square").foregroundColor(Constants.brightYellow).scaleEffect(1.5).padding(.bottom).padding(.horizontal, Constants.screenSize.width/28) : Image(systemName: "f.square.fill").foregroundColor(Constants.brightYellow).scaleEffect(1.5).padding(.bottom).padding(.horizontal, Constants.screenSize.width/28)
//            }
//            Button(action: {
//                self.weekdayArray[6].toggle()
//            }) {
//                self.weekdayArray[6] == false ? Image(systemName: "s.square").foregroundColor(Constants.brightYellow).scaleEffect(1.5).padding(.bottom).padding(.horizontal, Constants.screenSize.width/28) : Image(systemName: "s.square.fill").foregroundColor(Constants.brightYellow).scaleEffect(1.5).padding(.bottom).padding(.horizontal, Constants.screenSize.width/28)
//            }
//            Button(action: {
//                self.weekdayArray[0].toggle()
//            }) {
//                self.weekdayArray[0] == false ? Image(systemName: "s.square").foregroundColor(Constants.brightYellow).scaleEffect(1.5).padding(.bottom).padding(.horizontal, Constants.screenSize.width/28) : Image(systemName: "s.square.fill").foregroundColor(Constants.brightYellow).scaleEffect(1.5).padding(.bottom).padding(.horizontal, Constants.screenSize.width/28)
//            }
//        }
//    }
//    
//    var body: some View {
//        return ZStack {
//            if self.colorScheme == .dark {
//                Constants.darkGray.edgesIgnoringSafeArea(.bottom)
//            } else {
//                Color.white.edgesIgnoringSafeArea(.bottom)
//            }
//            VStack {
//                //Slider
//                CustomSlider(value: $number, range: (1, 20)) { modifiers in
//                  ZStack {
//                    LinearGradient(gradient: .init(colors: [Constants.dark, Constants.light]), startPoint: .leading, endPoint: .trailing)
//                    Text(/*self.number > 1 ? "Number of Weeks Displayed" : */"Number of Weeks Displayed").font(.system(size: 16, weight: .light, design: .default)).foregroundColor(self.colorScheme == .dark ? Color.black : Color.white)
//                    ZStack {
//                      Circle().fill(self.colorScheme == .dark ? Color.black : Color.white)
//                        Text(("\(Int(self.number))")).font(.system(size: 14, weight: .heavy, design: .default)).foregroundColor(Constants.light)
//                    }
//                    .padding([.top, .bottom], 2)
//                    .modifier(modifiers.knob)
//                  }.cornerRadius(15)
//                }.frame(height: 30).padding([.top, .bottom])
//                //Divider
//                returnDayOfWeekView()
//                Divider().background(self.colorScheme == .dark ? Color.white : Constants.medlightGray).opacity(0.25)
//                //Cultural Credit
//                Button(action: {
//                    self.eventModelController.filteringCultural.toggle()
//                    self.eventModelController.setDefaultCultural()
//                    print("is a button")
//                }) {
//                    HStack {
//                        Text("Cultural Credits").foregroundColor(Constants.brightYellow).padding()
//                        Spacer()
//                        ZStack {
//                            Image(systemName: "square").foregroundColor(self.colorScheme == .dark ? Color.white : Constants.medlightGray).opacity(0.5).scaleEffect(1.5).padding()
//                        if self.eventModelController.filteringCultural {
//                            Image(systemName: "checkmark").foregroundColor(Constants.brightYellow).padding()
//                        }
//                        }
//                    }
//                }.foregroundColor(self.colorScheme == .dark ? Color.white : Constants.darkGray)
//                //Divider
//                Divider().background(self.colorScheme == .dark ? Color.white : Constants.medlightGray).opacity(0.25)
//                //List
//                SearchEventFormView(eventModelController: self.eventModelController, selectAllDeselectAll: self.shouldDisplaySelectAllOrDeselectAll())
//                //Divider
//                Divider().background(self.colorScheme == .dark ? Color.white : Constants.medlightGray).opacity(0.25)
//                Spacer()
//                //Search Button
//                Button("Search") {
//                    self.eventModelController.haptic()
//                    self.showSearchForm.toggle()
//                    self.eventModelController.weekdayArray = self.weekdayArray
//                    self.eventModelController.setDefaultDaysOfWeek()
//                    self.eventModelController.lastWeeksSearched = Int(self.number)
//                    self.eventModelController.setDefaultTimeRange()
//                    self.search()
//                    if Int(self.number) > self.eventModelController.weeksStored {
//                        self.eventModelController.weeksStored = Int(self.number)
//                    }
//                }.onTapGesture(perform: searchSuccess)
//                    .buttonStyle(MainButtonStyle(colorScheme: self._colorScheme))
//            }.padding() //VStack end
//        }
//    }
//}
//
//extension Double {
//    func convert(fromRange: (Double, Double), toRange: (Double, Double)) -> Double {
//        // Example: if self = 1, fromRange = (0,2), toRange = (10,12) -> solution = 11
//        var value = self
//        value -= fromRange.0
//        value /= Double(fromRange.1 - fromRange.0)
//        value *= toRange.1 - toRange.0
//        value += toRange.0
//        return value
//    }
//}
//
//struct CustomSliderComponents {
//    let barLeft: CustomSliderModifier
//    let barRight: CustomSliderModifier
//    let knob: CustomSliderModifier
//}
//struct CustomSliderModifier: ViewModifier {
//    enum Name {
//        case barLeft
//        case barRight
//        case knob
//    }
//    let name: Name
//    let size: CGSize
//    let offset: CGFloat
//
//    func body(content: Content) -> some View {
//        content
//        .frame(width: size.width)
//        .position(x: size.width*0.5, y: size.height*0.5)
//        .offset(x: offset)
//    }
//}
//
//struct CustomSlider<Component: View>: View {
//
//    func haptic() {
//        print("activated haptic")
//        let generator = UINotificationFeedbackGenerator()
//        generator.notificationOccurred(.success)
//    }
//    
//    @Binding var value: Double
//    var range: (Double, Double)
//    var knobWidth: CGFloat?
//    let viewBuilder: (CustomSliderComponents) -> Component
//
//    init(value: Binding<Double>, range: (Double, Double), knobWidth: CGFloat? = nil,
//         _ viewBuilder: @escaping (CustomSliderComponents) -> Component
//    ) {
//        _value = value
//        self.range = range
//        self.viewBuilder = viewBuilder
//        self.knobWidth = knobWidth
//    }
//
//    var body: some View {
//        return GeometryReader { geometry in
//            self.view(geometry: geometry)
//        }
//    }
//    
//    private func onDragChange(_ drag: DragGesture.Value,_ frame: CGRect) {
//        //haptic()
//        let width = (knob: Double(knobWidth ?? frame.size.height), view: Double(frame.size.width))
//        let xrange = (min: Double(0), max: Double(width.view - width.knob))
//        var value = Double(drag.startLocation.x + drag.translation.width) // knob center x
//        value -= 0.5*width.knob // offset from center to leading edge of knob
//        value = value > xrange.max ? xrange.max : value // limit to leading edge
//        value = value < xrange.min ? xrange.min : value // limit to trailing edge
//        value = value.convert(fromRange: (xrange.min, xrange.max), toRange: range)
//        self.value = value
//    }
//    
//    private func getOffsetX(frame: CGRect) -> CGFloat {
//        let width = (knob: knobWidth ?? frame.size.height, view: frame.size.width)
//        let xrange: (Double, Double) = (0, Double(width.view - width.knob))
//        let result = self.value.convert(fromRange: range, toRange: xrange)
//        return CGFloat(result)
//    }
//    
//    private func view(geometry: GeometryProxy) -> some View {
//      let frame = geometry.frame(in: .global)
//      let drag = DragGesture(minimumDistance: 0).onChanged({ drag in
//        self.onDragChange(drag, frame) }
//      )
//      let offsetX = self.getOffsetX(frame: frame)
//
//      let knobSize = CGSize(width: knobWidth ?? frame.height, height: frame.height)
//      let barLeftSize = CGSize(width: CGFloat(offsetX + knobSize.width * 0.5), height:  frame.height)
//      let barRightSize = CGSize(width: frame.width - barLeftSize.width, height: frame.height)
//
//      let modifiers = CustomSliderComponents(
//          barLeft: CustomSliderModifier(name: .barLeft, size: barLeftSize, offset: 0),
//          barRight: CustomSliderModifier(name: .barRight, size: barRightSize, offset: barLeftSize.width),
//          knob: CustomSliderModifier(name: .knob, size: knobSize, offset: offsetX))
//
//      return ZStack { viewBuilder(modifiers).gesture(drag) }
//    }
//}
