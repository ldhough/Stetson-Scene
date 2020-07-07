//
//  EventViewController.swift
//  StetsonScene
//
//  Created by Lannie Hough on 1/12/20.
//  Copyright © 2020 Lannie Hough. All rights reserved.
//

import Foundation
import SwiftUI
import CoreLocation

//Main Button Style e.g. Custom Search button on Event View
struct MainButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    func makeBody(configuration: Self.Configuration) -> some View {
        return configuration.label
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(.horizontal, 7).padding(.vertical, 7)
            .background(colorScheme == .dark ? Constants.medGray : Constants.brightYellow) // changes background of buttons in top section
            .foregroundColor(colorScheme == .dark ? Constants.brightYellow : Color.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .font(.system(size: 16, weight: .light, design: .default))
    }
}

struct AnimatingLoadingCircle: View {
    var body: some View {
        Circle().stroke(/*lineWidth: 30, */style: StrokeStyle(lineWidth: 30, lineCap: CGLineCap.round, dash: [8])).fill(LinearGradient(gradient: .init(colors: [Constants.dark, Constants.light]), startPoint: .bottom, endPoint: .top)).scaleEffect(0.2)
    }
}

struct ActivityIndicator: UIViewRepresentable {
    let brightYellow = UIColor(red: 255/255, green: 196/255, blue: 0/255, alpha: 1.0)
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: style)
        activityIndicator.color = brightYellow
        return activityIndicator//UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

///View displays a list of events with links to an EventDetailView containing more in-depth information about the event
struct EventViewController: View {
    @State private var showSearchForm = false
    @State private var showSearchButton = true
    @State private var testing = 1
    //When instantiating from a location tag on map or AR view, set isSpecificLoc to true & specify specificLoc string.  Ensures search is synced only to correct location.
    @State var isSpecificLoc:Bool = false
    @State var specificLoc:String = ""
    @State var keyboardActivated:Bool = false
    //@ObservedObject means this variable listens to changes in the EventModelController instance passed in
    @ObservedObject var eventModelController:EventModelController
    
    @Environment(\.colorScheme) var colorScheme
    
    private func endEditing() {
        UIApplication.shared.endEditing()
    }
    
    ///Function resets event list to the full list for the last specified timeframe.  Obeys specific location if relevant.
    func resetList() {
        eventModelController.search(weeksToSearch: self.eventModelController.weeksStored, specificLocation: isSpecificLoc, specificLocationIs: specificLoc)
    } //Might end up showing more time than the last searched time range depending on how the app is used... this is fine & probably helpful more often than not.
    
    func returnToDetailsButton(imageName: String, toggleOrReturn: Bool) -> some View { //true is toggle, false is return to detail view
        Button(action: {
            if toggleOrReturn {
                self.eventModelController.navMap.toggle()
                self.eventModelController.navAR.toggle()
            } else {
                if self.eventModelController.navMap {
                    self.eventModelController.navMap = false
                }
                if self.eventModelController.navAR {
                    self.eventModelController.navAR = false
                }
            }
        }) {
            HStack {
                ZStack {
                    Image(systemName: "square.fill").foregroundColor(self.colorScheme == .dark ? Color.black : Constants.medGray).opacity(self.colorScheme == .dark ? 0.1 : 0.4).scaleEffect(3.0)
                    if imageName == "doc.plaintext" {
                        HStack {
                            Image(systemName: "chevron.left").foregroundColor(Constants.brightYellow).scaleEffect(1.0)
                            Image(systemName: imageName).foregroundColor(Constants.brightYellow).scaleEffect(1.5)
                        }
                    } else {
                        Image(systemName: imageName).foregroundColor(Constants.brightYellow).scaleEffect(1.5)
                    }
                }
            }.padding(toggleOrReturn ? .trailing : .leading, Constants.screenSize.width*0.1).padding(.bottom, Constants.screenSize.height < 700 ? Constants.screenSize.width*0.1 : Constants.screenSize.width*0.05)
        }
    }
    
