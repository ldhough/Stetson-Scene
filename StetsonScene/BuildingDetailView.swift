//
//  BuildingDetailView.swift
//  StetsonScene
//
//  Created by Madison Gipson on 8/11/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation
import SwiftUI
import CoreLocation
import FirebaseStorage

struct BuildingDetailView: View {
    @ObservedObject var evm:EventViewModel
    @EnvironmentObject var config: Configuration
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var buildingInstance:BuildingInstance 
    
    @State var card = 0
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 20).frame(width: Constants.width*0.25, height: 5, alignment: .center).foregroundColor(Color.secondaryLabel.opacity(0.2)).padding(.vertical, 20)
            
            HStack (alignment: .center) {
                self.evm.buildingModelController.getImage(evm: self.evm, eventLocation: buildingInstance.buildingName).resizable().clipShape(Circle()).frame(width: Constants.width*0.3, height: Constants.width*0.3).aspectRatio(contentMode: .fit).overlay(Circle().stroke(Color.white, lineWidth: 4)).shadow(radius: 10)
                VStack {
                    Text(buildingInstance.buildingName).fontWeight(.medium).font(.system(size: 30)).frame(maxWidth: Constants.width, alignment: .leading).multilineTextAlignment(.leading).foregroundColor(config.accent).padding(.bottom, 5)
                    Text("Est. \(buildingInstance.builtDate)").fontWeight(.light).font(.system(size: 20)).frame(maxWidth: Constants.width, alignment: .leading).foregroundColor(Color.label)
                }.padding(.horizontal, 5)
            }.padding([.horizontal]).padding(.leading, 15)
            Rectangle().frame(width: Constants.width*0.75, height: 1, alignment: .center).foregroundColor(Color.secondaryLabel.opacity(0.2)).padding(.vertical, 10)
            Text(buildingInstance.buildingSummary).fontWeight(.light).font(.system(size: 18)).multilineTextAlignment(.leading).foregroundColor(Color.label).padding(.horizontal, 20)
            
            Text("Building Fun Facts").fontWeight(.medium).font(.system(size: 25)).frame(alignment: .center).foregroundColor(self.config.accent).padding(.top, 15)
            //Carousel List- using GeomtryReader to detect the remaining height on the screen (smart scaling)
            GeometryReader{ geometry in
                FunFactCarousel(buildingInstance: self.buildingInstance, card: self.$card, height: geometry.frame(in: .global).height)
            }
            //dots that show which card is being displayed
            FunFactCardControl(buildingInstance: self.buildingInstance, card: self.$card).padding(.bottom, 10)
        }.background(Color.secondarySystemBackground).edgesIgnoringSafeArea(.bottom)//VStack end
    }
}

//CAROUSEL: UIView that embeds the Cards SwiftUI View
//Uses a UIScrollView to detect card offset and tells the UIView when the card changes through @Binding card
//@Binding card then updates in the rest of the structs that use it so the correct card is displayed
struct FunFactCarousel : UIViewRepresentable {
    @ObservedObject var buildingInstance:BuildingInstance
    @Binding var card : Int
    var height : CGFloat
    
    //create and update the Carousel UIScrollView
    func makeUIView(context: Context) -> UIScrollView{
        //create a scrollview to hold cards
        let scrollview = UIScrollView()
        let carouselWidth = Constants.width * CGFloat(buildingInstance.funFacts.count)
        scrollview.contentSize = CGSize(width: carouselWidth, height: 1.0) //setting height to 1.0 disables verical scroll
        scrollview.isPagingEnabled = true
        scrollview.bounces = true
        scrollview.showsVerticalScrollIndicator = false
        scrollview.showsHorizontalScrollIndicator = false
        scrollview.delegate = context.coordinator
        
        //make the Card SwiftUI View into a UIView (essentially)
        let uiCardView = UIHostingController(rootView: FunFactCards(buildingInstance: self.buildingInstance, height: height*0.9))
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
        return FunFactCarousel.Coordinator(parent: self)
    }
    
    class Coordinator : NSObject, UIScrollViewDelegate {
        var carousel : FunFactCarousel
        init(parent: FunFactCarousel) {
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
struct FunFactCards : View {
    @EnvironmentObject var config: Configuration
    @ObservedObject var buildingInstance:BuildingInstance
    var height : CGFloat
    let cardWidth = Constants.width*0.9
    
    var body: some View {
        //horizontal list of events in list
        HStack(spacing: 0) {
            ForEach(buildingInstance.funFacts, id: \.self) { fact in
                //area around the card (whole screen width)
                VStack {
                    //card view
                    ZStack {
                        RoundedRectangle(cornerRadius: 20).fill(self.config.accent.opacity(0.5))
                        Text("\(fact)").fontWeight(.light).font(.system(size: 20)).frame(alignment: .topLeading).padding(.vertical, 10).padding(.horizontal, 15).foregroundColor(Color.secondarySystemBackground)
                    }.padding([.horizontal, .vertical])
                        .frame(width: self.cardWidth, height: self.height)
                        .cornerRadius(20)
                        .shadow(radius: 5)
                }.frame(width: Constants.width)
            }
        }
    } //end of view
    
} //end of struct

//CARDCONTROL: shows which card is currently displayed
struct FunFactCardControl : UIViewRepresentable {
    @ObservedObject var buildingInstance:BuildingInstance
    @Binding var card : Int
    
    func makeUIView(context: Context) -> UIPageControl {
        let cardControl = UIPageControl()
        cardControl.currentPageIndicatorTintColor = UIColor.label
        cardControl.pageIndicatorTintColor = UIColor.secondaryLabel.withAlphaComponent(0.25)
        cardControl.numberOfPages = buildingInstance.funFacts.count
        return cardControl
    }
    
    //update page indicator (dots)
    func updateUIView(_ uiView: UIPageControl, context: Context) {
        DispatchQueue.main.async {
            uiView.currentPage = self.card
        }
    }
}
