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
            JacquardService.shared.connectToJacket(uuidString: "15488896-8AC0-691D-3535-A8E29774CC7A")
//            JacquardService.shared.searchForJacket()
        }
    }
    
    @IBAction func glowButtonTapped(_ sender: Any) {
        JacquardService.shared.rainbowGlowJacket()
    }
    
}

extension ViewController: JacquardServiceDelegate {
    
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
    
    func didDetectThreadTouch(threadArray: [Float]) {
        print("Threads: \(threadArray)")
    }
    
}
