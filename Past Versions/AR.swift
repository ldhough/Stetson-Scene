//
//  ARTourViewController.swift
//  StetsonScene
//
//  Created by Madison Gipson on 1/26/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.

import UIKit
import SceneKit
import ARKit
import ARCL
import CoreLocation
import MapKit
import SwiftUI

class ARTourViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate {
//    let configuration = ARWorldTrackingConfiguration()
//    var sceneLocationView = SceneLocationView()
//    let locationManager = CLLocationManager()
//    var userAltitude = Double?(10) //default value before getting user's location & therefore altitude
//    var userLocation: CLLocation!
    var distance:Double! = 0.0
    var distanceUsable:Double = 0.0
    var prevDistanceUsable:Double!
    var inRange:Bool = false
    var firstRender:Bool = true
//    var tagWidth:Float = 200//180
//    var tagHeight:Float = 50
//    var tagOpacity:Float = 1.0
    
//    var noNodes:Bool = true
//    var alerted:Bool = false
    
    var buildingUserDistanceMeters:Double!
    var buildingUserDistanceMiles:Double!
    
//    @ObservedObject var eventModelController:EventModelController
    var event:EventInstance
//    var mode:String
    var building:BuildingInstance!
    
//    func createAlert(title: String, message: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
//        NSLog("The \"OK\" alert occured.")
//        }))
//        self.present(alert, animated: true, completion: nil)
//        //return alert
//    }
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.view.isUserInteractionEnabled = true
//        // Location Manager
//        self.locationManager.requestAlwaysAuthorization()
//        self.locationManager.requestWhenInUseAuthorization() // For use in foreground
//        if CLLocationManager.locationServicesEnabled() {
//            locationManager.delegate = self
//            locationManager.desiredAccuracy = kCLLocationAccuracyBest
//            locationManager.distanceFilter = 5.0 // location manager updates location every time it's a difference of 5m
//            locationManager.startUpdatingLocation()
//        }
//        //Create TapGesture Recognizer & add recognizer to sceneview
//        let tap = UITapGestureRecognizer(target: self, action: /*mode == "navigation" ? nil : */#selector(handleTap(rec:)))
//        sceneLocationView.addGestureRecognizer(tap)
//        sceneLocationView.run()
//        view.addSubview(sceneLocationView)
//    }
    
//    func createAllNodes(){
//        firstRender = false
//        if self.eventModelController.eventMode {
//        var buildingsAlreadyRepresented:Dictionary<String, Bool> = [:]
//        var latArray:[Double] = []
//        //var lonArray:[Double]!
//            for event in EventModelController.eventList {
//                var eventLat:Double = Double(event.mainLat)!
//                var eventLon:Double = Double(event.mainLon)!
//                latArray.append(eventLat) //keeps track of all event lats- make sure that not all events are virtual (eventLat=0)
//                //if event coordinates aren't "" (invalid) or 0 (virtual), create a node at that building
//                if event.mainLat != "" && event.mainLon != "" && eventLat != 0 && eventLon != 0 && eventLat != 0.0 && eventLon != 0.0 {
//                    self.noNodes = false
//                    if buildingsAlreadyRepresented[event.location] == nil && ((eventLat > 5 || eventLat < -5) && (eventLon > 5 || eventLon < -5)) { //events without lat/lon set are 0.0, using 5 arbitrarily to make sure a real lat/lon is set, also key must not exist
//                        if (eventLat < 0 && eventLon > 0) {
//                            let temp = eventLat
//                            eventLat = eventLon
//                            eventLon = temp
//                        }
//                    buildingsAlreadyRepresented[event.location!] = true
//                    createAnnotationNode(latitude: eventLat, longitude: eventLon, altitude: (userAltitude! + 15), buildingName: event.location!)
//                    }
//                }
//            }
//        // if ALL event lats are 0, all events are virtual, let the user know, but create one Stetson node
//        for lat in latArray {
//            if lat != 0 || lat != 0.0 {
//                self.noNodes = false
//            }
//        }
//        if self.noNodes {createOneNode()} //if there are no events on campus, just create one node
//        } else {
//            for building in self.eventModelController.buildingModelController.buildingList {
//                createAnnotationNode(latitude: building.buildingLat, longitude: building.buildingLon, altitude: (userAltitude! + 15), buildingName: building.buildingName!)
//            }
//        }
//    }
    
//    func createOneNode() {
//        firstRender = false
//        createAnnotationNode(latitude: 29.0349780, longitude: -81.3026430, altitude: (userAltitude! + 15), buildingName: "Stetson University")
//        if self.noNodes && distanceUsable <= 0.5 && !self.alerted {
//            createAlert(title: "No Events on Campus to Display", message: "Unfortunately, there are no events on campus at the moment. Check back later for updates.")
//            self.alerted = true
//        } else if !self.alerted {
//            createAlert(title: "Too Far from Campus", message: "You're about \(String(describing: distanceUsable)) mile(s) away from campus, to use the interactive AR features you must be within 0.5 miles of campus.")
//            self.alerted = true
//        }
//    }
    
//    func createNavNode() {
//        firstRender = false
//        createAnnotationNode(latitude: Double(event.mainLat)!, longitude: Double(event.mainLon)!, altitude: (userAltitude! + 15), buildingName: event.name!) //for all intensive purposes, just plug in event name for building name
//        determineDistanceFromBuilding(latitude: Double(event.mainLat)!, longitude: Double(event.mainLon)!)
//        if buildingUserDistanceMeters > 54 && buildingUserDistanceMeters < 55 {
//            createAlert(title: "Getting Close!", message: "You're right around the corner from \(event.location!)")
//        } else if buildingUserDistanceMeters > 29 && buildingUserDistanceMeters < 30 {
//            createAlert(title: "Almost There!", message: "The \(event.location!) is probably in sight.")
//        } else if buildingUserDistanceMeters < 16 {
//            createAlert(title: "You've Arrived!", message: "Have fun at \(event.name!)!")
//        }
//    }
    
//    func determineDistanceFromBuilding(latitude: Double, longitude: Double){
//        // logic to change tag opacity based on distance from building
//        // and send alerts to user in navMode
//        if userLocation != nil {
//            buildingUserDistanceMeters = round(10*CLLocation(latitude: latitude, longitude: longitude).distance(from: userLocation))/10
//            //if buildings are more than 200m away & you're touring, don't show (helps declutter view)
//            /*if buildingUserDistance > 200 && mode == "tour" { return UIView(frame: CGRect(x:0, y:0, width:0, height:0)) }*/
//            buildingUserDistanceMiles = round(100 * (buildingUserDistanceMeters/1610)) / 100 //get from meters to miles
//            if buildingUserDistanceMiles < 0.5 { //if you're on campus, scale tag sizes
//                //further (0.5) lighter (0.1)
//                //closer (0.1) darker (1)
//                tagOpacity = Float((1-buildingUserDistanceMiles)*2) //make the tag more transparent, don't change the size
//            }
//        } else {
//        buildingUserDistanceMeters = 0
//        buildingUserDistanceMiles = 0
//        createAlert(title: "Invalid Location", message: "Your location hasn't loaded correctly, so you might experience issues with navigation in AR. Please close the app to try again.")
//        }
//    }

//    func createAnnotationNode(latitude: Double, longitude: Double, altitude: Double, buildingName: String) {
//        var contentView: UIView {
//            //determineDistanceFromBuilding(latitude: latitude, longitude: longitude) //get tag opacity
//            let tagBackground = UIView(frame: CGRect(x:0, y:0, width:Double(tagWidth), height:Double(tagHeight)))
//            tagBackground.layer.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Constants.darkGrayCG : UIColor.white.cgColor
//            tagBackground.layer.opacity = tagOpacity
//            tagBackground.layer.cornerRadius = 15;
//            let tagLabel = UILabel(frame: CGRect(x:0, y:0, width:Double(tagWidth-(tagWidth*0.1)), height:Double(tagHeight-(tagHeight*0.1)))) //subtract tagWidth/Height*0.1 for "padding"
//            tagLabel.text = buildingName
//            tagLabel.textColor = traitCollection.userInterfaceStyle == .dark ? UIColor.white : Constants.medGrayUI
//            tagLabel.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium)
//            //for centering
//            tagLabel.textAlignment = .center
//            tagLabel.center = tagBackground.center
//            //for multi-line
//            tagLabel.numberOfLines = 2
//            tagLabel.adjustsFontSizeToFitWidth = true
//            //add label to background
//            tagBackground.addSubview(tagLabel)
//            return tagBackground
//        }
//        let myBuildingTagNode = LocationAnnotationNode(location: (CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), altitude: altitude)), view: contentView)
//        myBuildingTagNode.annotationNode.name = buildingName
//        // DON'T NECESSARILY NEED TO ASSIGN RANDOM TO NAV NODE
//        let randomY = Double.random(in: 0.5 ... 2.0)
//        myBuildingTagNode.annotationHeightAdjustmentFactor = randomY;
//        // Add node to the scene for rendering
//        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: myBuildingTagNode)
//    }

