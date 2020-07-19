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
    @EnvironmentObject var viewRouter: ViewRouter
    @State var filterApplied: Bool = false
    @State var filterView: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            //HEADER
            HStack {
                //Title
                Text(viewRouter.page).fontWeight(.heavy).font(.system(size: 50)).frame(maxWidth: .infinity, alignment: .leading).foregroundColor(viewRouter.page == "Favorites" ? Color(Constants.bg2) : Color(Constants.text1))
                
                //Filter Button
                if viewRouter.page == "Discover" {
                    Image(systemName: "line.horizontal.3.decrease.circle")
                        .resizable().frame(width: 25, height: 25).padding(.trailing, 10)
                        .foregroundColor(filterApplied ? Color(Constants.accent1) : Color(Constants.text2))
                        .onTapGesture { self.filterView = true }
                        .sheet(isPresented: $filterView, content: { FilterView() })
                }
                
                //Quick Search Button
                Image(systemName: "magnifyingglass")
                    .resizable().frame(width: 25, height: 25).padding(.trailing, 10)
                    .foregroundColor(viewRouter.page == "Favorites" ? Color(Constants.bg1) : Color(Constants.text2))
                
            }.padding([.vertical, .horizontal])
            
            //LIST OR CALENDAR
            if viewRouter.subPage == "List" {
                ListView()
            } else if viewRouter.subPage == "Calendar" {
                CalendarView()
            }
            
        }
    }
}
