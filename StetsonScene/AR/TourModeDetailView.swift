//
//  TourModeDetailView.swift
//  StetsonScene
//
//  Created by Madison Gipson on 5/11/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation
import SwiftUI

struct TourModeDetailView: View {
    @ObservedObject var eventModelController:EventModelController
    @ObservedObject var buildingInstance:BuildingInstance
    //@ObservedObject var landmarkSupport:LandmarkSupport
    @Environment(\.colorScheme) var colorScheme
    //var image:UIImage = UIImage()
    //var buildingName:String
    //var builtDate:String! = "Built in 1900"
    //var buildingSummary:String! = "Description text goes here. Talk about the main usage of the building, maybe departments that reside here, activities done here, different things about the building that prospective students and visitors would care about."
    //var funFacts:String! = "The 'fun fact' about this building would go right here, but may be a little longer than this blurb."
    @State var num = 0
    
    var body: some View {
        VStack {
            Rectangle().foregroundColor(self.colorScheme == .dark ? Color.white : Constants.darkGray).opacity(0.6).cornerRadius(10).frame(width: Constants.screenSize.width/6, height: 5, alignment: .center)
            HStack {
                if buildingInstance.hasImg {
                    if !self.eventModelController.buildingModelController.isKeyInUserDefaults(key: buildingInstance.photoInfo) {
                        ZStack {
                            ActivityIndicator(isAnimating: .constant(true), style: .large)
                            FirebaseImage(id: buildingInstance.photoInfo, emc: self.eventModelController).clipShape(Circle()).frame(width: Constants.screenSize.width*0.3, height: Constants.screenSize.width*0.3).aspectRatio(contentMode: .fit).overlay(Circle().stroke(Color.white, lineWidth: 4)).shadow(radius: 10)
                            //first time image is loaded there's a gap between the image & outline
                        }
                    } else {
                        Image(uiImage: self.eventModelController.buildingModelController.retrieveImg(forKey: buildingInstance.photoInfo)!).resizable().clipShape(Circle()).frame(width: Constants.screenSize.width*0.3, height: Constants.screenSize.width*0.3).aspectRatio(contentMode: .fit).overlay(Circle().stroke(Color.white, lineWidth: 4)).shadow(radius: 10).padding(.horizontal)
                    }
                }
                VStack(alignment: .leading) {
                    Text(buildingInstance.buildingName).font(.system(size: 30, weight: .light, design: .default)).foregroundColor(Constants.brightYellow).padding(.vertical, 5)
                    Text("Est. \(buildingInstance.builtDate)").font(.system(size: 20, weight: .light, design: .default)).foregroundColor(self.colorScheme == .dark ? Color.white : Constants.darkGray)
                }.frame(alignment: .leading)
            }.padding([.horizontal]).padding(.vertical)
            
            Text(buildingInstance.buildingSummary).multilineTextAlignment(.leading).font(.system(size: 18, weight: .light, design: .default)).foregroundColor(self.colorScheme == .dark ? Color.white : Constants.medGray).padding([.horizontal]).frame(height: Constants.screenSize.height*0.45, alignment: .topLeading)
            
            Text("Fun Facts").font(.system(size: 20, weight: .light, design: .default)).foregroundColor(Constants.brightYellow)
            HStack() {
                //Left Button- only shows up when there are cells on the left
                if num > 0 {
                    Button(action: {
                        self.num -= 1
                    }) {
                        LinearGradient(gradient: .init(colors: [Constants.dark, Constants.light]), startPoint: .bottom, endPoint: .top).mask(Image(systemName: "chevron.left").resizable()).frame(width: Constants.screenSize.width*0.02, height: Constants.screenSize.width*0.07)
                    }
                }
                //Fun Fact cell
                //RecommendedCell(event: eventModelController.eventListRecLive[num], eventModelController: self.eventModelController).animation(.spring())
                ZStack {
                    Text(buildingInstance.funFacts[num]).font(.system(size: 18, weight: .light, design: .default)).foregroundColor(Constants.brightYellow).multilineTextAlignment(.center).lineLimit(3).padding([.horizontal, .vertical]).frame(width: Constants.screenSize.width*0.9, height: Constants.screenSize.height*0.15)
                }.background(
                    RoundedRectangle(cornerRadius: 10).stroke(Constants.brightYellow).background(Color.clear)).frame(width: Constants.screenSize.width*0.9, height: Constants.screenSize.height*0.15).transition(AnyTransition.slide).animation(.default)
                //Right Button- only shows up when there are cells on the right
                if num < buildingInstance.funFacts.count-1 {
                    Button(action: {
                        self.num += 1
                    }) {
                        LinearGradient(gradient: .init(colors: [Constants.dark, Constants.light]), startPoint: .bottom, endPoint: .top).mask(Image(systemName: "chevron.right").resizable()).frame(width: Constants.screenSize.width*0.02, height: Constants.screenSize.width*0.07)
                    }
                }
            }//HStack end
        }//VStack end
    }
}
