////
////  EventModelController.swift
////  StetsonScene
////
////  Created by Lannie Hough on 1/29/20.
////  Copyright © 2020 Lannie Hough. All rights reserved.
////
//
//import Foundation
//import SwiftUI
//import Firebase
//import FirebaseDatabase
//import CoreData
//import EventKit
//
/////Model Controller-style object to hold the state of our app.  A single instance is created in SceneDelegate on app launch & is populated with data from
/////AppDelegate's shared state.  EventModelController is passed to ViewControllers through dependency injection.
//class EventModelController: ObservableObject {
//    //Published to keep views that depend on this data updated as data is read in from Firebase
//    @Published var eventMode:Bool = true //if true, in event mode... if false, in tour campus mode
//    
//    static var eventList:[EventInstance] = []
//    @Published var eventListLive:[EventInstance] = []
//    @Published var eventListARLive:[EventInstance] = []
//    @Published var eventListMapLive:[EventInstance] = []
//    
//    @Published var eventTypeList:[String] //Used to contain event types or locations that the user cares about
//    @Published var displayEventTypeList:[Bool] = [] //same length as eventTypeList, boolean designates whether event @ same index in own list should be presented with a checkmark or not in the advanced search form
//    @Published var locationList:[String]
//    @Published var displayLocationList:[Bool] = []
//    
//    @Published var eventTypeAssociations:Dictionary<String, Any> = [:]
//    @Published var locationAssociations:Dictionary<String, Any> = [:]
//    
//    //Stores how many weeks worth of Firebase data are currently loaded into the app to prevent unnecessary Firebase queries
//    @Published var weeksStored:Int = 1
//    @Published var lastWeeksSearched:Int = 1
//    @Published var filteringCultural:Bool = false
//    @Published var lastSelectDeselect:Bool = true //true shows deselect all, false shows select all
//    @Published var weekdayArray:[Bool] = [false, false, false, false, false, false, false]
//    
//    @Published var navMap:Bool = false
//    @Published var navAR:Bool = false
//    @Published var event:EventInstance! //used for shortcut functions between EventListView and EventViewController
//    
//    @Published var buildingModelController:BuildingModelController!
//    //static var buildingList/*ModelController*/:[BuildingInstance]!//BuildingModelController!
//    
//    var hasObtainedAssociations:Bool = false //set to true on first call of retrieveFirebaseData, prevents continuous attempts to initiate listeners on association data which is unnecessary
//    var favoritesHasBeenLoaded:Bool = false //set to true after favorites have been loaded, prevents favoriteEventList from being repopulated with the same events multiple times
//    
//    @Published var favoriteLiveList:[EventInstance] = [] //use this list to display favorites in favorite UI
//    //Not all properties kept in persistent data/CoreData model should be used, because we want to keep EventInstance instances synced between all places where they are being used in the app.  For this reason, favoriteEventList should NOT be used to display anything, and should mostly just be used to validate properties that we care about from past sessions, like whether an event is favorited, or whether or not it has been added to the user's calendar.
//    @Published var favoriteEventList:[EventInstance] = [] //DON'T DISPLAY FROM THIS LIST
//    
//    //These two variables keep track of what events have been added to which list (favoriteLiveList and static eventList) and are used to keep references to the same event synchronized between lists.
//    var mainEventSet:Dictionary<String, EventInstance> = [:]
//    var favEventSet:Dictionary<String, EventInstance> = [:]
//    
//    var beingObservedSet:Set<String> = []//set of guids for which events have observers tied to them - prevents creation of too many excess observers
//    
//    var recommendationEngine:RecommendationEngine!
//    var hasEngineBeenRun:Bool = false
//    @Published var eventListRecLive:[EventInstance] = [] //recommendationEngine.recommendedEvents
//    
//    @Published var dataReturnedFromSnapshot:Bool = false
//    @Published var hasFirebaseConnection:Bool = true
//    
//    //Tests if can connect to Firebase
//    func testFirebaseConnection() {
//        var lastState:Bool = false
//        AppDelegate.shared().connectedRef.observe(.value, with: { snapshot in
//            if snapshot.value as? Bool ?? false {
//                print("Are connected to FB.")
//                self.hasFirebaseConnection = true
//                lastState = true
//            } else {
//                print("Are not connected to FB.")
//                lastState = false
//                DispatchQueue.main.asyncAfter(deadline: .now() + 5) { //give some time to attempt connection
//                    if !lastState {
//                        self.hasFirebaseConnection = false
//                    }
//                }
//            }
//        })
//    }
//    
//    init(eventList: [EventInstance], eventTypeList: [String], locationList: [String]) {
//        EventModelController.self.eventList = eventList
//        self.eventTypeList = eventTypeList
//        self.locationList = locationList
//    }
//    
//    ///Function is called when an event is favorited & this information needs to be kept in persistent storage.
//    func createFavoriteData(eventInstance: EventInstance) {
//        let appDelegate = AppDelegate.shared()
//        let managedContext = appDelegate.persistentContainer.viewContext
//        let newFavoriteEntity = NSEntityDescription.entity(forEntityName: "Favorites", in: managedContext)!
//        let newFavorite = NSManagedObject(entity: newFavoriteEntity, insertInto: managedContext)
//        newFavorite.setValue(eventInstance.isFavorite, forKey: "isFavorite")
//        newFavorite.setValue(eventInstance.contactMail, forKey: "contactMail")
//        newFavorite.setValue(eventInstance.contactName, forKey: "contactName")
//        newFavorite.setValue(eventInstance.contactPhone, forKey: "contactPhone")
//        newFavorite.setValue(eventInstance.date, forKey: "date")
//        newFavorite.setValue(eventInstance.daysIntoYear, forKey: "daysIntoYear")
//        newFavorite.setValue(eventInstance.eventDescription, forKey: "eventDescription")
//        newFavorite.setValue(eventInstance.eventType, forKey: "eventType") //ARRAY
//        newFavorite.setValue(eventInstance.guid, forKey: "guid")
//        newFavorite.setValue(eventInstance.hasCultural, forKey: "hasCultural")
//        newFavorite.setValue(eventInstance.location, forKey: "location")
//        newFavorite.setValue(eventInstance.locations, forKey: "locations") //ARRAY
//        newFavorite.setValue(eventInstance.mainAddress, forKey: "mainAddress")
//        newFavorite.setValue(eventInstance.mainCity, forKey: "mainCity")
//        newFavorite.setValue(eventInstance.mainEventType, forKey: "mainEventType")
//        newFavorite.setValue(eventInstance.mainLat, forKey: "mainLat")
//        newFavorite.setValue(eventInstance.mainLon, forKey: "mainLon")
//        newFavorite.setValue(eventInstance.mainState, forKey: "mainState")
//        newFavorite.setValue(eventInstance.mainZip, forKey: "mainZip")
//        newFavorite.setValue(eventInstance.name, forKey: "name")
//        newFavorite.setValue(eventInstance.summary, forKey: "summary")
//        newFavorite.setValue(eventInstance.time, forKey: "time")
//        newFavorite.setValue(eventInstance.url, forKey: "url")
//        newFavorite.setValue(/*eventInstance.isAttending,*/true, forKey: "isAttending")
//        // ^ hardcoded true because events can only be added to persistent data if added to calendar or favorited, which means they should always enter persistent data with "isAttending" being true
//        newFavorite.setValue(eventInstance.numAttending, forKey: "numAttending")
//        newFavorite.setValue(eventInstance.isInCalendar, forKey: "isInCalendar")
//        do {
//            try managedContext.save()
//        } catch let error as NSError {
//            print("Could not save. \(error)")
//        }
//    }
//    
//    ///Function is called to load favorited events in persistent storage into the app for use.
//    func loadFavoriteData() {
//        let appDelegate = AppDelegate.shared()
//        let managedContext = appDelegate.persistentContainer.viewContext
//        let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorites")
//        do {
//            let result = try managedContext.fetch(fetchReq)
//            for data in result as! [NSManagedObject] {
//                var eventInstance = EventInstance()
//                eventInstance.guid = data.value(forKey: "guid") as? String
//                eventInstance.name = data.value(forKey: "name") as? String
//                eventInstance.time = data.value(forKey: "time") as? String
//                eventInstance.date = data.value(forKey: "date") as? String
//                eventInstance.daysIntoYear = data.value(forKey: "daysIntoYear") as? Int
//                eventInstance.url = data.value(forKey: "url") as? String
//                eventInstance.summary = data.value(forKey: "summary") as? String
//                eventInstance.eventDescription = data.value(forKey: "eventDescription") as? String
//                eventInstance.contactName = data.value(forKey: "contactName") as? String
//                eventInstance.contactPhone = data.value(forKey: "contactPhone") as? String
//                eventInstance.contactMail = data.value(forKey: "contactMail") as? String
//                eventInstance.location = data.value(forKey: "location") as? String
//                eventInstance.mainAddress = data.value(forKey: "mainAddress") as? String
//                eventInstance.mainCity = data.value(forKey: "mainCity") as? String
//                eventInstance.mainState = data.value(forKey: "mainState") as? String
//                eventInstance.mainZip = data.value(forKey: "mainZip") as? String
//                eventInstance.mainLat = data.value(forKey: "mainLat") as? String
//                eventInstance.mainLon = data.value(forKey: "mainLon") as? String
//                eventInstance.hasCultural = (data.value(forKey: "hasCultural") as? Bool)!
//                eventInstance.mainEventType = data.value(forKey: "mainEventType") as? String
//                eventInstance.isFavorite = (data.value(forKey: "isFavorite") as? Bool)!
//                eventInstance.isAttending = (data.value(forKey: "isAttending") as? Bool)!
//                eventInstance.numAttending = data.value(forKey: "numAttending") as? Int
//                eventInstance.isInCalendar = (data.value(forKey: "isInCalendar") as? Bool)!
//                for element in (data.value(forKey: "eventType") as? [String])! {
//                    eventInstance.eventType.append(element)
//                }
//                for element in (data.value(forKey: "locations") as? [String])! {
//                    eventInstance.locations.append(element)
//                }
//                favoriteEventList.append(eventInstance)
//            }
//            for element in favoriteEventList {
//                print(element.name!)
//            }
//        } catch {
//            print("Failed to load favorite data.")
//        }
//    }
//    
//    func createRecommendedList() {
//        recommendationEngine.runRecommendationEngine()
//    }
//    
//    ///Removes events from favorite list that are outdated ie have passed
//    func removeOldFavoriteData() {}
//    
//    //Currently unused method, leaving it here because it could be useful in the future
//    func checkIfIsAttending(guid: String) -> Bool {
//        for event in favoriteEventList {
//            if guid == event.guid {
//                if event.isAttending == true {
//                    return true
//                }
//            }
//        }
//        return false
//    }
//    
//    func updateFavoriteData(guidToUpdate: String, favoriteTrueFalse: Bool, calendarTrueFalse: Bool) {
//        print(calendarTrueFalse)
//        print(favoriteTrueFalse)
//        let appDelegate = AppDelegate.shared()
//        let managedContext = appDelegate.persistentContainer.viewContext
//        let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorites")
//        //Only fetches entities with guid matching the guid of the event we want to modify
//        fetchReq.predicate = NSPredicate(format: "guid = %@", guidToUpdate)
//        do {
//            let test = try managedContext.fetch(fetchReq)
//            let toModify = test[0] as! NSManagedObject
//            toModify.setValue(favoriteTrueFalse, forKey: "isFavorite")
//            toModify.setValue(calendarTrueFalse, forKey: "isInCalendar")
//            if favoriteTrueFalse || calendarTrueFalse {
//                //if this event has been favorited OR added to calendar, persistent "isAttending" should be made true
//                toModify.setValue(true, forKey: "isAttending")
//            } else {
//                toModify.setValue(false, forKey: "isAttending")
//            }
//            do {
//                try managedContext.save()
//            } catch {
//                print(error)
//            }
//        } catch {
//            print(error)
//        }
//    }
//    
//    func isInPersistentData(guid: String) -> Bool {
//        let appDelegate = AppDelegate.shared()
//        let managedContext = appDelegate.persistentContainer.viewContext
//        let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorites")
//        fetchReq.predicate = NSPredicate(format: "guid = %@", guid)
//        do {
//            let test = try managedContext.fetch(fetchReq)
//            if test.isEmpty {
//                return false
//            } else {
//                return true
//            }
//        } catch {
//            print(error)
//        }
//        return false
//    }
//    
//    //NOT CURRENTLY IN USE?
//    ///Removes event in favorite list
//    func removeFavoriteData(guidToRemove: String) {
//        let appDelegate = AppDelegate.shared()
//        let managedContext = appDelegate.persistentContainer.viewContext
//        let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorites")
//        //Only fetches entities with guid matching the guid of the event we want to remove
//        fetchReq.predicate = NSPredicate(format: "guid = %@", guidToRemove)
//        do {
//            let test = try managedContext.fetch(fetchReq)
//            //test is an array, but because we are filtering by guid it should only contain one element at [0]
//            let toDelete = test[0] as! NSManagedObject
//            managedContext.delete(toDelete)
//            do {
//                try managedContext.save()
//            } catch {
//                print(error)
//            }
//        } catch {
//            print(error)
//        }
//    }
//    
//    ///Function checks if an event, loaded from Firebase, is being kept in persistent storage.  If so, this event is a favorite & the isFavorite field of that EventInstance should be updated accordingly.
//    func checkIfIsFavorited(guid: String) -> (Bool, Bool, Bool) {
//        var fav:Bool = false
//        var cal:Bool = false
//        var either:Bool = false
//        for event in favoriteEventList {
//            if guid == event.guid {
//                if event.isFavorite == true {
//                    fav = true
//                    either = true
//                    //return true
//                }
//                if event.isInCalendar == true {
//                    either = true
//                    cal = true
//                }
//                return (either, fav, cal)
//            }
//        }
//        return (either, fav, cal)
//    }
//    
//    //===== SEARCH / FILTER METHODS =====//
//    
//    func isKeyInUserDefaults(key: String) -> Bool {
//        return UserDefaults.standard.object(forKey: key) != nil
//    }
//    
//    func getUserDefaultsSearch() {
//        if isKeyInUserDefaults(key: "filteringCultural") {
//            filteringCultural = UserDefaults.standard.bool(forKey: "filteringCultural")
//        }
//        if isKeyInUserDefaults(key: "eventTypeList") {
//            eventTypeList = UserDefaults.standard.stringArray(forKey: "eventTypeList")!
//        }
//        if isKeyInUserDefaults(key: "displayEventTypeList") {
//            displayEventTypeList = UserDefaults.standard.array(forKey: "displayEventTypeList") as? [Bool] ?? [Bool]()
//        }
//        if isKeyInUserDefaults(key: "lastWeeksSearched") {
//            lastWeeksSearched = UserDefaults.standard.integer(forKey: "lastWeeksSearched")
//        }
//        if isKeyInUserDefaults(key: "lastSelectDeselect") {
//            
//        }
//        if isKeyInUserDefaults(key: "weekendArray") {
//            weekdayArray = UserDefaults.standard.array(forKey: "weekendArray") as? [Bool] ?? [Bool]()
//        }
//    }
//    
//    func setDefaultCultural() {
//        UserDefaults.standard.set(filteringCultural, forKey: "filteringCultural")
//    }
//    
//    func setDefaultEventList() {
//        UserDefaults.standard.set(eventTypeList, forKey: "eventTypeList")
//        UserDefaults.standard.set(displayEventTypeList, forKey: "displayEventTypeList")
//    }
//    
//    func setDefaultTimeRange() {
//        UserDefaults.standard.set(lastWeeksSearched, forKey: "lastWeeksSearched")
//    }
//    
//    func setSelectAllDeselectAll() {
//        UserDefaults.standard.set(lastSelectDeselect, forKey: "lastSelectDeselect")
//    }
//    
//    func setDefaultDaysOfWeek() {
//        UserDefaults.standard.set(weekdayArray, forKey: "weekendArray")
//    }
//    
//    ///Primary search function
//    ///Parameter: weeksToSearch specifies how many weeks into the future to search events.  Converted into days before use.
//    ///Parameter: hasToHaveCultural dictates whether or not only events with cultural credit opportunities are presented
//    ///Parameter: specifyTypes dictates whether we should list all types of events or only specific types as indicated by the displayEventTypeList boolean array
//    ///Parameter: specificLocation dictates whether only events at a specific location should be shown.  Set to true when going to a list from the map or AR views.
//    ///Parameter: specificLocationIs provides the name of the specific location if applicable
//    ///Parameter: whichSubList - makes sure search modifies the correct event sublist depending on what needs to be displayed
//    func search(weeksToSearch: Int, hasToHaveCultural: Bool = false, specifyTypes: Bool = false, specificLocation: Bool = false, specificLocationIs: String = "", whichSubList: String = "Event List", daysToSearch: [Bool] = []) {
//        //eventLocation = specificLocationIs
//        if weeksToSearch <= self.weeksStored { //
//            self.searchData(hasToHaveCultural: hasToHaveCultural, weeksToSearch: weeksToSearch, specifyTypes: specifyTypes, specificLocation: specificLocation, specificLocationIs: specificLocationIs, whichSubList: whichSubList, daysToSearch: daysToSearch)
//        } else {
//            self.retrieveFirebaseData(daysIntoYear: self.getDaysIntoYear(nowPlusWeeks: weeksToSearch), hasToHaveCultural: hasToHaveCultural, specifyTypes: specifyTypes, specificLocation: specificLocation, specificLocationIs: specificLocationIs, daysToSearch: daysToSearch)
//        }
//    }
//    
//    ///Method takes current number of days into the year from system & adds additional days in multiples of 7 depending on how many weeks the user wants to advance.  Helper search function.
//    func getDaysIntoYear(nowPlusWeeks: Int) -> Int { //we don't have to worry about getting old events because old events are never read or put into FB
//        var daysIntoYear:Int = 0
//        let calendar = Calendar.current
//        let date = Date()
//        var daysInMonths:[Int] = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
//        if calendar.component(.year, from: date) % 4 == 0 { //check if leap year
//            daysInMonths[1] = 29
//        }
//        let currentMonth = calendar.component(.month, from: date)
//        let currentDay = calendar.component(.day, from: date)
//        var i:Int = 1
//        while i < currentMonth {
//            daysIntoYear += daysInMonths[i-1]
//            i += 1
//        }
//        daysIntoYear += currentDay
//        return daysIntoYear + nowPlusWeeks*7
//    }
//    
//    ///Function takes an event subtype & returns the "parent" event type.  Helper search function.
//    func associateParentEventType(childType: String) -> String {
//        for (k, v) in eventTypeAssociations {
//            for (key, _) in (v as? Dictionary<String, String>)! {
//                if key == childType {
//                    return k
//                }
//            }
//        }
//        return childType
//    }
//    
//    ///Function takes a location subtype & returns the "parent" location type.  Helper search function.
//    func associateParentLocationType(childType: String) -> String {
//        for (k, v) in eventTypeAssociations {
//            for (key, _) in (v as? Dictionary<String, String>)! {
//                if key == childType {
//                    return k
//                }
//            }
//        }
//        return childType
//    }
//    
//    ///Function used in searches to update eventListLive.  Called in retrieveFirebaseData & searchData depending on whether or not more data needs to be retrieved from Firebase.  Call returns boolean value determing whether an event should be displayed or not.
//    ///Parameter event: EventInstance to be validated
//    ///Parameter hasToHaveCultural: whether or not to display only events that have cultural credits, use with cultural toggle
//    ///Parameter specifyTypes: set true to further constrain validation to only specfic types of events
//    func advancedSearchValidation(event: EventInstance, hasToHaveCultural: Bool, specifyTypes: Bool = false, specificLocation: Bool = false, specificLocationIs: String = "", daysToSearch: [Bool] = []) -> Bool {
//        if hasToHaveCultural != event.hasCultural && hasToHaveCultural == true { //Second conditional ensures that cultural credit events aren't filtered OUT
//            return false
//        }
//        
//        //Only if using this method in advanced search functions
//        if !specifyTypes && specificLocation { //This combination should occur when clicking on a specific location - events should not retain specified eType filters
//            var showThisType:Bool = false
//            var parentLocationTypes:[String] = [] //Associate all locations in EventInstance object w/ "parent" location
//            for loc in event.locations {
//                parentLocationTypes.append(associateParentLocationType(childType: loc))
//            }
//            if parentLocationTypes.contains(specificLocationIs) {
//                showThisType = true
//            }
//            if !showThisType {
//                return false
//            }
//        } else if specifyTypes {
//            var showThisType:Bool = false
//        
//            //Associate all event types in the EventInstance object with their "parent" event type
//            var parentEventTypes:[String] = []
//            for eType in event.eventType {
//                parentEventTypes.append(associateParentEventType(childType: eType))
//            }
//        
//            //Find indices of parent event types in eventTypeList
//            for element in parentEventTypes {
//                if displayEventTypeList[eventTypeList.firstIndex(of: element)!] == true {
//                    //showThisType = true
//                    if specificLocation { //Only if searching for events at a specific location
//                        var parentLocationTypes:[String] = [] //Associate all locations in EventInstance object w/ "parent" location
//                        for loc in event.locations {
//                            parentLocationTypes.append(associateParentLocationType(childType: loc/*.name*/))
//                        }
//                        if parentLocationTypes.contains(specificLocationIs) {
//                            showThisType = true
//                        }
//                    } else {
//                        showThisType = true
//                    }
//                }
//            }
//        
//            //If all of the values of these indices in displayEventTypeList are false, return false
//            if !showThisType {
//                return false
//            }
//        }
//        
//        exit: if daysToSearch != [] {
//            if daysToSearchAllFalse(arr: daysToSearch) {
//                break exit
//            }
//            let dateComponents = event.date.components(separatedBy: "/")
//            let day = getDayOfWeek(day: Int(dateComponents[1]) ?? 1, month: Int(dateComponents[0]) ?? 1, year: Int(dateComponents[2]) ?? 2020)
//            if !daysToSearch[day] {
//                return false
//            }
//        }
//        return true
//    }
//    
//    func daysToSearchAllFalse(arr: [Bool]) -> Bool {
//        for i in arr {
//            if i {
//                return false
//            }
//        }
//        return true
//    }
//    
//    ///Function used in searches to update eventListLive if we already have the necessary data to filter through in the app - prevents excessive Firebase querying.
//    ///Parameter: hasToHaveCultural - set true if only cultural credit events should be shown
//    ///Parameter: whichSubList - updates correct list depending on what we want to display
//    func searchData(hasToHaveCultural: Bool, weeksToSearch: Int = 1, specifyTypes: Bool = false, specificLocation: Bool = false, specificLocationIs: String = "", whichSubList: String = "Event List", daysToSearch: [Bool] = []) {
//        if whichSubList == "Event List" {
//            print("TEST")
//            self.eventListLive = []
//        } else if whichSubList == "AR List" {
//            self.eventListARLive = []
//        } else if whichSubList == "Map List" {
//            self.eventListMapLive = []
//        }
//        let daysToSearchIntoYear = getDaysIntoYear(nowPlusWeeks: weeksToSearch)
//        for event in EventModelController.self.eventList {
//            if event.daysIntoYear <= daysToSearchIntoYear {
//                if advancedSearchValidation(event: event, hasToHaveCultural: hasToHaveCultural, specifyTypes: specifyTypes, specificLocation: specificLocation, specificLocationIs: specificLocationIs, daysToSearch: daysToSearch) {
//                    if whichSubList == "Event List" {
//                        self.eventListLive.append(event)
//                    } else if whichSubList == "AR List" {
//                        eventListARLive.append(event)
//                    } else if whichSubList == "Map List" {
//                        eventListMapLive.append(event)
//                    }
//                }
//            }
//        }
//    }
//    
//    ///Function increments or decrements "numberAttending" field in Firebase data based on user input
//    func updateNumberAttending(guid: String, isAttending: Bool) {
//        let ref:DatabaseReference = AppDelegate.shared().eventListRef.child(guid)
//        var numAttending:Int = 0
//        ref.observeSingleEvent(of: .value, with: { (snapshot) in
//            if snapshot.value != nil { //if nil, event has presumably been removed from database/Firebase
//            let event = (snapshot.value as? Dictionary<String, Any>)!
//            //var numAttending:Int = 0
//            //print(event)
//            numAttending = (event["numberAttending"] as? Int)!
//            numAttending += isAttending ? 1 : -1
//            ref.child("numberAttending").setValue(numAttending)
//            }
//        })
//    }
//    
//    //Returns true if first date/time is later than second date, false if else
//    func compareEventDates(dateOne: String, timeOne: String, dateTwo: String, timeTwo: String) -> Bool { //parameters in format 3/14/2000 & 11:00 AM
//        let yearOneComponents = dateOne.components(separatedBy: "/") // ["3", "14", "2000"]
//        let yearTwoComponents = dateTwo.components(separatedBy: "/")
//        if Int(yearOneComponents[2]) ?? 2020 > Int(yearTwoComponents[2]) ?? 2020 { // ?? for potentially invalid date format
//            return true
//        } else if Int(yearOneComponents[2]) ?? 2020 < Int(yearTwoComponents[2]) ?? 2020 {
//            return false
//        }
//        if Int(yearOneComponents[0]) ?? 1 > Int(yearTwoComponents[0]) ?? 1 { // check month before day
//            return true
//        } else if Int(yearOneComponents[0]) ?? 1 < Int(yearTwoComponents[0]) ?? 1 {
//            return false
//        }
//        if Int(yearOneComponents[1]) ?? 1 > Int(yearTwoComponents[1]) ?? 1 {
//            return true
//        } else if Int(yearOneComponents[1]) ?? 1 < Int(yearTwoComponents[1]) ?? 1 {
//            return false
//        }
//        let timeOneComponents = timeOne.components(separatedBy: " ") // ["11:00", "AM"]
//        let timeTwoComponents = timeTwo.components(separatedBy: " ")
//        if timeOneComponents[1] == "PM" && timeTwoComponents[1] == "AM" {
//            return true
//        } else if timeOneComponents[1] == "AM" && timeTwoComponents[1] == "PM" {
//            return false
//        }
//        let timeOneC = timeOneComponents[0].components(separatedBy: ":") // ["11", "00"]
//        let timeTwoC = timeTwoComponents[0].components(separatedBy: ":")
//        if Int(timeOneC[0]) ?? 0 > Int(timeTwoC[0]) ?? 0 {
//            return true
//        } else if Int(timeOneC[0]) ?? 0 < Int(timeTwoC[0]) ?? 0 {
//            return false
//        }
//        if Int(timeOneC[1]) ?? 0 > Int(timeTwoC[1]) ?? 0 {
//            return true
//        } else if Int(timeOneC[1]) ?? 0 < Int(timeTwoC[1]) ?? 0 {
//            return false
//        }
//        return false
//    }
//    
//    func insertFavorite(event: EventInstance) {
//        if favoriteLiveList.count == 0 {
//            favoriteLiveList.append(event)
//            return
//        }
//        for i in 0 ..< self.favoriteLiveList.count {
//            if !compareEventDates(dateOne: event.date, timeOne: event.time, dateTwo: favoriteLiveList[i].date, timeTwo: favoriteLiveList[i].time) {
//                favoriteLiveList.insert(event, at: i)
//                return
//            }
//        }
//        favoriteLiveList.append(event)
//    }
//    
//    func printnames(x: [EventInstance]) {
//        print("--")
//        for i in x {
//            print(i.name!)
//        }
//        print("--")
//    }
//    
//    func removeUnfavoritedFromSet(guid: String) {
//        self.favEventSet.removeValue(forKey: guid)
//    }
//    
//    //Note - does not always query Firebase, only if necessary
//    ///Function loads favoriteListLive to be displayed in favorite UI.  Firebase is queried if an event stored in persistent favorites has not yet been loaded into the app because it is further in the future than Firebase has already been queried for.
//    func retrieveFavoriteFirebaseData() {
//        //self.dataReturnedFromSnapshot = false
//        self.favoriteLiveList = []
//        outerLoop: for event in favoriteEventList {
//            if event.isFavorite && (event.daysIntoYear >= getDaysIntoYear(nowPlusWeeks: 0)) { //Can ignore if in persistent data but not represented as a favorite event, or if event is outdated
//                if mainEventSet[event.guid] != nil {
//                    //If an event that has been favorited already exists in the main list, use the reference stored as a dictionary value in the favorite list
//                    self.insertFavorite(event: mainEventSet[event.guid]!)
//                    self.favEventSet[event.guid] = mainEventSet[event.guid]!
//                } else if favEventSet[event.guid] != nil {
//                    self.insertFavorite(event: favEventSet[event.guid]!)
//                } else {
//                    //Sometimes there will be favorited events in the future removed from the database, so this will be reached.  Should not be an issue.
//                    AppDelegate.shared().eventListRef.queryOrdered(byChild: "guid").queryEqual(toValue: event.guid).observeSingleEvent(of: .value, with: { snapshot in
//                        //self.dataReturnedFromSnapshot = true
//                        if snapshot.value != nil { //if nil, event has presumably been removed from database/Firebase
//                        let e = snapshot.value as? Dictionary<String, Any>
//                        if e == nil {return}
//                        if e![event.guid] == nil {return}
//                        let newInstance = self.readEventData(eventData: e![event.guid]! as! Dictionary<String, Any>, whereFrom: "fav call")
//                        //add observer to numberAttending so that this information can update live in detail views
//                        if !self.beingObservedSet.contains(newInstance.guid) {
//                            AppDelegate.shared().eventListRef.child(newInstance.guid).child("numberAttending").observe(.value, with: { snapshot in
//                                newInstance.numAttending = snapshot.value as? Int
//                                self.beingObservedSet.insert(newInstance.guid)
//                            })
//                        }
//                        self.insertFavorite(event: newInstance)
//                        self.favEventSet[newInstance.guid] = newInstance //make reference to this event in favorite dictionary using its guid as a key
//                        }
//                    }) //AD end
//                }
//            } //if end
//        }
//    }
//    
//    //Note that retreiveFirebaseData can only ever be called from searches in the main event list... map & AR views cannot perform custom searches
//    ///Function queries Firebase for event data, daysIntoYear designates how far into the future to return events from.  Send getDaysIntoYear() with the number of weeks you want to display as a parameter.
//    ///Parameter daysIntoYear: how far into the future to query Firebase data
//    ///Parameter hasToHaveCultural: set true if only cultural credit events should be shown (dictated by toggle on advanced search form)
//    ///Parameter specifyTypes: set true to further constrain validation to only specific types of events
//    func retrieveFirebaseData(daysIntoYear: Int, hasToHaveCultural: Bool = false, specifyTypes: Bool = false, specificLocation: Bool = false, specificLocationIs: String = "", daysToSearch: [Bool] = []) {
//        self.dataReturnedFromSnapshot = false
//        //Remove observers so that if method is called again fresh observers are used with the proper query parameters
//        if !favoritesHasBeenLoaded {
//            loadFavoriteData()
//            favoritesHasBeenLoaded = true
//        }
//        AppDelegate.shared().eventTypeAssociationRef.removeAllObservers()
//        AppDelegate.shared().locationAssocationRef.removeAllObservers()
//        
//        AppDelegate.shared().eventListOrderRef.queryOrdered(byChild: "daysIntoYear").queryEnding(atValue: daysIntoYear).observe(.value, with: { snpsht in
//            //order contains information about order of events to be displayed in the UI
//            let order = snpsht.value as? [Dictionary<String, Any>]
//            //If the observer notices a chang in the database, implying backend has updated the database, the lists will eb reset and the new data read
//            EventModelController.self.eventList = []
//            self.eventListLive = []
//            AppDelegate.shared().eventListRef.queryOrdered(byChild: "daysIntoYear").queryEnding(atValue: daysIntoYear).observeSingleEvent(of: .value, with: { (snapshot) in
//                self.dataReturnedFromSnapshot = true
//                let fullEventList = snapshot.value as? Dictionary<String, Dictionary<String, Any>>
//                for event in order! {
//                    var newInstance = self.readEventData(eventData: fullEventList![event["guid"] as! String]!, whereFrom: "main call")
//                    
//                    if self.favEventSet[newInstance.guid] == nil {
//                        //add observer to numberAttending so that this information can update live in detail views
//                        if !self.beingObservedSet.contains(newInstance.guid) {
//                            AppDelegate.shared().eventListRef.child(newInstance.guid).child("numberAttending").observe(.value, with: { snapshot in
//                                newInstance.numAttending = snapshot.value as? Int
//                                self.beingObservedSet.insert(newInstance.guid)
//                            })
//                        }
//                        EventModelController.self.eventList.append(newInstance)
//                        self.mainEventSet[newInstance.guid] = newInstance //make reference to this event in a dictionary using its guid as a key
//                        if self.advancedSearchValidation(event: newInstance, hasToHaveCultural: hasToHaveCultural, specifyTypes: specifyTypes, specificLocation: specificLocation, specificLocationIs: specificLocationIs, daysToSearch: daysToSearch) {
//                            self.appendLiveLists(toAppend: newInstance)
//                        }
//                    } else { //exists in favEventSet
//                        newInstance = self.favEventSet[newInstance.guid]! //replace newInstance with the existing "clone" of the event in favEventSet to keep references synced
//                        EventModelController.self.eventList.append(newInstance)
//                        self.mainEventSet[newInstance.guid] = newInstance
//                        if self.advancedSearchValidation(event: newInstance, hasToHaveCultural: hasToHaveCultural, specifyTypes: specifyTypes, specificLocation: specificLocation, specificLocationIs: specificLocationIs, daysToSearch: daysToSearch) {
//                            self.appendLiveLists(toAppend: newInstance)
//                        }
//                    }
//                }
//            })
//        })
//        
//        if !hasObtainedAssociations {
//            AppDelegate.shared().eventTypeAssociationRef.observe(.childAdded) { snapshot in
//                self.eventTypeList.append(snapshot.key)
//                self.displayEventTypeList.append(true)
//                self.eventTypeAssociations[snapshot.key] = snapshot.value as? Dictionary<String, String>
//            }
//        
//            AppDelegate.shared().locationAssocationRef.observe(.childAdded) { snapshot in
//                self.locationList.append(snapshot.key)
//                self.locationAssociations[snapshot.key] = snapshot.value as? Dictionary<String, String>
//            }
//        }
//        hasObtainedAssociations = true
//    }
//    
//    func appendLiveLists(toAppend: EventInstance) {
//        self.eventListLive.append(toAppend)
//        self.eventListARLive.append(toAppend)
//        self.eventListMapLive.append(toAppend)
//    }
//    
//    func readEventData(eventData: Dictionary<String, Any>, whereFrom: String) -> EventInstance {
//        //print(eventData)
//        //print(type(of: eventData))
//        //print(whereFrom)
////        if !favoritesHasBeenLoaded {
////            loadFavoriteData()
////            favoritesHasBeenLoaded = true
////        }
//        let newInstance = EventInstance()
//        for (k, v) in eventData {
//            switch k {
//            case "absolutePosition":
//                newInstance.absolutePosition = (v as? Int)! //get directly from FB data
//            case "guid":
//                newInstance.guid = (v as? String) ?? UUID().uuidString //this should never happen, not sure what would happen if it does
//            case "name":
//                newInstance.name = (v as? String) ?? "Default name"
//            case "time":
//                newInstance.time = (v as? String) ?? "Default time"
//            case "date":
//                newInstance.date = (v as? String) ?? "Default date"
//            case "endDate":
//                newInstance.endDate = (v as? String) ?? "Default end date"
//            case "endTime":
//                newInstance.endTime = (v as? String) ?? "Default end time"
//            case "daysIntoYear":
//                newInstance.daysIntoYear = (v as? Int) ?? 0
//            case "numberAttending":
//                newInstance.numAttending = (v as? Int) ?? 0
//            case "url":
//                newInstance.url = (v as? String) ?? "Default url"
//            case "summary":
//                newInstance.summary = (v as? String) ?? "Default summary"
//            case "description":
//                newInstance.eventDescription = (v as? String) ?? "Default description"
//            case "contactName":
//                newInstance.contactName = (v as? String) ?? "Default contact name"
//            case "contactPhone":
//                newInstance.contactPhone = (v as? String) ?? "Default contact phone"
//            case "contactMail":
//                newInstance.contactMail = (v as? String) ?? "Default contact mail"
//            case "mainLocation":
//                newInstance.location = (v as? String) ?? "Default location"
//            case "mainEventType":
//                newInstance.mainEventType = (v as? String) ?? "Default main event type"
//            case "address":
//                newInstance.mainAddress = (v as? String) ?? "Default address"
//            case "city":
//                newInstance.mainCity = (v as? String) ?? "Default city"
//            case "zip":
//                newInstance.mainZip = (v as? String) ?? "Default zip"
//            case "lat":
//                newInstance.mainLat = (v as? String) == "" ? "0" : (v as? String) ?? "0"
//            case "lon":
//                newInstance.mainLon = (v as? String) == "" ? "0" : (v as? String) ?? "0"
//            case "hasCultural":
//                newInstance.hasCultural = (v as? Bool) ?? false
//            case "subLocations":
//                for loc in v as? [String] ?? ["Default string"] {
//                    newInstance.locations.append(loc)
//                }
//            case "eventTypes":
//                for ev in v as? [String] ?? ["Default string"] {
//                    newInstance.eventType.append(ev)
//                }
//            default:
//                break;
//            }
//        }
//        //print(newInstance.guid + " * * * * * ")
//        let determineStatus = self.checkIfIsFavorited(guid: newInstance.guid)
//        if determineStatus.0 { //nil?
//            newInstance.isFavorite = determineStatus.1
//            newInstance.isInCalendar = determineStatus.2
//            if determineStatus.1 || determineStatus.2 {
//                newInstance.isAttending = true
//            }
//        }
//        return newInstance
//    }
//    
//    // ===== FAVORITE & CALENDAR MANAGEMENT ===== //
//    
//    private var canHitFavorites = true
//    
//    ///Function is called when the favorite status of events is interacted with
//    func manageFavorites(event: EventInstance) {
//        if self.canHitFavorites {
//            self.haptic()
//            self.timeDelayFavoriteHit()
//            self.managePersistentCreation(event: event, toggleFavorite: true, setCalendar: false)
//            self.favoriteEventList = [] //reset list
//            self.loadFavoriteData() //reload list to accout for new favorite
//            self.retrieveFavoriteFirebaseData() // new
//            if self.hasEngineBeenRun {
//                self.recommendationEngine.updateRecommendations(guid: event.guid)
//            }
//        }
//    }
//    
//    ///Function prevents "spamming" of the favorite button, which can cause erroneous Firebase input
//    func timeDelayFavoriteHit() {
//        canHitFavorites = false
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
//            self.canHitFavorites = true
//        }
//    }
//    
//    ///Function correctly updates local event data and makes calls to correct functions that manage persistent data.
//    func managePersistentCreation(event: EventInstance, toggleFavorite: Bool, setCalendar: Bool) {
//        if toggleFavorite && setCalendar {
//            print("ERROR: Should not be called with both toggleFavorite & setCalendar being true!!!")
//            return
//        }
//        if toggleFavorite {
//            event.isFavorite.toggle()
//            if !event.isInCalendar { //if the event has been added to the calendar, changing favorite status should not affect number attending
//                event.numAttending += event.isFavorite ? 1 : -1
//                self.updateNumberAttending(guid: event.guid, isAttending: event.isFavorite)
//            }
//        }
//        if setCalendar {
//            event.isInCalendar = true
//            if !event.isAttending { //if not already attending (ie has been favorited), update number attending in Firebase data & locally
//                event.numAttending += 1 //since events cannot be removed from the Apple calendar locally, this should only ever be incremented
//                self.updateNumberAttending(guid: event.guid, isAttending: true)
//            }
//        }
//        if event.isFavorite || event.isInCalendar { //if either of these properties is true, the event is being attended
//            event.isAttending = true
//        } else { //event is not being attended
//            event.isAttending = false
//        }
//        if !self.isInPersistentData(guid: event.guid) { //if not already represented in persistent data, represent it
//            self.createFavoriteData(eventInstance: event)
//        } else { //if already in persistent data, change fields as necessary
//            self.updateFavoriteData(guidToUpdate: event.guid, favoriteTrueFalse: event.isFavorite, calendarTrueFalse: event.isInCalendar)
//        }
//    }
//    
//    func manageCalendar(event: EventInstance) -> ActiveAlert {
//        let eventStore = EKEventStore()
//        //Determines what ActionSheet should be shown depending on whether or not an event already exists in the calendar.
//        if self.doesEventExist(store: eventStore, title: event.name, date: event.date, time: event.time, endDate: event.endDate, endTime: event.endTime) {
//            return .error
//        } else {
//            return .success
//        }
//    }
//    
//    func returnActionSheet(event: EventInstance, activeAlert: ActiveAlert) -> ActionSheet {
//        if activeAlert == .error { //event already exists
//            return ActionSheet(title: Text("Whoops!"),
//                               message: Text("You already have this event in your calendar!"),
//                               buttons: [.destructive(Text("Dismiss"), action: {})])
//        } else { //event does not already exist
//            return ActionSheet(title: Text("Add event?"),
//                               message: Text("Would you like to add an alert when this event is about to happen?"),
//                               buttons: [.default(Text("Save with alert"), action: {
//                                let eventStore = EKEventStore()
//                                switch EKEventStore.authorizationStatus(for: .event) {
//                                case .authorized:
//                                    self.manageCalendarInsertion(event: event, eventStore: eventStore, saveWithAlert: true)
//                                case .denied:
//                                    print("Access denied")
//                                case .notDetermined:
//                                    eventStore.requestAccess(to: .event, completion:
//                                        {[self] (granted: Bool, error: Error?) -> Void in
//                                            if granted {
//                                                self.manageCalendarInsertion(event: event, eventStore: eventStore, saveWithAlert: true)
//                                            } else {
//                                                print("Access denied")
//                                            }
//                                    })
//                                default:
//                                    print("Case default")
//                                }
//                               }),
//                                         .default(Text("Save without alert"), action: {
//                                            let eventStore = EKEventStore()
//                                            switch EKEventStore.authorizationStatus(for: .event) {
//                                            case .authorized:
//                                                self.manageCalendarInsertion(event: event, eventStore: eventStore, saveWithAlert: false)
//                                            case .denied:
//                                                print("Access denied")
//                                            case .notDetermined:
//                                                eventStore.requestAccess(to: .event, completion:
//                                                    {[self] (granted: Bool, error: Error?) -> Void in
//                                                        if granted {
//                                                        self.manageCalendarInsertion(event: event, eventStore: eventStore, saveWithAlert: false)
//                                                        } else {
//                                                            print("Access denied")
//                                                        }
//                                                })
//                                            default:
//                                                print("Case default")
//                                            }
//                                         }),
//                                         .destructive(Text("Cancel"), action: {
//                                         })])
//        }
//    }
//    
//    func manageCalendarInsertion(event: EventInstance, eventStore: EKEventStore, saveWithAlert: Bool) {
//        self.insertEvent(store: eventStore, title: event.name, date: event.date, time: event.time, endDate: event.endDate, endTime: event.endTime, saveWithAlert: saveWithAlert)
//        self.managePersistentCreation(event: event, toggleFavorite: false, setCalendar: true)
//    }
//    //Note that because events are removed from the calendar in the calendar app and not in the StetsonScene app the "numAttending" field cannot be decremented in this case.  This is of minimal concern but it should be noted that after an event is added to the calendar ONE TIME, event.isInCalendar will REMAIN true.  isAttending field will ensure that adding to the calendar multiple times will not increase number attending more than once.
//    
//    ///Called when attempting to add events to calendar to determine if the event already exists & deny adding if this is the case.
//    func doesEventExist(store: EKEventStore, title: String, date: String, time: String, endDate: String, endTime: String) -> Bool {
//        let calendar = store.defaultCalendarForNewEvents
//        let event = EKEvent(eventStore: store)
//        event.calendar = calendar
//        event.title = title
//        event.startDate = makeDateComponents(day: date, time: time)
//        event.endDate = makeDateComponents(day: endDate, time: endTime)
//        
//        let predicate = store.predicateForEvents(withStart: makeDateComponents(day: date, time: time), end: makeDateComponents(day: endDate, time: endTime), calendars: nil)
//        let existingEvents = store.events(matching: predicate)
//        let alreadyExists = existingEvents.contains(where: {e in e.title == event.title && e.startDate == event.startDate && e.endDate == event.endDate})
//        
//        if alreadyExists {
//            return true
//        } else {
//            return false
//        }
//    }
//    
//    ///Makes DateComponents object that can then be used in putting events on the user's calendar at the right time.
//    func makeDateComponents(day: String, time: String) -> Date {
//        let eventDate:Date
//        
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MM/dd/yyyy h:mm a"
//        formatter.timeZone = TimeZone(abbreviation: "EST")
//        let dateToUse = day + " " + time
//        eventDate = formatter.date(from: dateToUse)!
//        print()
//        
//        return eventDate
//    }
//    
//    ///Inserts events into the user's calendar.
//    func insertEvent(store: EKEventStore, title: String, date: String, time: String, endDate: String, endTime: String, saveWithAlert: Bool) {
//        let calendar = store.defaultCalendarForNewEvents
//        let event = EKEvent(eventStore: store)
//        event.calendar = calendar
//        event.title = title
//        event.startDate = makeDateComponents(day: date, time: time)
//        event.endDate = makeDateComponents(day: endDate, time: endTime)
//        if saveWithAlert { //should or should not save with an alert
//            let alarm = EKAlarm(relativeOffset: TimeInterval(-30*60)) //30 minutes before event start
//            event.addAlarm(alarm)
//        }
//        let alreadyExists = doesEventExist(store: store, title: title, date: date, time: time, endDate: endDate, endTime: endTime)
//        if !alreadyExists {
//            do {
//                try store.save(event, span: .thisEvent)
//                print("Successfully saved event.")
//            } catch {
//                print("Error saving event.")
//            }
//        } else {
//            print("Event already exists.")
//        }
//    }
//    
//    private let monthArray = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
//    
//    func formatDate(date: String) -> String {
//        let dateComponents = date.components(separatedBy: "/")
//        if dateComponents.count != 3 {return "Date not found"}
//        let monthNum = Int(dateComponents[0]) ?? 0
//        let month = monthArray[monthNum == 0 ? 0 : monthNum - 1]
//        let dayOfWeek = getDayOfWeek(day: Int(dateComponents[1]) ?? 1, month: Int(dateComponents[0]) ?? 1, year: Int(dateComponents[2]) ?? 2020)
//        return dayOfWeekArray[dayOfWeek] + ", " + month + " " + dateComponents[1]
//    }
//    
//    private let dayOfWeekArray = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
//    
//    //Tomohiko Sakamoto algorithm
//    func getDayOfWeek(day: Int, month: Int, year: Int) -> Int {
//        var y = year;
//        let t:[Int] = [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4]
//        y -= month < 3 ? 1 : 0
//        var x:Int = y + y/4
//        x -= y/100
//        x += y/400
//        x += t[month-1] + day
//        x %= 7
//        return x
//    }
//    
//    func isEventVirtual(location: String, lat: String, lon: String) -> Bool {
//        if (lat == "0" || lat == "") && (lon == "0" || lon == "") && (location == "virtual" || location == "Virtual") {
//            return true
//        }
//        return false
//    }
//    
//    func verifyUrl(urlString: String?) -> Bool {
//        if !urlString!.contains("http") && !urlString!.contains("https") {
//            return false
//        }
//        return true
//    }
//    
//    func makeLink(text: String) -> String {
//        print("AIUGKSBAKJBKBFEKB")
//        let linkPattern = #"(<a href=")(.)+?(?=")"#
//        do {
//            let linkRegex = try NSRegularExpression(pattern: linkPattern, options: [])
//            if linkRegex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) != nil {
//                print("matched")
//                let linkCG = linkRegex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text))
//                let range = linkCG?.range(at: 0)
//                var link:String = (text as NSString).substring(with: range!)
//                let scrapeHTMLPattern = #"(<a href=")"#
//                let scrapeHTMLRegex = try NSRegularExpression(pattern: scrapeHTMLPattern, options: [])
//                link = scrapeHTMLRegex.stringByReplacingMatches(in: link, options: [], range: NSRange(link.startIndex..., in: link), withTemplate: "")
//                print(link)
//                if verifyUrl(urlString: link) {
//                    return link
//                }
//            }
//        } catch { print("Regex error") }
//        return ""
//    }
//    
//    func haptic() {
//        print("activated haptic")
//        let generator = UINotificationFeedbackGenerator()
//        generator.notificationOccurred(.success)
//    }
//    
//}
