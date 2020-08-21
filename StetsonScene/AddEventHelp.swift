//
//  AddEventHelp.swift
//  StetsonScene
//
//  Created by Madison Gipson on 8/21/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation
import SwiftUI

struct AddEventHelp: View {
    @EnvironmentObject var config: Configuration
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            RoundedRectangle(cornerRadius: 20).frame(width: Constants.width*0.25, height: 5, alignment: .center).foregroundColor(Color.secondaryLabel.opacity(0.2)).padding(.vertical, 20)
            
            Text("Add Event").fontWeight(.heavy).font(.system(size: 50)).foregroundColor(config.accent).padding(.bottom, 20)
            
            InstructionRow(underline: true, accentColor: self.config.accent, title: "Go to the Event Webpage", description: "The events in the app are the same as those on the university's event page.", image: "1.circle").onTapGesture { UIApplication.shared.open(URL(string: "https://calendar.stetson.edu/site/deland/?view=")!) }
            InstructionRow(underline: false, accentColor: self.config.accent, title: "Request an Event", description: "On the event webpage, click 'Request Event' & login with your Stetson credentials.", image: "2.circle")
            InstructionRow(underline: false, accentColor: self.config.accent, title: "Create an Event", description: "Create an event through the EventManager portal! We check this event page for new additions daily, so keep an eye out the following day for your event; if you don't see it, let us know and we'll make sure there's not an issue on our end.", image: "3.circle")
            
            Spacer()
            Spacer()
        }.padding([.horizontal])
    }
}

struct InstructionRow: View {
    var underline: Bool
    var accentColor: Color
    var title: String
    var description: String
    var image: String
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: image).resizable().frame(width: 40, height: 40).foregroundColor(accentColor)
            VStack(alignment: .leading) {
                if underline {
                    Text(title).font(.headline).foregroundColor(Color.label).underline()
                } else {
                    Text(title).font(.headline).foregroundColor(Color.label)
                }
                Text(description).font(.body).foregroundColor(Color.secondaryLabel)
            }
        }.padding(.vertical, 5)
    }
}
