//
//  AppDelegate.swift
//  StetsonScene
//
//  Created by Lannie Hough on 1/1/20.
//  Copyright © 2020 Lannie Hough. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SwiftUI
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ObservableObject {
    
    var eventListRef:DatabaseReference! //references to Firebase Realtime Database
    var eventListOrderRef:DatabaseReference!
    var eventTypeAssociationRef:DatabaseReference!
    var locationAssocationRef:DatabaseReference!
    var connectedRef:DatabaseReference!
    var buildingsRef:DatabaseReference!
    
    lazy var persistentContainer:NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PersistentData")
        container.loadPersistentStores{ description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    ///Function used in Core Data to keep persistent data
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("error in saving persistent changes")
            }
        }
    }
    
    ///First function called on app launch.  Establishes interaction with Firebase Database & extracts import information for the app to run.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //Firebase & Firebase Realtime Database inititiation
        FirebaseApp.configure()
        
        //References to relevant data on the Firebase Database are established
                eventListRef = Database.database().reference(withPath: "Test/eventList")
                eventTypeAssociationRef = Database.database().reference(withPath: "EventTypeAssociationsTest")
                locationAssocationRef = Database.database().reference(withPath: "LocationAssociationsTest")
                eventListOrderRef = Database.database().reference(withPath: "eLocsTest")
                connectedRef = Database.database().reference(withPath: ".info/connected")
                buildingsRef = Database.database().reference(withPath: "Buildings")
        
//        eventListRef = Database.database().reference(withPath: "Events/eventList")
//        eventTypeAssociationRef = Database.database().reference(withPath: "EventTypeAssociations")
//        locationAssocationRef = Database.database().reference(withPath: "LocationAssociations")
//        eventListOrderRef = Database.database().reference(withPath: "EventLocs")
//        connectedRef = Database.database().reference(withPath: ".info/connected")
//        buildingsRef = Database.database().reference(withPath: "Buildings")
        
        return true
    }
    
    ///Allows for access to important information from outside the AppDelegate
    static func shared() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    //ADD PUSH NOTIFICATION CONTENT HERE!!!
    
}

