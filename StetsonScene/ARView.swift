//
//  ARView.swift
//  StetsonScene
//
//  Created by Madison Gipson on 7/18/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import UIKit
import SwiftUI
import ARKit
import SceneKit
import CoreLocation
import ARCL

// MARK: - ARViewIndicator (ties together AR UIKit & app SwiftUI)

struct ARViewIndicator: UIViewControllerRepresentable {
    @ObservedObject var evm:EventViewModel
    typealias UIViewControllerType = ARView
    @EnvironmentObject var config: Configuration
    var arFindMode: Bool
    var navToEvent: EventInstance?
    @Binding var internalAlert: Bool
    @Binding var externalAlert: Bool
    @Binding var tooFar: Bool
    @Binding var allVirtual: Bool
    @Binding var arrived: Bool
    @Binding var eventDetails: Bool
    
    func makeUIViewController(context: Context) -> ARView {
        return ARView(evm: self.evm, config: self.config, arFindMode: self.arFindMode, navToEvent: self.navToEvent ?? EventInstance(), internalAlert: self.$internalAlert, externalAlert: self.$externalAlert, tooFar: self.$tooFar, allVirtual: self.$allVirtual, arrived: self.$arrived, eventDetails: self.$eventDetails)
    }
    func updateUIViewController(_ uiViewController: ARViewIndicator.UIViewControllerType, context: UIViewControllerRepresentableContext<ARViewIndicator>) { }
}

// MARK: - ARCameraView

class ARView: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate {
    @ObservedObject var evm:EventViewModel
    var config: Configuration
    var arFindMode: Bool //true=finding | false=navigating
    var navToEvent: EventInstance?
    @Binding var internalAlert: Bool
    @Binding var externalAlert: Bool
    @Binding var tooFar: Bool
    @Binding var allVirtual: Bool
    @Binding var arrived: Bool
    @Binding var eventDetails: Bool
    @State var alertSent: Bool = false //keeps the alerts from being obnoxious
    let StetsonUniversity = CLLocation(latitude: 29.0349780, longitude: -81.3026430)
    let locationManager = CLLocationManager()
    var userAltitude = Double?(10)
    var sceneLocationView = SceneLocationView()
    var distanceFromBuilding:Int! = 0
    //every time user location is updated, update the scene as well
    var userLocation: CLLocation! {
        didSet {
            //if you're navigating to an event with AR, update distanceFromBuilding so it can be displayed on the AR tag
            if !arFindMode {
                let building = CLLocation(latitude: navToEvent!.mainLat, longitude: navToEvent!.mainLon)
                distanceFromBuilding = Int(building.distance(from: userLocation))
            }
            if StetsonUniversity.distance(from: userLocation) > 805 && !alertSent { //805m = 0.5mi //if you're too far away from campus, create just one node and send an alert
                for annotationNode in self.sceneLocationView.locationNodes { annotationNode.removeFromParentNode() } //clean scene
                createBuildingNode(location: "Stetson University", lat: 29.0349780, lon: -81.3026430, altitude: (userAltitude! + 15)) //just create a stetson node
                externalAlert = true
                tooFar = true
                alertSent = true
            } else { //if you're within 0.5mi of campus
                for annotationNode in self.sceneLocationView.locationNodes { annotationNode.removeFromParentNode() } //clean scene
                determineNodes() //create the appropriate nodes depending on appEventMode & arFindMode
                externalAlert = false
                tooFar = false
            }
        }
    }
    
