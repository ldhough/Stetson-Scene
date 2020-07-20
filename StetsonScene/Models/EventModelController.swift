//
//  EventModelController.swift
//  StetsonScene
//
//  Created by Lannie Hough on 1/29/20.
//  Copyright © 2020 Lannie Hough. All rights reserved.

import Foundation
import SwiftUI
import Firebase
import FirebaseDatabase
import CoreData
import EventKit

/// ViewModel class for MVVM design pattern.  A single instance is created and injected into various views.
class EventViewModel: ObservableObject {
    
    //List of EventInstance objects representing live events loaded into the app from the backend
    @Published var eventList:[EventInstance] = []
    
    //Dictionaries that associate sublocations and event subtypes with their parent types
    //ex: Room 210 is a sublocation for Elizabeth Hall
    var eventTypeAssociations:Dictionary<String, Any> = [:]
    var locationAssociations:Dictionary<String, Any> = [:]
    
    //Indicates how many weeks worth of database info are currently loaded into the app to prevent unnecessary database queries
    var weeksStored:Int = 1
    @Published var hasFirebaseConnection = true
    
    private enum ParentChildRelationship {
        case eventType
        case location
    }
    
    ///Function takes an event subtype & returns the "parent" event type.  Helper search function.
    private func associateParentType(childType: String, eventTypeOrLocation: ParentChildRelationship) -> String {
        var dictionary:Dictionary<String, Any> = [:]
        if eventTypeOrLocation == .eventType {
            dictionary = eventTypeAssociations
        } else if eventTypeOrLocation == .location {
            dictionary = locationAssociations
        }
        for (k, v) in dictionary {
            for (key, _) in (v as? Dictionary<String, String>)! {
                if key == childType {
                    return k
                }
            }
        }
        return childType
    }
    
    // ===== FIREBASE FUNCTIONS ===== //
    
    enum DataState {
        case valid
        case invalid
    }
    
    func readEventData(eventData: Dictionary<String, Any>) -> (EventInstance, DataState) {
        let newInstance = EventInstance()
        for (k, v) in eventData {
            switch k {
            case "absolutePosition":
                newInstance.absolutePosition = (v as? Int)!
            case "guid":
                newInstance.guid = (v as? String) ?? "" //Highly unlikely to occur
                return (newInstance, .invalid)
            case "name":
                newInstance.name = (v as? String) ?? "Default name"
            case "time":
                newInstance.time = (v as? String) ?? "Default time"
            case "date":
                newInstance.date = (v as? String) ?? "Default date"
            case "endDate":
                newInstance.endDate = (v as? String) ?? "Default end date"
            case "endTime":
                newInstance.endTime = (v as? String) ?? "Default end time"
            case "daysIntoYear":
                newInstance.daysIntoYear = (v as? Int) ?? 0
            case "numberAttending":
                newInstance.numAttending = (v as? Int) ?? 0
            case "url":
                newInstance.url = (v as? String) ?? "Default url"
            case "summary":
                newInstance.summary = (v as? String) ?? "Default summary"
            case "description":
                newInstance.eventDescription = (v as? String) ?? "Default description"
            case "contactName":
                newInstance.contactName = (v as? String) ?? "Default contact name"
            case "contactPhone":
                newInstance.contactPhone = (v as? String) ?? "Default contact phone"
            case "contactMail":
                newInstance.contactMail = (v as? String) ?? "Default contact mail"
            case "mainLocation":
                newInstance.location = (v as? String) ?? "Default location"
            case "mainEventType":
                newInstance.mainEventType = (v as? String) ?? "Default main event type"
            case "address":
                newInstance.mainAddress = (v as? String) ?? "Default address"
            case "city":
                newInstance.mainCity = (v as? String) ?? "Default city"
            case "zip":
                newInstance.mainZip = (v as? String) ?? "Default zip"
            case "lat":
                newInstance.mainLat = (v as? String) == "" ? "0" : (v as? String) ?? "0"
            case "lon":
                newInstance.mainLon = (v as? String) == "" ? "0" : (v as? String) ?? "0"
            case "hasCultural":
                newInstance.hasCultural = (v as? Bool) ?? false
            case "subLocations":
                for loc in v as? [String] ?? ["Default string"] {
                    newInstance.locations.append(loc)
                }
            case "eventTypes":
                for ev in v as? [String] ?? ["Default string"] {
                    newInstance.eventType.append(ev)
                }
            default:
                break;
            }
        }
        
        //Convert strings relating to date and time to a DateTimeInfo object - if this cannot be done, the event data is invalid because users wouldn't know when the event is occuring.
        let dateTimeInfoStart = makeDateTimeInfo(dateStr: newInstance.date, timeStr: newInstance.time)
        let dateTimeInfoEnd = makeDateTimeInfo(dateStr: newInstance.endDate, timeStr: newInstance.endTime)
        
        if !dateTimeInfoStart.1 || !dateTimeInfoEnd.1 {
            return (newInstance, .invalid)
        } else {
            newInstance.startDateTimeInfo = dateTimeInfoStart.0
            newInstance.endDateTimeInfo = dateTimeInfoEnd.0
        }
        
        //Add logic here to determine if the event is favorited, in the calendar, or if the user is attending
        
        return (newInstance, .valid)
    }
    
