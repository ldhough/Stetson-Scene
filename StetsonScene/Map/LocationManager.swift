//
//  LocationManager.swift
//  FirstMap
//
//  Created by Aaron Stewart on 1/29/20.
//  Copyright © 2020 Aaron Stewart. All rights reserved.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        //mapView.showsUserLocation = true
    }
    
    @Published var locationStatus: CLAuthorizationStatus? {
        willSet {
            objectWillChange.send()
        }
    }
    
    @Published var lastLocation: CLLocation? {
        willSet {
            objectWillChange.send()
        }
    }
    
    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }
        
        switch status {
        case .notDetermined: return "notDetermined"
        case .authorizedAlways: return "authorizedAlways"
        case .authorizedWhenInUse: return "authorizedWhileInUse"
        case .restricted: return "restricted"
        case .denied: return "denied"
        default: return "unknown"
        }
    }
    
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    private let locationManager = CLLocationManager()
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.locationStatus = status
        print(#function, statusString)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.lastLocation = location
        print(#function, location)
    }
    
}

