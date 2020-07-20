//
//  HomeViewController.swift
//  StetsonScene
//
//  Created by Madison Gipson on 2/5/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//
import Foundation
import SwiftUI
import UIKit
import Combine

class ViewRouter: ObservableObject {
    let objectWillChange = PassthroughSubject<ViewRouter,Never>()
    var eventViewModel:EventViewModel
    
    init(_ viewModel: EventViewModel) {
        self.eventViewModel = viewModel
    }
    
    var page: String = "Trending" {
        didSet {
            objectWillChange.send(self)
        }
    }
    var subPage: String = "List" {
        didSet {
            objectWillChange.send(self)
        }
    }
    var showOptions: Bool = false {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    var events = [
        Event(id: 0, name: "Event 1", dateString: "7/1/2020", time: "9:00am", location: "CUB", attCount: 12, description: "testing testing testing event 1 testing testing testing testing testing testing", culturalCredit: false, favorite: true, trending: false),
        Event(id: 1, name: "Event 2", dateString: "7/1/2020", time: "10:00am", location: "Elizabeth Hall", attCount: 100, description: "testing testing testing testing testing testing testing testing testing", culturalCredit: false, favorite: true, trending: true),
        Event(id: 2, name: "Event 3", dateString: "7/2/2020", time: "11:00am", location: "DuPont Ball Library", attCount: 12, description: "testing testing testing testing testing testing testing testing testing event 3", culturalCredit: false, favorite: true, trending: false),
        Event(id: 3, name: "Event 4", dateString: "7/3/2020", time: "5:00pm", location: "Allen Hall", attCount: 5, description: "testing testing testing", culturalCredit: false, favorite: true, trending: true),
        Event(id: 4, name: "Event 5", dateString: "7/17/2020", time: "9:00am", location: "CUB", attCount: 12, description: "testing testing testing testing testing testing testing testing testing testing testing testing event 5", culturalCredit: true, favorite: true, trending: false),
        Event(id: 5, name: "Event 6", dateString: "7/7/2020", time: "10:00am", location: "Elizabeth Hall", attCount: 12, description: "testing testing testing  testing testing testingtesting testing testing testing testing testing event 6", culturalCredit: false, favorite: false, trending: true),
        Event(id: 6, name: "Event 7", dateString: "7/18/2020", time: "11:00am", location: "DuPont Ball Library", attCount: 1, description: "testing testing testing testing testing testing testing testing testing testing testing testing", culturalCredit: true, favorite: false, trending: false),
        Event(id: 7, name: "Event 8", dateString: "7/19/2020", time: "5:00pm", location: "Allen Hall", attCount: 50, description: "testing testing testing testing testing testing testing testing testing testing testing testing testing testing testing", culturalCredit: true, favorite: false, trending: true),
        Event(id: 8, name: "Event 9", dateString: "7/4/2020", time: "9:00pm", location: "Stetson Green", attCount: 0, description: "testing testing testing testing testing testing testing testing testing testing testing testing testing testing testing testing testing testing", culturalCredit: true, favorite: false, trending: false),
        Event(id: 9, name: "Event 10", dateString: "7/4/2020", time: "7:00pm", location: "Stetson Green", attCount: 12, description: "testing testing testing testing testing testing testing testing testing testing testing testing testing testing testing testing testing testing", culturalCredit: true, favorite: false, trending: true)
        ] {
        didSet {
            objectWillChange.send(self)
        }
    }
}

struct Event : Identifiable {
    var id : Int
    var name : String
    var dateString : String
    var date: Date?
    var month: String?
    var day: String?
    var weekday: String?
    var time : String
    var location : String
    var attCount: Int
    var description: String?
    var culturalCredit : Bool
    var favorite: Bool
    var trending: Bool
}


struct NavigationIndicator: UIViewControllerRepresentable {
    typealias UIViewControllerType = ARView
    
