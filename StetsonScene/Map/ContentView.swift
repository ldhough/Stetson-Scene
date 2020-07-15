////
////  LocationManager.swift
////  FirstMap
////
////  Created by Aaron Stewart on 1/29/20.
////  Copyright © 2020 Aaron Stewart. All rights reserved.
////
//
//import SwiftUI
//import CoreLocation
//
//struct Landmark: Equatable {
//    static func ==(lhs: Landmark, rhs: Landmark) -> Bool {
//        lhs.id == rhs.id
//    }
//    
//    let id = UUID().uuidString
//    let name: String
//    let location: CLLocationCoordinate2D
//    let description: String
//}
//
//class LandmarkSupport: ObservableObject {
//    @Published var landmarks:[Landmark] = []
//    @Published var buildings:[Landmark] = []
//    func createAllNodes() {
//            print("creating all nodes")
//            var buildingsAlreadyRepresented:Dictionary<String, Bool> = [:]
//            for event in EventModelController.eventList {
//                if event.mainLat != "" && event.mainLon != "" {
//                    let eventLat:Double = Double(event.mainLat)!
//                    let eventLon:Double = Double(event.mainLon)!
//                    if buildingsAlreadyRepresented[event.location] == nil && ((eventLat > 5 || eventLat < -5) && (eventLon > 5 || eventLon < -5)) { //events without lat/lon set are 0.0, using 5 arbitrarily to make sure a real lat/lon is set, also key must not exist
//                        buildingsAlreadyRepresented[event.location!] = true
//                        let landmark:Landmark = Landmark(name: event.location, location: .init(latitude: eventLat, longitude: eventLon), description: "This is a test")
//                        print("this happened")
//                        self.landmarks.append(landmark)
//                    }
//                }
//            }
//        for building in AppDelegate.shared().eventModelController.buildingModelController.buildingList {
//                let landmark:Landmark = Landmark(name: building.buildingName!, location: .init(latitude: building.buildingLat, longitude: building.buildingLon), description: building.buildingSummary)
//                self.buildings.append(landmark)
//            }
//        }
//}
//
//struct ContentView: View {
//    @ObservedObject var landmarkSupport:LandmarkSupport
//    @ObservedObject var locationManager = LocationManager()
//    @ObservedObject var eventModelController:EventModelController
//    
//    var userLatitude: String {
//        return "\(locationManager.lastLocation?.coordinate.latitude ?? 0)"
//    }
//    
//    var userLongitude: String {
//        return "\(locationManager.lastLocation?.coordinate.longitude ?? 0)"
//    }
//    
//    @State var selectedLandmark: Landmark? = nil
//    
//    var body: some View {
//        ZStack {
//            MapView(eventModelController: self.eventModelController, landmarks: self.eventModelController.eventMode ? self.landmarkSupport.landmarks : self.landmarkSupport.buildings,
//                    selectedLandmark: $selectedLandmark) //new replaced $landmarks
//                .edgesIgnoringSafeArea(.vertical)
//        }
//    }
//}
//
