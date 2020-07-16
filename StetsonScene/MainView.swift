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
import SceneKit
import ARKit
import ARCL
import CoreLocation
import MapKit

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


struct MainView : View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    var body: some View {
        ZStack {
            Color(Constants.bg1).edgesIgnoringSafeArea(.all)
        VStack(spacing: 0){
            if viewRouter.currentPage == "Trending" {
                TrendingView()
            } else if viewRouter.currentPage == "Discover" {
                DiscoverView()
            } else if viewRouter.currentPage == "Favorites" {
                FavoriteView()
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

struct HomeViewController: View/*, UIViewControllerRepresentable*/ {
    //    @ObservedObject var eventModelController:EventModelController
    //    @Environment(\.colorScheme) var colorScheme
    //    var event:EventInstance
    //    @ObservedObject var landmarkSupport:LandmarkSupport //new
    //    @State var page:String = "Event List"
    //    @State var icon:String = "calendar"
    //    @State var selectScreen:Bool = false
    //    @State private var rightSide:Bool = true
    //    @State private var xOffset:CGFloat = 0
    //    @State private var yOffset:CGFloat = 0
    //    @State private var animationAmount = 0.0
    //    var menuDrag: some Gesture {
    //        DragGesture().onChanged { value in
    //            self.xOffset = value.location.x
    //            self.yOffset = value.location.y
    //        }.onEnded { value in
    //            if (self.rightSide && value.translation.width < -(Constants.screenSize.width*0.5)) ||
    //                (!self.rightSide && value.translation.width > Constants.screenSize.width*0.5){
    //                self.rightSide.toggle()
    //            }
    //            self.xOffset = 0
    //            self.yOffset = 0
    //        }
    //    }
    
    var body: some View {
        Text("Hello")
        //        ZStack(alignment: rightSide ? .bottomTrailing : .bottomLeading) {
        //            (colorScheme == .dark ? Constants.darkGray : Color.white).edgesIgnoringSafeArea(.all)
        //            VStack {
        //                if page == "Event List" {
        //                    EventViewController(eventModelController: self.eventModelController)
        //                }
        //                if page == "AR" {
        //                    NavigationIndicator(eventModelController: self.eventModelController, event: self.event, mode: "tour").edgesIgnoringSafeArea(.all)
        //                }
        //                if page == "Map" {
        //                    ContentView(landmarkSupport: self.landmarkSupport, eventModelController: self.eventModelController).edgesIgnoringSafeArea(.all) //landmark support new
        //                }
        //                if page == "Favorite List" {
        //                    FavoriteView(eventModelController: self.eventModelController)
        //                }
        //                if page == "Information View"  {
        //                    InformationView(eventModelController: self.eventModelController)
        //                }
        //            }
        //            ZStack {
        //                VStack {
        //                    if !self.eventModelController.navMap && !self.eventModelController.navAR && self.eventModelController.dataReturnedFromSnapshot {
        //                    if selectScreen {
        //                        Button(action: {
        //                            self.page = "Information View"
        //                            self.icon = "info.circle"
        //                        }) {
        //                            Image(systemName: "info.circle").resizable().frame(width: Constants.screenSize.width*0.07, height: Constants.screenSize.width*0.07)
        //                            }.buttonStyle(PageButtonStyle(colorScheme: self._colorScheme)).background(Constants.light).cornerRadius(15)
        //                        if self.eventModelController.eventMode {
        //                            Button(action: {
        //                                self.page = "Favorite List"
        //                                self.eventModelController.retrieveFavoriteFirebaseData()
        //                                self.eventModelController.recommendationEngine.runRecommendationEngine()
        //                                self.icon = "heart"
        //                            }) {
        //                                Image(systemName: "heart").resizable().frame(width: Constants.screenSize.width*0.07, height: Constants.screenSize.width*0.07)
        //                                }.buttonStyle(PageButtonStyle(colorScheme: self._colorScheme)).background(Constants.lightmed).cornerRadius(15)
        //                        }
        //                        Button(action: {
        //                            self.page = "AR"
        //                            self.icon = "arkit"
        //                        }) {
        //                            Image(systemName: "arkit").resizable().frame(width: Constants.screenSize.width*0.07, height: Constants.screenSize.width*0.07)
        //                            }.buttonStyle(PageButtonStyle(colorScheme: self._colorScheme)).background(Constants.med).cornerRadius(15)
        //                        Button(action: {
        //                            self.landmarkSupport.createAllNodes() //new
        //                            self.page = "Map"
        //                            self.icon = "mappin.and.ellipse"
        //                        }) {
        //                            Image(systemName: "mappin.and.ellipse").resizable().frame(width: Constants.screenSize.width*0.07, height: Constants.screenSize.width*0.07)
        //                        }.buttonStyle(PageButtonStyle(colorScheme: self._colorScheme)).background(self.eventModelController.eventMode ? Constants.darkmed : Constants.dark).cornerRadius(15)
        //                        if self.eventModelController.eventMode {
        //                            Button(action: {
        //                                self.page = "Event List"
        //                                self.icon = "calendar"
        //                            }) {
        //                                Image(systemName: "calendar").resizable().frame(width: Constants.screenSize.width*0.07, height: Constants.screenSize.width*0.07)
        //                            }.buttonStyle(PageButtonStyle(colorScheme: self._colorScheme)).background(Constants.dark).cornerRadius(15)
        //                        }
        //                    }
        //                    //current screen
        //                    Button(action: {
        //                        self.selectScreen.toggle()
        //                    }) {
        //                        ZStack {
        //                            LinearGradient(gradient: .init(colors: [Constants.dark, Constants.light]), startPoint: .topTrailing, endPoint: .bottomLeading).mask(RoundedRectangle(cornerRadius: 15)).frame(width: Constants.screenSize.width*0.12, height: Constants.screenSize.width*0.12)
        //                            Image(systemName: selectScreen ? "chevron.up" : icon).resizable().foregroundColor(colorScheme == .dark ? Constants.darkGray : Color.white).frame(width: Constants.screenSize.width*0.07, height: selectScreen ? Constants.screenSize.width*0.02 : Constants.screenSize.width*0.07)
        //                        }
        //                    }.animation(.spring()).gesture(menuDrag)
        //                }//if end
        //                }.offset(x: xOffset, y: yOffset).padding([Constants.screenSize.height < 700 ? .all : (rightSide ? .trailing : .leading)]).animation(.spring()).gesture(menuDrag) //VStack end
        //            }//ZStack end
        //            if !self.eventModelController.hasFirebaseConnection {
        //                ZStack {
        //                    Rectangle().foregroundColor(colorScheme == .dark ? Constants.darkGray : Color.white).edgesIgnoringSafeArea(.all)
        //                    VStack {
        //                        Text("Cannot connect to the server :(").foregroundColor(colorScheme == .dark ? Color.white : Color.black)
        //                        Text("Find internet or try again later!").foregroundColor(colorScheme == .dark ? Color.white : Color.black)
        //                    }
        //                }
        //            }
        //
        //        } //ZStack end
    }//View end
}//Struct end
