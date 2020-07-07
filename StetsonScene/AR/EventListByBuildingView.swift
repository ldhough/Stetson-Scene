//
//  EventListByBuilding.swift
//  StetsonScene
//
//  Created by Madison Gipson on 2/10/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import SwiftUI

struct EventListByBuildingView: View {
    var body: some View {
        Form {
            Text("hello world")
        }
    }
}
    
    /*var event:EventInstance
    @ObservedObject var eventModelController:EventModelController
    var body: some View {
        RoundedRectangle(cornerRadius: 10).fill(Color.gray).overlay(
            VStack {
                HStack {
                    Text(event.name)
                    Spacer()
                    //if
                    if event.hasCultural {
                        //Spacer()
                        CulturalCreditCircleView()
                    }
                }
                //Text(event.date)
            }
        )*/
        //Text("Home").foregroundColor(.blue).padding().overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 3))

/*struct EventListByBuilding_Previews: PreviewProvider {
    static var previews: some View {
        EventListByBuilding()
    }
}*/
