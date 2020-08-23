//
//  TrendingView.swift
//  StetsonScene
//
//  Created by Madison Gipson on 7/15/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation
import SwiftUI
import CoreLocation

struct TrendingView : View {
    @ObservedObject var evm:EventViewModel
    @EnvironmentObject var config: Configuration
    @State var card = 0
    
    @Binding var page:String
    @Binding var subPage:String
    
    var body: some View {
        VStack {
            Text("Trending").fontWeight(.heavy).font(.system(size: 50)).frame(maxWidth: .infinity, alignment: .leading).foregroundColor(Color.label).padding([.vertical, .horizontal]).padding(.bottom, 10)
            
            //Announcements
            Text("ANNOUNCEMENTS").fontWeight(.medium).font(.system(size: 25)).padding([.horizontal]).frame(maxWidth: .infinity, alignment: .leading).foregroundColor(config.accent)
            Text("Important announcements will go here, they'll probably be updates about things going on on-campus.").fontWeight(.light).font(.system(size: 20)).padding(.vertical, 5).padding([.horizontal]).frame(maxWidth: .infinity, alignment: .leading).foregroundColor(Color.label)
            
            //Carousel List- using GeomtryReader to detect the remaining height on the screen (smart scaling)
            GeometryReader{ geometry in
                Carousel(evm: self.evm, trendingList: self.trendingList(), card: self.$card, height: geometry.frame(in: .global).height, page: self.$page, subPage: self.$subPage)
            }
            //dots that show which card is being displayed
            CardControl(trendingList: self.trendingList(), card: self.$card, page: self.$page, subPage: self.$subPage).padding(.bottom, 10)
            
        }
    }
    
    func trendingList() -> [EventInstance] {
        let recEngine = RecommendationEngine(evm: self.evm)
        let list = recEngine.runEngine()
        return list
    }
}

//CAROUSEL: UIView that embeds the Cards SwiftUI View
//Uses a UIScrollView to detect card offset and tells the UIView when the card changes through @Binding card
//@Binding card then updates in the rest of the structs that use it so the correct card is displayed
struct Carousel : UIViewRepresentable {
    @ObservedObject var evm:EventViewModel
    var trendingList: [EventInstance]
    @Binding var card : Int
    var height : CGFloat
    
    @Binding var page:String
    @Binding var subPage:String
    
    //create and update the Carousel UIScrollView
    func makeUIView(context: Context) -> UIScrollView{
        //create a scrollview to hold cards
        let scrollview = UIScrollView()
        let carouselWidth = Constants.width * CGFloat(trendingList.count)
        scrollview.contentSize = CGSize(width: carouselWidth, height: 1.0) //setting height to 1.0 disables verical scroll
        scrollview.isPagingEnabled = true
        scrollview.bounces = true
        scrollview.showsVerticalScrollIndicator = false
        scrollview.showsHorizontalScrollIndicator = false
        scrollview.delegate = context.coordinator
        
        //make the Card SwiftUI View into a UIView (essentially)
        let uiCardView = UIHostingController(rootView: Cards(evm: self.evm, trendingList: trendingList, height: height*0.9, page: self.$page, subPage: self.$subPage))
        uiCardView.view.frame = CGRect(x: 0, y: 0, width: carouselWidth, height: self.height)
        uiCardView.view.backgroundColor = .clear
        
        //add the uiCardView as a subview of the scrollview
        //(effectively embeds the Cards SwiftUI View into the Carousel UIScrollView)
        scrollview.addSubview(uiCardView.view)
        return scrollview
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {}
    
    //give the Carousel UIScrollView a Coordinator to handle scrolling and changing cards
    func makeCoordinator() -> Coordinator {
        return Carousel.Coordinator(parent: self)
    }
    
    class Coordinator : NSObject, UIScrollViewDelegate {
        var carousel : Carousel
        init(parent: Carousel) {
            carousel = parent
        }
        
        //get current page
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            let card = Int(scrollView.contentOffset.x / Constants.width)
            self.carousel.card = card
        }
    }
}

//CARDS: create a card for each event in the list
struct Cards : View {
    @ObservedObject var evm:EventViewModel
    @EnvironmentObject var config: Configuration
    var trendingList: [EventInstance]
    var height : CGFloat
    let cardWidth = Constants.width*0.9
    @State var selectedEvent: EventInstance? = nil
    
    @Binding var page:String
    @Binding var subPage:String
    
    //context menu
    @State var detailView: Bool = false
    @State var share: Bool = false
    @State var calendar: Bool = false
    @State var fav: Bool = false
    @State var navigate: Bool = false
    //for alerts
    @State var internalAlert: Bool = false
    @State var externalAlert: Bool = false
    @State var tooFar: Bool = false
    @State var arrived: Bool = false
    @State var eventDetails: Bool = false
    @State var isVirtual: Bool = false
    
