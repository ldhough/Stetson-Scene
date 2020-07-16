//
//  DiscoverView.swift
//  StetsonScene
//
//  Created by Madison Gipson on 7/15/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation
import SwiftUI

struct DiscoverView : View {
    @EnvironmentObject var viewRouter: ViewRouter
    @State var discoverView: String = "List"
    @State var filterApplied: Bool = false
    @State var filterView: Bool = false
    @State var detailView: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            //HEADER
            HStack {
                //Title
                Text("Discover").fontWeight(.heavy).font(.system(size: 50)).frame(maxWidth: .infinity, alignment: .leading).foregroundColor(Color(Constants.text1))
                
                //Filter Button
                Image(systemName: "line.horizontal.3.decrease.circle")
                .resizable().frame(width: 25, height: 25).padding(.trailing, 10)
                    .foregroundColor(filterApplied ? Color(Constants.accent1) : Color(Constants.text2))
                .onTapGesture { self.filterView = true }
                .sheet(isPresented: $filterView, content: { FilterView() })
                
                //Quick Search Button
                Image(systemName: "magnifyingglass")
                .resizable().frame(width: 25, height: 25).padding(.trailing, 10)
                .foregroundColor(Color(Constants.text2))
                
            }.padding([.vertical, .horizontal])
            
            //LIST AND CALENDAR TABS
            HStack {
                
                //List Tab (order of attributes matters)
                Text("List").fontWeight(.light).font(.system(size: 20))
                    .foregroundColor(discoverView == "List" ? Color(Constants.bg2) : Color(Constants.accent1)).padding(.vertical, 10)
                .frame(width: Constants.width*0.45)
                .background(discoverView == "List" ? Color(Constants.accent1) : Color(Constants.bg2))
                .cornerRadius(radius: 10, corners: [.topLeft, .topRight])
                .onTapGesture { self.discoverView = "List" }
                
                //Calendar Tab
                Text("Calendar").fontWeight(.light).font(.system(size: 20))
                .foregroundColor(discoverView == "Calendar" ? Color(Constants.bg2) : Color(Constants.accent1)).padding(.vertical, 10)
                .frame(width: Constants.width*0.45)
                .background(discoverView == "Calendar" ? Color(Constants.accent1): Color(Constants.bg2))
                .cornerRadius(radius: 10, corners: [.topLeft, .topRight])
                .onTapGesture { self.discoverView = "Calendar" }
            }
            
            //SMALL SPACER
            Rectangle().frame(width: Constants.width, height: 8).foregroundColor(Color(Constants.accent1))
            
            //LIST OR CALENDAR VIEW
            if discoverView == "List" {
                List {
                    ForEach(data) { event in
                        DiscoverListCell(event: event).onTapGesture { self.detailView = true }
                    }.listRowBackground(Color(Constants.accent1))
                }.sheet(isPresented: $detailView, content: { EventDetailView() })
            } else if discoverView == "Calendar" {
                CalendarView()
            }
            
        }//.background(Color(Constants.bg1))//end of largest VStack
    } //end of View
}

//CONTENTS OF EACH EVENT CELL
struct DiscoverListCell : View {
    var event: Type
    
    var body: some View {
        ZStack {
            HStack {
                //Date & Time, Left Side
                VStack(alignment: .trailing) {
                    Text(event.date).fontWeight(.medium).font(.system(size: 16)).foregroundColor(Color(Constants.accent1)).padding(.vertical, 5)
                    Text(event.time).fontWeight(.medium).font(.system(size: 12)).foregroundColor(Color(Constants.text2).opacity(0.5)).padding(.bottom, 5)
                    //Duration?
                }.frame(width: Constants.width*0.2)
                
                //Name & Location, Right Side
                VStack(alignment: .leading) {
                    Text(event.eventName).fontWeight(.medium).font(.system(size: 22)).lineLimit(1).foregroundColor(Color(Constants.text1)).padding(.vertical, 5)
                    Text(event.location).fontWeight(.light).font(.system(size: 16)).foregroundColor(Color(Constants.text2).opacity(0.5)).padding(.bottom, 5)
                }
                
                //Fill out rest of cell
                Spacer()
                
            }.padding(([.vertical, .horizontal])) //padding within the cell, between words and borders
        }.background(RoundedRectangle(cornerRadius: 10).stroke(Color(Constants.accent1)).foregroundColor(Color(Constants.text1)).background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color(Constants.bg2))))
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
