//
//  MapView.swift
//  StetsonScene
//
//  Created by Madison Gipson on 7/19/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import SwiftUI
import MapKit
import CoreLocation
import Combine

//MARK: MapView
//handles UI view loading and updating, as well as placement of annotations
struct MapView: UIViewRepresentable {
    @ObservedObject var evm:EventViewModel
    @EnvironmentObject var config: Configuration
    var mapFindMode: Bool //true=finding | false=navigating
    var navToEvent: EventInstance?
    @Binding var internalAlert: Bool
    @Binding var externalAlert: Bool
    @Binding var tooFar: Bool
    @Binding var allVirtual: Bool
    @Binding var arrived: Bool
    @Binding var eventDetails: Bool
    @State var alertSent: Bool = false //keeps the alerts from being obnoxious
    let locationManager = CLLocationManager()
    
    @Binding var page:String
    @Binding var subPage:String
    
    //handle UIView with makeUIView and updateUIView
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        return map
    }
    func updateUIView(_ uiView: MKMapView, context: Context) {
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            locationManager.distanceFilter = 5.0 // location manager updates location every time it's a difference of 5m- want this for navigation
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 29.0350, longitude: -81.3032), span:MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015))
                uiView.setRegion(region, animated: true)
            })
        }
        //show user location & update annotations
        uiView.showsUserLocation = true
        uiView.removeAnnotations(uiView.annotations)
        uiView.addAnnotations(determineAnnotations())
    }
    
    //figure out what annotations should go on the map
    //depends on appEventMode, mapFindMode, if there are virtual events/only virtual events, distance from campus, etc.
    func determineAnnotations() -> [Annotation] {
        var annotations:[Annotation] = []
        var locationsWithAnnotation: [String] = []
        //app event mode
        if config.appEventMode {
            //if you're navigating to a single event, create just one annotation for it
            if !mapFindMode && navToEvent != nil {
                print("navigating")
                if locationManager.location != nil && (CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways) {
                    //if you're too far away from campus, exit map
                    let StetsonUniversity = CLLocation(latitude: 29.0349780, longitude: -81.3026430)
                    if StetsonUniversity.distance(from: locationManager.location!) > 805 { //in meters
                        print("too far to navigate")
                        return annotations //preemptively exit
                    }
                    //if you're on campus, create one annotation (immediately return)
                    annotations.append(Annotation(title: navToEvent?.name, info: navToEvent?.eventDescription, coordinate: CLLocationCoordinate2D(latitude: (navToEvent?.mainLat)!, longitude: (navToEvent?.mainLon)!)))
                    return annotations
                }
            }
            
            //if you're finding/discovering events
            //add buildings with non-virtual events to discover/favorites view
            for event in evm.eventList {
                if !allVirtual {
                    evm.sanitizeCoords(event: event)
                    //don't repeat building annotations, only add to favorites view if the event is favorited
                    if !locationsWithAnnotation.contains(event.location) && ((self.page == "Favorites" && event.isFavorite) || self.page == "Discover") {
                        locationsWithAnnotation.append(event.location)
                        annotations.append(Annotation(title: event.location, info: event.eventDescription, coordinate: CLLocationCoordinate2D(latitude: (event.mainLat)!, longitude: (event.mainLon)!)))
                    }
                }
            }
            
            //if all events are virtual, create a single Stetson annotation (immediately return)
            if mapFindMode && allVirtual {
                annotations.append(Annotation(title: "Stetson University", info: "", coordinate: CLLocationCoordinate2D(latitude: 29.0349780, longitude: -81.3026430)))
                return annotations
            }
        } else { //app tour mode
            for building in self.evm.buildingModelController.buildingList {
                if !locationsWithAnnotation.contains(building.buildingName!) {
                    locationsWithAnnotation.append(building.buildingName!)
                    annotations.append(Annotation(title: building.buildingName!, info: building.buildingSummary, coordinate: CLLocationCoordinate2D(latitude: (building.buildingLat)!, longitude: (building.buildingLon)!)))
                }
            }
        }
        return annotations
    }
    
    //make a coordinator to handle updating values during the view session
    func makeCoordinator() -> Coordinator {
        Coordinator(evm: self.evm, self, config: config, locationManager: locationManager, mapFindMode: mapFindMode, navToEvent: navToEvent, internalAlert: $internalAlert, externalAlert: $externalAlert, tooFar: $tooFar, allVirtual: $allVirtual, arrived: $arrived, eventDetails: $eventDetails, alertSent: $alertSent, page: self.$page, subPage: self.$subPage)
    }
}

