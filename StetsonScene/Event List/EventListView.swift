////
////  EventListView.swift
////  StetsonScene
////
////  Created by Lannie Hough on 2/12/20.
////  Copyright © 2020 Madison Gipson. All rights reserved.
////
//
//import SwiftUI
//
//struct EventListView: View {
//    @ObservedObject var eventModelController:EventModelController
//    @State private var showDetailForm = false
//    @State private var showOptions = false
//    @State private var share = false
//    @State var navigate = false
//    
//    @State private var showNavAlert = false
//    
//    @State private var calendarAlert = false
//    @State private var activeAlert:ActiveAlert = .success
//    
//    @State var safariView:Bool = false
//    @State private var safariUrl = ""
//    @State private var linkText:String = ""
//    
//    @State var shareDetails:String!
//    @State var shareClosing:String!
//    @State var virtualEvent:Bool = false
//    
//    @Environment(\.colorScheme) var colorScheme
//    
//    var listingWhatView:String //comes from EventViewController, ARController, MapController
//
//    var navAlert: Alert {
//        Alert(title: Text("Uh oh!"), message: Text("You can't navigate to this event. It might be virtual, or we might have incomplete data."), dismissButton: .default(Text("Dismiss")))
//    }
//    
//    var body: some View {
//                VStack {
//                    if listingWhatView == "AR List" || listingWhatView == "Map List" {
//                        Text("Upcoming Events").font(.system(size: 22, weight: .light, design: .default)).foregroundColor(Constants.brightYellow).padding([.horizontal]).padding([.top])
//                    } else if listingWhatView == "Favorite List" {
//                        Text("Favorites").font(.system(size: 22, weight: .light, design: .default)).foregroundColor(Constants.brightYellow).padding([.horizontal]).padding([.top])
//                    } else if listingWhatView == "Recommended List" {
//                        Text("Recommended").font(.system(size: 22, weight: .light, design: .default)).foregroundColor(Constants.brightYellow).padding([.horizontal]).padding([.top])
//                    }
//                    if listingWhatView == "Event List" {
//                        if self.eventModelController.eventListLive.count == 0 {
//                            Spacer()
//                            Text("No results, try another search or check back later!").padding()
//                            Spacer()
//                        }
//                    }
//                    if listingWhatView == "AR List" {
//                        if self.eventModelController.eventListARLive.count == 0 {
//                            Spacer()
//                            Text("No events here right now, check back later!").padding()
//                            Spacer()
//                        }
//                    }
//                    if listingWhatView == "Map List" {
//                        if self.eventModelController.eventListMapLive.count == 0 {
//                            Spacer()
//                            Text("No events here right now, check back later!").padding()
//                            Spacer()
//                        }
//                    }
//                    if listingWhatView == "Favorite List" {
//                        if self.eventModelController.favoriteLiveList.count == 0 {
//                            Spacer()
//                            Text("No favorite events!  Check out recommended to see some you might like!").padding()
//                            Spacer()
//                        }
//                    }
//                    if listingWhatView == "Recommended List" {
//                        if self.eventModelController.eventListRecLive.count == 0 {
//                            Spacer()
//                            Text("No recommended events! Try favoriting some events so we can get an idea of what you might like!").padding()
//                            Spacer()
//                        }
//                    }
//                    List {
//                        ForEach(
//                            listingWhatView == "Recommended List" ? eventModelController.eventListRecLive :
//                                (listingWhatView == "AR List" ? eventModelController.eventListARLive :
//                                    (listingWhatView == "Favorite List" ? eventModelController.favoriteLiveList :
//                                        (listingWhatView == "Map List" ? eventModelController.eventListMapLive : eventModelController.eventListLive)))) { eventInstance in
//                                        Button(action: {
//                                            print("action")
//                                            self.showDetailForm.toggle()
//                                        }) {
//                                            ZStack {
//                                                EventListNavigationView(event: eventInstance).contextMenu {
//                                                    //Favorite
//                                                    Button(action: {
//                                                        self.eventModelController.manageFavorites(event: eventInstance)
//                                                    }) {
//                                                        Text(eventInstance.isFavorite ? "Unfavorite":"Favorite")
//                                                        Image(systemName: eventInstance.isFavorite ? "heart.fill":"heart")
//                                                    }
//                                                    //Add to Calendar
//                                                    Button(action: {
//                                                        //self.calendar.toggle()
//                                                        self.activeAlert = self.eventModelController.manageCalendar(event: eventInstance)
//                                                        self.calendarAlert = true
//                                                        //prompt action sheet
//                                                    }) {
//                                                        Text("Add to Calendar")
//                                                        Image(systemName: "calendar")
//                                                    }.actionSheet(isPresented: self.$calendarAlert, content: {
//                                                        self.eventModelController.returnActionSheet(event: eventInstance, activeAlert: self.activeAlert)
//                                                    }).padding([.horizontal])
//                                                    //Share
//                                                    Button(action: {
//                                                        //self.share.toggle()
//                                                        self.share = true
//                                                        print("share: ", self.share)
//                                                        //add share functionality
//                                                        if eventInstance.mainLon == "0" || eventInstance.mainLon == "" || eventInstance.mainLat == "0" || eventInstance.mainLat == "" {
//                                                            self.virtualEvent = true
//                                                            self.linkText = self.eventModelController.makeLink(text: eventInstance.eventDescription)
//                                                            if self.linkText == "" {self.virtualEvent = false}
//                                                            print(self.linkText)
//                                                            self.shareDetails = "Check out this event I found via StetsonScene! \(eventInstance.name!) is happening on \(eventInstance.date!) at \(eventInstance.time!)!"
//                                                        } else {
//                                                            self.shareDetails = "Check out this event I found via StetsonScene! \(eventInstance.name!), on \(eventInstance.date!) at \(eventInstance.time!), is happening at the \(eventInstance.location!)!"
//                                                        }
//                                                        print(self.shareDetails!)
//                                                    }) {
//                                                        Text("Share")
//                                                        Image(systemName: "square.and.arrow.up")
//                                                    }//modal prompted at end of view
//                                                    //Navigate
//                                                    Button(action: {
//                                                        self.eventModelController.event = eventInstance
//                                                        self.navigate.toggle()
//                                                        if eventInstance.mainLon == "0" || eventInstance.mainLon == "" || eventInstance.mainLat == "0" || eventInstance.mainLat == "" {
//                                                            self.linkText = self.eventModelController.makeLink(text: eventInstance.eventDescription)
//                                                            if self.linkText != "" {
//                                                                self.safariUrl = self.linkText
//                                                                if self.eventModelController.verifyUrl(urlString: self.safariUrl) {self.safariView.toggle()}
//                                                            } else {self.showNavAlert.toggle()}
//                                                        } else {
//                                                            self.eventModelController.navMap.toggle()
//                                                            //self.navMap.toggle()
//                                                        }
//                                                    }) {
//                                                        Text("Navigate")
//                                                        Image(systemName: "location")
//                                                    }/*.sheet(isPresented: self.$safariView) {
//                                                        SafariView(url:URL(string: self.linkText)!)
//                                                    }.padding([.horizontal])*/
//                                                }
//                                            }
//                                        }.background(EmptyView().sheet(isPresented: self.$share) {
//                                            //Insert link to app/appstore
//                                            ShortcutShareView(activityItems: [/*"linktoapp.com"*/self.virtualEvent ? URL(string: self.linkText)!:"", eventInstance.hasCultural ? "\(self.shareDetails!) It’s even offering a cultural credit!" : "\(self.shareDetails!)"/*, self.virtualEvent ? URL(string: self.linkText)!:""*/], applicationActivities: nil)
//                                        }.background(EmptyView().sheet(isPresented: self.$safariView) {
//                                            SafariView(url:URL(string: self.linkText)!)
//                                        }.background(EmptyView().sheet(isPresented: self.$showDetailForm) {
//                                            EventDetailView(event: eventInstance, numAttendingState: eventInstance.numAttending, isFavorite: eventInstance.isFavorite, eventModelController: self.eventModelController) //if favorited, update main ModelController & local EventInstance
//                                        })))
//                        }.listRowBackground(colorScheme == .dark ? Constants.darkGray : Color.white)
//                    }.alert(isPresented: $showNavAlert, content: {self.navAlert}).padding([.top]) //end of list
//                }.background(colorScheme == .dark ? Constants.darkGray : Color.white) //end of vstack for view
//        } //end of view
//} //end of struct
//
//struct ShortcutShareView: UIViewControllerRepresentable {
//    let activityItems: [Any]
//    let applicationActivities: [UIActivity]?
//    func makeUIViewController(context: UIViewControllerRepresentableContext<ShortcutShareView>) -> UIActivityViewController {
//        print("HERE")
//        return UIActivityViewController(activityItems: activityItems,
//                                        applicationActivities: applicationActivities)
//    }
//    func updateUIViewController(_ uiViewController: UIActivityViewController,
//                                context: UIViewControllerRepresentableContext<ShortcutShareView>) {
//        print("HERE HERE")
//    }
//}
