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
                        .sheet(isPresented: $filterView, content: { FilterView().environmentObject(self.config) })
                }
                
                //Quick Search Button
                Image(systemName: "magnifyingglass")
                    .resizable().frame(width: 25, height: 25).padding(.trailing, 10)
                    .foregroundColor((config.page == "Favorites" && colorScheme == .light) ? Color.secondarySystemBackground : Color.secondaryLabel)
                
            }.padding([.vertical, .horizontal])
            
            //LIST OR CALENDAR
            if config.subPage == "List" {
                ListView()
            } else if config.subPage == "Calendar" {
                CalendarView()
            }
            
        }.background((config.page == "Favorites" && colorScheme == .light) ? config.accent : Color.secondarySystemBackground)
    }
}