    // Method called when screen is tapped
    @objc func handleTap(rec: UITapGestureRecognizer){
        if rec.state == .ended {
            let location: CGPoint = rec.location(in: sceneLocationView)
            guard let hits = self.sceneLocationView.hitTest(location, options: nil).first?.node else { return }
            
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()

            if mode == "tour" && self.eventModelController.eventMode {
                if (String(describing: hits.name!)) != "Stetson University" {
                    self.eventModelController.search(weeksToSearch: 1, specificLocation: true, specificLocationIs: (String(describing: hits.name!)), whichSubList: "AR List")
                } else {
                    self.eventModelController.search(weeksToSearch: 4, specificLocation: false, whichSubList: "AR List")
                }
                let eventListByBuilding = UIHostingController(rootView: EventListView(eventModelController: self.eventModelController, listingWhatView: "AR List"))
                present(eventListByBuilding, animated: true)
            }
            if mode == "navigation" && self.eventModelController.eventMode {
                createAlert(title: "\(event.name!)", message: "This event is at \(event.time!) on \(event.date!), and you are \(buildingUserDistanceMeters!)m from \(event.location!).")
            }
            if !self.eventModelController.eventMode { //tour campus mode- give building details
                present(UIHostingController(rootView: TourModeDetailView(eventModelController: self.eventModelController, buildingInstance: self.eventModelController.buildingModelController.buildingDic[String(describing: hits.name!)]!)), animated: true)
            }
        }
    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        defer { userLocation = locations.last }
//        if let lastLocation = locations.last {
//            userAltitude = lastLocation.altitude
//            userLocation = lastLocation
//            //userLocation = CLLocation(latitude: 29.0349780, longitude: -81.3026430) //TESTING PURPOSES ONLY- on campus
//            //userLocation = CLLocation(latitude: 50, longitude: -50) //TESTING PURPOSES ONLY- far away
//            if (userLocation != nil) {
//                let StetsonUniversity = CLLocation(latitude: 29.0349780, longitude: -81.3026430)
//                distance = StetsonUniversity.distance(from: userLocation)
//            }
//        }
//        // Depending on distance user is away from campus, create one or all node(s)
//        prevDistanceUsable = distanceUsable
//        distanceUsable = round(1000 * (distance/1610)) / 1000
//        //Out of Range
//        if distanceUsable > 0.5 {
//            if prevDistanceUsable <= 0.5 && !firstRender { //not the first rander, was in range, now out of range- remove all
//                for annotationNode in self.sceneLocationView.locationNodes {
//                    annotationNode.removeFromParentNode()
//                }
//            }
//            //too far away- create single node or send alert
//            if self.eventModelController.eventMode {
//                createOneNode() //regardless of tour/nav mode, only create one node & send alert
//            } else {
//                createAlert(title: "Too Far from Campus to Tour", message: "Sorry! It looks like you're too far away from campus to tour using AR. Try touring with the map instead!")
//            }
//        //In Range
//        } else if distanceUsable <= 0.5 { //change to in range, populate with all nodes
//            if !firstRender { //not the first render, in range- remove all
//                for annotationNode in self.sceneLocationView.locationNodes {
//                    annotationNode.removeFromParentNode()
//                }
//            }
//            //repopulate scene with nodes
//            if self.eventModelController.eventMode {
//                mode == "tour" ? createAllNodes() : createNavNode() //if in tour mode, create one node... otherwise create nav node
//            } else {
//                createAllNodes()
//            }
//        }
//    }
    
//    override func viewDidLayoutSubviews() {
//      super.viewDidLayoutSubviews()
//      sceneLocationView.frame = view.bounds
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        // Create a session configuration
//        //let configuration = ARWorldTrackingConfiguration()
//        // Run the view's session
//        sceneLocationView.run()
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        // Pause the view's session
//        sceneLocationView.pause()
//    }
//
//    // MARK: - ARSCNViewDelegate
//
//    func session(_ session: ARSession, didFailWithError error: Error) {
//        // Present an error message to the user
//    }
//
//    func sessionWasInterrupted(_ session: ARSession) {
//        // Inform the user that the session has been interrupted, for example, by presenting an overlay
//    }
//
//    func sessionInterruptionEnded(_ session: ARSession) {
//        // Reset tracking and/or remove existing anchors if consistent tracking is required
//    }
}
