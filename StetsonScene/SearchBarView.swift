//
//  SearchBarView.swift
//  StetsonScene
//
//  Created by Lannie Hough on 8/16/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import SwiftUI
import UIKit

//Struct represents a search bar for searching for events by name
struct SearchBar: View {
    @State var searchString:String = ""
    @State var liveSearching:Bool = false
    @State var searching:Bool = false
    @ObservedObject var evm:EventViewModel
    @EnvironmentObject var config:Configuration
    @Environment(\.colorScheme) var colorScheme
    
    //@State var canSearch:Bool = false //when typing, only search a certain amount of time after a key has been hit without another being hit to allow fast responsive typing

    func hide_keyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    public func fillIt() -> some View  {
        ZStack {
            RoundedRectangle(cornerRadius: 10).fill(Color.tertiarySystemBackground)
            RoundedRectangle(cornerRadius: 10).stroke(config.accent)
        }
    }
    
    var body: some View {
        
        let binding = Binding<String>(get: {
            self.searchString
        }, set: {
            self.searchString = $0
            if !self.liveSearching {
                self.liveSearching.toggle() //searching started
                self.performSearch()
                self.liveSearching.toggle() //searching ended
            }
        })
        
        return HStack {
            TextField("Search by name", text: binding, onEditingChanged: {_ in
            }, onCommit: {
                self.BG {
                    self.performSearch(hideKeyboard: false)
                }
            }).onTapGesture(/*count: 2*/) { self.searching = true
            }.onLongPressGesture(minimumDuration: 0, maximumDistance: 0, pressing: nil, perform: hide_keyboard)
                .font(.system(size: 16, weight: .light, design: .default))
                .foregroundColor(colorScheme == .dark ? config.accent : Color.tertiarySystemBackground)
                .padding(7)
                .background(fillIt())
            }.padding() //HStack end
        
    }
    
    func BG(_ block: @escaping() -> Void) {
        DispatchQueue.global(qos: .default).async(execute: block)
    }
    
    ///Function searches for events that have titles that partially or fully contain the text in the search query.
    func performSearch(hideKeyboard: Bool = true) {
        if self.searchString == "" {
            self.searching = false
            for event in evm.eventList {
                evm.eventSearchEngine.checkEvent(event, self.evm)
            }
            updateList(self.evm)
            if hideKeyboard {
                self.hide_keyboard()
            }
            //self.evm.search(weeksToSearch: self.evm.weeksStored, hasToHaveCultural: false, specifyTypes: false) //Might end up showing more time than the last searched time range depending on how the app is used... this is fine & probably helpful more often than not.
            return
        }
        self.searching = true
        //var intermediateList:[EventInstance] = []
        for event in evm.eventList {
            if event.name.lowercased().contains(self.searchString.lowercased()) {
                event.filteredOn = true
                updateList(self.evm)
                //intermediateList.append(event)
            } else {
                event.filteredOn = false
                updateList(self.evm)
            }
        }
        //self.eventModelController.eventListLive = intermediateList
    }
}

func updateList(_ evm: EventViewModel) {
    let tempEvent = evm.eventList.last!
    evm.eventList.removeLast()
    evm.eventList.append(tempEvent)
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension View {
    func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
