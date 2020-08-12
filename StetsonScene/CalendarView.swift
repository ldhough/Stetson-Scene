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
    
    @Binding var page:String
    @Binding var subPage:String
    
    var body: some View {
        //CALENDAR & SUB-LIST
        VStack(spacing: 0) {
            //horizontal months list
            MonthCarousel(evm: self.evm, selectedDate: self.$selectedDate, month: self.$month, height: 330, page: self.$page, subPage: self.$subPage).frame(height: 330)
            //event list that corresponds to selected day
            List {
                ForEach(evm.eventList) { event in
                    if self.evm.compareDates(date1: self.selectedDate, date2: self.evm.getEventDate(event: event)) {
                        if self.page == "Favorites" && event.isFavorite {
                            ListCell(evm: self.evm, event: event, page: self.$page, subPage: self.$subPage)
                        } else if self.page == "Discover" {
                            ListCell(evm: self.evm, event: event, page: self.$page, subPage: self.$subPage)
                        }
                    }
                }.padding(.horizontal, 10).listRowBackground((self.page == "Favorites" && colorScheme == .light) ? config.accent : Color.secondarySystemBackground)
            }.frame(alignment: .center)
        }.background((self.page == "Favorites" && colorScheme == .light) ? config.accent : Color.secondarySystemBackground)
    }
}

//MARK: MONTHCAROUSEL DISPLAYS EACH MONTH IN A HORIZONTAL CAROUSEL
struct MonthCarousel : UIViewRepresentable {
    @ObservedObject var evm:EventViewModel
    @EnvironmentObject var config: Configuration
    @Binding var selectedDate: Date
    @Binding var month : Int
    var height : CGFloat
    let numMonths = 6 //year
    
    @Binding var page:String
    @Binding var subPage:String
    
    //create and update the Carousel UIScrollView
    func makeUIView(context: Context) -> UIScrollView{
        //create a scrollview to hold cards
        let scrollview = UIScrollView()
        let carouselWidth = UIScreen.main.bounds.width * CGFloat(numMonths) //CGFloat(numberOfMonths()) //for width
        scrollview.contentSize = CGSize(width: carouselWidth, height: 1.0) //setting height to 1.0 disables verical scroll
        scrollview.isPagingEnabled = true
        scrollview.bounces = true
        scrollview.showsVerticalScrollIndicator = false
        scrollview.showsHorizontalScrollIndicator = false
        
        //make the Months SwiftUI View into a UIView (essentially)
        let uiMonthView = UIHostingController(rootView: Months(evm: self.evm, selectedDate: self.$selectedDate, height: self.height, numMonths: numMonths, page: self.$page, subPage: self.$subPage)) //numberOfMonths()))
        uiMonthView.view.frame = CGRect(x: 0, y: 0, width: carouselWidth, height: self.height)
        uiMonthView.view.backgroundColor = .clear
        
        //add the uiMonthView as a subview of the scrollview
        //(effectively embeds the Months SwiftUI View into the Carousel UIScrollView)
        scrollview.addSubview(uiMonthView.view)
        return scrollview
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {}
    
    //function to determine number of months & consequently width
//    func numberOfMonths() -> Int {
//        let minimumDate: Date = Date()
//        let maximumDate: Date = Date().addingTimeInterval(60*60*24*365)
//        var components = Calendar.current.dateComponents([.year, .month, .day], from: maximumDate)
//        components.month! += 1
//        components.day = 0
//        return Calendar.current.dateComponents([.month], from:minimumDate, to: Calendar.current.date(from: components)!).month! + 1
//    }
}

//MARK: MONTHS DISPLAYS EACH MONTH IN THE NUMBER OF MONTHS WE WANT TO SEE (DEFAULT IS A YEAR)
struct Months: View {
    @ObservedObject var evm:EventViewModel
    @Binding var selectedDate: Date
    var height: CGFloat
    var numMonths: Int
    
    @Binding var page:String
    @Binding var subPage:String
    
