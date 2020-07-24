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

struct NavigationIndicator: UIViewControllerRepresentable {
    typealias UIViewControllerType = ARView
    
    func makeUIViewController(context: Context) -> ARView {
        return ARView()
    }
    func updateUIViewController(_ uiViewController: NavigationIndicator.UIViewControllerType, context: UIViewControllerRepresentableContext<NavigationIndicator>) { }
}


struct MainView : View {
    @EnvironmentObject var config: Configuration
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color((config.page == "Favorites" && colorScheme == .light) ? config.accentUIColor : UIColor.secondarySystemBackground).edgesIgnoringSafeArea(.all)
            VStack(spacing: 0){
                if config.page == "Trending" {
                    TrendingView().disabled(config.showOptions ? true : false)
                } else if config.page == "Discover" || config.page == "Favorites" {
                    if config.subPage == "List" || config.subPage == "Calendar" {
                        DiscoverFavoritesView().blur(radius: config.showOptions ? 5 : 0).disabled(config.showOptions ? true : false)
                    } else if config.subPage == "AR" {
                        NavigationIndicator().blur(radius: config.showOptions ? 5 : 0).disabled(config.showOptions ? true : false).edgesIgnoringSafeArea(.top)
                    } else if config.subPage == "Map" {
                        MapView().blur(radius: config.showOptions ? 5 : 0).disabled(config.showOptions ? true : false).edgesIgnoringSafeArea(.top)
                    }
                } else if config.page == "Information" {
                    InformationView().blur(radius: config.showOptions ? 5 : 0).disabled(config.showOptions ? true : false)
                }
                
                TabBar()
                
            }.edgesIgnoringSafeArea(.bottom)
            
        }.animation(.spring())
    }
}

struct TabBar : View {
    @EnvironmentObject var config: Configuration
    
    var body: some View {
        ZStack {
            HStack(spacing: 20){
                //Trending
                HStack {
                    Image(systemName: "hand.thumbsup").resizable().frame(width: 20, height: 20).foregroundColor(config.page == "Trending" ? Color.white : Color.secondaryLabel)
                    Text(config.page == "Trending" ? config.page : "").fontWeight(.light).font(.system(size: 14)).foregroundColor(Color.white)
                }.padding(15)
                    .background(config.page == "Trending" ? config.accent : Color.clear)
                    .clipShape(Capsule())
                    .onTapGesture {
                        self.config.page = "Trending"
                        self.config.showOptions = false
                }
                //Discover
                HStack {
                    Image(systemName: "magnifyingglass").resizable().frame(width: 20, height: 20).foregroundColor(config.page == "Discover" ? Color.white : Color.secondaryLabel)
                    Text(config.page == "Discover" ? config.page : "").fontWeight(.light).font(.system(size: 14)).foregroundColor(Color.white)
                }.padding(15)
                    .background(config.page == "Discover" ? config.accent : Color.clear)
                    .clipShape(Capsule())
                    .onTapGesture {
                        if self.config.page == "Discover" {
                            self.config.showOptions.toggle()
                        } else {
                            self.config.showOptions = true
                        }
                        self.config.page = "Discover"
                }
                //Favorites
                HStack {
                    Image(systemName: "heart").resizable().frame(width: 20, height: 20).foregroundColor(config.page == "Favorites" ? Color.white : Color.secondaryLabel)
                    Text(config.page == "Favorites" ? config.page : "").fontWeight(.light).font(.system(size: 14)).foregroundColor(Color.white)
                }.padding(15)
                    .background(config.page == "Favorites" ? config.accent : Color.clear)
                    .clipShape(Capsule())
                    .onTapGesture {
                        if self.config.page == "Favorites" {
                            self.config.showOptions.toggle()
                        } else {
                            self.config.showOptions = true
                        }
                        self.config.page = "Favorites"
                }
                //Info
                HStack {
                    Image(systemName: "info.circle").resizable().frame(width: 20, height: 20).foregroundColor(config.page == "Information" ? Color.white : Color.secondaryLabel)
                    Text(config.page == "Information" ? config.page : "").fontWeight(.light).font(.system(size: 14)).foregroundColor(Color.white)
                }.padding(15)
                    .background(config.page == "Information" ? config.accent : Color.clear)
                    .clipShape(Capsule())
                    .onTapGesture {
                        self.config.page = "Information"
                        self.config.showOptions = false
                }
            }.padding(.vertical, 10)
                .frame(width: Constants.width)
                .background(Color.tertiarySystemBackground)
                .animation(.default) //hstack end
            
            //other tabs
            if self.config.showOptions {
                TabOptions().offset(x: self.config.page == "Discover" ? -30 : 30, y: -60)
            }
            
        }//zstack end
    }
}