    func makeUIViewController(context: Context) -> ARView {
        return ARView()
    }
    func updateUIViewController(_ uiViewController: NavigationIndicator.UIViewControllerType, context: UIViewControllerRepresentableContext<NavigationIndicator>) { }
}


struct MainView : View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    var body: some View {
        ZStack {
            Color(viewRouter.page == "Favorites" ? Constants.accent1 : Constants.bg1).edgesIgnoringSafeArea(.all)
            VStack(spacing: 0){
                if viewRouter.page == "Trending" {
                    TrendingView()
                } else if viewRouter.page == "Discover" || viewRouter.page == "Favorites" {
                    if viewRouter.subPage == "List" || viewRouter.subPage == "Calendar" {
                        DiscoverFavoritesView().blur(radius: viewRouter.showOptions ? 5 : 0)
                    } else if viewRouter.subPage == "AR" {
                        NavigationIndicator().blur(radius: viewRouter.showOptions ? 5 : 0).edgesIgnoringSafeArea(.top)
                    } else if viewRouter.subPage == "Map" {
                        MapView().blur(radius: viewRouter.showOptions ? 5 : 0).edgesIgnoringSafeArea(.top)
                    }
                } else if viewRouter.page == "Information" {
                    InformationView().blur(radius: viewRouter.showOptions ? 5 : 0)
                }
                
                TabBar()
                
            }.edgesIgnoringSafeArea(.bottom)
            
        }.animation(.spring())
    }
}

struct TabBar : View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    var body: some View {
        ZStack {
            HStack(spacing: 20){
                //Trending
                HStack {
                    Image(systemName: "hand.thumbsup").resizable().frame(width: 20, height: 20).foregroundColor(viewRouter.page == "Trending" ? Color(Constants.bg2) : Color(Constants.text2))
                    Text(viewRouter.page == "Trending" ? viewRouter.page : "").fontWeight(.light).font(.system(size: 14)).foregroundColor(Color(Constants.bg2))
                }.padding(15)
                    .background(viewRouter.page == "Trending" ? Color(Constants.accent1) : Color.clear)
                    .clipShape(Capsule())
                    .onTapGesture {
                        self.viewRouter.page = "Trending"
                        self.viewRouter.showOptions = false
                }
                //Discover
                HStack {
                    Image(systemName: "magnifyingglass").resizable().frame(width: 20, height: 20).foregroundColor(viewRouter.page == "Discover" ? Color(Constants.bg2) : Color(Constants.text2))
                    Text(viewRouter.page == "Discover" ? viewRouter.page : "").fontWeight(.light).font(.system(size: 14)).foregroundColor(Color(Constants.bg2))
                }.padding(15)
                    .background(viewRouter.page == "Discover" ? Color(Constants.accent1) : Color.clear)
                    .clipShape(Capsule())
                    .onTapGesture {
                        if self.viewRouter.page == "Discover" {
                            self.viewRouter.showOptions.toggle()
                        } else {
                            self.viewRouter.showOptions = true
                        }
                        self.viewRouter.page = "Discover"
                }
                //Favorites
                HStack {
                    Image(systemName: "heart").resizable().frame(width: 20, height: 20).foregroundColor(viewRouter.page == "Favorites" ? Color(Constants.bg2) : Color(Constants.text2))
                    Text(viewRouter.page == "Favorites" ? viewRouter.page : "").fontWeight(.light).font(.system(size: 14)).foregroundColor(Color(Constants.bg2))
                }.padding(15)
                    .background(viewRouter.page == "Favorites" ? Color(Constants.accent1) : Color.clear)
                    .clipShape(Capsule())
                    .onTapGesture {
                        if self.viewRouter.page == "Favorites" {
                            self.viewRouter.showOptions.toggle()
                        } else {
                            self.viewRouter.showOptions = true
                        }
                        self.viewRouter.page = "Favorites"
                }
                //Info
                HStack {
                    Image(systemName: "info.circle").resizable().frame(width: 20, height: 20).foregroundColor(viewRouter.page == "Information" ? Color(Constants.bg2) : Color(Constants.text2))
                    Text(viewRouter.page == "Information" ? viewRouter.page : "").fontWeight(.light).font(.system(size: 14)).foregroundColor(Color(Constants.bg2))
                }.padding(15)
                    .background(viewRouter.page == "Information" ? Color(Constants.accent1) : Color.clear)
                    .clipShape(Capsule())
                    .onTapGesture {
                        self.viewRouter.page = "Information"
                        self.viewRouter.showOptions = false
                }
            }.padding(.vertical, 5)
                .frame(width: Constants.width)
                .background(Color(Constants.bg2))
                .animation(.default) //hstack end
            
            //other tabs
            if self.viewRouter.showOptions {
                TabOptions().offset(x: self.viewRouter.page == "Discover" ? -30 : 30, y: -60)
            }
            
        }//zstack end
    }
}