    var body: some View {
        //horizontal list of events in list
        HStack(spacing: 0) {
            ForEach(trendingList) {  event in
                //area around the card (whole screen width)
                VStack {
                    //card view
                    ZStack {
                        //Background Image
                        self.evm.buildingModelController.getImage(evm: self.evm, eventLocation: event.location).resizable().aspectRatio(contentMode: .fill).frame(width: self.cardWidth, height: self.height).cornerRadius(20)
                        //Layer over image
                        VStack {
                            //Spacer
                            VStack {
                                Spacer()
                            }.frame(width: self.cardWidth, height: self.height*0.6)
                            //Text
                            VStack (alignment: .leading) {
                                Text(event.name).fontWeight(.medium).font(.system(size: 30)).padding(.top, 10).foregroundColor(event.hasCultural ? self.config.accent : Color.label)
                                //TODO: CHANGE DATESTRING TO MONTH + DAY
                                Text(event.date + " | " + event.time).fontWeight(.light).font(.system(size: 20)).padding(.vertical, 5).foregroundColor(Color.secondaryLabel)
                                Text(event.location).fontWeight(.light).font(.system(size: 20)).padding(.bottom, 10).foregroundColor(Color.secondaryLabel)
                            }.padding([.horizontal, .vertical])
                                .frame(width: self.cardWidth, height: self.height*0.4, alignment: .leading)
                                .background(Color.tertiarySystemBackground.opacity(0.7))
                        }.frame(width: self.cardWidth, height: self.height)
                    }.padding([.horizontal, .vertical])
                        .frame(width: self.cardWidth, height: self.height)
                        .cornerRadius(20)
                        .shadow(radius: 5)
                        .onTapGesture {
                            self.detailView = true
                            self.selectedEvent = event
                        }
                        .contextMenu {
                                //SHARE
                                Button(action: {
                                    haptic()
                                    self.selectedEvent = event
                                    self.share.toggle()
                                    self.evm.isVirtual(event: event)
                                    if event.isVirtual {
                                        event.linkText = self.evm.makeLink(text: event.eventDescription)
                                        if event.linkText == "" { event.isVirtual = false }
                                        event.shareDetails = "Check out this event I found via StetsonScene! \(event.name!) is happening on \(event.date!) at \(event.time!)!"
                                    } else {
                                        event.shareDetails = "Check out this event I found via StetsonScene! \(event.name!), on \(event.date!) at \(event.time!), is happening at the \(event.location!)!"
                                    }
                                }) {
                                    Text("Share")
                                    Image(systemName: "square.and.arrow.up")
                                }
                                //ADD TO CALENDAR
                                Button(action: {
                                    haptic()
                                    self.selectedEvent = event
                                    self.calendar = true
                                }) {
                                    Text(event.isInCalendar ? "Already in Calendar" : "Add to Calendar")
                                    Image(systemName: "calendar.badge.plus")
                                }
                                
                                //FAVORITE
                                Button(action: {
                                    haptic()
                                    self.selectedEvent = event
                                    self.evm.toggleFavorite(event)
                                    //self.fav = event.isFavorite //this fixes the display
                                }) {
                                    Text(event.isFavorite ? "Unfavorite":"Favorite")
                                    Image(systemName: event.isFavorite ? "heart.fill":"heart")
                                }
                                
                                //NAVIGATE
//                                Button(action: {
//                                    haptic()
//                                    self.selectedEvent = event
//                                    self.evm.isVirtual(event: event)
//                                    //if you're trying to navigate to an event and are too far from campus, alert user and don't go to map
//                                    let locationManager = CLLocationManager()
//                                    let StetsonUniversity = CLLocation(latitude: 29.0349780, longitude: -81.3026430)
//                                    if !event.isVirtual && locationManager.location != nil && (CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways) && StetsonUniversity.distance(from: locationManager.location!) > 805 {
//                                        self.externalAlert = true
//                                        self.tooFar = true
//                                        self.navigate = false
//                                    } else if event.isVirtual { //if you're trying to navigate to a virtual event, alert user and don't go to map
//                                        //TODO: add in the capability to follow a link to register or something
//                                        self.externalAlert = true
//                                        self.isVirtual = true
//                                        self.navigate = false
//                                    } else { //otherwise go to map
//                                        self.externalAlert = false
//                                        self.isVirtual = false
//                                        self.tooFar = false
//                                        self.navigate = true
//                                    }
//                                }) {
//                                    Text("Navigate")
//                                    Image(systemName: "location")
//                                }
                        } //end of context menu
                }.frame(width: Constants.width).animation(.default) //end of vstack
            } //end of foreach
            .background(EmptyView().sheet(isPresented: $share, content: { //NEED TO LINK TO APPROPRIATE LINKS ONCE APP IS PUBLISHED
                ShareView(activityItems: [/*"linktoapp.com"*/(self.selectedEvent!.isVirtual && URL(string: self.selectedEvent!.linkText) != nil) ? URL(string: self.selectedEvent!.linkText)!:"", self.selectedEvent!.hasCultural ? "\(self.selectedEvent!.shareDetails) It’s even offering a cultural credit!" : "\(self.selectedEvent!.shareDetails)"/*, event.isVirtual ? URL(string: event.linkText)!:""*/], applicationActivities: nil)
            }).background(EmptyView().sheet(isPresented: self.$detailView, content: {
                EventDetailView(evm: self.evm, event: self.selectedEvent!, page: self.$page, subPage: self.$subPage).environmentObject(self.config)
            })))
        } //end of hstack
        .actionSheet(isPresented: $calendar) {
            self.evm.manageCalendar(self.selectedEvent!)
        } //end of background and action sheet nonsense
    } //end of view
    
} //end of struct

