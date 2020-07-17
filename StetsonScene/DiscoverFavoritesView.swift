//
//  DiscoverFavoritesView.swift
//  StetsonScene
//
//  Created by Madison Gipson on 7/15/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation
import SwiftUI

struct DiscoverFavoritesView : View { 
    @EnvironmentObject var viewRouter: ViewRouter
    @State var page: String
    @State var tab: String = "List"
    @State var filterApplied: Bool = false
    @State var filterView: Bool = false
    @State var detailView: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            //HEADER
            HStack {
                //Title
                Text(page).fontWeight(.heavy).font(.system(size: 50)).frame(maxWidth: .infinity, alignment: .leading).foregroundColor(Color(Constants.text1))
                
                //Filter Button
                if page == "Discover" {
                Image(systemName: "line.horizontal.3.decrease.circle")
                .resizable().frame(width: 25, height: 25).padding(.trailing, 10)
                    .foregroundColor(filterApplied ? Color(Constants.accent1) : Color(Constants.text2))
                .onTapGesture { self.filterView = true }
                .sheet(isPresented: $filterView, content: { FilterView() })
                }
                
                //Quick Search Button
                Image(systemName: "magnifyingglass")
                .resizable().frame(width: 25, height: 25).padding(.trailing, 10)
                .foregroundColor(Color(Constants.text2))
                
            }.padding([.vertical, .horizontal])
            
            //LIST AND CALENDAR TABS
            HStack {
                
                //List Tab (order of attributes matters)
                Text("List").fontWeight(.light).font(.system(size: 20))
                    .foregroundColor(tab == "List" ? Color(Constants.bg2) : Color(Constants.accent1)).padding(.vertical, 10)
                .frame(width: Constants.width*0.45)
                .background(tab == "List" ? Color(Constants.accent1) : Color(Constants.bg2))
                .cornerRadius(radius: 10, corners: [.topLeft, .topRight])
                .onTapGesture { self.tab = "List" }
                
                //Calendar Tab
                Text("Calendar").fontWeight(.light).font(.system(size: 20))
                .foregroundColor(tab == "Calendar" ? Color(Constants.bg2) : Color(Constants.accent1)).padding(.vertical, 10)
                .frame(width: Constants.width*0.45)
                .background(tab == "Calendar" ? Color(Constants.accent1): Color(Constants.bg2))
                .cornerRadius(radius: 10, corners: [.topLeft, .topRight])
                .onTapGesture { self.tab = "Calendar" }
            }
            
            //SMALL SPACER
            Rectangle().frame(width: Constants.width, height: 8).foregroundColor(Color(Constants.accent1))
            
            //LIST OR CALENDAR VIEW
            if tab == "List" {
                List {
                    ForEach(data) { event in
                        if self.page == "Favorites" && event.favorite {
                            DiscoverListCell(event: event, context: "List").onTapGesture { self.detailView = true }
                        } else if self.page == "Discover" {
                            DiscoverListCell(event: event, context: "List").onTapGesture { self.detailView = true }
                        }
                    }.listRowBackground(Color(Constants.accent1))
                }.sheet(isPresented: $detailView, content: { EventDetailView() })
            } else if tab == "Calendar" {
                CalendarView(page: self.page)
            }
            
        }//.background(Color(Constants.bg1))//end of largest VStack
    } //end of View
}

//CONTENTS OF EACH EVENT CELL
struct DiscoverListCell : View {
    var event: Type
    var context: String
    
    var body: some View {
        ZStack {
            HStack {
                //Date & Time, Left Side
                VStack(alignment: .trailing) {
                    //TODO: CHANGE DATESTRING TO MONTH + DAY
                    Text(event.dateString).fontWeight(.medium).font(.system(size: context == "List" ? 16 : 12)).foregroundColor(Color(Constants.accent1)).padding(.vertical, context == "List" ? 5 : 2)
                    Text(event.time).fontWeight(.medium).font(.system(size: context == "List" ? 12 : 10)).foregroundColor(Color(Constants.text2).opacity(0.5)).padding(.bottom, context == "List" ? 5 : 2)
                    //Duration?
                }.padding(.horizontal, 5)
                
                //Name & Location, Right Side
                VStack(alignment: .leading) {
                    Text(event.eventName).fontWeight(.medium).font(.system(size: context == "List" ? 22 : 16)).lineLimit(1).foregroundColor(Color(Constants.text1)).padding(.vertical, context == "List" ? 5 : 2)
                    Text(event.location).fontWeight(.light).font(.system(size: context == "List" ? 16 : 12)).foregroundColor(Color(Constants.text2).opacity(0.5)).padding(.bottom, context == "List" ? 5 : 2)
                }

                Spacer() //fill out rest of cell
            }.padding(.vertical, context == "List" ? 10 : 5).padding(.horizontal, context == "List" ? 10 : 5) //padding within the cell, between words and borders
            }.background(RoundedRectangle(cornerRadius: 10).stroke(Color(Constants.accent1)).foregroundColor(Color(Constants.text1)).background(RoundedRectangle(cornerRadius: 10).foregroundColor(context == "List" ? Color(Constants.bg2) : Color(Constants.bg1))))
    }
}

//ROUND SELECT CORNERS FOR TAB LOOK
struct CornerRadiusStyle: ViewModifier {
    var radius: CGFloat
    var corners: UIRectCorner
    
    struct CornerRadiusShape: Shape {
        
        var radius = CGFloat.infinity
        var corners = UIRectCorner.allCorners
        
        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            return Path(path.cgPath)
        }
    }
    
    func body(content: Content) -> some View {
        content
            .clipShape(CornerRadiusShape(radius: radius, corners: corners))
    }
}

extension View {
    func cornerRadius(radius: CGFloat, corners: UIRectCorner) -> some View {
        ModifiedContent(content: self, modifier: CornerRadiusStyle(radius: radius, corners: corners))
    }
}