//does all the actual work
final class Coordinator: NSObject, MKMapViewDelegate {
    @ObservedObject var evm:EventViewModel
    var parent:MapView
    var config: Configuration
    var locationManager: CLLocationManager
    var mapFindMode: Bool
    var navToEvent: EventInstance?
    @Binding var internalAlert: Bool
    @Binding var externalAlert: Bool
    @Binding var tooFar: Bool
    @Binding var allVirtual: Bool
    @Binding var arrived: Bool
    @Binding var eventDetails: Bool
    @Binding var alertSent: Bool //keeps the alerts from being obnoxious
    
    @Binding var page:String
    @Binding var subPage:String
    
    //initialize
    init(evm: EventViewModel, _ parent: MapView, config: Configuration, locationManager: CLLocationManager, mapFindMode: Bool, navToEvent: EventInstance?, internalAlert: Binding<Bool>, externalAlert: Binding<Bool>, tooFar: Binding<Bool>, allVirtual: Binding<Bool>, arrived: Binding<Bool>, eventDetails: Binding<Bool>, alertSent: Binding<Bool>, page: Binding<String>, subPage: Binding<String>) {
        self.evm = evm
        self.parent = parent
        self.config = config
        self.locationManager = locationManager
        self.mapFindMode = mapFindMode
        self.navToEvent = navToEvent
        self._internalAlert = internalAlert
        self._externalAlert = externalAlert
        self._tooFar = tooFar
        self._allVirtual = allVirtual
        self._arrived = arrived
        self._eventDetails = eventDetails
        self._alertSent = alertSent
        self._page = page
        self._subPage = subPage
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let coordinates = view.annotation?.coordinate else { return }
        mapView.setRegion(MKCoordinateRegion(center: coordinates, span: mapView.region.span), animated: true)
    }
    
    //when the view loads & reloads
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        let infoButton = UIButton(type: .detailDisclosure)
        infoButton.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        view.rightCalloutAccessoryView = infoButton
        view.pinTintColor = config.accentUIColor
        view.canShowCallout = true
        
        //if all events in list are virtual, allVirtual = true & alert will be sent upon screen initialization ONCE
        //determine if all events are virtual
        //start with allVirtual = true
        for event in evm.eventList {
            evm.isVirtual(event: event)
            if self.page == "Favorites" && event.isFavorite && !event.isVirtual {
                allVirtual = false
            } else if self.page != "Favorites" && !event.isVirtual {
                allVirtual = false
            }
        }
        if config.appEventMode && mapFindMode && allVirtual && !alertSent {
            allVirtual = true
            alertSent = true
        }
        //if you're navigating to an event and are basically there, send the "you've arrived" alert ONCE
        if config.appEventMode && !mapFindMode && !alertSent && locationManager.location != nil && (CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways) {
            let destination = CLLocation(latitude: (navToEvent!.mainLat)!, longitude: (navToEvent!.mainLon)!)
            if (round(1000 * (destination.distance(from: locationManager.location!)))/1000) < 16 {
                print("should send arrived alert")
                internalAlert = true
                arrived = true
                alertSent = true
            }
        }
        
        return view
    }
    
    @objc func tapped() {UIImpactFeedbackGenerator(style: .medium).impactOccurred()}
    
    //only for if you tap
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let window = UIApplication.shared.windows.first
        
        if config.appEventMode {
            //if all events are virtual and you tap on the Stetson University node, send the virtual events only alert
            if mapFindMode && allVirtual && view.annotation?.title!! == "Stetson University" {
                //allVirtual = true
                return
            }
            //if you click on an actual event or building, not Stetson University pin
            if view.annotation?.title!! != "Stetson University" {
                if mapFindMode {
                    //event list for buildings
                    for event in evm.eventList {
                        if event.location == view.annotation?.title!! {
                            //let eventListByBuilding = UIHostingController(rootView: ListView(evm: self.evm, eventLocation: event.location!, page: self.$page, subPage: self.$subPage).environmentObject(self.config).background(Color.secondarySystemBackground))
                            //present(eventListByBuilding, animated: true)
                            window?.rootViewController?.present(UIHostingController(rootView: ListView(evm: self.evm, eventLocation: event.location!, page: self.$page, subPage: self.$subPage).environmentObject(self.config).background(Color.secondarySystemBackground)), animated: true)
                        }
                    }
                } else {
                    //navigating to specific event & want details about the event- tap for eventDetails alert
                    internalAlert = true
                    eventDetails = true
                }
            }
        } else {
            window?.rootViewController?.present(UIHostingController(rootView: BuildingDetailView(evm: self.evm, buildingInstance: self.evm.buildingModelController.buildingDic[(view.annotation?.title!!)!]!, page: self.$page, subPage: self.$subPage).environmentObject(self.config)), animated: true)
        }
    }
    
}

class Annotation: NSObject, MKAnnotation {
    let title: String?
    let info: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String?, info: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.info = info
        self.coordinate = coordinate
        super.init()
    }
}
