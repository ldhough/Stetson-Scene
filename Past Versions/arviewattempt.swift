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
    
    func makeUIViewController(context: Context) -> ARView {
        return ARView(config: self.config)
    }
    func updateUIViewController(_ uiViewController: ARViewIndicator.UIViewControllerType, context: UIViewControllerRepresentableContext<ARViewIndicator>) { }
}

// MARK: - ARCameraView

class ARView: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate {
    var config: Configuration
    let locationManager = CLLocationManager()
    var userLocation: CLLocation!
    var userAltitude = Double?(10)
    var sceneLocationView = SceneLocationView()
    var firstRender: Bool = true
    
    //Initialization
    init(config: Configuration) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isUserInteractionEnabled = true
        //        arView.delegate = self
        //        arView.scene = SCNScene()
        //        arView.showsStatistics = false
        // Location Manager
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization() // For use in foreground
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = 5.0 // location manager updates location every time it's a difference of 5m
            locationManager.startUpdatingLocation()
        }
        if firstRender {
            determineNodes()
            firstRender = false
        }
        //Create TapGesture Recognizer & add recognizer to sceneview
        //        let tap = UITapGestureRecognizer(target: self, action: /*mode == "navigation" ? nil : */#selector(handleTap(rec:)))
        //        sceneLocationView.addGestureRecognizer(tap)
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
            //userLocation = CLLocation(latitude: 29.0349780, longitude: -81.3026430) //TESTING PURPOSES ONLY- on campus
            //userLocation = CLLocation(latitude: 50, longitude: -50) //TESTING PURPOSES ONLY- far away
            if (userLocation != nil) {
                let StetsonUniversity = CLLocation(latitude: 29.0349780, longitude: -81.3026430)
                //distance = StetsonUniversity.distance(from: userLocation)
            }
        }
        for annotationNode in self.sceneLocationView.locationNodes {
            annotationNode.removeFromParentNode()
        }
        determineNodes()
        
        // Depending on distance user is away from campus, create one or all node(s)
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
    }
    
    //MARK:
    func determineNodes() {
        var allVirtual: Bool = true
        var locationsWithNode: [String] = []
        //firstRender = false
        
        print("determineNodes evoked")
        if config.appMode == "Events" {
            //TESTING
            for event in config.eventViewModel.eventList {
                if !event.isVirtual {
                    createBuildingNode(event: event, altitude: 25)
                    return
                }
            }
            return
            //if you're navigating to a single event, create just one node for it
            if config.arMode == "Navigate" {
                //                createAnnotationNode(latitude: Double(event.mainLat)!, longitude: Double(event.mainLon)!, altitude: (userAltitude! + 15), buildingName: event.name!) //for all intensive purposes, just plug in event name for building name
                //                determineDistanceFromBuilding(latitude: Double(event.mainLat)!, longitude: Double(event.mainLon)!)
                //                if buildingUserDistanceMeters > 54 && buildingUserDistanceMeters < 55 {
                //                    createAlert(title: "Getting Close!", message: "You're right around the corner from \(event.location!)")
                //                } else if buildingUserDistanceMeters > 29 && buildingUserDistanceMeters < 30 {
                //                    createAlert(title: "Almost There!", message: "The \(event.location!) is probably in sight.")
                //                } else if buildingUserDistanceMeters < 16 {
                //                    createAlert(title: "You've Arrived!", message: "Have fun at \(event.name!)!")
                //                }
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
                        //createBuildingNode(event: event, altitude: (userAltitude! + 15))
                        ("creating nodes!")
                        createBuildingNode(event: event, altitude: 25)
                    }
                }
            }
            
            //if all events are virtual, create a single Stetson node and send an alert
            if allVirtual {
                //createBuildingNode(latitude: 29.0349780, longitude: -81.3026430, altitude: (userAltitude! + 15), buildingName: "Stetson University")
                //TODO: SEND ALERT
                //                if self.noNodes && distanceUsable <= 0.5 && !self.alerted {
                //                    createAlert(title: "No Events on Campus to Display", message: "Unfortunately, there are no events on campus at the moment. Check back later for updates.")
                //                    self.alerted = true
                //                } else if !self.alerted {
                //                    createAlert(title: "Too Far from Campus", message: "You're about \(String(describing: distanceUsable)) mile(s) away from campus, to use the interactive AR features you must be within 0.5 miles of campus.")
                //                    self.alerted = true
                //                }
            }
        } else if config.appMode == "Tour" {
            //TODO: create all building nodes
            //for building in buildinglist {
            //createAnnotationNode(latitude: event.mainLat, longitude: event.mainLon, altitude: (userAltitude! + 15), buildingName: event.location!)
            //}
        }
    }
    
    func createBuildingNode(event: EventInstance, altitude: Double) {
        let width:CGFloat = 50
        let height:CGFloat = 10
        
        var uiview: UIView {
            let uiview = UIView(frame: CGRect(x:0, y:0, width:Double(width*1.1), height:Double(height*1.5)))
            
            //create the tag shape
            let rect = CGRect(x: 0, y: 0, width: width, height: height)
            let tag = UIBezierPath(roundedRect: rect, cornerRadius: 15)
            tag.move(to: CGPoint(x: rect.midX, y: rect.maxY+(height/3)))
            tag.addLine(to: CGPoint(x: rect.midX-(width/12), y: rect.maxY))//left
            tag.addLine(to: CGPoint(x: rect.midX+(width/12), y: rect.maxY))//right
            tag.addLine(to: CGPoint(x: rect.midX, y: rect.maxY+(height/3)))//bottom
            //width/10, height/3
            
            let layer = CAShapeLayer()
            layer.path = tag.cgPath
            layer.fillColor = UIColor.systemBackground.cgColor
            
            //add text
            let text = CATextLayer()
            text.frame = CGRect(x: 0, y: 0, width: width, height: height)
            //text.fontSize = 12
            text.alignmentMode = .center
            text.string = event.location
            text.isWrapped = true
            text.truncationMode = .end
            //text.backgroundColor = UIColor.white.cgColor
            text.foregroundColor = UIColor.label.cgColor
            
            layer.addSublayer(text)
            uiview.layer.addSublayer(layer)
            return uiview
        }
        
        let parent = UIViewController()
        let child = UIHostingController(rootView: Pin(label: event.location, width: width, height: height)) //no width and height set on pin
        child.view.translatesAutoresizingMaskIntoConstraints = false
        child.view.frame = CGRect(x:0, y:0, width:Double(width*1.5), height:Double(height*1.5))
        // add the view of the child to the view of the parent then add child to parent
        parent.view.addSubview(child.view)
        parent.addChild(child)
        
        let testLocation = CLLocationCoordinate2D(latitude: 25, longitude: -78) //TESTING PURPOSES ONLY- on campus
        let myBuildingTagNode = LocationAnnotationNode(location: (CLLocation(coordinate: testLocation, altitude: altitude)), view: uiview)
        
        //let myBuildingTagNode = LocationAnnotationNode(location: (CLLocation(coordinate: CLLocationCoordinate2D(latitude: event.mainLat, longitude: event.mainLon), altitude: altitude)), view: parent.view)
        myBuildingTagNode.annotationNode.name = event.location
        // DON'T NECESSARILY NEED TO ASSIGN RANDOM TO NAV NODE
        //let randomY = Double.random(in: 0.5 ... 2.0)
        //myBuildingTagNode.annotationHeightAdjustmentFactor = randomY;
        // Add node to the scene for rendering
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: myBuildingTagNode)
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


struct Pin: View {
    var label: String
    var width: CGFloat
    var height: CGFloat
    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 15).foregroundColor(Color.accentColor)//.frame(width: width, height: height)
            Triangle().foregroundColor(Color.accentColor)//.frame(width: width/10, height: height/3)
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}

