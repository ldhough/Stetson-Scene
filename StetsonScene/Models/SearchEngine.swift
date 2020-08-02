//
//  SearchEngine.swift
//  StetsonScene
//
//  Created by Lannie Hough on 7/21/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation

class EventSearchEngine {
    
    var applyFilter = false
    
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
    
    var locationSet:Set<String> = []
    
    func filter(evm: EventViewModel) {
        
    }
    
}
