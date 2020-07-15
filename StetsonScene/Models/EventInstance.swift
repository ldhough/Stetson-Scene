////
////  EventInstance.swift
////  StetsonScene
////
////  Created by Lannie Hough on 1/12/20.
////  Copyright © 2020 Lannie Hough. All rights reserved.
////
//
//import Foundation
//
/////EventInstance objects represent events at Stetson & are used in the Event class to create a list of these events
//class EventInstance: Identifiable, ObservableObject {
//    var guid:String! //each event is stored on Stetson's website with a unique GUID
//    var name:String!
//    var time:String!
//    var endTime:String!
//    var date:String!
//    var endDate:String!
//    var daysIntoYear:Int!
//    var url:String!
//    var summary:String!
//    var eventDescription:String! //description should generally be used over summary as it typically contains more information
//    
//    //contact information
//    var contactName:String!
//    var contactPhone:String!
//    var contactMail:String!
//    
//    //location information
//    var location:String! //Primary location
//    var mainAddress:String!
//    var mainCity:String!
//    var mainState:String!
//    var mainZip:String!
//    var mainLat:String!
//    var mainLon:String!
//    var locations:[/*Location*/String]! = [] //sublocations
//    
//    var hasCultural:Bool = false //exists for easy validation of which events provide cultural credits
//    
//    //event type information
//    var mainEventType:String!
//    var eventType:[/*EventType*/String]! = [] //contains other event types in case an event falls into multiple categories
//
//    var isFavorite:Bool = false
//    
//    var absolutePosition:Int!
//    @Published var numAttending:Int!
//    var isAttending:Bool = false
//    var isInCalendar:Bool = false
//}
//
/////Helper class to represent part of an EventInstance
//class EventType {
//    var eventID:String!
//    var eventTypeName:String!
//}
//
/////Helper class to represent part of an EventInstance
//class Location {
//    var name:String!
//    var facilityID:String!
//}
