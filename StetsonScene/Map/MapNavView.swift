//
//  MapNavView.swift
//  StetsonScene
//
//  Created by Lannie Hough on 4/17/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import SwiftUI
import MapKit
import UIKit

struct MapNavigationView: UIViewRepresentable {
    
    @ObservedObject var event:EventInstance
    @Binding var checkpoints:[Checkpoint]
  
    var locationManager = CLLocationManager()
    func setupManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
    }
  
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.showsUserLocation = true
        let coordinate = CLLocationCoordinate2D(
            latitude: 29.0350, longitude: -81.3032)
        let span = MKCoordinateSpan(latitudeDelta: 0.013, longitudeDelta: 0.013)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        map.setRegion(region, animated: true)
        return map
  }
  
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.addAnnotations(checkpoints)
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent:MapNavigationView
        init(_ parent: MapNavigationView) {
            self.parent = parent
        }
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let coordinates = view.annotation?.coordinate else { return }
            let span = mapView.region.span
            let region = MKCoordinateRegion(center: coordinates, span: span)
            mapView.setRegion(region, animated: true)
        }
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation.isKind(of: MKUserLocation.self) {
                return nil
            }
            let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
            view.canShowCallout = true
            let infoButton = UIButton(type: .detailDisclosure)
            //view.rightCalloutAccessoryView = infoButton
            view.pinTintColor = Constants.brightYellowUI
            infoButton.addTarget(self, action: #selector(tapped), for: .touchUpInside)
            return view
        }
        @objc func tapped(){
                print("it got here!")
                let generatorLight = UIImpactFeedbackGenerator(style: .medium)
                generatorLight.impactOccurred()
        }
    }
}

struct MapNavView: View {
    @ObservedObject var event:EventInstance
    @State var checkpoints:[Checkpoint]
    var body: some View {
        MapNavigationView(event: event, checkpoints: $checkpoints)
    }
}

final class Checkpoint: NSObject, MKAnnotation {
  let title: String?
  let coordinate: CLLocationCoordinate2D
  
  init(title: String?, coordinate: CLLocationCoordinate2D) {
    self.title = title
    self.coordinate = coordinate
  }
}
