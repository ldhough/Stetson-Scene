//
//  RecommendationEngine.swift
//  StetsonScene
//
//  Created by Lannie Hough on 3/24/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

class RecommendationEngine {
    var evm:EventViewModel
    
    init(evm: EventViewModel) {
        self.evm = evm
    }
    
    var weightDic:[String: Double] = [:]
    var typeDic:[String: Int] = [:]
    var timeDic:[String: Int] = [:]
    
    func runEngine() -> [EventInstance] {
        self.buildDics()
        let pool = self.makeRecommendationPool()
        let recommended = self.makeRecommendations(list: pool)
        return recommended
    }
    
    func buildDics() {
        for event in self.evm.eventList {
            if event.isFavorite {
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
    }
    
    func makeRecommendationPool() -> [EventInstance] {
        var top20:[EventInstance] = []
        for event in self.evm.eventList {
            event.recommendScore = 0.0
            if !event.isFavorite {
                weightDic[event.guid] = 0
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
                event.recommendScore = weightDic[event.guid]!
                
                if top20.count < 20 {
                    top20.append(event)
                    top20.sort(by: {$0.recommendScore > $1.recommendScore })
                } else {
                    if event.recommendScore > top20.last!.recommendScore {
                        top20[top20.count-1] = event
                    }
                }
                
            }
        }
        return top20
    }
    
    func makeRecommendations(list: [EventInstance]) -> [EventInstance] {
        var recommendedList:[EventInstance] = []
        let shuffled = list.shuffled()
        let numRecommended = shuffled.count >= 10 ? 10 : shuffled.count
        for i in 0 ..< numRecommended {
            recommendedList.append(list[i])
        }
        return recommendedList
    }
    
}
