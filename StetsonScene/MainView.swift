//
//  MainView.swift
//  StetsonScene
//
//  Created by Madison Gipson on 2/5/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//
import Foundation
import SwiftUI
import UIKit

struct ARNavigationIndicator: UIViewControllerRepresentable {
    @ObservedObject var evm:EventViewModel
    typealias UIViewControllerType = ARView
    @EnvironmentObject var config: Configuration
    var arFindMode: Bool
    var navToEvent: EventInstance?
    @Binding var internalAlert: Bool
    @Binding var externalAlert: Bool
    @Binding var tooFar: Bool
    @Binding var allVirtual: Bool
    @Binding var arrived: Bool
    @Binding var eventDetails: Bool
    
    @Binding var page:String
    @Binding var subPage:String
    
    func makeUIViewController(context: Context) -> ARView {
        return ARView(evm: self.evm, config: self.config, arFindMode: self.arFindMode, navToEvent: self.navToEvent ?? EventInstance(), internalAlert: self.$internalAlert, externalAlert: self.$externalAlert, tooFar: self.$tooFar, allVirtual: self.$allVirtual, arrived: self.$arrived, eventDetails: self.$eventDetails, page: self.$page, subPage: self.$subPage)
    }
    func updateUIViewController(_ uiViewController: ARNavigationIndicator.UIViewControllerType, context: UIViewControllerRepresentableContext<ARNavigationIndicator>) { }
}

struct ActivityIndicator: UIViewRepresentable { //loading wheel
    let color:UIColor
    //let brightYellow = UIColor(red: 255/255, green: 196/255, blue: 0/255, alpha: 1.0)
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: style)
        activityIndicator.color = color
        return activityIndicator//UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

