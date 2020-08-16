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
    
    @Binding var page:String
    @Binding var subPage:String
    
    @State var searchBarVisible = false
    
    var body: some View {
        VStack(spacing: 0) {
            //HEADER
            HStack {
                //Title
                Text(self.page).fontWeight(.heavy).font(.system(size: 50)).frame(maxWidth: .infinity, alignment: .leading).foregroundColor((self.page == "Favorites" && colorScheme == .light) ? Color.tertiarySystemBackground : Color.label)
                
                //Filter Button
                if self.page == "Discover" && self.subPage == "List" {
                    Image(systemName: "line.horizontal.3.decrease.circle")
                        .resizable().frame(width: 25, height: 25).padding(.trailing, 10)
                        .foregroundColor(filterApplied ? config.accent : Color.secondaryLabel)
                        .onTapGesture {
                            self.filterView = true
                            print("tapped ")
                    }
                    .sheet(isPresented: $filterView, content: { FilterView(evm: self.evm, filterView: self.$filterView, filterApplied: self.$filterApplied, weeksDisplayed:  Double(self.evm.eventSearchEngine.weeksDisplayed), weekdaysSelected:  self.evm.eventSearchEngine.weekdaysSelected, onlyCultural: self.evm.eventSearchEngine.onlyCultural, onlyVirtual: self.evm.eventSearchEngine.onlyVirtual, eventTypesSelected: { 
                        
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
                if self.page == "Discover" && self.subPage == "List" {
                    Image(systemName: "magnifyingglass")
                        .resizable().frame(width: 25, height: 25).padding(.trailing, 10)
                        .foregroundColor((self.page == "Favorites" && colorScheme == .light) ? Color.secondarySystemBackground : Color.secondaryLabel)
                        .onTapGesture {
                            self.searchBarVisible.toggle()
                        }
                }
            }.padding([.top, .horizontal])
            
            if searchBarVisible {
                SearchBar(evm: self.evm)
            }
            
        }.background((self.page == "Favorites" && colorScheme == .light) ? config.accent : Color.secondarySystemBackground)
    }
}
