//
//  ListView.swift
//  StetsonScene
//
//  Created by Madison Gipson on 7/15/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation
import SwiftUI

struct ListView : View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    var body: some View {
        VStack(spacing: 0) {
            //LIST
            List {
                ForEach(viewRouter.events) { event in
                    if self.viewRouter.page == "Favorites" && event.favorite { //only list favorites on Favorites screen
                        ListCell(event: event)
                    } else if self.viewRouter.page == "Discover" {
                        ListCell(event: event)
                    }
                }.listRowBackground(viewRouter.page == "Favorites" ? Color(Constants.accent1) : Color(Constants.bg1))
            }
        }
    } //end of View
}

//CONTENTS OF EACH EVENT CELL
struct ListCell : View {
    @EnvironmentObject var viewRouter: ViewRouter
    var event: Event
    @State var detailView: Bool = false
    
    var body: some View {
        ZStack {
            HStack {
                //Date & Time, Left Side
                VStack(alignment: .trailing) {
                    //TODO: CHANGE DATESTRING TO MONTH + DAY
                    Text(event.dateString).fontWeight(.medium).font(.system(size: viewRouter.subPage == "List" ? 16 : 12)).foregroundColor(Color(Constants.accent1)).padding(.vertical, viewRouter.subPage == "List" ? 5 : 2)
                    Text(event.time).fontWeight(.medium).font(.system(size: viewRouter.subPage == "List" ? 12 : 10)).foregroundColor(Color(Constants.text2).opacity(0.5)).padding(.bottom, viewRouter.subPage == "List" ? 5 : 2)
                    //Duration?
                }.padding(.horizontal, 5)
                
                //Name & Location, Right Side
                VStack(alignment: .leading) {
                    Text(event.name).fontWeight(.medium).font(.system(size: viewRouter.subPage == "List" ? 22 : 16)).lineLimit(1).foregroundColor(event.culturalCredit ? Color(Constants.accent1) :  Color(Constants.text1)).padding(.vertical, viewRouter.subPage == "List" ? 5 : 2)
                    Text(event.location).fontWeight(.light).font(.system(size: viewRouter.subPage == "List" ? 16 : 12)).foregroundColor(Color(Constants.text2).opacity(0.5)).padding(.bottom, viewRouter.subPage == "List" ? 5 : 2)
                }
                
                Spacer() //fill out rest of cell
            }.padding(.vertical, viewRouter.subPage == "List" ? 10 : 5).padding(.horizontal, viewRouter.subPage == "List" ? 10 : 5) //padding within the cell, between words and borders
        }.background(RoundedRectangle(cornerRadius: 10).stroke(Color(Constants.accent1)).foregroundColor(Color(Constants.text1)).background(RoundedRectangle(cornerRadius: 10).foregroundColor(viewRouter.page == "Favorites" ? Color(Constants.bg1): Color(Constants.bg2))))
            .onTapGesture { self.detailView = true }
            .sheet(isPresented: $detailView, content: { EventDetailView(event: self.event) })
        
    }
}
