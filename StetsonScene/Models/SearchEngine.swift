//
//  SearchEngine.swift
//  StetsonScene
//
//  Created by Lannie Hough on 7/21/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation

class EventSearchEngine {
    
    //Number displayed on the slider for weeks displayed & how many weeks the user wants displayed
    var weeksDisplayed:Int = {
        if UserDefaults.standard.object(forKey: "weeksDisplayed") != nil {
            return UserDefaults.standard.integer(forKey: "weeksDisplayed")
        } else {
            return 1
        }
    }() {
        didSet {
            UserDefaults.standard.set(self.weeksDisplayed, forKey: "weeksDisplayed")
        }
    }
    
    //Whether the user wants only events w/ cultural credits to be displayed
    var onlyCultural:Bool = {
        if UserDefaults.standard.object(forKey: "onlyCultural") != nil {
            return UserDefaults.standard.bool(forKey: "onlyCultural")
        } else {
            return false
        }
    }() {
        didSet {
            UserDefaults.standard.set(self.onlyCultural, forKey: "onlyCultural")
        }
    }
    
    //What days of the week the user wants displayed
    var weekdaysSelected:[Bool] = {
        if UserDefaults.standard.object(forKey: "weekdaysSelected") != nil {
            return UserDefaults.standard.array(forKey: "weekdaysSelected") as! [Bool]
        } else {
            return [true, true, true, true, true, true, true]
        }
    }() {
        didSet {
            UserDefaults.standard.set(self.weekdaysSelected, forKey: "weekdaysSelected")
        }
    }
    
    
    //Set of event types that the user wants displayed
    var eventTypeSet:Set<String> = {
        if UserDefaults.standard.object(forKey: "eventTypeSet") != nil {
            let tempList = UserDefaults.standard.stringArray(forKey: "eventTypeSet")!
            var tempSet:Set<String> = []
            for element in tempList {
                tempSet.insert(element)
            }
            return tempSet
        } else {
            return []
        }
    }() {
        didSet {
            var tempList:[String] = []
            for element in self.eventTypeSet {
                tempList.append(element)
            }
            UserDefaults.standard.set(tempList, forKey: "eventTypeSet")
            if UserDefaults.standard.object(forKey: "firstTypeLoad") == nil {
                UserDefaults.standard.set(true, forKey: "firstTypeLoad")
            }
        }
    }
    
    var locationSet:Set<String> = [] //Not yet adding to filter
    
    func filter(evm: EventViewModel) {
        if evm.weeksStored >= self.weeksDisplayed { //If weeks loaded > what is actually loaded filter on current event list
            print("Don't need to query DB")
            for event in evm.eventList {
                checkEvent(event, evm)
            }
            //remove and add an event to force view update by changing state of list
            let tempEvent = evm.eventList[evm.eventList.count-1]
            evm.eventList.remove(at: evm.eventList.count-1)
            evm.eventList.append(tempEvent)
        } else if evm.weeksStored < self.weeksDisplayed { //If weeks loaded < what is actually loaded, call retrieveFirebaseData to load in new data, then filter
            evm.retrieveFirebaseData(daysIntoYear: evm.getDaysIntoYear(nowPlusWeeks: self.weeksDisplayed), doFilter: true, searchEngine: self)
        }
    }
    
    func checkEvent(_ ei: EventInstance, _ evm: EventViewModel) {
        var filteredState = true
        block: if true {
            if self.onlyCultural && !ei.hasCultural { //Check cultural
                print("Failed cultural check")
                filteredState = false
                break block
            }
            var eventTypeSatisfied = false
            loop: for eType in self.eventTypeSet { //Check event type
                for (type, _) in evm.eventTypeAssociations[eType] as! Dictionary<String, String> { //k, v
                    if type == ei.mainEventType {
                        eventTypeSatisfied = true
                        break loop
                    }
                }
            }
            if !eventTypeSatisfied {
                print("Failed eType check")
                filteredState = false
                break block
            }
            //Check weekdays selected
            if !self.weekdaysSelected[EventViewModel.getDayOfWeek(day: ei.startDateTimeInfo.day, month: ei.startDateTimeInfo.month, year: ei.startDateTimeInfo.year)] {
                print("Failed weekday check")
                filteredState = false
                break block
            }
            //Check week displayed
            let maxDays = evm.getDaysIntoYear(nowPlusWeeks: self.weeksDisplayed)
            if ei.daysIntoYear > maxDays {
                print("Failed weeks displayed check")
                filteredState = false
            }
        }
        if filteredState {
            print("Passed all checks")
        }
        ei.filteredOn = filteredState //event should show up in list
    }
    
}
