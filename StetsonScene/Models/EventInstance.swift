//
//  EventInstance.swift
//  StetsonScene
//
//  Created by Lannie Hough on 1/12/20.
//  Copyright © 2020 Lannie Hough. All rights reserved.
//

import Foundation

///EventInstance objects represent events at Stetson & are used in the Event class to create a list of these events
class EventInstance: Identifiable, ObservableObject {
    var absolutePosition:Int!
    
    var guid:String! //each event is stored on Stetson's website with a unique GUID
    var name:String!
    var time:String!
    var endTime:String!
    var date:String!
    var endDate:String!
    var daysIntoYear:Int!
    var url:String!
    var summary:String!
    var eventDescription:String! //description should generally be used over summary as it typically contains more information
    var startDateTimeInfo:DateTimeInfo!
    var endDateTimeInfo:DateTimeInfo!
    
    //contact information
    var contactName:String!
    var contactPhone:String!
    var contactMail:String!
    
    //location information
    var location:String! //Primary location
    var mainAddress:String!
    var mainCity:String!
    var mainState:String!
    var mainZip:String!
    var mainLat:String!
    var mainLon:String!
    var locations:[String]! = [] //sublocations
    
    var hasCultural:Bool = false //exists for easy validation of which events provide cultural credits
    
    //event type information
    var mainEventType:String!
    var eventType:[String]! = [] //contains other event types in case an event falls into multiple categories

    var isFavorite:Bool = false //Might need to be published
    var isAttending:Bool = false
    var isInCalendar:Bool = false
    var isVirtual:Bool = false
    
    var linkText:String = ""
    var shareDetails:String = ""
    
    //Properties that can change while the program is running, changes should cause updates in views
    @Published var numAttending:Int!
    @Published var filteredOn:Bool = true //Default is true, updated as search criteria are changed to determine if an event should show up in a list
    @Published var filteredOnLocation:Bool = true //
    @Published var isTrending:Bool = false
}

