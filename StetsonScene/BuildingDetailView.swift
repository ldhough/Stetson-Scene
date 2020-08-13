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
import FirebaseStorage

struct BuildingDetailView: View {
    @ObservedObject var evm:EventViewModel
    @EnvironmentObject var config: Configuration
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var buildingInstance:BuildingInstance //=self.evm.buildingModelController.buildingDic[(String(describing: hits.name!))]!
    
    @Binding var page:String
    @Binding var subPage:String
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 20).frame(width: Constants.width*0.25, height: 5, alignment: .center).foregroundColor(Color.secondaryLabel.opacity(0.2)).padding(.vertical, 10)
            Text(buildingInstance.buildingName).fontWeight(.medium).font(.system(size: 30)).frame(maxWidth: .infinity, alignment: .center).multilineTextAlignment(.center).foregroundColor(config.accent).padding([.horizontal]).padding(.bottom, 5)
            self.evm.buildingModelController.getImage(evm: self.evm, eventLocation: buildingInstance.buildingName).resizable().clipShape(Circle()).frame(width: Constants.width*0.3, height: Constants.width*0.3).aspectRatio(contentMode: .fit).overlay(Circle().stroke(Color.white, lineWidth: 4)).shadow(radius: 10)
            Text("Est. \(buildingInstance.builtDate)").fontWeight(.light).font(.system(size: 20)).frame(maxWidth: Constants.width, alignment: .center).foregroundColor(Color.label)
            Rectangle().frame(width: Constants.width*0.75, height: 1, alignment: .center).foregroundColor(Color.secondaryLabel.opacity(0.2)).padding(.vertical, 10)
            Text(buildingInstance.buildingSummary).fontWeight(.light).font(.system(size: 16)).multilineTextAlignment(.leading).foregroundColor(Color.label).padding(.horizontal, 10)
            Spacer()
            Spacer()
        }.background(Color.secondarySystemBackground).edgesIgnoringSafeArea(.bottom)//VStack end
    }
}