    func makeDateTimeInfo(dateStr: String, timeStr: String) -> (DateTimeInfo, Bool) {
        let dateComponents:(Int, Int, Int, Bool) = {
            let strComp = dateStr.components(separatedBy: "/") // ["3", "14", "2000")
            do {
                return try (getInt(strComp[0]), getInt(strComp[1]), getInt(strComp[2]), true)
            } catch {
                return (0, 0, 0, false)
            }
        }()
        let timeComponents:(Int, Int, AM_PM, Bool) = {
            let strComp = timeStr.components(separatedBy: " ") // ["11:59", "PM"]
            let timeComp = strComp[0].components(separatedBy: ":") // ["11", "59"]
            var valid:Bool = true
            do {
                return try (getInt(timeComp[0]), getInt(timeComp[1]), {
                    if strComp[1] == "AM" {
                        return .am
                    }
                    if strComp[1] == "PM" {
                        return .pm
                    }
                    valid = false
                    return .pm
                }(), valid ? true : false)
            } catch {
                return (0, 0, .pm, false)
            }
        }()
        if !dateComponents.3 || !timeComponents.3 {
            return (DateTimeInfo(year: 0, month: 0, day: 0, hour: 0, minute: 0, am_pm: .pm), false)
        }
        return (DateTimeInfo(year: dateComponents.0, month: dateComponents.1, day: dateComponents.2, hour: timeComponents.0, minute: timeComponents.1, am_pm: timeComponents.2), true)
    }
    
    func testFirebaseConnection() {
        var lastState:Bool = false
        AppDelegate.shared().connectedRef.observe(.value, with: { snapshot in
            if snapshot.value as? Bool ?? false {
                print("App is connected to FB.")
                self.hasFirebaseConnection = true
                lastState = true
            } else {
                print("App is not connected to FB.")
                lastState = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) { //Give some time to attempt connection.
                    if !lastState {
                        self.hasFirebaseConnection = false
                    }
                }
            }
        })
    }
    
    // ===== SUPPORT FUNCTIONS ===== //
    
    //Returns true if first date/time is later than second date, false if else
    func compareEventDates(dateTimeOne: DateTimeInfo, dateTimeTwo: DateTimeInfo) -> Bool {
        if dateTimeOne.year > dateTimeTwo.year { return true }
        if dateTimeOne.month > dateTimeTwo.year { return true }
        if dateTimeOne.day > dateTimeOne.day { return true }
        if dateTimeOne.am_pm.rawValue > dateTimeTwo.am_pm.rawValue { return true }
        if dateTimeOne.hour > dateTimeTwo.hour { return true }
        if dateTimeOne.minute > dateTimeTwo.minute { return true }
        return false
    }
    
    ///Method takes current number of days into the year from system & adds additional days in multiples of 7 depending on how many weeks the user wants to advance.  Helper search function.
    func getDaysIntoYear(nowPlusWeeks: Int) -> Int { //we don't have to worry about getting old events because old events are never read or put into FB
        var daysIntoYear:Int = 0
        let calendar = Calendar.current
        let date = Date()
        var daysInMonths:[Int] = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        if calendar.component(.year, from: date) % 4 == 0 { //check if leap year
            daysInMonths[1] = 29
        }
        let currentMonth = calendar.component(.month, from: date)
        let currentDay = calendar.component(.day, from: date)
        var i:Int = 1
        while i < currentMonth {
            daysIntoYear += daysInMonths[i-1]
            i += 1
        }
        daysIntoYear += currentDay
        return daysIntoYear + nowPlusWeeks*7
    }
}

enum AM_PM: Int {
    case am = 1
    case pm = 2
}

struct DateTimeInfo {
    let year:Int
    let month:Int
    let day:Int
    let hour:Int
    let minute:Int
    let am_pm:AM_PM
}

enum MyError: Error {
   case conversionError
}

func getInt(_ data: String) throws -> Int {
    guard let result = Int(data) else { throw MyError.conversionError }
    return result

}

class EventSearchEngine {
    
    struct EventType {
        let name:String
        let selected:Bool
    }
    
    struct Location {
        let name:String
        let selected:Bool
    }
    
    var eventTypeList:[EventType] = []
    var locationList:[Location] = []
    
    
}
