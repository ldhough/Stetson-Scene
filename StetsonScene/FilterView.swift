//
//  FilterView.swift
//  StetsonScene
//
//  Created by Madison Gipson on 7/15/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation
import SwiftUI

struct FilterView : View {
    
    @EnvironmentObject var config: Configuration
    
    @State var weeksDisplayed:Double = 1
    @State var weekdaysSelected:[Bool] = [false, false, false, false, false, false, false]
    @State var onlyCultural:Bool = false
    @State var eventTypesSelected:[String] = []
    
    func daysOfWeekView() -> some View {
        let systemImagesLetters:[String] = ["s.square", "m.square", "t.square", "w.square", "t.square", "f.square", "s.square"]
        return HStack {
            ForEach(0 ..< weekdaysSelected.count) { i in
            Button(action: {
                self.weekdaysSelected[i].toggle()
            }) {
                !self.weekdaysSelected[i] ? Image(systemName: systemImagesLetters[i]).foregroundColor(self.config.accent).scaleEffect(1.5).padding(.bottom).padding(.horizontal, Constants.width/28) : Image(systemName: systemImagesLetters[i] + ".fill").foregroundColor(self.config.accent).scaleEffect(1.5).padding(.bottom).padding(.horizontal, Constants.width/28)
            }
        }
        }
    }
    
    var body: some View {
        VStack {
            CustomSlider(value: $weeksDisplayed, range: (1, 20)) { modifiers in
              ZStack {
                LinearGradient(gradient: .init(colors: [self.config.accent, Color.blue]), startPoint: .leading, endPoint: .trailing)
                Text("Number of Weeks Displayed").font(.system(size: 16, weight: .light, design: .default)).foregroundColor(Color.white)
                ZStack {
                    Circle().fill(Color.black)
                    Text(("\(Int(self.weeksDisplayed))")).font(.system(size: 14, weight: .heavy, design: .default)).foregroundColor(Color.white)
                }
                .padding([.top, .bottom], 2)
                .modifier(modifiers.knob)
              }.cornerRadius(15)
            }.frame(height: 30).padding([.top, .bottom])
            daysOfWeekView()
            Divider().background(Color.black).opacity(0.25)
            Button(action: {
                
            }) {
                HStack {
                    Text("Cultural Credits").foregroundColor(self.config.accent).padding()
                    Spacer()
                    ZStack {
                        Image(systemName: "square").foregroundColor(Color.white).opacity(0.5).scaleEffect(1.5).padding()
                        if self.onlyCultural {
                            Image(systemName: "checkmark").foregroundColor(self.config.accent).padding()
                        }
                    }
                }
            }.foregroundColor(Color.white)
            Divider().background(Color.black).opacity(0.25)
            //Select event type view
            
            Divider().background(Color.black).opacity(0.25)
            Spacer()
            //Search Button
            Button("Search") {
                
            }
        }.padding()
    }
}

// SLIDER VIEW STUFF //

struct CustomSliderComponents {
    let barLeft: CustomSliderModifier
    let barRight: CustomSliderModifier
    let knob: CustomSliderModifier
}

struct CustomSliderModifier: ViewModifier {
    enum Name {
        case barLeft
        case barRight
        case knob
    }
    let name: Name
    let size: CGSize
    let offset: CGFloat

    func body(content: Content) -> some View {
        content
        .frame(width: size.width)
        .position(x: size.width*0.5, y: size.height*0.5)
        .offset(x: offset)
    }
}

struct CustomSlider<Component: View>: View {
    
    @Binding var value: Double
    var range: (Double, Double)
    var knobWidth: CGFloat?
    let viewBuilder: (CustomSliderComponents) -> Component

    init(value: Binding<Double>, range: (Double, Double), knobWidth: CGFloat? = nil,
         _ viewBuilder: @escaping (CustomSliderComponents) -> Component
    ) {
        _value = value
        self.range = range
        self.viewBuilder = viewBuilder
        self.knobWidth = knobWidth
    }

    var body: some View {
        return GeometryReader { geometry in
            self.view(geometry: geometry)
        }
    }
    
    private func onDragChange(_ drag: DragGesture.Value,_ frame: CGRect) {
        //haptic()
        let width = (knob: Double(knobWidth ?? frame.size.height), view: Double(frame.size.width))
        let xrange = (min: Double(0), max: Double(width.view - width.knob))
        var value = Double(drag.startLocation.x + drag.translation.width) // knob center x
        value -= 0.5*width.knob // offset from center to leading edge of knob
        value = value > xrange.max ? xrange.max : value // limit to leading edge
        value = value < xrange.min ? xrange.min : value // limit to trailing edge
        value = value.convert(fromRange: (xrange.min, xrange.max), toRange: range)
        self.value = value
    }
    
    private func getOffsetX(frame: CGRect) -> CGFloat {
        let width = (knob: knobWidth ?? frame.size.height, view: frame.size.width)
        let xrange: (Double, Double) = (0, Double(width.view - width.knob))
        let result = self.value.convert(fromRange: range, toRange: xrange)
        return CGFloat(result)
    }
    
    private func view(geometry: GeometryProxy) -> some View {
      let frame = geometry.frame(in: .global)
      let drag = DragGesture(minimumDistance: 0).onChanged({ drag in
        self.onDragChange(drag, frame) }
      )
      let offsetX = self.getOffsetX(frame: frame)

      let knobSize = CGSize(width: knobWidth ?? frame.height, height: frame.height)
      let barLeftSize = CGSize(width: CGFloat(offsetX + knobSize.width * 0.5), height:  frame.height)
      let barRightSize = CGSize(width: frame.width - barLeftSize.width, height: frame.height)

      let modifiers = CustomSliderComponents(
          barLeft: CustomSliderModifier(name: .barLeft, size: barLeftSize, offset: 0),
          barRight: CustomSliderModifier(name: .barRight, size: barRightSize, offset: barLeftSize.width),
          knob: CustomSliderModifier(name: .knob, size: knobSize, offset: offsetX))

      return ZStack { viewBuilder(modifiers).gesture(drag) }
    }
}

extension Double {
    func convert(fromRange: (Double, Double), toRange: (Double, Double)) -> Double {
        // Example: if self = 1, fromRange = (0,2), toRange = (10,12) -> solution = 11
        var value = self
        value -= fromRange.0
        value /= Double(fromRange.1 - fromRange.0)
        value *= toRange.1 - toRange.0
        value += toRange.0
        return value
    }
}
