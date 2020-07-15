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
    //@Published var eventModelController:EventModelController!
    
    @Published var eventListRef:DatabaseReference! //references to Firebase Realtime Database
    @Published var eventListOrderRef:DatabaseReference!
    @Published var eventTypeAssociationRef:DatabaseReference!
    @Published var locationAssocationRef:DatabaseReference!
    @Published var connectedRef:DatabaseReference!
    @Published var buildingsRef:DatabaseReference!
    //var eventList:[EventInstance]! = []
    var eventTypeAssociations:Dictionary<String, Any> = [:]
    var locationAssociations:Dictionary<String, Any> = [:]
    var eventTypesList:[String] = []
    var locationList:[String] = []
    
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
//        eventListRef = Database.database().reference(withPath: "Test/eventList"/*"Events/eventList"*/)//"Events/eventList")
//        eventTypeAssociationRef = Database.database().reference(withPath: "EventTypeAssociationsTest")//"EventTypeAssociations")
//        locationAssocationRef = Database.database().reference(withPath: "LocationAssociationsTest")//"LocationAssociations")
//        eventListOrderRef = Database.database().reference(withPath: "eLocsTest")//"EventLocs")
        
        eventListRef = Database.database().reference(withPath: "Events/eventList")//"Events/eventList")
        eventTypeAssociationRef = Database.database().reference(withPath: "EventTypeAssociations")
        locationAssocationRef = Database.database().reference(withPath: "LocationAssociations")
        eventListOrderRef = Database.database().reference(withPath: "EventLocs")
        connectedRef = Database.database().reference(withPath: ".info/connected")
        buildingsRef = Database.database().reference(withPath: "Buildings")
        
        //let storage = Storage.storage()
        
        return true
    }
    
    ///Allows for access to important information from outside the AppDelegate
    static func shared() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    //ADD PUSH NOTIFICATION CONTENT HERE!!!
    
}

