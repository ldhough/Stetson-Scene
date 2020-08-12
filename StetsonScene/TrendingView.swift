//
//  TrendingView.swift
//  StetsonScene
//
//  Created by Madison Gipson on 7/15/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation
import SwiftUI

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
        var allTrending: [EventInstance] = []
        var selectTrending: [EventInstance] = []
        var id = 0
        
        //pick out trending events
        for event in self.evm.eventList {
            //if event.isTrending {
                allTrending.append(event)
            //}
        }
        
        //shuffle all the trending events and pick the first 10
        for event in allTrending.shuffled() {
            if id<10 {
                selectTrending.append(event)
                id += 1
            }
        }
        return selectTrending
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
    
    var body: some View {
        //horizontal list of events in list
        HStack(spacing: 0) {
            ForEach(trendingList) {  event in
                //area around the card (whole screen width)
                VStack {
                    //card view
                    ZStack {
                        //Background Image
                        Image("SS").resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: self.cardWidth, height: self.height)
                            .cornerRadius(20)
                        //FirebaseImage(id: self.evm.buildingModelController.buildingDic[event.location]!.photoInfo, evm: self.evm).resizable().aspectRatio(contentMode: .fill).frame(width: self.cardWidth, height: self.height).cornerRadius(20)
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
                        .onTapGesture { self.selectedEvent = event }
                }.frame(width: Constants.width).animation(.default) //end of vstack
            } //end of foreach
        }.sheet(item: $selectedEvent) { event in
            EventDetailView(evm: self.evm, event: event, page: self.$page, subPage: self.$subPage).environmentObject(self.config)
        }//end of hstack
    } //end of view
}

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
