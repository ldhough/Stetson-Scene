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
            //horizontal months list
            MonthCarousel(selectedDate: self.$selectedDate, month: self.$month, height: 330).frame(height: 330)
            //event list that corresponds to selected day
            List {
                ForEach(data) { event in
                    if self.compareDates(date1: self.selectedDate, date2: self.getEventDate(event: event)) {
                        DiscoverListCell(event: event, context: "Calendar").onTapGesture { self.detailView = true }
                    }
                }.padding(.horizontal, 10).listRowBackground(Color(Constants.accent1))
            }.frame(alignment: .center).sheet(isPresented: $detailView, content: { EventDetailView() })
            
        }.background(Color(Constants.accent1))
    }
    
    //USE THIS IN EVENT INITIALIZATION
    func getEventDate(event: Type) -> Date {
        var event: Type = event
        var stringDate: String = event.dateString
        
        //if date has a single digit month, prepare it for dateFormat by adding a second month digit
        if stringDate.count != 10 {
            stringDate = "0" + stringDate
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let date = dateFormatter.date(from: stringDate)!
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .weekday], from: date)

        event.date = calendar.date(from:components)! //full thing
        event.month = String(calendar.component(.month, from: date)) //TODO: get the actual month, not just a number
        event.day = String(calendar.component(.day, from: date))
        event.weekday = String(calendar.component(.weekday, from: date)) //TODO: get the actual weekday, not just a number

        return calendar.date(from:components)!
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
    @Binding var selectedDate: Date
    var height: CGFloat //used for cellWidth
    let monthOffset: Int
    let calendarUnitYMD = Set<Calendar.Component>([.year, .month, .day])
    var monthsArray: [[Date]] { monthArray() }
    var weekdaysArray : [String] = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        VStack(alignment: HorizontalAlignment.center, spacing: 10) {
            Text(getMonthHeader()).fontWeight(.medium).font(.system(size: 30)).foregroundColor(Color(Constants.accent1)).padding(.top, 15)
            //weekday header
            HStack {
                ForEach(weekdaysArray, id: \.self) { weekday in
                    Text(weekday).fontWeight(Font.Weight.light).font(.system(size: 18))
                        .foregroundColor(Color(Constants.text2).opacity(0.5)).frame(minWidth: 0, maxWidth: .infinity)
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
        }.background(RoundedRectangle(cornerRadius: 10)).foregroundColor(Color(Constants.bg2))
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
    var date: Date
    var match: Bool
    var cellWidth: CGFloat
    
    var body: some View {
        Text(self.getDate(date: date))
            .fontWeight(Font.Weight.light)
            .foregroundColor(match ? Color(Constants.bg2) : Color(Constants.text1))
            .frame(width: cellWidth, height: cellWidth)
            .font(.system(size: 18))
            .background(match ? Color(Constants.accent1) : Color.clear)
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
