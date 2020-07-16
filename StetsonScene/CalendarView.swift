//
//  CalendarView.swift
//  StetsonScene
//
//  Created by Madison Gipson on 7/15/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import SwiftUI

//MARK: CALENDARVIEW DISPLAYS MONTHCAROUSEL
struct CalendarView : View {
    @State var selectedDate: Date = Date()
    @State var month = 0
    @State var detailView: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            MonthCarousel(selectedDate: self.$selectedDate, month: self.$month, height: Constants.height*0.4).frame(height: Constants.height*0.4)
            Rectangle().frame(width: Constants.width, height: 2).foregroundColor(Color(Constants.bg1))
            List {
                ForEach(data) { event in
                    SmallDiscoverListCell(event: event).onTapGesture { self.detailView = true }
                }.listRowBackground(Color(Constants.accent1))
            }.sheet(isPresented: $detailView, content: { EventDetailView() })
        }.background(Color(Constants.accent1))
    }
}

//MARK: MONTHCAROUSEL DISPLAYS EACH MONTH IN A HORIZONTAL CAROUSEL
struct MonthCarousel : UIViewRepresentable {
    @Binding var selectedDate: Date
    @Binding var month : Int
    var height : CGFloat
    
    //create and update the Carousel UIScrollView
    func makeUIView(context: Context) -> UIScrollView{
        //create a scrollview to hold cards
        let scrollview = UIScrollView()
        let carouselWidth = UIScreen.main.bounds.width * CGFloat(numberOfMonths())
        scrollview.contentSize = CGSize(width: carouselWidth, height: 1.0) //setting height to 1.0 disables verical scroll
        scrollview.isPagingEnabled = true
        scrollview.bounces = true
        scrollview.showsVerticalScrollIndicator = false
        scrollview.showsHorizontalScrollIndicator = false
        
        //make the Months SwiftUI View into a UIView (essentially)
        let uiMonthView = UIHostingController(rootView: Months(selectedDate: self.$selectedDate, numMonths: numberOfMonths()))
        uiMonthView.view.frame = CGRect(x: 0, y: 0, width: carouselWidth, height: self.height)
        uiMonthView.view.backgroundColor = Constants.accent1
        
        //add the uiMonthView as a subview of the scrollview
        //(effectively embeds the Months SwiftUI View into the Carousel UIScrollView)
        scrollview.addSubview(uiMonthView.view)
        return scrollview
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {}
    
    //function to determine number of months & consequently width
    func numberOfMonths() -> Int {
        let minimumDate: Date = Date()
        let maximumDate: Date = Date().addingTimeInterval(60*60*24*365)
        var components = Calendar.current.dateComponents([.year, .month, .day], from: maximumDate)
        components.month! += 1
        components.day = 0
        return Calendar.current.dateComponents([.month], from:minimumDate, to: Calendar.current.date(from: components)!).month! + 1
    }
}

//MARK: MONTHS DISPLAYS EACH MONTH IN THE NUMBER OF MONTHS WE WANT TO SEE (DEFAULT IS A YEAR)
struct Months: View {
    @Binding var selectedDate: Date
    var numMonths: Int
    
    var body: some View {
        HStack {
            ForEach(0..<numMonths) { index in
                Month(selectedDate: self.$selectedDate, monthOffset: index)
            }.padding(.horizontal, 10)
        }
    }
}

//MARK: MONTH DISPLAYS EACH MONTH FOR THE NEXT YEAR AND ALLOWS SELECTION OF EVENTS ON THAT DAY
//USES A SYSTEM CALENDAR TO DETERMINE THE CALENDAR VIEW
struct Month: View {
    @Binding var selectedDate: Date
    
    let monthOffset: Int
    let calendarUnitYMD = Set<Calendar.Component>([.year, .month, .day])
    var monthsArray: [[Date]] { monthArray() }
    
    var body: some View {
        VStack(alignment: HorizontalAlignment.center, spacing: 10) {
            Text(getMonthHeader()).fontWeight(.medium).font(.system(size: 30)).foregroundColor(Color(Constants.accent1)).padding(.top, 15)
            //month
            VStack(alignment: .leading, spacing: 5) {
                ForEach(monthsArray, id:  \.self) { row in
                    //week
                    HStack {
                        ForEach(row, id:  \.self) { column in
                            //day
                            HStack {
                                Spacer()
                                if Calendar.current.isDate(column, equalTo: self.firstOfMonth(), toGranularity: .month) {
                                    DateCell(date: column, selectedDate: self.$selectedDate, cellWidth: CGFloat(30))
                                    .onTapGesture { self.selectedDate = column }
                                } else {
                                    Text("").frame(width: CGFloat(30), height: CGFloat(30))
                                }
                                Spacer()
                            }
                        }
                    }
                }
            }.frame(minWidth: 0, maxWidth: .infinity).padding(.vertical, 15)
        }.background(RoundedRectangle(cornerRadius: 10)).foregroundColor(Color(Constants.bg1))
    }
    
