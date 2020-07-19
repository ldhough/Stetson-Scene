//
//  EventDetailView.swift
//  StetsonScene
//
//  Created by Madison Gipson on 7/15/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation
import SwiftUI

struct EventDetailView : View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    var event: Event
    
    var body: some View {
        VStack {
            Text(event.name)
        }
    }
}
