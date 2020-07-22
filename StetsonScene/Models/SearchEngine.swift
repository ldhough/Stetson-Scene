//
//  SearchEngine.swift
//  StetsonScene
//
//  Created by Lannie Hough on 7/21/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation

class EventSearchEngine {
    
    var applyFilter = false //
    
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
