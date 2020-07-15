////
////  RecommendationView.swift
////  StetsonScene
////
////  Created by Lannie Hough on 3/24/20.
////  Copyright © 2020 Madison Gipson. All rights reserved.
////
//
//import SwiftUI
//
//struct RecommendationView: View {
//    var event:EventInstance
//    @Environment(\.colorScheme) var colorScheme
//
//    var body: some View {
//        VStack {
//            HStack {
//                Text(event.name).font(.system(size: 16, weight: .light, design: .default)).lineLimit(1).padding([.horizontal, .top]).foregroundColor(event.hasCultural ? Constants.brightYellow: (colorScheme == .dark ? Color.white : Constants.darkGray))
//                Spacer()
//            }
//            HStack {
//                Text(event.date + " | " + event.time).fontWeight(.light).font(.system(size: 12)).padding([.horizontal]).foregroundColor(colorScheme == .dark ? Color.white : Constants.darkGray)
//                Spacer()
//            }
//            HStack {
//                Text(event.location).fontWeight(.light).font(.system(size: 12)).padding([.horizontal, .bottom]).foregroundColor(colorScheme == .dark ? Color.white : Constants.darkGray)
//                Spacer()
//            }
//        }.background(
//            RoundedRectangle(cornerRadius: 10).stroke(Constants.brightYellow).background(Color.clear)).frame(width: Constants.screenSize.width*0.8, height: Constants.screenSize.height*0.15)
//    }
//}