    //Initialization
    init(evm: EventViewModel, config: Configuration, arFindMode: Bool, navToEvent: EventInstance, internalAlert: Binding<Bool>, externalAlert: Binding<Bool>, tooFar: Binding<Bool>, allVirtual: Binding<Bool>, arrived: Binding<Bool>, eventDetails: Binding<Bool>) {
        self.evm = evm
        self.config = config
        self.arFindMode = arFindMode
        self.navToEvent = navToEvent
        self._internalAlert = internalAlert
        self._externalAlert = externalAlert
        self._tooFar = tooFar
        self._allVirtual = allVirtual
        self._arrived = arrived
        self._eventDetails = eventDetails
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isUserInteractionEnabled = true
        // Location Manager
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization() // For use in foreground
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = 5.0 // location manager updates location every time it's a difference of 5m
            locationManager.startUpdatingLocation()
        }
        //Create TapGesture Recognizer & add recognizer to sceneview
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(rec:)))
        sceneLocationView.addGestureRecognizer(tap)
        sceneLocationView.run()
        view.addSubview(sceneLocationView)
    }
    
    //whenever location updates, so do tags -> this is how the live rendering happens
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("locationManager evoked")
        defer { userLocation = locations.last }
        if let lastLocation = locations.last {
            userAltitude = lastLocation.altitude
            userLocation = lastLocation
        }
    }
    
    func determineNodes() {
        var locationsWithNode: [String] = []
        if config.appEventMode {
            //if you're navigating to a single event and are close enough to campus to navigate, create just one node for it
            if !arFindMode && navToEvent != nil && StetsonUniversity.distance(from: userLocation) <= 805 {
                for annotationNode in self.sceneLocationView.locationNodes { annotationNode.removeFromParentNode() } //clean scene
                createBuildingNode(location: navToEvent!.name, lat: navToEvent!.mainLat, lon: navToEvent!.mainLon, altitude: (userAltitude! + 15))
                //if you're navigating to an event and are basically there, send the "you've arrived" alert ONCE
                if !alertSent && locationManager.location != nil && (CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways) {
                    let destination = CLLocation(latitude: (navToEvent!.mainLat)!, longitude: (navToEvent!.mainLon)!)
                    if (round(1000 * (destination.distance(from: locationManager.location!)))/1000) < 16 {
                        print("should send arrived alert")
                        internalAlert = true
                        arrived = true
                        alertSent = true
                    }
                }
                return
            }
            
            //if you're touring with AR, create nodes for each building with events
            for event in config.eventViewModel.eventList {
                if !config.eventViewModel.determineVirtualList(config: config) {
                    config.eventViewModel.sanitizeCoords(event: event)
                    //only add non-virtual events, don't repeat building nodes, only add to favorites view if the event is favorited
                    if (event.location.lowercased() != "virtual") && !locationsWithNode.contains(event.location) && ((config.page == "Favorites" && event.isFavorite) || config.page == "Discover") {
                        locationsWithNode.append(event.location)
                        createBuildingNode(location: event.location, lat: event.mainLat, lon: event.mainLon, altitude: (userAltitude! + 15))
                    }
                }
            }
            
            //if all events are virtual, create a single Stetson node and send an alert
            if arFindMode && config.eventViewModel.determineVirtualList(config: config) && !alertSent {
                createBuildingNode(location: "Stetson University", lat: 29.0349780, lon: -81.3026430, altitude: (userAltitude! + 15))
                allVirtual = true
                alertSent = true
            }
        } else {
            //TODO
            //create all building nodes
        }
    }
    
    func createBuildingNode(location: String, lat: Double, lon: Double, altitude: Double) {
        let width:CGFloat = 250
        let height:CGFloat = 50
        
        var uiview: UIView {
            let uiview = UIView(frame: CGRect(x:0, y:0, width:Double(width), height:Double(height*1.5)))
            //create the tag shape and add it as a layer with good color & opacity
            let rect = CGRect(x: 0, y: 0, width: width, height: height)
            let tag = UIBezierPath(roundedRect: rect, cornerRadius: 15)
            tag.move(to: CGPoint(x: rect.midX, y: rect.maxY+(height/3)))
            tag.addLine(to: CGPoint(x: rect.midX-(width/15), y: rect.maxY))//left
            tag.addLine(to: CGPoint(x: rect.midX+(width/15), y: rect.maxY))//right
            tag.addLine(to: CGPoint(x: rect.midX, y: rect.maxY+(height/3)))//bottom
            let layer = CAShapeLayer()
            layer.path = tag.cgPath
            layer.fillColor = UIColor.secondarySystemBackground.cgColor
            //layer.opacity = 0.95
            uiview.layer.addSublayer(layer)
            
            //add a text label to the uiview and get it all configured with relative sizing
            let tagLabel = UILabel(frame: CGRect(x:0, y:0, width: arFindMode ? Double(width*0.9) : Double(width*0.75), height:Double(height)))
            tagLabel.text = location
            tagLabel.textColor = UIColor.label
            tagLabel.font = UIFont.systemFont(ofSize: 25, weight: UIFont.Weight.medium)
            tagLabel.textAlignment = arFindMode ? .center : .left
            tagLabel.center = CGPoint(x: arFindMode ? uiview.frame.midX : (uiview.frame.midX-CGFloat(Double(width*0.1))), y: uiview.frame.minY+(height/2))
            tagLabel.adjustsFontSizeToFitWidth = arFindMode ? true : false
            uiview.addSubview(tagLabel)
            
            if !arFindMode {
                //add a text label to the uiview and get it all configured with relative sizing
                let tagLabel2 = UILabel(frame: CGRect(x:0, y:0, width:Double(width*0.9), height:Double(height)))
                tagLabel2.text = "\(distanceFromBuilding!)m"
                tagLabel2.textColor = UIColor.secondaryLabel
                tagLabel2.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.light)
                tagLabel2.textAlignment = .right
                tagLabel2.center = CGPoint(x: uiview.frame.midX, y: uiview.frame.minY+(height/2))
                tagLabel2.adjustsFontSizeToFitWidth = true
                uiview.addSubview(tagLabel2)
            }
            return uiview
        }
        
        let myBuildingTagNode = LocationAnnotationNode(location: (CLLocation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon), altitude: altitude)), view: uiview)
        myBuildingTagNode.annotationNode.name = location
        myBuildingTagNode.annotationHeightAdjustmentFactor = Double.random(in: 0.5 ... 2.0)
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: myBuildingTagNode)
    }
    
    // Method called when screen is tapped
    @objc func handleTap(rec: UITapGestureRecognizer) {
        if rec.state == .ended {
            let location: CGPoint = rec.location(in: sceneLocationView)
            guard let hits = self.sceneLocationView.hitTest(location, options: nil).first?.node else { return }
            
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            
            if config.appEventMode {
                //if all events are virtual and you tap on the Stetson University node, send the virtual events only alert
                if arFindMode && config.eventViewModel.determineVirtualList(config: config) && (String(describing: hits.name!)) == "Stetson University" {
                    externalAlert = true
                    allVirtual = true
                    return
                }
                //if you're too far from campus and you tap the Stetson node, send the too far alert
                if arFindMode && StetsonUniversity.distance(from: userLocation) > 805 && (String(describing: hits.name!)) == "Stetson University" {
                    externalAlert = true
                    tooFar = true
                    return
                }
                //if you tap an actual building
                if (String(describing: hits.name!)) != "Stetson University" {
                    if arFindMode {
                        //see event list for a building
                        for event in config.eventViewModel.eventList {
                            if event.location == (String(describing: hits.name!)) {
                                let eventListByBuilding = UIHostingController(rootView: ListView(evm: self.evm, eventLocation: event.location!).environmentObject(self.config).background(Color.secondarySystemBackground))
                                present(eventListByBuilding, animated: true)
                            }
                        }
                    } else {
                        //navigating to specific event & want details about the event- tap for eventDetails alert
                        internalAlert = true
                        eventDetails = true
                    }
                }
            } else {
                //TODO
                //present detail views for buildings
            }
        }
    }
    
    
    // MARK: - Functions for standard AR view handling
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneLocationView.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) { //setUpSceneView
        super.viewWillAppear(animated)
        sceneLocationView.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneLocationView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    func sessionWasInterrupted(_ session: ARSession) {} // Inform the user that the session has been interrupted, for example, by presenting an overlay
    
    func sessionInterruptionEnded(_ session: ARSession) {} // Reset tracking and/or remove existing anchors if consistent tracking is required
    
    func session(_ session: ARSession, didFailWithError error: Error) {} // Present an error message to the user
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {}
}
