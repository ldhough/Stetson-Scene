//
//  CalendarView.swift
//  StetsonScene
//
//  Created by Madison Gipson on 7/15/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//
import Foundation
import SwiftUI

//MARK: CALENDARVIEW DISPLAYS MONTHCAROUSEL
struct CalendarView : View {
    @ObservedObject var evm:EventViewModel
    @EnvironmentObject var config: Configuration
    @Environment(\.colorScheme) var colorScheme
    @State var selectedDate: Date = Date()
    @State var month = 0
    
    var body: some View {
        //CALENDAR & SUB-LIST
        VStack(spacing: 0) {
            //horizontal months list
            MonthCarousel(selectedDate: self.$selectedDate, month: self.$month, height: 330).frame(height: 330)
            //event list that corresponds to selected day
            List {
                ForEach(evm.eventList) { event in
                    if self.compareDates(date1: self.selectedDate, date2: self.evm.getEventDate(event: event)) {
                        if self.config.page == "Favorites" && event.isFavorite {
                            ListCell(evm: self.evm, event: event)
                        } else if self.config.page == "Discover" {
                            ListCell(evm: self.evm, event: event)
                        }
                    }
                }.padding(.horizontal, 10).listRowBackground((config.page == "Favorites" && colorScheme == .light) ? config.accent : Color.secondarySystemBackground)
            }.frame(alignment: .center)
        }.background((config.page == "Favorites" && colorScheme == .light) ? config.accent : Color.secondarySystemBackground)
    }

    //REMOVES TIME- USED ALSO IN MONTH CAROUSEL, MAKE IT GLOBAL IF POSSIBLE
    func compareDates(date1: Date, date2: Date) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        if dateFormatter.string(from: date1) == dateFormatter.string(from: date2) {
            return true
        } else {
            return false
        }
    }
}

//MARK: MONTHCAROUSEL DISPLAYS EACH MONTH IN A HORIZONTAL CAROUSEL
struct MonthCarousel : UIViewRepresentable {
    @EnvironmentObject var config: Configuration
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
        let uiMonthView = UIHostingController(rootView: Months(selectedDate: self.$selectedDate, height: self.height, numMonths: numberOfMonths()))
        uiMonthView.view.frame = CGRect(x: 0, y: 0, width: carouselWidth, height: self.height)
        uiMonthView.view.backgroundColor = UIColor.clear
        
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
    var height: CGFloat
    var numMonths: Int
    
    var body: some View {
        HStack {
            ForEach(0..<numMonths) { index in
                Month(selectedDate: self.$selectedDate, height: self.height, monthOffset: index)
            }.padding(.horizontal, 10)
        }
    }
}

//MARK: MONTH DISPLAYS EACH MONTH FOR THE NEXT YEAR AND ALLOWS SELECTION OF EVENTS ON THAT DAY
//USES A SYSTEM CALENDAR TO DETERMINE THE CALENDAR VIEW
struct Month: View {
    @EnvironmentObject var config: Configuration
    @Binding var selectedDate: Date
    @Environment(\.colorScheme) var colorScheme
    var height: CGFloat //used for cellWidth
    let monthOffset: Int
    let calendarUnitYMD = Set<Calendar.Component>([.year, .month, .day])
    var monthsArray: [[Date]] { monthArray() }
    var weekdaysArray : [String] = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        //Discover
        //back: blue
        VStack(alignment: HorizontalAlignment.center, spacing: 10) {
            Text(getMonthHeader()).fontWeight(.medium).font(.system(size: 30)).foregroundColor((config.page == "Favorites" || self.colorScheme == .dark) ? Color.label : Color.secondarySystemBackground).padding(.top, 15)
            //weekday header
            HStack {
                ForEach(weekdaysArray, id: \.self) { weekday in
                    Text(weekday).fontWeight(Font.Weight.light).font(.system(size: 18))
                        .foregroundColor((self.config.page == "Favorites" || self.colorScheme == .dark) ? Color.secondaryLabel : Color.tertiarySystemBackground).frame(minWidth: 0, maxWidth: .infinity)
                }
            }
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
                                    DateCell(date: column, match: self.compareDates(date1: column, date2: self.selectedDate), cellWidth: self.height/11)
                                        .onTapGesture { self.selectedDate = column }
                                } else {
                                    Text("").frame(width: self.height/11, height: self.height/11)
                                }
                                Spacer()
                            }
                        }
                    }
                }
            }.frame(minWidth: 0, maxWidth: .infinity).padding(.bottom, 15)
        }.background(RoundedRectangle(cornerRadius: 10)).foregroundColor(config.page == "Favorites" ? Color.tertiarySystemBackground : config.accent)
    }
    
    func compareDates(date1: Date, date2: Date) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        if dateFormatter.string(from: date1) == dateFormatter.string(from: date2) {
            return true
        } else {
            return false
        }
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

//MARK: FORMATTING FOR A SINGLE DATE CELL IN CALENDAR VIEW
struct DateCell: View {
    @EnvironmentObject var config: Configuration
    var date: Date
    var match: Bool
    var cellWidth: CGFloat
    
    
    var body: some View {
        Text(self.getDate(date: date))
            .fontWeight(Font.Weight.light)
            .foregroundColor(match ? (config.page == "Favorites" ? Color.tertiarySystemBackground : config.accent) : Color.label)
            .frame(width: cellWidth, height: cellWidth)
            .font(.system(size: 18))
            .background(match ? (config.page == "Favorites" ? config.accent : Color.white) : Color.clear)
            .clipShape(Circle())
    }
    
    func getDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "d"
        formatter.calendar = Calendar.current
        return formatter.string(from: date)
    }
}
