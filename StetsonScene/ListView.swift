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
    @EnvironmentObject var config: Configuration
    @Environment(\.colorScheme) var colorScheme
    var eventLocation: String? = ""
    
    var body: some View { 
        VStack(spacing: 0) {
            //LIST
            List {
                ForEach(config.eventViewModel.eventList) { event in
                    //have to do this by subpage then page to get the correct sub-lists
                    if (self.config.subPage == "AR" || self.config.subPage == "Map") && (event.location! == self.eventLocation!) {
                        if self.config.page == "Discover" || (self.config.page == "Favorites" && event.isFavorite) {
                            ListCell(event: event)
                        }
                    } else if (self.config.subPage == "List" || self.config.subPage == "Calendar") {
                        if self.config.page == "Discover" || (self.config.page == "Favorites" && event.isFavorite) {
                            ListCell(event: event)
                        }
                    }
                }.listRowBackground((config.page == "Favorites" && colorScheme == .light) ? config.accent : Color.secondarySystemBackground)
            }
        }
    } //end of View
}

//CONTENTS OF EACH EVENT CELL
struct ListCell : View {
    @EnvironmentObject var config: Configuration
    @Environment(\.colorScheme) var colorScheme
    var event: EventInstance
    @State var detailView: Bool = false
    
    var body: some View {
        ZStack {
            HStack {
                //Date & Time, Left Side
                VStack(alignment: .trailing) {
                    //TODO: CHANGE DATESTRING TO MONTH + DAY
                    Text(event.date).fontWeight(.medium).font(.system(size: config.subPage == "Calendar" ? 12 : 16)).foregroundColor(config.accent).padding(.vertical, config.subPage == "Calendar" ? 2 : 5)
                    Text(event.time).fontWeight(.medium).font(.system(size: config.subPage == "Calendar" ? 10 : 12)).foregroundColor(Color.secondaryLabel).padding(.bottom, config.subPage == "Calendar" ? 2 : 5)
                    //Duration?
                }.padding(.horizontal, 5)
                
                //Name & Location, Right Side
                VStack(alignment: .leading) {
                    Text(event.name).fontWeight(.medium).font(.system(size: config.subPage == "Calendar" ? 16 : 22)).lineLimit(1).foregroundColor(event.hasCultural ? config.accent :  Color.label).padding(.vertical, config.subPage == "Calendar" ? 2 : 5)
                    Text(event.location).fontWeight(.light).font(.system(size: config.subPage == "Calendar" ? 12 : 16)).foregroundColor(Color.secondaryLabel).padding(.bottom, config.subPage == "Calendar" ? 2 : 5)
                }
                
                Spacer() //fill out rest of cell
            }.padding(.vertical, config.subPage == "Calendar" ? 5 : 10).padding(.horizontal, config.subPage == "Calendar" ? 5 : 10) //padding within the cell, between words and borders
        }.background(RoundedRectangle(cornerRadius: 10).stroke(Color.clear).foregroundColor(Color.label).background(RoundedRectangle(cornerRadius: 10).foregroundColor(config.page == "Favorites" ? (colorScheme == .light ? Color.secondarySystemBackground : config.accent.opacity(0.1)) : Color.tertiarySystemBackground)))
            .padding(.top, (self.config.subPage == "AR" || self.config.subPage == "Map") ? 15 : 0)
            .onTapGesture { self.detailView = true }
            .sheet(isPresented: $detailView, content: { EventDetailView(event: self.event).environmentObject(self.config) })
    }
}
