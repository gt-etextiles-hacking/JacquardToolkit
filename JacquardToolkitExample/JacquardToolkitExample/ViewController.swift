//
//  ViewController.swift
//  JacquardToolkitExample
//
//  Created by Caleb Rudnicki on 11/27/18.
//  Copyright © 2018 Caleb Rudnicki. All rights reserved.
//

import UIKit
import JacquardToolkit

class ViewController: UIViewController, JacquardServiceDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        JacquardService.shared.delegate = self
        JacquardService.shared.activateBlutooth()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            JacquardService.shared.connectToJacket(uuidString: "3DF4C660-AAE3-FC91-DBE5-0217FCDE7894")
        }
    }
    
    @IBAction func glowButtonTapped(_ sender: Any) {
        JacquardService.shared.rainbowGlowJacket()
    }

    func gestureDetected(gestureString: String) {
        print("The gesture that was detected was \(gestureString)")
    }

}



