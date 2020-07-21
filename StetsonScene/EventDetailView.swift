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
    
    @EnvironmentObject var viewRouter: ViewRouter
    var event: EventInstance
    
    var body: some View {
        VStack(spacing: 30) {
            RoundedRectangle(cornerRadius: 20).frame(width: Constants.width*0.25, height: 5, alignment: .center).foregroundColor(Color(Constants.text2).opacity(0.2)).padding(.bottom, CGFloat(10.0))
            
            ScrollView {
            //Event name
            Text(event.name).fontWeight(.medium).font(.system(size: 40)).frame(maxWidth: .infinity, alignment: .center).multilineTextAlignment(.center).foregroundColor(event.hasCultural ? Color(Constants.accent1) : Color(Constants.text1))
            //Info row
            HStack(spacing: 20) {
                Text(event.date).fontWeight(.light).font(.system(size: 20)).frame(maxWidth: .infinity, alignment: .trailing).foregroundColor(event.hasCultural ? Color(Constants.text1) : Color(Constants.accent1))
                VStack {
                    Image(systemName: "person.fill").resizable().frame(width: 20, height: 20).foregroundColor(event.hasCultural ? Color(Constants.text1) :  Color(Constants.accent1))
                    Text(String(event.numAttending)).fontWeight(.light).font(.system(size: 14)).foregroundColor(event.hasCultural ? Color(Constants.text1) : Color(Constants.accent1))
                }
                Text(event.time).fontWeight(.light).font(.system(size: 20)).frame(maxWidth: .infinity, alignment: .leading).foregroundColor(event.hasCultural ? Color(Constants.text1) : Color(Constants.accent1))
            }
            Rectangle().frame(width: Constants.width*0.75, height: 1, alignment: .center).foregroundColor(Color(Constants.text2).opacity(0.2))
            //Description
                Text(event.eventDescription!).fontWeight(.light).font(.system(size: 16)).multilineTextAlignment(.leading).foregroundColor(Color(Constants.text1)).padding(.horizontal, 10)
                Text("DETAILS").fontWeight(.light).font(.system(size: 16)).foregroundColor(Color(Constants.accent1)).padding(.top)
            }
            
            Spacer()
            Buttons()
        }.padding([.vertical]).background(Color(Constants.bg1)).edgesIgnoringSafeArea(.bottom)
    }
}

struct Buttons: View {
    var body: some View {
        HStack(spacing: 25) {
            ZStack {
                Circle().stroke(Color(Constants.accent1)).background(Color(Constants.bg2)).clipShape(Circle())
                Image(systemName: "square.and.arrow.up").resizable().frame(width: 18, height: 22).foregroundColor(Color(Constants.accent1))
            }.frame(width: 40, height: 40)
            
            ZStack {
                Circle().stroke(Color(Constants.accent1)).background(Color(Constants.bg2)).clipShape(Circle())
                Image(systemName: "calendar.badge.plus").resizable().frame(width: 22, height: 20).foregroundColor(Color(Constants.accent1))
            }.frame(width: 40, height: 40)
            
            ZStack {
                Circle().stroke(Color(Constants.bg2)).background(Color.pink).clipShape(Circle())
                Image(systemName: "heart").resizable().frame(width: 20, height: 20).foregroundColor(Color(Constants.bg2))
            }.frame(width: 40, height: 40)
            
            ZStack {
                Circle().stroke(Color(Constants.accent1)).background(Color(Constants.bg2)).clipShape(Circle())
                Image(systemName: "location").resizable().frame(width: 20, height: 20).foregroundColor(Color(Constants.accent1))
            }.frame(width: 40, height: 40)
        }.padding([.horizontal, .vertical])
    }
}
