//
//  Configuration.swift
//  StetsonScene
//
//  Created by Madison Gipson on 5/11/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit
import Combine

class Configuration: ObservableObject {
    let objectWillChange = PassthroughSubject<Configuration,Never>()
    var eventViewModel:EventViewModel 

    init(_ viewModel: EventViewModel) {
        self.eventViewModel = viewModel
    }
    
    //true=events | false=buildings
    var appEventMode: Bool = true {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    //Trending, Discover, Favorites, Information 
    var page: String = "Trending" {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    //List, Calendar, AR, Map
    var subPage: String = "List" {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    var showOptions: Bool = false {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    var accent: Color = Color(UIColor.systemIndigo) {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    var accentUIColor: UIColor = UIColor.systemIndigo {
        didSet {
            objectWillChange.send(self)
        }
    }
}

struct Constants {
    static let width = UIScreen.main.bounds.width
    static let height = UIScreen.main.bounds.height
}

extension Color {
    static var label: Color { return Color(UIColor.label) }
    static var secondaryLabel: Color { return Color(UIColor.secondaryLabel) }
    static var secondarySystemBackground: Color { return Color(UIColor.secondarySystemBackground) }
    static var tertiarySystemBackground: Color { return Color(UIColor.tertiarySystemBackground) }
}