    //MONTH OFFSET
    func firstOfMonth() -> Date {
        var offset = DateComponents()
        offset.month = monthOffset
        var components =  Calendar.current.dateComponents(calendarUnitYMD, from: Date()) //minDate
        components.day = 1
        return Calendar.current.date(byAdding: offset, to: Calendar.current.date(from: components)!)!
    }
     
    //MONTH ARRAY
    func monthArray() -> [[Date]] {
        var rowArray = [[Date]]()
        let numberOfDays = (Calendar.current.range(of: .weekOfMonth, in: .month, for: firstOfMonth())?.count)! * 7
        for row in 0 ..< (numberOfDays/7) {
            var columnArray = [Date]()
            for column in 0 ... 6 {
                let abc = self.getDateAtIndex(index: (row * 7) + column)
                columnArray.append(abc)
            }
            rowArray.append(columnArray)
        }
        return rowArray
    }
    
    func getDateAtIndex(index: Int) -> Date {
        let weekday =  Calendar.current.component(.weekday, from: firstOfMonth())
        var startOffset = weekday -  Calendar.current.firstWeekday
        startOffset += startOffset >= 0 ? 0 : 7 //(days per week)
        var dateComponents = DateComponents()
        dateComponents.day = index - startOffset
        return  Calendar.current.date(byAdding: dateComponents, to: firstOfMonth())!
    }
    
    //MONTHHEADER
    func getMonthHeader() -> String {
        let headerDateFormatter = DateFormatter()
        headerDateFormatter.calendar = Calendar.current
        headerDateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "LLLL", options: 0, locale:  Calendar.current.locale)
        return headerDateFormatter.string(from: firstOfMonth())
    }
}

struct DateCell: View {
    var date: Date
    @Binding var selectedDate: Date
    var cellWidth: CGFloat
    @State var initialized: Bool = false
    
    var body: some View {
        Text(self.formatDate(date: date, calendar: Calendar.current))
            .fontWeight(Font.Weight.light)
            .foregroundColor(date == selectedDate ? Color(Constants.bg2) : Color(Constants.text1))
            .frame(width: cellWidth, height: cellWidth)
            .font(.system(size: 18))
            .background(date == selectedDate ? Color(Constants.accent1) : Color.clear)
            .clipShape(Circle())
    }
    
    func formatDate(date: Date, calendar: Calendar) -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "d"
        if formatter.calendar != calendar {
            formatter.calendar = calendar
        }
        return formatter.string(from: date)
    }
}

//CONTENTS OF EACH EVENT CELL
struct SmallDiscoverListCell : View {
    var event: Type
    
    var body: some View {
        ZStack {
            HStack {
                //Date & Time, Left Side
                VStack(alignment: .trailing) {
                    Text(event.date).fontWeight(.medium).font(.system(size: 12)).foregroundColor(Color(Constants.accent1)).padding(.vertical, 5)
                    Text(event.time).fontWeight(.medium).font(.system(size: 10)).foregroundColor(Color(Constants.text2).opacity(0.5)).padding(.bottom, 5)
                    //Duration?
                }.frame(width: Constants.width*0.15)
                
                //Name & Location, Right Side
                VStack(alignment: .leading) {
                    Text(event.eventName).fontWeight(.medium).font(.system(size: 16)).lineLimit(1).foregroundColor(Color(Constants.text1)).padding(.vertical, 5)
                    Text(event.location).fontWeight(.light).font(.system(size: 12)).foregroundColor(Color(Constants.text2).opacity(0.5)).padding(.bottom, 5)
                }
                
                //Fill out rest of cell
                Spacer()
                
            }.padding(([.vertical, .horizontal])) //padding within the cell, between words and borders
        }.frame(height: Constants.height*0.075).background(RoundedRectangle(cornerRadius: 10).stroke(Color(Constants.accent1)).foregroundColor(Color(Constants.text1)).background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color(Constants.bg2))))
    }
}

