//
//  ViewController.swift
//  JacquardToolkitExample
//
//  Created by Caleb Rudnicki on 11/27/18.
//  Copyright © 2018 Caleb Rudnicki. All rights reserved.
//

import UIKit
import MessageUI
import JacquardToolkit

class ViewController: UIViewController {
    // UI Outlets
    @IBOutlet weak var connectionIndicator: UIImageView!
    @IBOutlet weak var lastGestureLabel: UILabel!
    @IBOutlet weak var loggingButton: UIButton!
    @IBOutlet weak var rainbowGlowButton: UIButton!
    @IBOutlet var threads:[UIImageView]!
    
    // CSV Logging Constants
    private let fileName = "data.csv"
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        JacquardService.shared.delegate = self
        for thread in threads {
            thread.alpha = CGFloat(0.05)
        }
        updateUI(isConnected: false)
    }
    
    public func updateUI(isConnected: Bool) {
        connectionIndicator.image = UIImage(named: isConnected ? "GreenCircle" : "RedCircle")
        rainbowGlowButton.isEnabled = isConnected
        rainbowGlowButton.alpha = CGFloat(isConnected ? 1 : 0.4)
        loggingButton.isEnabled = isConnected
        loggingButton.alpha = CGFloat(isConnected ? 1 : 0.7)
    }
    
    @IBAction func connectButtonTapped(_ sender: Any) {
        JacquardService.shared.activateBlutooth { _ in
            JacquardService.shared.connect(viewController: self)
        }
    }
    
    @IBAction func glowButtonTapped(_ sender: Any) {
        JacquardService.shared.rainbowGlowJacket()
    }
    
    @IBAction func loggingButtonToggled(_ sender: Any) {
        if JacquardService.shared.loggingThreads {
            let csvText = JacquardService.shared.exportLog()
            let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
            
            do {
                try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
                self.sendMail(dataURL: path!)
            } catch {
                print("Failed to create/send csv file: \(error)")
            }
        }
        loggingButton.setTitle(JacquardService.shared.loggingThreads ? "Start Logging" : "Stop Logging", for: UIControl.State.normal)
        JacquardService.shared.loggingThreads = !JacquardService.shared.loggingThreads
    }
}

extension ViewController: JacquardServiceDelegate {
    
    func didDetectConnection(isConnected: Bool) {
        self.updateUI(isConnected: isConnected)
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

// Extension class for emailing log files
extension ViewController: MFMailComposeViewControllerDelegate {
    
    func sendMail(dataURL: URL) {
        if( MFMailComposeViewController.canSendMail()) {
            // attach logged csv data to email and display compose pop-up
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self
            mailComposerVC.setSubject("Thread Pressure Readings: \(NSDate().description)")
            do {
                try mailComposerVC.addAttachmentData(NSData(contentsOf: dataURL, options: NSData.ReadingOptions.mappedRead) as Data, mimeType: "text/csv", fileName: fileName)
            } catch {
                print("Couldn't Attach \(fileName)")
            }
            self.present(mailComposerVC, animated: true, completion: nil)
        } else {
            // email failed to send
            let sendMailErrorAlert = UIAlertController(title: "Could not send email", message: "Your device could not send email", preferredStyle: .alert)
            let dismiss = UIAlertAction(title: "Ok", style: .default, handler: nil)
            sendMailErrorAlert.addAction(dismiss)
            self.present(sendMailErrorAlert, animated: true, completion: nil)
        }
    }
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
