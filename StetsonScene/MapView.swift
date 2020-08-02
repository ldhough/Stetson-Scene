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
struct MapView: UIViewRepresentable {
    @EnvironmentObject var config: Configuration
    var mapFindMode: Bool //true=finding | false=navigating
    var navToEvent: EventInstance?
    //for alerts- pass straight through to coordinator
    @Binding var showAlert: Bool
    @Binding var arrived: Bool
    @Binding var tooFar: Bool
    
    let locationManager = CLLocationManager()
    var distanceFromBuilding:Int! = 0
    
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
    
    func determineAnnotations() -> [Annotation] {
        var annotations:[Annotation] = []
        var locationsWithAnnotation: [String] = []
        
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
            
            //add buildings with non-virtual events to discover/favorites view
            for event in config.eventViewModel.eventList {
                if !config.eventViewModel.determineVirtualList(config: config) {
                    config.eventViewModel.sanitizeCoords(event: event)
                    //don't repeat building annotations, only add to favorites view if the event is favorited
                    if !locationsWithAnnotation.contains(event.location) && ((config.page == "Favorites" && event.isFavorite) || config.page == "Discover") {
                        locationsWithAnnotation.append(event.location)
                        annotations.append(Annotation(title: event.location, info: event.eventDescription, coordinate: CLLocationCoordinate2D(latitude: (event.mainLat)!, longitude: (event.mainLon)!)))
                    }
                }
            }
            
            //if all events are virtual, create a single Stetson annotation (immediately return)
            if mapFindMode && config.eventViewModel.determineVirtualList(config: config) {
                annotations.append(Annotation(title: "Stetson University", info: "", coordinate: CLLocationCoordinate2D(latitude: 29.0349780, longitude: -81.3026430)))
                return annotations
            }
        } else {
            //TODO
            //create all building annotations
        }
        return annotations
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, config: config, locationManager: locationManager, mapFindMode: mapFindMode, navToEvent: navToEvent, showAlert: self.$showAlert, arrived: self.$arrived, tooFar: self.$tooFar)
    }
}

//does all the actual work
final class Coordinator: NSObject, MKMapViewDelegate {
    var parent:MapView
    var config: Configuration
    var locationManager: CLLocationManager
    var mapFindMode: Bool
    var navToEvent: EventInstance?
    //for alerts
    @Binding var showAlert: Bool
    @Binding var arrived: Bool
    @Binding var tooFar: Bool
    
    init(_ parent: MapView, config: Configuration, locationManager: CLLocationManager, mapFindMode: Bool, navToEvent: EventInstance?, showAlert: Binding<Bool>, arrived: Binding<Bool>, tooFar: Binding<Bool>) {
        self.parent = parent
        self.config = config
        self.locationManager = locationManager
        self.mapFindMode = mapFindMode
        self.navToEvent = navToEvent
        self._showAlert = showAlert
        self._arrived = arrived
        self._tooFar = tooFar
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let coordinates = view.annotation?.coordinate else { return }
        mapView.setRegion(MKCoordinateRegion(center: coordinates, span: mapView.region.span), animated: true)
    }
    
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
        return view
    }
    
    @objc func tapped() {UIImpactFeedbackGenerator(style: .medium).impactOccurred()}
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let window = UIApplication.shared.windows.first
        
        if config.appEventMode {
            //if all events are virtual and you tap on the Stetson University node, send the virtual events only alert
            if mapFindMode && config.eventViewModel.determineVirtualList(config: config) && view.annotation?.title!! == "Stetson University" {
                self.showAlert = true
                return
            }
            if view.annotation?.title!! != "Stetson University" { //if you click on an actual event or building, not Stetson University pin
                if mapFindMode { //checking out events in a building
                    print("find mode")
                    for event in config.eventViewModel.eventList {
                        if event.location == view.annotation?.title!! {
                            window?.rootViewController?.present(UIHostingController(rootView: ListView(eventLocation: event.location!).environmentObject(self.config).background(Color.secondarySystemBackground)), animated: true)
                        }
                    }
                } else { //navigating to specific event
                    print("nav mode")
                    if locationManager.location != nil && (CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways) {
                        let building = CLLocation(latitude: navToEvent!.mainLat, longitude: navToEvent!.mainLon)
                        let distanceFromBuilding = Int(building.distance(from: locationManager.location!))
                        //if you're too far away from campus, send alert
                        let StetsonUniversity = CLLocation(latitude: 29.0349780, longitude: -81.3026430)
                        if StetsonUniversity.distance(from: locationManager.location!) > 805 { //in meters
                            self.tooFar = true
                            self.showAlert = true
                            print("too far to navigate")
                        }
                        //if you're on campus navigating to an event, send alert if you've basically arrived
                        let destination = CLLocation(latitude: (navToEvent!.mainLat)!, longitude: (navToEvent!.mainLon)!)
                        if (round(1000 * (destination.distance(from: locationManager.location!)))/1000) < 16 {
                            self.arrived = true
                            self.showAlert = true
                        }
                        //if you tap on the pin
                        //assume this is for event details, w/o any other clarification
                        self.showAlert = true
                    }
                }
            }
        } else {
            //TODO
            //present detail views for buildings
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
