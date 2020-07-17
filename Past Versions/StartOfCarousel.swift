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
    @State var page = 0
    
    var body: some View {
        VStack {
            Text("Trending").fontWeight(.heavy).font(.system(size: 32)).padding([.vertical, .horizontal]).frame(alignment: .leading)
            //Carousel List- using GeomtryReader to detect the remaining height on the screen (smart scaling)
            GeometryReader{ geometry in
                Carousel(page: self.$page, height: geometry.frame(in: .global).height)
            }
            //Page control are the dots
            PageControl(page: self.$page).padding(.top, 5)
        }
    }
}

struct Carousel : UIViewRepresentable {
    @Binding var page : Int
    var height : CGFloat
    
    func makeUIView(context: Context) -> UIScrollView{
        let carouselWidth = Constants.width * CGFloat(data.count)
        let view = UIScrollView()
        view.isPagingEnabled = true
        //1.0  For Disabling Vertical Scroll....
        view.contentSize = CGSize(width: carouselWidth, height: 1.0)
        view.bounces = true
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.delegate = context.coordinator
        
        // Now Going to  embed swiftUI View Into UIView...
        print("height: ", height)
        print("page: ", page)
        let view1 = UIHostingController(rootView: List(page: self.$page))
        view1.view.frame = CGRect(x: 0, y: 0, width: carouselWidth, height: self.height)
        view1.view.backgroundColor = .clear
        view.addSubview(view1.view)
        return view
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Carousel.Coordinator(parent1: self)
    }
    
    class Coordinator : NSObject,UIScrollViewDelegate{
        var parent : Carousel
        init(parent1: Carousel) {
           parent = parent1
        }
        
        //get current page
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            let page = Int(scrollView.contentOffset.x / Constants.width)
            print(page)
            self.parent.page = page
        }
    }
}

struct List : View {
    @Binding var page : Int

    var body: some View{
        HStack(spacing: 0){
            ForEach(data){ event in
                Card(page: self.$page, data: event)
            }
        }
    }
}

struct Card : View {
    @Binding var page : Int
    var data : Type
    
    var body: some View{
        VStack {
            VStack {
                Text(self.data.eventName)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 25)
            .background(Color.blue.opacity(0.5))
            .cornerRadius(20)
            .padding(.top, 25)
            .padding(.vertical, self.page == data.id ? 0 : 25)
            .padding(.horizontal, self.page == data.id ? 0 : 25)
            // Increasing Height And Width If Currnet Page Appears...
        }
        .frame(width: Constants.width)
        .animation(.default)
    }
}

//USED TO PREVENT INFINITE SCROLLING-  CONTROLS PAGING
struct PageControl : UIViewRepresentable {
    @Binding var page : Int
    
    func makeUIView(context: Context) -> UIPageControl {
        let view = UIPageControl()
        view.currentPageIndicatorTintColor = .black
        view.pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
        view.numberOfPages = data.count
        print("numberOfPages: ", data.count)
        return view
    }
    
    //update page indicator (dots)
    func updateUIView(_ uiView: UIPageControl, context: Context) {
        DispatchQueue.main.async {
            uiView.currentPage = self.page
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
}

var data = [
    Type(id: 0, eventName: "Event0", date: "6/1", time: "9:00am", location: "CUB"),
    Type(id: 0, eventName: "Event1", date: "6/2", time: "10:00am", location: "Elizabeth Hall"),
    Type(id: 0, eventName: "Event2", date: "6/3", time: "11:00am", location: "DuPont Ball Library"),
    Type(id: 0, eventName: "Event3", date: "6/4", time: "5:00pm", location: "Allen Hall"),
    Type(id: 0, eventName: "Event4", date: "6/5", time: "9:00pm", location: "Stetson Green")
]
