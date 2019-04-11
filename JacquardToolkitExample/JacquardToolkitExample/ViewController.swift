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
    
    @IBOutlet weak var connectionIndicator: UIImageView!
    @IBOutlet weak var lastGestureLabel: UILabel!
    
    @IBOutlet var threads:[UIImageView]!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        JacquardService.shared.delegate = self
    }
    
    @IBAction func connectButtonTapped(_ sender: Any) {
        JacquardService.shared.activateBlutooth { _ in
            JacquardService.shared.connect(viewController: self)
        }
    }
    
    @IBAction func glowButtonTapped(_ sender: Any) {
        JacquardService.shared.rainbowGlowJacket()
    }
    
}

extension ViewController: JacquardServiceDelegate {
    
    func didDetectConnection(isConnected: Bool) {
        if isConnected {
            connectionIndicator.image = UIImage(named: "GreenCircle")
        } else {
            connectionIndicator.image = UIImage(named: "RedCircle")
        }
    }
    
    func didDetectDoubleTapGesture() {
        print("didDetectDoubleTapGesture")
        lastGestureLabel.text = "Double Tap"
    }
    
    func didDetectBrushInGesture() {
        print("didDetectBrushInGesture")
        lastGestureLabel.text = "Brush In"
    }
    
    func didDetectBrushOutGesture() {
        print("didDetectBrushOutGesture")
        lastGestureLabel.text = "Brush Out"
    }
    
    func didDetectCoverGesture() {
        print("didDetectCoverGesture")
        lastGestureLabel.text = "Cover"
    }
    
    func didDetectScratchGesture() {
        print("didDetectScratchGesture")
        lastGestureLabel.text = "Scratch"
    }
    
    func didDetectThreadTouch(threadArray: [Float]) {
        for (index, thread) in threads.enumerated() {
            thread.alpha = CGFloat(max(0.05, threadArray[index]))
        }
    }
    
    func didDetectForceTouchGesture() {
        print("didDetectForceTouchGesture")
        lastGestureLabel.text = "Force Touch"
    }
}
