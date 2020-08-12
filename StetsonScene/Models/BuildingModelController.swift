//
//  BuildingModelController.swift
//  StetsonScene
//
//  Created by Lannie Hough on 5/11/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import SwiftUI
import Combine

class BuildingModelController: ObservableObject {
    @Published var buildingList:[BuildingInstance]!
    @Published var buildingDic:Dictionary<String, BuildingInstance>!
    @Published var image = Image(systemName: "circle.fill") //placeholder init
    @Published var imgLoaded:Bool = false
    
    func retrieveFirebaseDataBuildings() {
        self.buildingList = []
        self.buildingDic = [:]
        AppDelegate.shared().buildingsRef.observe(.value, with: { snapshot in
            let buildingsDic = snapshot.value as? Dictionary<String, Dictionary<String, Any>>
            for (_, value) in buildingsDic! {
                let newInstance = BuildingInstance()
                for (k, v) in value {
                    switch k {
                    case "buildingName":
                        newInstance.buildingName = (v as? String) ?? "Default building name"
                    case "buildingLat":
                        newInstance.buildingLat = (v as? Double) ?? 0
                    case "buildingLon":
                        newInstance.buildingLon = (v as? Double) ?? 0
                    case "buildingSummary":
                        newInstance.buildingSummary = (v as? String) ?? "Default building summary"
                    case "builtDate":
                        newInstance.builtDate = (v as? String) ?? "03/14/2000"
                    case "hasImg":
                        newInstance.hasImg = (v as? Bool) ?? false
                    case "photoInfo":
                        newInstance.photoInfo = (v as? String) ?? ""
                    case "funFacts":
                        for f in v as? [String] ?? ["Default string"] {
                            newInstance.funFacts.append(f)
                        }
                    default:
                        break;
                    }
                }
                self.buildingList.append(newInstance)
                self.buildingDic[newInstance.buildingName] = newInstance
            }
        })
    }
    
    func storeImg(image: UIImage, forKey key: String) {
        if let pngRep = image.pngData() {
            UserDefaults.standard.set(pngRep, forKey: key)
        }
    }
    
    func retrieveImg(forKey key: String) -> UIImage? {
        if let imageData = UserDefaults.standard.object(forKey: key) as? Data,
            let image = UIImage(data: imageData) {
                return image
            }
        return UIImage()
    }
    
    func isKeyInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }

}

let placeholder:UIImage = UIImage()//UIImage(named: "App-Icon.png")!

struct FirebaseImage: View {
    @ObservedObject var evm:EventViewModel

    init(id: String, evm: EventViewModel) {
        self.imageLoader = Loader(id, evm: evm)
        self.evm = evm
    }

    @ObservedObject private var imageLoader:Loader

    var image: UIImage? {
        imageLoader.data.flatMap(UIImage.init)
    }

    var body: some View {
        Image(uiImage: image ?? placeholder).resizable().aspectRatio(contentMode: .fit)

    }
}

final class Loader: ObservableObject {
    var evm:EventViewModel
    let didChange = PassthroughSubject<Data?, Never>()
    @Published var data:Data? = nil
//    var data: Data? = nil {
//        didSet { didChange.send(data) }
//    }

    init(_ id: String, evm: EventViewModel) {
        self.evm = evm
        self.evm.buildingModelController.imgLoaded = false
        // the path to the image
        let url = id + ".png"//"images/\(id)"
        let storage = Storage.storage()
        let ref = storage.reference().child(url)
        ref.getData(maxSize: 25 * 1024 * 1024) { data, error in
            if let error = error {
                print("\(error)")
                print("THERE WAS AN ERROR * * * * *")
            }

            DispatchQueue.main.async {
                self.data = data
                print("LOADED IMAGE * * * * *")
                if !self.evm.buildingModelController.isKeyInUserDefaults(key: id) {
                    self.evm.buildingModelController.storeImg(image: UIImage(data: data!)!, forKey: id)
                }
                self.evm.buildingModelController.imgLoaded = true
            }
        }
    }
}