struct MainView : View {
    @ObservedObject var evm:EventViewModel
    @EnvironmentObject var config: Configuration
    @Environment(\.colorScheme) var colorScheme
    @State var listVirtualEvents:Bool = false
    @State var noFavorites: Bool = false
    @State var showOptions: Bool = false
    //for alerts
    @State var externalAlert: Bool = false
    @State var tooFar: Bool = false
    @State var allVirtual: Bool = true
    
    
    @State var page:String = "Discover" //Discover, Favorites, Trending, Information
    @State var subPage:String = "List" //List, Calendar, AR, Map
    
    
    var body: some View {
        ZStack {
            Color((self.page == "Favorites" && colorScheme == .light) ? config.accentUIColor : UIColor.secondarySystemBackground).edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                ZStack {
                    if self.page == "Trending" {
                        TrendingView(evm: self.evm, page: self.$page, subPage: self.$subPage)
                    }
                    if self.page == "Discover" || self.page == "Favorites" {
                        if self.subPage == "List" {
                            VStack {
                                DiscoverFavoritesView(evm: self.evm, page: self.$page, subPage: self.$subPage)
                                //IF IT'S FAVORITES PAGE BUT THERE AREN'T ANY FAVORITES
                                if self.page == "Favorites" && !evm.doFavoritesExist(list: self.evm.eventList) {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("No Events Favorited").fontWeight(.light).font(.system(size: 16)).padding([.horizontal]).foregroundColor((self.page == "Favorites" && colorScheme == .light) ? Color.tertiarySystemBackground : Color.label)
                                        Text("Add some events to your favorites by using the hard-press shortcut on the event preview or the favorite button on the event detail page.").fontWeight(.light).font(.system(size: 16)).padding([.horizontal]).foregroundColor((self.page == "Favorites" && colorScheme == .light) ? Color.tertiarySystemBackground : Color.label)
                                        Spacer()
                                        Spacer()
                                    }.padding(.vertical, 10)
                                } else {
                                    if self.evm.dataReturnedFromSnapshot {
                                        ListView(evm: self.evm, page: self.$page, subPage: self.$subPage)
                                    } else {
                                        Spacer()
                                        ActivityIndicator(color: config.accentUIColor ,isAnimating: .constant(true), style: .large)
                                        Spacer()
                                    }
                                }
                            }.blur(radius: self.showOptions ? 5 : 0).disabled(self.showOptions ? true : false)
                        }
                        if self.subPage == "Calendar" {
                            VStack {
                                DiscoverFavoritesView(evm: self.evm, page: self.$page, subPage: self.$subPage)
                                //IF IT'S FAVORITES PAGE BUT THERE AREN'T ANY FAVORITES
                                if self.page == "Favorites" && !evm.doFavoritesExist(list: self.evm.eventList) {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("No Events Favorited").fontWeight(.light).font(.system(size: 16)).padding([.horizontal]).foregroundColor((self.page == "Favorites" && colorScheme == .light) ? Color.tertiarySystemBackground : Color.label)
                                        Text("Add some events to your favorites by using the hard-press shortcut on the event preview or the favorite button on the event detail page.").fontWeight(.light).font(.system(size: 16)).padding([.horizontal]).foregroundColor((self.page == "Favorites" && colorScheme == .light) ? Color.tertiarySystemBackground : Color.label)
                                        Spacer()
                                        Spacer()
                                    }.padding(.vertical, 10)
                                } else {
                                    CalendarView(evm: self.evm, page: self.$page, subPage: self.$subPage)
                                }
                            }.blur(radius: self.showOptions ? 5 : 0).disabled(self.showOptions ? true : false)
                        }
                        if self.subPage == "AR"  ||  self.subPage == "Map" { //AR or Map
                            ZStack {
                                if self.subPage == "AR" {
                                    ARNavigationIndicator(evm: self.evm, arFindMode: true, internalAlert: .constant(false), externalAlert: self.$externalAlert, tooFar: self.$tooFar, allVirtual: self.$allVirtual, arrived: .constant(false), eventDetails: .constant(false), page: self.$page, subPage: self.$subPage).environmentObject(self.config)
                                        .blur(radius: self.showOptions ? 5 : 0)
                                        .disabled(self.showOptions ? true : false)
                                        .edgesIgnoringSafeArea(.top)
                                        .alert(isPresented: self.$externalAlert) { () -> Alert in
                                            if self.tooFar {
                                                return self.evm.alert(title: "Too Far to Tour with AR", message: "You're currently too far away from campus to use the AR feature to tour. Try using the map instead.")
                                            } else if self.allVirtual {
                                                if self.page == "Favorites" {
                                                    return self.evm.alert(title: "All Favorited Events are Virtual", message: "Unfortunately, there are no events in your favorites list that are on campus at the moment. Check out the virtual event list instead.")
                                                } else {
                                                    return self.evm.alert(title: "All Events are Virtual", message: "Unfortunately, there are no events on campus at the moment. Check out the virtual event list instead.")
                                                }
                                            } else if self.page == "Favorites" && self.noFavorites {
                                                return self.evm.alert(title: "No Favorites to Show", message: "Add some favorites so we can show you them in \(self.subPage) Mode!")
                                            }
                                            return self.evm.alert(title: "ERROR", message: "Please report as a bug.")
                                    }
                                }
                                if self.subPage == "Map" {
                                    MapView(evm: self.evm, mapFindMode: true, internalAlert: .constant(false), externalAlert: self.$externalAlert, tooFar: .constant(false), allVirtual: self.$allVirtual, arrived: .constant(false), eventDetails: .constant(false), page: self.$page, subPage: self.$subPage).environmentObject(self.config)
                                        .blur(radius: self.showOptions ? 5 : 0)
                                        .disabled(self.showOptions ? true : false)
                                        .edgesIgnoringSafeArea(.top)
                                        .alert(isPresented: self.self.$externalAlert) { () -> Alert in
                                            if self.allVirtual {
                                                return self.evm.alert(title: "All Events are Virtual", message: "Unfortunately, there are no events on campus at the moment. Check out the virtual event list instead.")
                                            } else if self.page == "Favorites" && self.noFavorites {
                                                return self.evm.alert(title: "No Favorites to Show", message: "Add some favorites so we can show you them in \(self.subPage) Mode!")
                                            }
                                            return self.evm.alert(title: "ERROR", message: "Please report as a bug.")
                                    }
                                }
                                if config.appEventMode {
                                    ZStack {
                                        Text("Virtual Events").fontWeight(.light).font(.system(size: 18)).foregroundColor(config.accent)
                                    }.padding(10)
                                        .background(RoundedRectangle(cornerRadius: 15).stroke(Color.clear).foregroundColor(Color.tertiarySystemBackground.opacity(0.8)).background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color.tertiarySystemBackground.opacity(0.8))))
                                        .onTapGesture { withAnimation { self.listVirtualEvents = true } }
                                        .offset(y: Constants.height*0.38)
                                }
                            }.sheet(isPresented: $listVirtualEvents, content: {
                                ListView(evm: self.evm, allVirtual: true, page: self.$page, subPage: self.$subPage).environmentObject(self.config).background(Color.secondarySystemBackground)
                            })
//                            .alert(isPresented: self.$noFavorites) { () -> Alert in //if favorites map or favorites AR & there are no favorites
//                                return self.evm.alert(title: "No Favorites to Show", message: "Add some favorites so we can show you them in \(self.subPage) Mode!")
//                            } //end of ZStack
                        }
                    }
                    if self.page == "Information" {
                        InformationView()
                    }
                    //JUST FOR TOUR MODE WITH BUILDINGS
                    if self.page == "AR" {
                        ARNavigationIndicator(evm: self.evm, arFindMode: true, internalAlert: .constant(false), externalAlert: self.$externalAlert, tooFar: self.$tooFar, allVirtual: .constant(false), arrived: .constant(false), eventDetails: .constant(false), page: self.$page, subPage: self.$subPage).environmentObject(self.config)
                            .blur(radius: self.showOptions ? 5 : 0)
                            .disabled(self.showOptions ? true : false)
                            .edgesIgnoringSafeArea(.top)
                            .alert(isPresented: self.$externalAlert) { () -> Alert in
                                if self.tooFar {
                                    return self.evm.alert(title: "Too Far to Tour with AR", message: "You're currently too far away from campus to use the AR feature to tour. Try using the map instead.")
                                }
                                return self.evm.alert(title: "ERROR", message: "Please report as a bug.")
                        }
                    }
                    if self.page == "Map" {
                        MapView(evm: self.evm, mapFindMode: true, internalAlert: .constant(false), externalAlert: .constant(false), tooFar: .constant(false), allVirtual: .constant(false), arrived: .constant(false), eventDetails: .constant(false), page: self.$page, subPage: self.$subPage).environmentObject(self.config)
                            .blur(radius: self.showOptions ? 5 : 0)
                            .disabled(self.showOptions ? true : false)
                            .edgesIgnoringSafeArea(.top)
                    }
                }//.onTapGesture { self.showOptions = false } //end of ZStack that holds everything above the tab bar //interferes with tapping on map pin, figure this out later
                TabBar(evm: self.evm, showOptions: self.$showOptions, externalAlert: self.$externalAlert, noFavorites: self.$noFavorites, page: self.$page, subPage: self.$subPage)
                
            }.edgesIgnoringSafeArea(.bottom)//end of VStack
            
        }.animation(.spring()) //end of ZStack
    } //end of view
} //end of struct

