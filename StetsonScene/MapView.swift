//
//  MapView.swift
//  StetsonScene
//
//  Created by Madison Gipson on 7/19/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation
import SwiftUI
import MapKit

struct MapView: View {
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

    var body: some View {
        ZStack {
            MapViewUI().edgesIgnoringSafeArea(.vertical)
            VStack {
                RoundedRectangle(cornerRadius: 20).frame(width: Constants.width*0.35, height: 7).foregroundColor(Color.secondaryLabel.opacity(0.6)).padding(.top, 20)
                Spacer()
                Spacer()
            }
        }
    }
}

struct MapViewUI: UIViewRepresentable {
    
    var locationManager = CLLocationManager()
    func setupManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
    }
    
    func makeUIView(context: Context) -> MKMapView {
        setupManager()
        let mapView = MKMapView(frame: UIScreen.main.bounds)
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
    }
}
