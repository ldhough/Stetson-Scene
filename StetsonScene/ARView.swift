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
    var arFindMode: Bool
    var navToEvent: EventInstance? = nil
    @EnvironmentObject var config: Configuration
    
    func makeUIViewController(context: Context) -> ARView {
        return ARView(arFindMode: arFindMode, config: self.config)
    }
    func updateUIViewController(_ uiViewController: ARViewIndicator.UIViewControllerType, context: UIViewControllerRepresentableContext<ARViewIndicator>) { }
}

// MARK: - ARCameraView

class ARView: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate {
    var arFindMode: Bool //true=finding | false=navigating
    var config: Configuration
    var navToEvent: EventInstance? = nil
    let locationManager = CLLocationManager()
    var userLocation: CLLocation!
    var userAltitude = Double?(10)
    var sceneLocationView = SceneLocationView()
    var distanceFromCampus:Double! = 0.0
    var distanceFromBuilding:Double! = 0.0
    
    //Initialization
    init(arFindMode: Bool, config: Configuration) {
        self.arFindMode = arFindMode
        self.config = config
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
                distanceFromCampus = round(1000 * (StetsonUniversity.distance(from: userLocation)/1610)) / 1000
            }
        }
        //if you're too far away from campus
        if distanceFromCampus > 0.5 {
            for annotationNode in self.sceneLocationView.locationNodes { annotationNode.removeFromParentNode() } //clean scene
            createBuildingNode(location: "Stetson University", lat: 29.0349780, lon: -81.3026430, altitude: (userAltitude! + 15)) //just create a stetson node
            createAlert(title: "Too Far from Campus to Tour", message: "Sorry! It looks like you're too far away from campus to tour using AR. Try touring with the map instead!") //send an alert
        } else { //if you're within 0.5mi of campus
            for annotationNode in self.sceneLocationView.locationNodes { annotationNode.removeFromParentNode() } //clean scene
            determineNodes() //create the appropriate nodes depending on appEventMode & arFindMode
        }
        //if you change from discover AR -> favorites AR, refresh
        let prevPage = config.page
        if prevPage != config.page {
            for annotationNode in self.sceneLocationView.locationNodes { annotationNode.removeFromParentNode() } //clean scene
            determineNodes() //create the appropriate nodes depending on appEventMode & arFindMode
        }
    }
    
    //MARK:
    func determineNodes() {
        var allVirtual: Bool = true
        var locationsWithNode: [String] = []
        if config.appEventMode {
            //if you're navigating to a single event, create just one node for it
            if !arFindMode && navToEvent != nil {
                //TODO
                createBuildingNode(location: navToEvent!.location, lat: navToEvent!.mainLat, lon: navToEvent!.mainLon, altitude: (userAltitude! + 15))
                //as you get closer, send alerts
                //54-55m createAlert(title: "Getting Close!", message: "You're right around the corner from \(event.location!)")
                //20-30m createAlert(title: "Almost There!", message: "The \(event.location!) is probably in sight.")
                //less than 16m createAlert(title: "You've Arrived!", message: "Have fun at \(event.name!)!")
                return
            }
            
            //add buildings with non-virtual events to discover/favorites view
            for event in config.eventViewModel.eventList {
                config.eventViewModel.isVirtual(event: event)
                if !event.isVirtual {
                    allVirtual = false
                    config.eventViewModel.sanitizeCoords(event: event)
                    //don't repeat building nodes, only add to favorites view if the event is favorited
                    if !locationsWithNode.contains(event.location) && ((config.page == "Favorites" && event.isFavorite) || config.page == "Discover") {
                        locationsWithNode.append(event.location)
                        createBuildingNode(location: event.location, lat: event.mainLat, lon: event.mainLon, altitude: (userAltitude! + 15))
                    }
                }
            }
            
            //if all events are virtual, create a single Stetson node and send an alert
            if allVirtual {
                createBuildingNode(location: "Stetson University", lat: 29.0349780, lon: -81.3026430, altitude: (userAltitude! + 15))
                createAlert(title: "No Events on Campus to Display", message: "Unfortunately, there are no events on campus at the moment. Check back later for updates.")
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
            layer.opacity = 0.95
            uiview.layer.addSublayer(layer)
            
            //add a text label to the uiview and get it all configured with relative sizing
            let tagLabel = UILabel(frame: CGRect(x:0, y:0, width:Double(width*0.8), height:Double(height)))
            tagLabel.text = location
            tagLabel.textColor = UIColor.label
            tagLabel.font = UIFont.systemFont(ofSize: 25, weight: UIFont.Weight.medium)
            tagLabel.textAlignment = .center
            tagLabel.center = CGPoint(x: uiview.frame.midX, y: uiview.frame.minY+(height/2))
            tagLabel.adjustsFontSizeToFitWidth = true
            uiview.addSubview(tagLabel)
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
                if (String(describing: hits.name!)) != "Stetson University" {
                    for event in config.eventViewModel.eventList {
                        if arFindMode {
                            if event.location == (String(describing: hits.name!)) {
                                let eventListByBuilding = UIHostingController(rootView: ListView(eventLocation: event.location!).environmentObject(self.config).background(Color.secondarySystemBackground))
                                present(eventListByBuilding, animated: true)
                            }
                        } else {
                            if userLocation != nil {
                                distanceFromBuilding = round(10*CLLocation(latitude: event.mainLat, longitude: event.mainLon).distance(from: userLocation))/10
                                distanceFromBuilding = round(100 * (distanceFromBuilding/1610)) / 100 //get from meters to miles
                                createAlert(title: "\(event.name!)", message: "This event is at \(event.time!) on \(event.date!), and you are \(distanceFromBuilding!)m from \(event.location!).")
                            }
                        }
                    }
                }
            } else {
                //TODO
                //present detail views for buildings
            }
        }
    }
    
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
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
