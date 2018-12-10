//
//  ViewController.swift
//  JacquardToolkitExample
//
//  Created by Caleb Rudnicki on 11/27/18.
//  Copyright © 2018 Caleb Rudnicki. All rights reserved.
//

import UIKit
import JacquardToolkit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        JacquardService.shared.delegate = self
        JacquardService.shared.activateBlutooth { _ in 
//            JacquardService.shared.connectToJacket(uuidString: "3DF4C660-AAE3-FC91-DBE5-0217FCDE7894")
            JacquardService.shared.searchForJacket()
        }
    }
    
    @IBAction func glowButtonTapped(_ sender: Any) {
        JacquardService.shared.rainbowGlowJacket()
    }

}

extension ViewController: JacquardServiceDelegate {
    
    func updatedNearbyJacketsList(localJacketsUUIDList: [String]) {
        for jacketUUID in localJacketsUUIDList {
            print(jacketUUID)
        }
    }
    
    func didDetectDoubleTapGesture() {
        print("didDetectDoubleTapGesture")
    }
    
    func didDetectBrushInGesture() {
        print("didDetectBrushInGesture")
    }
    
    func didDetectBrushOutGesture() {
        print("didDetectBrushOutGesture")
    }
    
    func didDetectCoverGesture() {
        print("didDetectCoverGesture")
    }
    
    func didDetectScratchGesture() {
        print("didDetectScratchGesture")
    }
    
}
