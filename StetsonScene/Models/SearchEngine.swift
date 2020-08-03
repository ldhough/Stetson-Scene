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
        //If weeks loaded > what is actually loaded, use compare date functions
        //If weeks loaded < what is actually loaded, call retrieveFirebaseData
        //evm.weeksStored
    }
    
}