struct TabOptions: View {
    @EnvironmentObject var config: Configuration
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            //List
            ZStack {
                Circle()
                    .stroke(self.config.subPage == "List" ? selectedColor(element: "stroke") : nonselectedColor(element: "stroke"))
                    .background(self.config.subPage == "List" ? selectedColor(element: "background") : nonselectedColor(element: "background"))
                    .clipShape(Circle())
                Image(systemName: "list.bullet")
                    .resizable().frame(width: 20, height: 20)
                    .foregroundColor(self.config.subPage == "List" ? selectedColor(element: "foreground") : nonselectedColor(element: "foreground"))
            }.frame(width: 50, height: 50)
                .offset(x: 10)
                .onTapGesture {
                    withAnimation {
                        self.config.subPage = "List"
                        self.config.showOptions = false
                    }
            }
            //Calendar
            ZStack {
                Circle()
                    .stroke(self.config.subPage == "Calendar" ? selectedColor(element: "stroke") : nonselectedColor(element: "stroke"))
                    .background(self.config.subPage == "Calendar" ? selectedColor(element: "background") : nonselectedColor(element: "background"))
                    .clipShape(Circle())
                Image(systemName: "calendar")
                    .resizable().frame(width: 20, height: 20)
                    .foregroundColor(self.config.subPage == "Calendar" ? selectedColor(element: "foreground") : nonselectedColor(element: "foreground"))
            }.frame(width: 50, height: 50)
                .offset(y: -30)
                .onTapGesture {
                    withAnimation {
                        self.config.subPage = "Calendar"
                        self.config.showOptions = false
                    }
            }
            //AR
            ZStack {
                Circle()
                    .stroke(self.config.subPage == "AR" ? selectedColor(element: "stroke") : nonselectedColor(element: "stroke"))
                    .background(self.config.subPage == "AR" ? selectedColor(element: "background") : nonselectedColor(element: "background"))
                    .clipShape(Circle())
                Image(systemName: "camera")
                    .resizable().frame(width: 22, height: 18)
                    .foregroundColor(self.config.subPage == "AR" ? selectedColor(element: "foreground") : nonselectedColor(element: "foreground"))
            }.frame(width: 50, height: 50)
                .offset(y: -30)
                .onTapGesture {
                    withAnimation {
                        self.config.subPage = "AR"
                        self.config.showOptions = false
                    }
            }
            //Map
            ZStack {
                Circle()
                    .stroke(self.config.subPage == "Map" ? selectedColor(element: "stroke") : nonselectedColor(element: "stroke"))
                    .background(self.config.subPage == "Map" ? selectedColor(element: "background") : nonselectedColor(element: "background"))
                    .clipShape(Circle())
                Image(systemName: "mappin.and.ellipse")
                    .resizable().frame(width: 20, height: 22)
                    .foregroundColor(self.config.subPage == "Map" ? selectedColor(element: "foreground") : nonselectedColor(element: "foreground"))
            }.frame(width: 50, height: 50)
                .offset(x: -10)
                .onTapGesture {
                    withAnimation {
                        self.config.subPage = "Map"
                        self.config.showOptions = false
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

