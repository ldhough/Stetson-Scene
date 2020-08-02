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
    typealias UIViewControllerType = ARView
    @EnvironmentObject var config: Configuration
    var arFindMode: Bool
    var navToEvent: EventInstance?
    
    func makeUIViewController(context: Context) -> ARView {
        return ARView(config: self.config, arFindMode: self.arFindMode, navToEvent: self.navToEvent ?? EventInstance())
    }
    func updateUIViewController(_ uiViewController: ARViewIndicator.UIViewControllerType, context: UIViewControllerRepresentableContext<ARViewIndicator>) { }
}

// MARK: - ARCameraView

class ARView: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate {
    var config: Configuration
    var arFindMode: Bool //true=finding | false=navigating
    var navToEvent: EventInstance?
    let locationManager = CLLocationManager()
    var userLocation: CLLocation!
    var userAltitude = Double?(10)
    var sceneLocationView = SceneLocationView()
    var distanceFromCampus:Double! = 0.0
    var distanceFromBuilding:Int! = 0
    var alertSent: Bool = false
    
    //Initialization
    init(config: Configuration, arFindMode: Bool, navToEvent: EventInstance) {
        self.config = config
        self.arFindMode = arFindMode
        self.navToEvent = navToEvent
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
            if (userLocation != nil) {
                let StetsonUniversity = CLLocation(latitude: 29.0349780, longitude: -81.3026430)
                distanceFromCampus = StetsonUniversity.distance(from: userLocation) //in meters
            }
        }
        //if you're too far away from campus
        if distanceFromCampus > 805 { //805m = 0.5mi
            for annotationNode in self.sceneLocationView.locationNodes { annotationNode.removeFromParentNode() } //clean scene
            createBuildingNode(location: "Stetson University", lat: 29.0349780, lon: -81.3026430, altitude: (userAltitude! + 15)) //just create a stetson node
            if !alertSent {
                alertSent = true
                //self.config.eventViewModel.createAlert(title: "Too Far from Campus to Tour", message: "Sorry! It looks like you're too far away from campus to tour using AR. Try touring with the map instead!") //send an alert once
            }
        } else { //if you're within 0.5mi of campus
            alertSent = false //if you were too far away and are now on-campus, reset alertSent so if you go off-campus again it will only alert you once
            for annotationNode in self.sceneLocationView.locationNodes { annotationNode.removeFromParentNode() } //clean scene
            determineNodes() //create the appropriate nodes depending on appEventMode & arFindMode
        }
        //refresh
        for annotationNode in self.sceneLocationView.locationNodes { annotationNode.removeFromParentNode() } //clean scene
        determineNodes() //create the appropriate nodes depending on appEventMode & arFindMode
    }
    
    func determineNodes() {
        var locationsWithNode: [String] = []
        if config.appEventMode {
            //if you're navigating to a single event, create just one node for it
            if !arFindMode && navToEvent != nil {
                for annotationNode in self.sceneLocationView.locationNodes { annotationNode.removeFromParentNode() } //clean scene
                //if you're too far away from campus, send alert and exit AR
                if distanceFromCampus > 805 {
                    for annotationNode in self.sceneLocationView.locationNodes { annotationNode.removeFromParentNode() } //clean scene
                    createBuildingNode(location: "Stetson University", lat: 29.0349780, lon: -81.3026430, altitude: (userAltitude! + 15)) //just create a stetson node
                    if !alertSent {
                        alertSent = true
                        //self.config.eventViewModel.createAlert(title: "Too Far from Campus to Navigate", message: "Sorry! It looks like you're too far away from campus to navigate to an event.") //send an alert once
                    }
                }
                //if you're on campus, create a node and send alert if you've basically arrived
                createBuildingNode(location: navToEvent!.name, lat: navToEvent!.mainLat, lon: navToEvent!.mainLon, altitude: (userAltitude! + 15))
                if userLocation != nil {
                    //CLLocationDistance distanceInMeters = [location1 distanceFromLocation:location2];
                    let destination = CLLocation(latitude: (navToEvent!.mainLat)!, longitude: (navToEvent!.mainLon)!)
                    if (round(1000 * (destination.distance(from: userLocation)))/1000) < 16 {
                        //self.config.eventViewModel.createAlert(title: "You've Arrived!", message: "Have fun at \(String(describing: navToEvent!.name))!")
                    }
                }
                return
            }
            
            //add buildings with non-virtual events to discover/favorites view
            for event in config.eventViewModel.eventList {
                if !config.eventViewModel.determineVirtualList(config: config) {
                    config.eventViewModel.sanitizeCoords(event: event)
                    //don't repeat building nodes, only add to favorites view if the event is favorited
                    if !locationsWithNode.contains(event.location) && ((config.page == "Favorites" && event.isFavorite) || config.page == "Discover") {
                        print("HERE 2")
                        locationsWithNode.append(event.location)
                        createBuildingNode(location: event.location, lat: event.mainLat, lon: event.mainLon, altitude: (userAltitude! + 15))
                    }
                }
            }
            
            //if all events are virtual, create a single Stetson node and send an alert
            if arFindMode && config.eventViewModel.determineVirtualList(config: config) {
                print("HERE 3")
                createBuildingNode(location: "Stetson University", lat: 29.0349780, lon: -81.3026430, altitude: (userAltitude! + 15))
                //self.config.eventViewModel.createAlert(title: "All Events are Virtual", message: "Unfortunately, there are no events on campus at the moment. Check out the virtual event list instead.")
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
                if config.eventViewModel.determineVirtualList(config: config) && (String(describing: hits.name!)) == "Stetson University" {
                    //self.config.eventViewModel.createAlert(title: "All Events are Virtual", message: "Unfortunately, there are no events on campus at the moment. Check out the virtual event list instead.")
                    return
                }
                if (String(describing: hits.name!)) != "Stetson University" {
                        if arFindMode { //checking out events in a building
                            for event in config.eventViewModel.eventList {
                            if event.location == (String(describing: hits.name!)) {
                                let eventListByBuilding = UIHostingController(rootView: ListView(eventLocation: event.location!).environmentObject(self.config).background(Color.secondarySystemBackground))
                                present(eventListByBuilding, animated: true)
                            }
                            }
                        } else { //navigating to specific event
                            if userLocation != nil {
                                let building = CLLocation(latitude: navToEvent!.mainLat, longitude: navToEvent!.mainLon)
                                distanceFromBuilding = Int(building.distance(from: userLocation))
                                //self.config.eventViewModel.createAlert(title: "\(navToEvent!.name!)", message: "This event is at \(navToEvent!.time!) on \(navToEvent!.date!), and you are \(distanceFromBuilding!)m from \(navToEvent!.location!).")
                            }
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
