//
//  FavoriteView.swift
//  StetsonScene
//
//  Created by Lannie Hough on 3/24/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import SwiftUI

struct FavoriteView: View {
    @ObservedObject var eventModelController:EventModelController
    @State private var showDetailForm = false
    @Environment(\.colorScheme) var colorScheme
    @State private var num = 0
    
    var body: some View {
        return VStack {
            //Title comes from EventListView, don't worry about it here
            EventListView(eventModelController: self.eventModelController, listingWhatView: "Favorite List")
            Text("Recommended").font(.system(size: 22, weight: .light, design: .default)).foregroundColor(Constants.brightYellow).padding([.horizontal]).padding([.top])
            HStack() {
                //Left Button- only shows up when there are cells on the left
                if num > 0 {
                    Button(action: {
                        self.num -= 1
                    }) {
                        LinearGradient(gradient: .init(colors: [Constants.dark, Constants.light]), startPoint: .bottom, endPoint: .top).mask(Image(systemName: "chevron.left").resizable()).frame(width: Constants.screenSize.width*0.02, height: Constants.screenSize.width*0.07)
                    }
                }
                //Event cell
                RecommendedCell(event: eventModelController.eventListRecLive[num], eventModelController: self.eventModelController).transition(AnyTransition.slide).animation(.spring())
                //Right Button- only shows up when there are cells on the right
                if num < eventModelController.eventListRecLive.count-1 {
                    Button(action: {
                        self.num += 1
                    }) {
                        LinearGradient(gradient: .init(colors: [Constants.dark, Constants.light]), startPoint: .bottom, endPoint: .top).mask(Image(systemName: "chevron.right").resizable()).frame(width: Constants.screenSize.width*0.02, height: Constants.screenSize.width*0.07)
                    }
                }
            }
        }
    }
}

struct RecommendedCell: View {
    @ObservedObject var event:EventInstance
    @ObservedObject var eventModelController:EventModelController
    @State private var showDetailForm = false
    
    var body: some View {
        Button(action: {
            self.showDetailForm.toggle()
        }) {
            RecommendationView(event: self.event).padding([.horizontal])
        }.sheet(isPresented: self.$showDetailForm) {
            EventDetailView(event: self.event, numAttendingState: self.event.numAttending, isFavorite: self.event.isFavorite, eventModelController: self.eventModelController) //if favorited, update main ModelController & local EventInstance
        }
    }
    
}
