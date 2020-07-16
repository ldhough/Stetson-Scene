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
    @EnvironmentObject var viewRouter: ViewRouter
    @State var card = 0
    
    var body: some View {
        VStack {
            Text("Trending").fontWeight(.heavy).font(.system(size: 50)).padding([.vertical, .horizontal]).frame(maxWidth: .infinity, alignment: .leading)
            //Carousel List- using GeomtryReader to detect the remaining height on the screen (smart scaling)
            GeometryReader{ geometry in
                Carousel(card: self.$card, height: geometry.frame(in: .global).height)
            }
            //dots that show which card is being displayed
            CardControl(card: self.$card).padding([.vertical, .horizontal])
        }
    }
}

//CAROUSEL: UIView that embeds the Cards SwiftUI View
//Uses a UIScrollView to detect card offset and tells the UIView when the card changes through @Binding card
//@Binding card then updates in the rest of the structs that use it so the correct card is displayed
struct Carousel : UIViewRepresentable {
    @Binding var card : Int
    var height : CGFloat
    
    //create and update the Carousel UIScrollView
    func makeUIView(context: Context) -> UIScrollView{
        //create a scrollview to hold cards
        let scrollview = UIScrollView()
        let carouselWidth = Constants.width * CGFloat(data.count)
        scrollview.contentSize = CGSize(width: carouselWidth, height: 1.0) //setting height to 1.0 disables verical scroll
        scrollview.isPagingEnabled = true
        scrollview.bounces = true
        scrollview.showsVerticalScrollIndicator = false
        scrollview.showsHorizontalScrollIndicator = false
        scrollview.delegate = context.coordinator
        
        //make the Card SwiftUI View into a UIView (essentially)
        let uiCardView = UIHostingController(rootView: Cards(height: height*0.9))
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
    var height : CGFloat
    let cardWidth = Constants.width*0.9
    @State var detailView: Bool = false
    
    var body: some View {
        //horizontal list of events in list
        HStack(spacing: 0) {
            ForEach(data) {  event in
                //area around the card (whole screen width)
                    VStack {
                        //card view
                        ZStack {
                            //Background Image
                            Image("SS").resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: self.cardWidth, height: self.height)
                                .cornerRadius(20)
                            //Layer over image
                            VStack {
                                //Spacer
                                VStack {
                                    Spacer()
                                }.frame(width: self.cardWidth, height: self.height*0.6)
                                //Text
                                VStack (alignment: .leading) {
                                    Text(event.eventName).fontWeight(.heavy).font(.system(size: 40)).padding(.top, 10)
                                    Text(event.date + " | " + event.time).fontWeight(.light).font(.system(size: 25)).padding(.top, 5).padding(.bottom, 5)
                                    Text(event.location).fontWeight(.light).font(.system(size: 25)).padding(.bottom, 10)
                                }.padding([.horizontal, .vertical])
                                    .frame(width: self.cardWidth, height: self.height*0.4, alignment: .leading)
                                    .background(Color.white.opacity(0.7))
                            }.frame(width: self.cardWidth, height: self.height)
                        }.padding([.horizontal, .vertical])
                            .frame(width: self.cardWidth, height: self.height)
                            .cornerRadius(20)
                            .shadow(radius: 5)
                            .onTapGesture { self.detailView = true }
                            .sheet(isPresented: self.$detailView, content: { EventDetailView() }) //end of button
                    }.frame(width: Constants.width).animation(.default) //end of vstack
            } //end of foreach
        } //end of hstack
        
    }
}

//CARDCONTROL: shows which card is currently displayed
struct CardControl : UIViewRepresentable {
    @Binding var card : Int
    
    func makeUIView(context: Context) -> UIPageControl {
        let cardControl = UIPageControl()
        cardControl.currentPageIndicatorTintColor = UIColor.black
        cardControl.pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.25)
        cardControl.numberOfPages = data.count
        return cardControl
    }
    
    //update page indicator (dots)
    func updateUIView(_ uiView: UIPageControl, context: Context) {
        DispatchQueue.main.async {
            uiView.currentPage = self.card
        }
    }
}


//TESTING PURPOSES ONLY- WILL PULL FROM EVENT OBJECT LATER
struct Type : Identifiable {
    var id : Int
    var eventName : String
    var date : String
    var time : String
    var location : String
    var category : String
}

var data = [
    Type(id: 0, eventName: "Event 1", date: "JUL 1", time: "9:00am", location: "CUB", category: "test"),
    Type(id: 1, eventName: "Event 2", date: "JUL 2", time: "10:00am", location: "Elizabeth Hall", category: "test"),
    Type(id: 2, eventName: "Event 3", date: "AUG 3", time: "11:00am", location: "DuPont Ball Library", category: "test"),
    Type(id: 3, eventName: "Event 4", date: "AUG 4", time: "5:00pm", location: "Allen Hall", category: "test"),
    Type(id: 4, eventName: "Event 5", date: "SEP 5", time: "9:00pm", location: "Stetson Green", category: "test")
]
