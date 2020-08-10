//
//  DiscoverFavoritesView.swift
//  StetsonScene
//
//  Created by Madison Gipson on 7/19/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation
import SwiftUI

struct DiscoverFavoritesView : View {
    @ObservedObject var evm:EventViewModel
    @EnvironmentObject var config: Configuration
    @Environment(\.colorScheme) var colorScheme
    @State var filterApplied: Bool = false
    @State var filterView: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            //HEADER
            HStack {
                //Title
                Text(config.page).fontWeight(.heavy).font(.system(size: 50)).frame(maxWidth: .infinity, alignment: .leading).foregroundColor((config.page == "Favorites" && colorScheme == .light) ? Color.tertiarySystemBackground : Color.label)
                
                //Filter Button
                if config.page == "Discover" {
                    Image(systemName: "line.horizontal.3.decrease.circle")
                        .resizable().frame(width: 25, height: 25).padding(.trailing, 10)
                        .foregroundColor(filterApplied ? config.accent : Color.secondaryLabel)
                        .onTapGesture {
                            self.filterView = true
                            print("tapped ")
                    }
                    .sheet(isPresented: $filterView, content: { FilterView(evm: self.evm, filterView: self.$filterView, weeksDisplayed:  Double(self.evm.eventSearchEngine.weeksDisplayed), weekdaysSelected:  self.evm.eventSearchEngine.weekdaysSelected, onlyCultural: self.evm.eventSearchEngine.onlyCultural, onlyVirtual: self.evm.eventSearchEngine.onlyVirtual, eventTypesSelected: {
                        
                            if self.evm.eventSearchEngine.eventTypeSet == [] && UserDefaults.standard.object(forKey: "firstTypeLoad") == nil {
                                //If no event types are being filtered on and it is the first time that the eventTypeSet has been computed (which will result in empty set), use the full event type set to have all event types selected in filter view
                                return self.evm.eventTypeSetFull
                            } else {
                                return self.evm.eventSearchEngine.eventTypeSet
                            }
                    }() ).environmentObject(self.config)
                        
                    })
                }
                
                //Quick Search Button
                Image(systemName: "magnifyingglass")
                    .resizable().frame(width: 25, height: 25).padding(.trailing, 10)
                    .foregroundColor((config.page == "Favorites" && colorScheme == .light) ? Color.secondarySystemBackground : Color.secondaryLabel)
                
            }.padding([.vertical, .horizontal])
            
            //IF IT'S FAVORITES PAGE BUT THERE AREN'T ANY FAVORITES
            if self.config.page == "Favorites" && !evm.doFavoritesExist(list: self.evm.eventList) {
                VStack(alignment: .center, spacing: 10) {
                    Text("No Events Favorited").fontWeight(.light).font(.system(size: 20)).padding([.horizontal]).foregroundColor(config.accent)
                    Text("Add some events to your favorites by using the hard-press shortcut on the event preview or the favorite button on the event detail page.").fontWeight(.light).font(.system(size: 16)).padding([.horizontal]).foregroundColor(Color.label)
                    Spacer()
                    Spacer()
                }
            }
            //LIST OR CALENDAR
            else if config.subPage == "List" {
                ListView(evm: self.evm)
            } else if config.subPage == "Calendar" {
                CalendarView(evm: self.evm)
            }
            
        }.background((config.page == "Favorites" && colorScheme == .light) ? config.accent : Color.secondarySystemBackground)
    }
}
