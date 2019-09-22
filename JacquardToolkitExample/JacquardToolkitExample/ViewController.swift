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
    
    @IBOutlet weak var connectButton: UIBarButtonItem!
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
    @IBOutlet weak var lastDectedGestureLabel: UILabel!
    @IBOutlet weak var rainbowGlowButton: UIButton!
    @IBOutlet weak var tutorialPickerView: UIPickerView!
    @IBOutlet weak var playTutorialButton: UIButton!
    
    var threadArray: [UIImageView] = []
    let tutorialArray: [String] = ["Double Tap", "Brush In", "Brush Out", "Cover", "Scratch", "Force Touch"]
    var currentlySelectedTutorial = "Brush Out"
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        threadArray = [thread1, thread2, thread3, thread4, thread5, thread6, thread7, thread8, thread9, thread10, thread11, thread12, thread13, thread14, thread15]
        for thread in threadArray {
            thread.frame = CGRect(x: thread.frame.origin.x, y: thread.frame.origin.y, width: thread.frame.width, height: 5)
            thread.alpha = 0.3
        }
        JacquardService.shared.delegate = self
        tutorialPickerView.delegate = self
        tutorialPickerView.selectRow(2, inComponent: 0, animated: true)
    }
    
    @IBAction func connectButtonTapped(_ sender: Any) {
        if !JacquardService.shared.isJacquardConnected() {
            JacquardService.shared.activateBluetooth { _ in
                guard self.navigationController != nil else {
                    JacquardService.shared.connect(viewController: self)
                    return
                }
                JacquardService.shared.connect(viewController: self.navigationController!)
            }
        }
    }
    
    @IBAction func rainbowGlowButtonTapped(_ sender: Any) {
        JacquardService.shared.rainbowGlowJacket()
    }
    
    @IBAction func playTutorialButtonTapped(_ sender: Any) {
        switch currentlySelectedTutorial {
        case "Double Tap":
            JacquardService.shared.playDoubleTapTutorial(viewController: self.navigationController!, showDismissButton: true)
        case "Brush In":
            JacquardService.shared.playBrushInTutorial(viewController: self.navigationController!, showDismissButton: true)
        case "Brush Out":
            JacquardService.shared.playBrushOutTutorial(viewController: self.navigationController!, showDismissButton: true)
        case "Cover":
            JacquardService.shared.playCoverTutorial(viewController: self.navigationController!, showDismissButton: true)
        case "Scratch":
            JacquardService.shared.playScratchTutorial(viewController: self.navigationController!, showDismissButton: true)
        case "Force Touch":
            JacquardService.shared.playForceTouchTutorial(viewController: self.navigationController!, showDismissButton: true)
        default:
            print("Did not select a valid choice")
        }
    }
}

extension ViewController: JacquardServiceDelegate {
    
    func didDetectDoubleTapGesture() {
        lastDectedGestureLabel.text = "Most Recent Gesture: Double Tap"
    }
    
    func didDetectBrushInGesture() {
        lastDectedGestureLabel.text = "Most Recent Gesture: Brush In"
    }
    
    func didDetectBrushOutGesture() {
        lastDectedGestureLabel.text = "Most Recent Gesture: Brush Out"
    }
    
    func didDetectCoverGesture() {
        lastDectedGestureLabel.text = "Most Recent Gesture: Cover"
    }
    
    func didDetectScratchGesture() {
        lastDectedGestureLabel.text = "Most Recent Gesture: Scratch"
    }
    
    func didDetectForceTouchGesture() {
        lastDectedGestureLabel.text = "Most Recent Gesture: Force Touch"
    }
    
    func didDetectThreadTouch(threadArray: [Float]) {
        for (thread, threadValue) in zip(self.threadArray, threadArray) {
            thread.frame = CGRect(x: thread.frame.origin.x, y: thread.frame.origin.y, width: thread.frame.width, height: 15 * CGFloat(threadValue))
        }
    }
    
    func didDetectConnection(isConnected: Bool) {
        connectButton.title = isConnected ? "Connected" : "Connect"
        connectButton.isEnabled = !isConnected
        rainbowGlowButton.isEnabled = isConnected
        playTutorialButton.isEnabled = isConnected
        for thread in threadArray {
            thread.alpha = isConnected ? 1.0 : 0.3
        }
    }
    
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return tutorialArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return tutorialArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row {
        case 0:
            currentlySelectedTutorial = "Double Tap"
        case 1:
            currentlySelectedTutorial = "Brush In"
        case 2:
            currentlySelectedTutorial = "Brush Out"
        case 3:
            currentlySelectedTutorial = "Cover"
        case 4:
            currentlySelectedTutorial = "Scratch"
        case 5:
            currentlySelectedTutorial = "Force Touch"
        default:
            print("Did not select a valid choice")
        }
    }
    
}
