////
////  EventListNavigationView.swift
////  StetsonScene
////
////  Created by Lannie Hough on 2/9/20.
////  Copyright © 2020 Madison Gipson. All rights reserved.
////
//
//import SwiftUI
//
/////Visual appearance of event instances in List views
//struct EventListNavigationView: View {
//    var event:EventInstance
//    @Environment(\.colorScheme) var colorScheme
//    
//    var body: some View {
//        ZStack {
//            VStack {
//                HStack {
//                    if event.hasCultural {
//                        Text(event.name).font(.system(size: 16, weight: .light, design: .default)).lineLimit(1).padding([.horizontal, .top]).foregroundColor(Constants.brightYellow)
//                        Spacer()
//                    } else {
//                        Text(event.name).font(.system(size: 16, weight: .light, design: .default)).lineLimit(1).padding([.horizontal, .top])
//                        Spacer()
//                    }
//                }
//                HStack {
//                    Text(event.date + " | " + event.time).font(.system(size: 12, weight: .light, design: .default)).padding([.horizontal])
//                    Spacer()
//                }
//                HStack {
//                    Text(event.location).font(.system(size: 12, weight: .light, design: .default)).padding([.horizontal, .bottom])
//                    Spacer()
//                }
//            }
//            HStack {
//                Spacer()
//                Spacer()
//                Image(systemName: "chevron.right").resizable().frame(width: Constants.screenSize.width*0.02, height: colorScheme == .dark ? Constants.screenSize.height*0.035 : Constants.screenSize.height*0.04).foregroundColor(Constants.brightYellow).padding([.horizontal])
//            }
//        }.background(
//        RoundedRectangle(cornerRadius: 10).stroke(self.colorScheme == .light ? Constants.brightYellow : Constants.medGray).foregroundColor(self.colorScheme == .dark ? Constants.medGray : Color.white).background(RoundedRectangle(cornerRadius: 10).foregroundColor(self.colorScheme == .dark ? Constants.medGray : Color.white)))
//    }
//}
