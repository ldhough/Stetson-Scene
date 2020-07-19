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

// MARK: - ARViewIndicator (ties together AR UIKit & app SwiftUI)

struct ARViewIndicator: UIViewControllerRepresentable {
    typealias UIViewControllerType = ARView
    
    func makeUIViewController(context: Context) -> ARView {
        return ARView()
    }
    func updateUIViewController(_ uiViewController: ARViewIndicator.UIViewControllerType, context: UIViewControllerRepresentableContext<ARViewIndicator>) { }
}

// MARK: - ARCameraView

class ARView: UIViewController, ARSCNViewDelegate {
    
    //Initialization
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //create ARSCNView & load it, set up some config variables
    var arView: ARSCNView {
        return self.view as! ARSCNView
    }
    
    override func loadView() {
        self.view = ARSCNView(frame: .zero)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arView.isUserInteractionEnabled = true
        arView.delegate = self
        arView.scene = SCNScene()
        arView.showsStatistics = false
    }
    
    // MARK: - Functions for standard AR view handling
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        arView.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) { //setUpSceneView
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.worldAlignment = .gravityAndHeading
        arView.session.run(configuration)
        arView.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    func sessionWasInterrupted(_ session: ARSession) {} // Inform the user that the session has been interrupted, for example, by presenting an overlay
    
    func sessionInterruptionEnded(_ session: ARSession) {} // Reset tracking and/or remove existing anchors if consistent tracking is required
    
    func session(_ session: ARSession, didFailWithError error: Error) {} // Present an error message to the user
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {}
}