//.background(EmptyView().sheet(isPresented: $navigate, content: {
//        ZStack {
//            if self.arMode && !self.event.isVirtual {
//                ARNavigationIndicator(evm: self.evm, arFindMode: false, navToEvent: self.event, internalAlert: self.$internalAlert, externalAlert: self.$externalAlert, tooFar: .constant(false), allVirtual: .constant(false), arrived: self.$arrived, eventDetails: self.$eventDetails, page: self.$page, subPage: self.$subPage).environmentObject(self.config)
//            } else if !self.event.isVirtual { //mapMode
//                MapView(evm: self.evm, mapFindMode: false, navToEvent: self.event, internalAlert: self.$internalAlert, externalAlert: self.$externalAlert, tooFar: .constant(false), allVirtual: .constant(false), arrived: self.$arrived, eventDetails: self.$eventDetails, page: self.$page, subPage: self.$subPage).environmentObject(self.config)
//            }
//            if self.config.appEventMode {
//                ZStack {
//                    Text(self.arMode ? "Map View" : "AR View").fontWeight(.light).font(.system(size: 18)).foregroundColor(self.config.accent)
//                }.padding(10)
//                    .background(RoundedRectangle(cornerRadius: 15).stroke(Color.clear).foregroundColor(Color.tertiarySystemBackground.opacity(0.8)).background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color.tertiarySystemBackground.opacity(0.8))))
//                    .onTapGesture { withAnimation { self.arMode.toggle() } }
//                    .offset(y: Constants.height*0.4)
//            }
//        }.alert(isPresented: self.$internalAlert) { () -> Alert in //done in the view
//            if self.arrived {
//                return self.evm.alert(title: "You've Arrived!", message: "Have fun at \(String(describing: self.event.name!))!")
//            } else if self.eventDetails {
//                return self.evm.alert(title: "\(self.event.name!)", message: "This event is at \(self.event.time!) on \(self.event.date!).")/*, and you are \(distanceFromBuilding!)m from \(event!.location!)*/
//            }
//            return self.evm.alert(title: "ERROR", message: "Please report as a bug.")
//        }
//    }).alert(isPresented: self.$externalAlert) { () -> Alert in //done outside the view
//        if self.isVirtual {
//            return self.evm.alert(title: "Virtual Event", message: "Sorry! This event is virtual, so you have no where to navigate to.")
//        } else if self.tooFar {
//            //return self.evm.alert(title: "Too Far to Navigate to Event", message: "You're currently too far away from campus to navigate to this event. You can still view it in the map, and once you get closer to campus, can navigate there.")
//            return self.evm.navAlert(lat: self.event.mainLat, lon: self.event.mainLon)
//        }
//        return self.evm.alert(title: "ERROR", message: "Please report as a bug.")
//    }

//CARDCONTROL: shows which card is currently displayed
struct CardControl : UIViewRepresentable {
    var trendingList: [EventInstance]
    @Binding var card : Int
    
    @Binding var page:String
    @Binding var subPage:String
    
    func makeUIView(context: Context) -> UIPageControl {
        let cardControl = UIPageControl()
        cardControl.currentPageIndicatorTintColor = UIColor.label
        cardControl.pageIndicatorTintColor = UIColor.secondaryLabel.withAlphaComponent(0.25)
        cardControl.numberOfPages = trendingList.count
        return cardControl
    }
    
    //update page indicator (dots)
    func updateUIView(_ uiView: UIPageControl, context: Context) {
        DispatchQueue.main.async {
            uiView.currentPage = self.card
        }
    }
}
