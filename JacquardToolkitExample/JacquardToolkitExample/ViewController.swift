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
    
    @IBOutlet weak var thread1: UIImageView!
    @IBOutlet weak var thread2: UIImageView!
    @IBOutlet weak var thread3: UIImageView!
    @IBOutlet weak var thread4: UIImageView!
    @IBOutlet weak var thread5: UIImageView!
    @IBOutlet weak var thread6: UIImageView!
    @IBOutlet weak var thread7: UIImageView!
    @IBOutlet weak var thread8: UIImageView!
    @IBOutlet weak var thread9: UIImageView!
    @IBOutlet weak var thread10: UIImageView!
    @IBOutlet weak var thread11: UIImageView!
    @IBOutlet weak var thread12: UIImageView!
    @IBOutlet weak var thread13: UIImageView!
    @IBOutlet weak var thread14: UIImageView!
    @IBOutlet weak var thread15: UIImageView!
    
    
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
//        print("Threads: \(threadArray)")
        thread1.alpha = CGFloat(threadArray[0])
        thread2.alpha = CGFloat(threadArray[1])
        thread3.alpha = CGFloat(threadArray[2])
        thread4.alpha = CGFloat(threadArray[3])
        thread5.alpha = CGFloat(threadArray[4])
        thread6.alpha = CGFloat(threadArray[5])
        thread7.alpha = CGFloat(threadArray[6])
        thread8.alpha = CGFloat(threadArray[7])
        thread9.alpha = CGFloat(threadArray[8])
        thread10.alpha = CGFloat(threadArray[9])
        thread11.alpha = CGFloat(threadArray[10])
        thread12.alpha = CGFloat(threadArray[11])
        thread13.alpha = CGFloat(threadArray[12])
        thread14.alpha = CGFloat(threadArray[13])
        thread15.alpha = CGFloat(threadArray[14])
    }
    
    func didDetectForceTouchGesture() {
        print("didDetectForceTouchGesture")
        lastGestureLabel.text = "Force Touch"
    }
}