struct TabBar : View {
    @ObservedObject var evm:EventViewModel
    @EnvironmentObject var config: Configuration
    @Binding var showOptions: Bool
    @Binding var externalAlert: Bool
    @Binding var noFavorites: Bool
    
    @Binding var page:String
    @Binding var subPage:String
    
    var body: some View {
        ZStack {
            HStack(spacing: 20){
                if config.appEventMode {
                    //Discover
                    HStack {
                        Image(systemName: "magnifyingglass").resizable().frame(width: 20, height: 20).foregroundColor(self.page == "Discover" ? Color.white : Color.secondaryLabel)
                        Text(self.page == "Discover" ? self.page : "").fontWeight(.light).font(.system(size: 14)).foregroundColor(Color.white)
                    }.padding(15)
                        .background(self.page == "Discover" ? config.accent : Color.clear)
                        .clipShape(Capsule())
                        .onTapGesture {
                            if self.page == "Discover" {
                                self.showOptions.toggle()
                            } else {
                                self.showOptions = true
                            }
                            self.page = "Discover"
                    }
                    //Favorites
                    HStack {
                        Image(systemName: "heart").resizable().frame(width: 20, height: 20).foregroundColor(self.page == "Favorites" ? Color.white : Color.secondaryLabel)
                        Text(self.page == "Favorites" ? self.page : "").fontWeight(.light).font(.system(size: 14)).foregroundColor(Color.white)
                    }.padding(15)
                        .background(self.page == "Favorites" ? config.accent : Color.clear)
                        .clipShape(Capsule())
                        .onTapGesture {
                            if self.page == "Favorites" {
                                self.showOptions.toggle()
                            } else {
                                self.showOptions = true
                            }
                            self.page = "Favorites"
                            //if there aren't any favorites, send alert through noFavorites & don't allow Map/AR to show by not getting rid of options
                            if !self.evm.doFavoritesExist(list: self.evm.eventList) && (self.subPage == "AR" || self.subPage == "Map") {
                                self.externalAlert = true
                                self.noFavorites = true
                                self.showOptions = true
                            }
                    }
                    //Trending
                    HStack {
                        Image(systemName: "hand.thumbsup").resizable().frame(width: 20, height: 20).foregroundColor(self.page == "Trending" ? Color.white : Color.secondaryLabel)
                        Text(self.page == "Trending" ? self.page : "").fontWeight(.light).font(.system(size: 14)).foregroundColor(Color.white)
                    }.padding(15)
                        .background(self.page == "Trending" ? config.accent : Color.clear)
                        .clipShape(Capsule())
                        .onTapGesture {
                            self.page = "Trending"
                            self.showOptions = false
                    }
                    //Info
                    HStack {
                        Image(systemName: "info.circle").resizable().frame(width: 20, height: 20).foregroundColor(self.page == "Information" ? Color.white : Color.secondaryLabel)
                        Text(self.page == "Information" ? self.page : "").fontWeight(.light).font(.system(size: 14)).foregroundColor(Color.white)
                    }.padding(15)
                        .background(self.page == "Information" ? config.accent : Color.clear)
                        .clipShape(Capsule())
                        .onTapGesture {
                            self.page = "Information"
                            self.showOptions = false
                    }
                } else { //tour mode with buildings
                    //AR
                    HStack {
                        Image(systemName: "camera.viewfinder").resizable().frame(width: 20, height: 20).foregroundColor(self.page == "AR" ? Color.white : Color.secondaryLabel)
                        Text(self.page == "AR" ? self.page : "").fontWeight(.light).font(.system(size: 14)).foregroundColor(Color.white)
                    }.padding(15)
                        .background(self.page == "AR" ? config.accent : Color.clear)
                        .clipShape(Capsule())
                        .onTapGesture {
                            self.page = "AR"
                            self.showOptions = false
                    }
                    //Map
                    HStack {
                        Image(systemName: "map.fill").resizable().frame(width: 20, height: 20).foregroundColor(self.page == "Map" ? Color.white : Color.secondaryLabel)
                        Text(self.page == "Map" ? self.page : "").fontWeight(.light).font(.system(size: 14)).foregroundColor(Color.white)
                    }.padding(15)
                        .background(self.page == "Map" ? config.accent : Color.clear)
                        .clipShape(Capsule())
                        .onTapGesture {
                            self.page = "Map"
                            self.showOptions = false
                    }
                    //Info
                    HStack {
                        Image(systemName: "info.circle").resizable().frame(width: 20, height: 20).foregroundColor(self.page == "Information" ? Color.white : Color.secondaryLabel)
                        Text(self.page == "Information" ? self.page : "").fontWeight(.light).font(.system(size: 14)).foregroundColor(Color.white)
                    }.padding(15)
                        .background(self.page == "Information" ? config.accent : Color.clear)
                        .clipShape(Capsule())
                        .onTapGesture {
                            self.page = "Information"
                            self.showOptions = false
                    }
                }
            }.padding(.vertical, 10)
                .frame(width: Constants.width)
                .background(Color.tertiarySystemBackground)
                .animation(.default) //hstack end
            
            //other tabs
            if self.showOptions {
                TabOptions(evm: self.evm, showOptions: self.$showOptions, externalAlert: self.$externalAlert, noFavorites: self.$noFavorites, page: self.$page, subPage: self.$subPage).offset(x: self.page == "Discover" ? -100 : -35, y: -65)
            }
            
        }//zstack end
    }
}

