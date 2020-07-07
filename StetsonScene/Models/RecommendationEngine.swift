//
//  RecommendationEngine.swift
//  StetsonScene
//
//  Created by Lannie Hough on 3/24/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation

//add no two events w/ same name
//add based on people attending
//sync correctly w/ favorite list & remove correctly

//have main EventModelController reference one RecommendationEngine & have RecommendationEngine reference EventModelController

class RecommendationEngine: ObservableObject {
    var eventModelController:EventModelController
    
    static var recommendedEvents:[EventInstance] = []
    var recommendationPool:[Dictionary<String, Any>] = []
    var rPoolSize:Int = 10
    var recommendationPoolSet:Set<String> = [] //for faster access to which elements are in recommendation pool - by NAME of event
    
    var weightDic:Dictionary<String, Double> = [:] //value contains relevance of the event to the user
    
    var typeDic:Dictionary<String, Int> = [:] //marks number of occurences of events the user has favorited of a certain type
    var timeDic:Dictionary<String, Int> = [:] //marks number of occurences of events the user has favorited at a certain time
    
    init(eventModelController: EventModelController) {
        self.eventModelController = eventModelController
    }
    
    func runRecommendationEngine() {
        RecommendationEngine.recommendedEvents = []
        buildDictionaries()
        buildRecommendationPool()
        makeRecommendations()
        self.eventModelController.hasEngineBeenRun = true
        self.eventModelController.eventListRecLive = RecommendationEngine.recommendedEvents
    }
    
    func buildDictionaries() {
        for event in eventModelController.favoriteEventList {
            for eType in event.eventType {
                if typeDic[eType] == nil {
                    typeDic[eType] = 1
                } else {
                    typeDic[eType]! += 1
                }
            }
            if timeDic[event.time] == nil {
                timeDic[event.time] = 1
            } else {
                timeDic[event.time]! += 1
            }
        }
    }
    
    ///Function obtains 10 events with the highest weight and keeps them in the recommendationPool array
    func buildRecommendationPool() {
        var inc:Int = 0
        for event in EventModelController.eventList {
            if !event.isFavorite {
                weightDic[event.guid] = 0 //initialize event in weightDic
                //increases weight based on how many times the user has attended events w/ same type
                if typeDic[event.mainEventType] != nil {
                    weightDic[event.guid]! += Double(typeDic[event.mainEventType]!)
                }
                //increases weight based on how many times the user has attended events at the same time
                if timeDic[event.time] != nil {
                    weightDic[event.guid]! += Double(timeDic[event.time]!)
                }
                if event.hasCultural {
                    weightDic[event.guid]! *= 1.25
                }
                if recommendationPool.count < 10 && !recommendationPoolSet.contains(self.eventModelController.mainEventSet[event.guid]!.name) {
                    var tempDic:Dictionary<String, Any> = [:]
                    tempDic["guid"] = event.guid
                    tempDic["weight"] = weightDic[event.guid]
                    tempDic["event"] = event
                    recommendationPool.append(tempDic)
                    recommendationPoolSet.insert(self.eventModelController.mainEventSet[event.guid]!.name)
                    recommendationPool.sort(by: {$0["weight"] as! Double > $1["weight"] as! Double})
                    inc += 1
                } else {
                    if !recommendationPoolSet.contains(self.eventModelController.mainEventSet[event.guid]!.name) {
                    if (weightDic[event.guid]! > recommendationPool[9]["weight"] as! Double) {
                        var tempDic:Dictionary<String, Any> = [:]
                        tempDic["guid"] = event.guid
                        tempDic["weight"] = weightDic[event.guid]
                        tempDic["event"] = event
                        recommendationPoolSet.remove(self.eventModelController.mainEventSet[recommendationPool[9]["guid"] as! String]!.name)
                        recommendationPool[9] = tempDic
                        recommendationPoolSet.insert(self.eventModelController.mainEventSet[event.guid]!.name)
                        recommendationPool.sort(by: {$0["weight"] as! Double > $1["weight"] as! Double})
                    }
                    }
                }
            }
        }
    }
    
    func makeRecommendations() {
        var index:Int = 0
        let originalSize = recommendationPool.count
        while RecommendationEngine.recommendedEvents.count != (originalSize >= 5 ? 5 : originalSize) {
            let random = Int.random(in: 1 ... 3)
            if random == 3 {
                if !containsThisEvent(guid: (recommendationPool[index]["event"] as! EventInstance).guid) {
                    RecommendationEngine.recommendedEvents.append(recommendationPool[index]["event"] as! EventInstance)
                    
                }
            }
            index = index < originalSize - 1 ? index + 1 : 0
        }
        buildRecommendationPool()
    }
    
    //Called when a recommended event is favorited to remove it from the recommended cells & put a new event in its place
    func updateRecommendations(guid: String) {
        if containsThisEvent(guid: guid) {
            RecommendationEngine.recommendedEvents.remove(at: { (guid: String) -> Int in
                for i in 0...RecommendationEngine.recommendedEvents.count {
                    if guid == RecommendationEngine.recommendedEvents[i].guid { return i }
                }; return 0
            }(guid))
            for i in 0...recommendationPool.count-1 {
                if guid == recommendationPool[i]["guid"] as! String {
                    recommendationPool.remove(at: i)
                    break
                }
            }
            makeRecommendations()
            //should only ever make one recommendation when called here
        }
    }
    
    func containsThisEvent(guid: String) -> Bool {
        for event in RecommendationEngine.recommendedEvents {
            if event.guid == guid {
                return true
            }
        }
        return false
    }
    
}