struct TabOptions: View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    var body: some View {
        HStack {
            //List
            ZStack {
                Circle()
                    .stroke(self.viewRouter.subPage == "List" ? Color(Constants.bg2) : Color(Constants.accent1))
                    .background(self.viewRouter.subPage == "List" ? Color(Constants.accent1) : Color(Constants.bg2))
                    .clipShape(Circle())
                Image(systemName: "list.bullet")
                    .resizable().frame(width: 20, height: 20)
                    .foregroundColor(self.viewRouter.subPage == "List" ? Color(Constants.bg2) : Color(Constants.accent1))
            }.frame(width: 50, height: 50)
                .offset(x: 10)
                .onTapGesture {
                    withAnimation {
                        self.viewRouter.subPage = "List"
                        self.viewRouter.showOptions = false
                    }
            }
            //Calendar
            ZStack {
                Circle()
                    .stroke(self.viewRouter.subPage == "Calendar" ? Color(Constants.bg2) : Color(Constants.accent1))
                    .background(self.viewRouter.subPage == "Calendar" ? Color(Constants.accent1) : Color(Constants.bg2))
                    .clipShape(Circle())
                Image(systemName: "calendar")
                    .resizable().frame(width: 20, height: 20)
                    .foregroundColor(self.viewRouter.subPage == "Calendar" ? Color(Constants.bg2) : Color(Constants.accent1))
            }.frame(width: 50, height: 50)
                .offset(y: -30)
                .onTapGesture {
                    withAnimation {
                        self.viewRouter.subPage = "Calendar"
                        self.viewRouter.showOptions = false
                    }
            }
            //AR
            ZStack {
                Circle()
                    .stroke(self.viewRouter.subPage == "AR" ? Color(Constants.bg2) : Color(Constants.accent1))
                    .background(self.viewRouter.subPage == "AR" ? Color(Constants.accent1) : Color(Constants.bg2))
                    .clipShape(Circle())
                Image(systemName: "camera")
                    .resizable().frame(width: 22, height: 18)
                    .foregroundColor(self.viewRouter.subPage == "AR" ? Color(Constants.bg2) : Color(Constants.accent1))
            }.frame(width: 50, height: 50)
                .offset(y: -30)
                .onTapGesture {
                    withAnimation {
                        self.viewRouter.subPage = "AR"
                        self.viewRouter.showOptions = false
                    }
            }
            //Map
            ZStack {
                Circle()
                    .stroke(self.viewRouter.subPage == "Map" ? Color(Constants.bg2) : Color(Constants.accent1))
                    .background(self.viewRouter.subPage == "Map" ? Color(Constants.accent1) : Color(Constants.bg2))
                    .clipShape(Circle())
                Image(systemName: "mappin.and.ellipse")
                    .resizable().frame(width: 20, height: 22)
                    .foregroundColor(self.viewRouter.subPage == "Map" ? Color(Constants.bg2) : Color(Constants.accent1))
            }.frame(width: 50, height: 50)
                .offset(x: -10)
                .onTapGesture {
                    withAnimation {
                        self.viewRouter.subPage = "Map"
                        self.viewRouter.showOptions = false
                    }
            }
        }.transition(.scale) //hstack
    }
}