struct TabOptions: View {
    @ObservedObject var evm:EventViewModel
    @EnvironmentObject var config: Configuration
    @Binding var showOptions: Bool
    @Environment(\.colorScheme) var colorScheme
    @Binding var externalAlert: Bool
    @Binding var noFavorites: Bool
    
    @Binding var page:String
    @Binding var subPage:String
    
    var body: some View {
        HStack {
            //List
            ZStack {
                Circle()
                    .stroke(self.subPage == "List" && colorScheme == .light ? Color.tertiarySystemBackground : Color.clear)
                    .background(self.subPage == "List" ? selectedColor(element: "background") : nonselectedColor(element: "background"))
                    .clipShape(Circle())
                Image(systemName: "list.bullet")
                    .resizable().frame(width: 20, height: 20)
                    .foregroundColor(self.subPage == "List" ? selectedColor(element: "foreground") : nonselectedColor(element: "foreground"))
            }.frame(width: 50, height: 50)
                .offset(x: 25)
                .onTapGesture {
                    withAnimation {
                        self.subPage = "List"
                        self.showOptions = false
                    }
            }
            //Calendar
            ZStack {
                Circle()
                    .stroke(self.subPage == "Calendar" && colorScheme == .light ? Color.tertiarySystemBackground : Color.clear)
                    .background(self.subPage == "Calendar" ? selectedColor(element: "background") : nonselectedColor(element: "background"))
                    .clipShape(Circle())
                Image(systemName: "calendar")
                    .resizable().frame(width: 20, height: 20)
                    .foregroundColor(self.subPage == "Calendar" ? selectedColor(element: "foreground") : nonselectedColor(element: "foreground"))
            }.frame(width: 50, height: 50)
                .offset(y: -50)
                .onTapGesture {
                    withAnimation {
                        self.subPage = "Calendar"
                        self.showOptions = false
                    }
            }
            //AR
            ZStack {
                Circle()
                    .stroke(self.subPage == "AR" && colorScheme == .light ? Color.tertiarySystemBackground : Color.clear)
                    .background(self.subPage == "AR" ? selectedColor(element: "background") : nonselectedColor(element: "background"))
                    .clipShape(Circle())
                Image(systemName: "camera")
                    .resizable().frame(width: 22, height: 18)
                    .foregroundColor(self.subPage == "AR" ? selectedColor(element: "foreground") : nonselectedColor(element: "foreground"))
            }.frame(width: 50, height: 50)
                .offset(y: -50)
                .onTapGesture {
                    withAnimation {
                        self.subPage = "AR"
                        self.showOptions = false
                    }
                    //if there aren't any favorites, send alert through noFavorites & don't allow AR to show by not getting rid of options
                    if !self.evm.doFavoritesExist(list: self.evm.eventList) && self.page == "Favorites" {
                        self.externalAlert = true
                        self.noFavorites = true
                        self.showOptions = true
                    }
            }
            //Map
            ZStack {
                Circle()
                    .stroke(self.subPage == "Map" && colorScheme == .light ? Color.tertiarySystemBackground : Color.clear)
                    .background(self.subPage == "Map" ? selectedColor(element: "background") : nonselectedColor(element: "background"))
                    .clipShape(Circle())
                Image(systemName: "mappin.and.ellipse")
                    .resizable().frame(width: 20, height: 22)
                    .foregroundColor(self.subPage == "Map" ? selectedColor(element: "foreground") : nonselectedColor(element: "foreground"))
            }.frame(width: 50, height: 50)
                .offset(x: -25)
                .onTapGesture {
                    withAnimation {
                        self.subPage = "Map"
                        self.showOptions = false
                    }
                    //if there aren't any favorites, send alert through noFavorites & don't allow Map to show by not getting rid of options
                    if !self.evm.doFavoritesExist(list: self.evm.eventList) && self.page == "Favorites" {
                        self.externalAlert = true
                        self.noFavorites = true
                        self.showOptions = true
                    }
            }
        }.transition(.scale) //hstack
    }
    
    func selectedColor(element: String) -> Color {
        if element == "background" {
            return config.accent
        }
        //if element == stroke or foreground
        if colorScheme == .light {
            return Color.tertiarySystemBackground
        } else if colorScheme == .dark {
            return Color.secondaryLabel
        }
        
        return config.accent //absolute default
    }
    
    func nonselectedColor(element: String) -> Color {
        if element == "stroke" || element == "foreground" {
            return config.accent
        } else if element == "background" {
            if colorScheme == .light {
                return Color.tertiarySystemBackground
            } else if colorScheme == .dark {
                return Color.secondaryLabel
            }
        }
        return config.accent //absolute default
    }
}

