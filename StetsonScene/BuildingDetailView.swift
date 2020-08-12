//
//  BuildingDetailView.swift
//  StetsonScene
//
//  Created by Madison Gipson on 8/11/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation
import SwiftUI
import CoreLocation

struct BuildingDetailView: View {
    @ObservedObject var evm:EventViewModel
    @EnvironmentObject var config: Configuration
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var buildingInstance:BuildingInstance
    
    @Binding var page:String
    @Binding var subPage:String
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 20).frame(width: Constants.width*0.25, height: 5, alignment: .center).foregroundColor(Color.secondaryLabel.opacity(0.2)).padding(.vertical, 10)
            Text(buildingInstance.buildingName).fontWeight(.medium).font(.system(size: 30)).frame(maxWidth: .infinity, alignment: .center).multilineTextAlignment(.center).foregroundColor(config.accent).padding([.horizontal]).padding(.bottom, 5)
                if buildingInstance.hasImg {
                    if !self.evm.buildingModelController.isKeyInUserDefaults(key: buildingInstance.photoInfo) {
                        ZStack {
                            //ActivityIndicator(isAnimating: .constant(true), style: .large)
                            FirebaseImage(id: buildingInstance.photoInfo, evm: self.evm).clipShape(Circle()).frame(width: Constants.width*0.3, height: Constants.width*0.3).aspectRatio(contentMode: .fit).overlay(Circle().stroke(Color.white, lineWidth: 4)).shadow(radius: 10)
                            //first time image is loaded there's a gap between the image & outline
                        }
                    } else {
                        Image(uiImage: self.evm.buildingModelController.retrieveImg(forKey: buildingInstance.photoInfo)!).resizable().clipShape(Circle()).frame(width: Constants.width*0.3, height: Constants.width*0.3).aspectRatio(contentMode: .fit).overlay(Circle().stroke(Color.white, lineWidth: 4)).shadow(radius: 10).padding(.horizontal)
                    }
                }
            Text("Est. \(buildingInstance.builtDate)").fontWeight(.light).font(.system(size: 20)).frame(maxWidth: Constants.width, alignment: .center).foregroundColor(Color.label)
            Rectangle().frame(width: Constants.width*0.75, height: 1, alignment: .center).foregroundColor(Color.secondaryLabel.opacity(0.2)).padding(.vertical, 10)
            Text(buildingInstance.buildingSummary).fontWeight(.light).font(.system(size: 16)).multilineTextAlignment(.leading).foregroundColor(Color.label).padding(.horizontal, 10)
            Spacer()
            Spacer()
        }.background(Color.secondarySystemBackground).edgesIgnoringSafeArea(.bottom)//VStack end
        //        VStack {
        //            RoundedRectangle(cornerRadius: 20).frame(width: Constants.width*0.25, height: 5, alignment: .center).foregroundColor(Color.secondaryLabel.opacity(0.2)).padding(.vertical, 10)
        //            //Event name
        //            Text(event.name).fontWeight(.medium).font(.system(size: 30)).frame(maxWidth: .infinity, alignment: .center).multilineTextAlignment(.center).foregroundColor(event.hasCultural ? config.accent : Color.label).padding([.horizontal]).padding(.bottom, 5)
        //            //Info row
        //            Text("\(event.date) | \(event.time)").fontWeight(.light).font(.system(size: 20)).frame(maxWidth: Constants.width, alignment: .center).foregroundColor(event.hasCultural ? Color.label : config.accent)
        //            Text("\(event.location)").fontWeight(.light).font(.system(size: 20)).frame(maxWidth: Constants.width, alignment: .center).foregroundColor(event.hasCultural ? Color.label : config.accent)
        //            //Divider
        //            Rectangle().frame(width: Constants.width*0.75, height: 1, alignment: .center).foregroundColor(Color.secondaryLabel.opacity(0.2)).padding(.vertical, 10)
        //
        //            ScrollView {
        //                //Description
        //                Text(event.eventDescription!).fontWeight(.light).font(.system(size: 16)).multilineTextAlignment(.leading).foregroundColor(Color.label).padding(.horizontal, 10)
        //                Text("DETAILS").fontWeight(.light).font(.system(size: 16)).foregroundColor(config.accent).padding(.top)
        //            }.padding([.horizontal]).padding(.bottom, 5)
        //        }.background(Color.secondarySystemBackground).edgesIgnoringSafeArea(.bottom)
    }
}