    var body: some View {
        HStack {
            ForEach(0..<numMonths) { index in
                Month(evm: self.evm, selectedDate: self.$selectedDate, height: self.height, monthOffset: index, page: self.$page, subPage: self.$subPage)
            }.padding(.horizontal, 10)
        }
    }
}

//MARK: MONTH DISPLAYS EACH MONTH FOR THE NEXT YEAR AND ALLOWS SELECTION OF EVENTS ON THAT DAY
//USES A SYSTEM CALENDAR TO DETERMINE THE CALENDAR VIEW
struct Month: View {
    @ObservedObject var evm:EventViewModel
    @EnvironmentObject var config: Configuration
    @Binding var selectedDate: Date
    @Environment(\.colorScheme) var colorScheme
    var height: CGFloat //used for cellWidth
    let monthOffset: Int
    let calendarUnitYMD = Set<Calendar.Component>([.year, .month, .day])
    var monthsArray: [[Date]] { monthArray() }
    var weekdaysArray : [String] = ["S", "M", "T", "W", "T", "F", "S"]
    
    @Binding var page:String
    @Binding var subPage:String
    
    var body: some View {
        //Discover
        //back: blue
        VStack(alignment: HorizontalAlignment.center, spacing: 10) {
            Text(getMonthHeader()).fontWeight(.medium).font(.system(size: 30)).foregroundColor((self.page == "Favorites" || self.colorScheme == .dark) ? Color.label : Color.secondarySystemBackground).padding(.top, 15)
            //weekday header
            HStack {
                ForEach(weekdaysArray, id: \.self) { weekday in
                    Text(weekday).fontWeight(Font.Weight.light).font(.system(size: 18))
                        .foregroundColor((self.page == "Favorites" || self.colorScheme == .dark) ? Color.secondaryLabel : Color.tertiarySystemBackground).frame(minWidth: 0, maxWidth: .infinity)
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
                                    DateCell(date: column, match: self.evm.compareDates(date1: column, date2: self.selectedDate), cellWidth: self.height/11, page: self.$page, subPage: self.$subPage)
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
        }.background(RoundedRectangle(cornerRadius: 10)).foregroundColor(self.page == "Favorites" ? Color.tertiarySystemBackground : config.accent)
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
    
    @Binding var page:String
    @Binding var subPage:String
    
    func getDayMonthYear(date: Date) -> (String, String, String) { //month, date, year
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let year = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "M"
        let month = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "d"
        let day = dateFormatter.string(from: date)
        return (month, day, year)
    }
    
    func makeColor() -> Color { //could be made a lot shorter lol oops
        let currentDate = getDayMonthYear(date: Date())
        let checkDate = getDayMonthYear(date: self.date)
        
        if self.page == "Favorites" {
            if Int(checkDate.0)! < Int(currentDate.0)! { //If month before than current month
                if Int(checkDate.2)! >=  Int(currentDate.2)! {
                    return Color.label
                }
                return Color.red
            } else if Int(checkDate.0)! > Int(currentDate.0)! {
                if Int(checkDate.2)! >= Int(currentDate.2)! {
                    return Color.label
                }
                return Color.red
            }
            if Int(checkDate.1)! < Int(currentDate.1)! {
                return Color.red
            } else {
                return Color.label//Color.tertiarySystemBackground
            }
        } else {
            if Int(checkDate.0)! < Int(currentDate.0)! { //If month before than current month
                if Int(checkDate.2)! >=  Int(currentDate.2)! {
                    return Color.label
                }
                return Color.red
            } else if Int(checkDate.0)! > Int(currentDate.0)! {
                if Int(checkDate.2)! >= Int(currentDate.2)! {
                    return Color.label
                }
                return Color.red
            }
            if Int(checkDate.1)! < Int(currentDate.1)! {
                return Color.red
            } else {
                return Color.label//config.accent
            }
        }
    }
    
    var body: some View {
        Text(self.getDate(date: date))
            .fontWeight(Font.Weight.light)
            // self.date < Date()
            .foregroundColor(match ? (self.page == "Favorites" ? Color.tertiarySystemBackground : config.accent) : makeColor())//Color.label)
            //.foregroundColor(match ? (self.page == "Favorites" ? Color.tertiarySystemBackground : config.accent) : Color.label)
            .frame(width: cellWidth, height: cellWidth)
            .font(.system(size: 18))
            .background(match ? (self.page == "Favorites" ? config.accent : Color.white) : Color.clear)
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
