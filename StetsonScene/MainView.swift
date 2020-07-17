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
//import SceneKit
//import ARKit
//import ARCL
//import CoreLocation
//import MapKit
import Combine


///UIViewControllerRepresentable builds on View, struct is used inside SwiftUI view, view's body is ViewController - shows what UI kit sends back.
//struct NavigationIndicator: UIViewControllerRepresentable {
//    @ObservedObject var eventModelController:EventModelController
//    var event:EventInstance
//    var mode:String
//
//    typealias UIViewControllerType = ARTourViewController
//
//    //    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationIndicator>) -> NavigationIndicator.UIViewControllerType {
//    //        return ARTourViewController()
//    //    }
//    func makeUIViewController(context: Context) -> ARTourViewController {
//        return ARTourViewController(eventModelController: self.eventModelController, event: self.event, mode: self.mode)
//    }
//
//    func updateUIViewController(_ uiViewController: NavigationIndicator.UIViewControllerType, context: UIViewControllerRepresentableContext<NavigationIndicator>) {
//        //
//    }
//
//}

//struct PageButtonStyle: ButtonStyle {
//    @Environment(\.colorScheme) var colorScheme
//
//    func makeBody(configuration: Self.Configuration) -> some View {
//        return configuration.label
//            .foregroundColor(colorScheme == .dark ? Constants.darkGray : Color.white)
//            .frame(width: Constants.screenSize.width*0.12, height: Constants.screenSize.width*0.12)
//            //.background(brightYellow)
//            //.cornerRadius(15)
//            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
//    }
//}

class ViewRouter: ObservableObject {
    let objectWillChange = PassthroughSubject<ViewRouter,Never>()
    var currentPage: String = "Trending" {
        didSet {
            objectWillChange.send(self)
        }
    }
}


struct MainView : View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    var body: some View {
        ZStack { 
            Color(Constants.bg1).edgesIgnoringSafeArea(.all)
            VStack(spacing: 0){
                if viewRouter.currentPage == "Trending" {
                    TrendingView()
                } else if viewRouter.currentPage == "Discover" {
                    DiscoverFavoritesView(page: "Discover")
                } else if viewRouter.currentPage == "Favorites" {
                    DiscoverFavoritesView(page: "Favorites")
                } else if viewRouter.currentPage == "Information" {
                    InformationView()
                }
                
                TabBar()
                
            }.edgesIgnoringSafeArea(.bottom)
            
        }.animation(.spring())
    }
}

struct TabBar : View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    var body: some View {
        //ZStack {
        HStack(spacing: 20){
            //Trending
            HStack {
                Image(systemName: "hand.thumbsup").resizable().frame(width: 20, height: 20).foregroundColor(viewRouter.currentPage == "Trending" ? Color(Constants.bg2) : Color(Constants.text2))
                Text(viewRouter.currentPage == "Trending" ? viewRouter.currentPage : "").fontWeight(.light).font(.system(size: 14)).foregroundColor(Color(Constants.bg2))
            }.padding(15)
                .background(viewRouter.currentPage == "Trending" ? Color(Constants.accent1) : Color.clear)
                .clipShape(Capsule())
                .onTapGesture { self.viewRouter.currentPage = "Trending" }
            //Discover
            HStack {
                Image(systemName: "magnifyingglass").resizable().frame(width: 20, height: 20).foregroundColor(viewRouter.currentPage == "Discover" ? Color(Constants.bg2) : Color(Constants.text2))
                Text(viewRouter.currentPage == "Discover" ? viewRouter.currentPage : "").fontWeight(.light).font(.system(size: 14)).foregroundColor(Color(Constants.bg2))
            }.padding(15)
                .background(viewRouter.currentPage == "Discover" ? Color(Constants.accent1) : Color.clear)
                .clipShape(Capsule())
                .onTapGesture { self.viewRouter.currentPage = "Discover" }
            //Favorites
            HStack {
                Image(systemName: "heart").resizable().frame(width: 20, height: 20).foregroundColor(viewRouter.currentPage == "Favorites" ? Color(Constants.bg2) : Color(Constants.text2))
                Text(viewRouter.currentPage == "Favorites" ? viewRouter.currentPage : "").fontWeight(.light).font(.system(size: 14)).foregroundColor(Color(Constants.bg2))
            }.padding(15)
                .background(viewRouter.currentPage == "Favorites" ? Color(Constants.accent1) : Color.clear)
                .clipShape(Capsule())
                .onTapGesture { self.viewRouter.currentPage = "Favorites" }
            //Info
            HStack {
                Image(systemName: "info.circle").resizable().frame(width: 20, height: 20).foregroundColor(viewRouter.currentPage == "Information" ? Color(Constants.bg2) : Color(Constants.text2))
                Text(viewRouter.currentPage == "Information" ? viewRouter.currentPage : "").fontWeight(.light).font(.system(size: 14)).foregroundColor(Color(Constants.bg2))
            }.padding(15)
                .background(viewRouter.currentPage == "Information" ? Color(Constants.accent1) : Color.clear)
                .clipShape(Capsule())
                .onTapGesture { self.viewRouter.currentPage = "Information" }
        }.padding(.vertical, 5)
            .frame(width: Constants.width)
            .background(Color(Constants.bg2))
            .animation(.default)
    }
}

//TESTING PURPOSES ONLY- WILL PULL FROM EVENT OBJECT LATER
struct Type : Identifiable {
    var id : Int
    var eventName : String
    var dateString : String
    var date: Date?
    var month: String?
    var day: String?
    var weekday: String?
    var time : String
    var location : String
    var category : String
    var favorite: Bool
}

var data = [
    Type(id: 0, eventName: "Event 1", dateString: "7/1/2020", time: "9:00am", location: "CUB", category: "test", favorite: true),
    Type(id: 1, eventName: "Event 2", dateString: "7/1/2020", time: "10:00am", location: "Elizabeth Hall", category: "test", favorite: true),
    Type(id: 2, eventName: "Event 3", dateString: "7/2/2020", time: "11:00am", location: "DuPont Ball Library", category: "test", favorite: true),
    Type(id: 3, eventName: "Event 4", dateString: "7/3/2020", time: "5:00pm", location: "Allen Hall", category: "test", favorite: true),
    Type(id: 4, eventName: "Event 5", dateString: "7/17/2020", time: "9:00am", location: "CUB", category: "test", favorite: true),
    Type(id: 5, eventName: "Event 6", dateString: "7/7/2020", time: "10:00am", location: "Elizabeth Hall", category: "test", favorite: false),
    Type(id: 6, eventName: "Event 7", dateString: "7/18/2020", time: "11:00am", location: "DuPont Ball Library", category: "test", favorite: false),
    Type(id: 7, eventName: "Event 8", dateString: "7/19/2020", time: "5:00pm", location: "Allen Hall", category: "test", favorite: false),
    Type(id: 8, eventName: "Event 9", dateString: "7/4/2020", time: "9:00pm", location: "Stetson Green", category: "test", favorite: false),
    Type(id: 9, eventName: "Event 10", dateString: "7/4/2020", time: "7:00pm", location: "Stetson Green", category: "test", favorite: false)
]
