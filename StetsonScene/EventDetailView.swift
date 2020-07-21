//
//  EventDetailView.swift
//  StetsonScene
//
//  Created by Madison Gipson on 7/15/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation
import SwiftUI

struct EventDetailView : View {
    @EnvironmentObject var config: Configuration
    var event: EventInstance
    
    var body: some View {
        VStack(spacing: 30) {
            RoundedRectangle(cornerRadius: 20).frame(width: Constants.width*0.25, height: 5, alignment: .center).foregroundColor(Color.secondaryLabel.opacity(0.2)).padding(.bottom, 10)
            
            ScrollView {
            //Event name
            Text(event.name).fontWeight(.medium).font(.system(size: 40)).frame(maxWidth: .infinity, alignment: .center).multilineTextAlignment(.center).foregroundColor(event.hasCultural ? config.accent : Color.label)
            //Info row
            HStack(spacing: 20) {
                Text(event.date).fontWeight(.light).font(.system(size: 20)).frame(maxWidth: .infinity, alignment: .trailing).foregroundColor(event.hasCultural ? Color.label : config.accent)
                VStack {
                    Image(systemName: "person.fill").resizable().frame(width: 20, height: 20).foregroundColor(event.hasCultural ? Color.label : config.accent)
                    Text(String(event.numAttending)).fontWeight(.light).font(.system(size: 14)).foregroundColor(event.hasCultural ? Color.label : config.accent)
                }
                Text(event.time).fontWeight(.light).font(.system(size: 20)).frame(maxWidth: .infinity, alignment: .leading).foregroundColor(event.hasCultural ? Color.label : config.accent)
            }
                Rectangle().frame(width: Constants.width*0.75, height: 1, alignment: .center).foregroundColor(Color.secondaryLabel.opacity(0.2)).padding(.vertical, 15)
            //Description
                Text(event.eventDescription!).fontWeight(.light).font(.system(size: 16)).multilineTextAlignment(.leading).foregroundColor(Color.label).padding(.horizontal, 10)
                Text("DETAILS").fontWeight(.light).font(.system(size: 16)).foregroundColor(config.accent).padding(.top)
            }
            
            Spacer()
            Buttons()
        }.padding([.vertical]).background(Color.secondarySystemBackground).edgesIgnoringSafeArea(.bottom)
    }
}

struct Buttons: View {
    @EnvironmentObject var config: Configuration
    var body: some View {
        HStack(spacing: 25) {
            ZStack {
                Circle().stroke(config.accent).background(Color.tertiarySystemBackground).clipShape(Circle())
                Image(systemName: "square.and.arrow.up").resizable().frame(width: 18, height: 22).foregroundColor(config.accent)
            }.frame(width: 40, height: 40)
            
            ZStack {
                Circle().stroke(config.accent).background(Color.tertiarySystemBackground).clipShape(Circle())
                Image(systemName: "calendar.badge.plus").resizable().frame(width: 22, height: 20).foregroundColor(config.accent)
            }.frame(width: 40, height: 40)
            
            ZStack {
                Circle().stroke(Color.tertiarySystemBackground).background(Color.pink).clipShape(Circle())
                Image(systemName: "heart").resizable().frame(width: 20, height: 20).foregroundColor(Color.tertiarySystemBackground)
            }.frame(width: 40, height: 40)
            
            ZStack {
                Circle().stroke(config.accent).background(Color.tertiarySystemBackground).clipShape(Circle())
                Image(systemName: "location").resizable().frame(width: 20, height: 20).foregroundColor(config.accent)
            }.frame(width: 40, height: 40)
        }.padding([.horizontal, .vertical])
    }
}
