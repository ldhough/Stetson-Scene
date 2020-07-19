////
////  LocationManager.swift
////  FirstMap
////
////  Created by Aaron Stewart on 1/29/20.
////  Copyright © 2020 Aaron Stewart. All rights reserved.
////
//import SwiftUI
//import MapKit
//import UIKit
//
//
//class LandmarkAnnotation: NSObject, MKAnnotation {
//    let id: String
//    let title: String?
//    let coordinate: CLLocationCoordinate2D
//    let info: String
//    //let button:UIButton
//    init(landmark: Landmark) {
//        self.id = landmark.id
//        self.title = landmark.name
//        self.coordinate = landmark.location
//        self.info = landmark.description
//        //self.button = UIButton()
//        print(info)
//    }
//}
//
//struct MapView: UIViewRepresentable {
//    @ObservedObject var eventModelController:EventModelController
//    /*@Binding */var landmarks: [Landmark]
//    @Binding var selectedLandmark: Landmark?
//    
//    func makeUIView(context: Context) -> MKMapView {
//        let map = MKMapView()
//        map.delegate = context.coordinator
//        return map
//    }
//    
//    func updateUIView(_ uiView: MKMapView, context: Context) {
//        let locationManager = CLLocationManager()
//        uiView.showsUserLocation = true
//        
//        locationManager.requestAlwaysAuthorization()
//        
//        locationManager.requestWhenInUseAuthorization()
//        
//        if CLLocationManager.locationServicesEnabled() {
//            locationManager.desiredAccuracy = kCLLocationAccuracyBest
//            locationManager.startUpdatingLocation()
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
//                let coordinate = CLLocationCoordinate2D(
//                    latitude: 29.0350, longitude: -81.3032)
//                let span = MKCoordinateSpan(latitudeDelta: 0.013, longitudeDelta: 0.013)
//                let region = MKCoordinateRegion(center: coordinate, span: span)
//                uiView.setRegion(region, animated: true)
//            })
//        }
//        
//        updateAnnotations(from: uiView)
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self, eventModelController: self.eventModelController)
//    }
//    
//    private func updateAnnotations(from mapView: MKMapView) {
//        mapView.removeAnnotations(mapView.annotations)
//        let newAnnotations = landmarks.map { LandmarkAnnotation(landmark: $0) }
//        mapView.addAnnotations(newAnnotations)
//        if let selectedAnnotation = newAnnotations.filter({ $0.id == selectedLandmark?.id }).first {
//            mapView.selectAnnotation(selectedAnnotation, animated: true)
//        }
//    }
//    
//    final class Coordinator: NSObject, MKMapViewDelegate {
//        var parent:MapView
//        var eventModelController:EventModelController
//        
//        init(_ parent: MapView, eventModelController: EventModelController) {
//            self.parent = parent
//            self.eventModelController = eventModelController
//        }
//        
//        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//            guard let coordinates = view.annotation?.coordinate else { return }
//            let span = mapView.region.span
//            let region = MKCoordinateRegion(center: coordinates, span: span)
//            mapView.setRegion(region, animated: true)
//        }
//
//        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//            if annotation.isKind(of: MKUserLocation.self) {
//                return nil
//            }
//            let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
//            view.canShowCallout = true
//            let infoButton = UIButton(type: .detailDisclosure)
//            view.rightCalloutAccessoryView = infoButton
//            view.pinTintColor = Constants.brightYellowUI
//            infoButton.addTarget(self, action: #selector(tapped), for: .touchUpInside)
//            return view
//        }
//        @objc func tapped() {UIImpactFeedbackGenerator(style: .medium).impactOccurred()}
//        
//        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
//                     calloutAccessoryControlTapped control: UIControl) {
//            let window = UIApplication.shared.windows.first
//            if self.eventModelController.eventMode {
//                let toSearch = view.annotation?.title!!
//                self.eventModelController.search(weeksToSearch: 1, specificLocation: true, specificLocationIs: toSearch!, whichSubList: "Map List")
//                window?.rootViewController?.present(UIHostingController(rootView: EventListView(eventModelController: self.eventModelController, listingWhatView: "Map List")), animated: true)
//            } else {
//                let toPresent = view.annotation?.title!!
////                if self.eventModelController.buildingModelController.buildingDic[toPresent!]!.hasImg {
////                    self.eventModelController.buildingModelController.loadImgFromGoogleStorage(childStr: self.eventModelController.buildingModelController.buildingDic[toPresent!]!.photoInfo)
////                }
//                window?.rootViewController?.present(UIHostingController(rootView: TourModeDetailView(eventModelController: self.eventModelController, buildingInstance: self.eventModelController.buildingModelController.buildingDic[toPresent!]!)), animated: true)
//            }
//        }
//        
//    }
//    
//}