    var body: some View {
        return VStack {
            if self.eventModelController.navMap {
                ZStack {
                    MapNavView(event: self.eventModelController.event, checkpoints: {
                        return [Checkpoint(title: self.eventModelController.event.name, coordinate: .init(latitude: Double(self.eventModelController.event.mainLat)!, longitude: Double(self.eventModelController.event.mainLon)!))]
                    }()).edgesIgnoringSafeArea(.all).edgesIgnoringSafeArea(.all)
                    VStack {
                        /*ZStack {
                            Rectangle().frame(width: Constants.screenSize.width, height: Constants.screenSize.height/9, alignment: .center).opacity(0.9).foregroundColor(self.colorScheme == .dark ? Color.black : Color.white)
                            //Image(systemName: "chevron.down").foregroundColor(Constants.brightYellow)
                        }*/
                        Spacer()
                        Spacer()
                        HStack {
                            returnToDetailsButton(imageName: "doc.plaintext", toggleOrReturn: false)
                            Spacer()
                            returnToDetailsButton(imageName: "arkit", toggleOrReturn: true)
                        }
                    }
                }
            }; if self.eventModelController.navAR {
                ZStack {
                    NavigationIndicator(eventModelController: self.eventModelController, event: self.eventModelController.event, mode: "navigation").edgesIgnoringSafeArea(.all)
                    VStack {
                        Spacer()
                        HStack {
                            returnToDetailsButton(imageName: "doc.plaintext", toggleOrReturn: false)
                            Spacer()
                            returnToDetailsButton(imageName: "mappin.and.ellipse", toggleOrReturn: true)
                        }
                    }
                }
            }; if !self.eventModelController.navMap && !self.eventModelController.navAR {
            SearchBar(eventModelController: self.eventModelController).onTapGesture {
                print("did this")
            }
            HStack {
                Button(action: {
                    self.eventModelController.haptic()
                    self.eventModelController.getUserDefaultsSearch()
                    self.showSearchForm.toggle()
                }) {
                    HStack {
                        Image(systemName: "doc.text.magnifyingglass")
                        Text("Custom Search")
                    }
                }.buttonStyle(MainButtonStyle(colorScheme: self._colorScheme)).padding(.leading, 15).padding(.trailing, 6.5)
                    .sheet(isPresented: $showSearchForm) {
                        SearchFormView(showSearchForm: self.$showSearchForm, number: Double(self.eventModelController.lastWeeksSearched), eventModelController: self.eventModelController, isSpecificLoc: self.isSpecificLoc, specificLoc: self.specificLoc, weekdayArray: self.eventModelController.weekdayArray)
                }
                Button(action: {
                    self.eventModelController.haptic()
                    self.resetList()
                }) {
                    HStack {
                        Image(systemName: "clear")
                        Text("Reset List")
                    }
                }.buttonStyle(MainButtonStyle(colorScheme: self._colorScheme)).padding(.leading, 6.5).padding(.trailing, 15)
            }
            if self.eventModelController.dataReturnedFromSnapshot {
                EventListView(eventModelController: self.eventModelController, listingWhatView: "Event List")
            } else {
                VStack {
                    Spacer()
                    //AnimatingLoadingCircle()
                    ActivityIndicator(isAnimating: .constant(true), style: .large)
                    Spacer()
                }
            }
        }//end of if statements
        }.background(colorScheme == .dark ? Constants.darkGray : Color.white).gesture(DragGesture().onChanged{_ in UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)}) //end of whole vstack
    }//end of view
} //end of struct

extension View {
    func endEditing(_ force: Bool) {
        UIApplication.shared.windows.forEach { $0.endEditing(force)}
    }
}

struct DismissingKeyboard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                let keyWindow = UIApplication.shared.connectedScenes
                    .filter({$0.activationState == .foregroundActive})
                    .map({$0 as? UIWindowScene})
                    .compactMap({$0})
                    .first?.windows
                    .filter({$0.isKeyWindow}).first
                keyWindow?.endEditing(true)
        }
    }
}

///Struct represents a search bar for searching for events by name
struct SearchBar: View {
    @State var searchString:String = ""
    @State var liveSearching:Bool = false
    @State var searching:Bool = false
    @ObservedObject var eventModelController:EventModelController
    @Environment(\.colorScheme) var colorScheme
    
    //@State var canSearch:Bool = false //when typing, only search a certain amount of time after a key has been hit without another being hit to allow fast responsive typing

    func hide_keyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    public func fillIt() -> some View  {
        ZStack {
            RoundedRectangle(cornerRadius: 10).fill(colorScheme == .dark ? Constants.medGray : Color.white)
            RoundedRectangle(cornerRadius: 10).stroke(colorScheme == .dark ? .clear : Constants.brightYellow)
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
                .foregroundColor(colorScheme == .dark ? Constants.brightYellow : Constants.darkGray)
                .padding(7)
                .background(fillIt())
            Button(action: {
                //if icon is xmark and is pressed, clear text field, hide keyboard, and change icon to magnifyingglass
                if self.searchString != "" {
                    self.searchString = ""
                    self.performSearch(hideKeyboard: true)
                }
            }) {
                if self.searchString != "" {
                    LinearGradient(gradient: .init(colors: [Constants.dark, Constants.light]), startPoint: .bottom, endPoint: .top).mask(Image(systemName: "xmark").resizable()).frame(width: Constants.screenSize.width*0.05, height: Constants.screenSize.width*0.05)
                } else {
                    LinearGradient(gradient: .init(colors: [Constants.dark, Constants.light]), startPoint: .bottom, endPoint: .top).mask(Image(systemName: "magnifyingglass").resizable()).frame(width: Constants.screenSize.width*0.05, height: Constants.screenSize.width*0.05)
                }
            }
            }.padding() //HStack end
        
    }
    
    func BG(_ block: @escaping() -> Void) {
        DispatchQueue.global(qos: .default).async(execute: block)
    }
    
    ///Function searches for events that have titles that partially or fully contain the text in the search query.
    func performSearch(hideKeyboard: Bool = true) {
        if self.searchString == "" {
            self.searching = false
            if hideKeyboard {
                self.hide_keyboard()
            }
            self.eventModelController.search(weeksToSearch: self.eventModelController.weeksStored, hasToHaveCultural: false, specifyTypes: false) //Might end up showing more time than the last searched time range depending on how the app is used... this is fine & probably helpful more often than not.
            return
        }
        self.searching = true //keep icon as xmark
        var intermediateList:[EventInstance] = []
        for event in EventModelController.eventList {
            if event.name.contains(self.searchString) || event.name.contains(self.searchString.uppercased()) || event.name.contains(self.searchString.lowercased()) || event.name.contains(self.searchString.capitalized) {
                intermediateList.append(event)
            }
        }
        self.eventModelController.eventListLive = intermediateList
    }
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
