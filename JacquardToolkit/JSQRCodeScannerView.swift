//
//  JSQRCodeScannerView.swift
//  JacquardToolkit
//
//  Created by Caleb Rudnicki on 4/3/19.
//

import UIKit
import AVFoundation
import NotificationCenter

class JSQRCodeScannerView: UIView {
    
    private var video = AVCaptureVideoPreviewLayer()
    private var session = AVCaptureSession()
    private let output = AVCaptureMetadataOutput()
    
    private var instructionsViewShouldBeShiftedUp = false
    private var keyboardIsPresent = false
    
    private var trayOriginalCenter: CGPoint!
    private var trayUp: CGPoint!
    private var trayDown: CGPoint!
    
    private let tappableView: UIView = {
        let tappableView = UIView()
        tappableView.backgroundColor = .red
        tappableView.alpha = 0.3
        tappableView.translatesAutoresizingMaskIntoConstraints = false
        return tappableView
    }()
    
    private let scannerTargetView: UIView = {
        let scannerTargetView = UIView()
        scannerTargetView.backgroundColor = .clear
        scannerTargetView.layer.borderColor = UIColor.gray.cgColor
        scannerTargetView.layer.borderWidth = 5
        scannerTargetView.translatesAutoresizingMaskIntoConstraints = false
        return scannerTargetView
    }()
    
    private let instructionsView: JSQRCodeInstructionsView = {
        let instructionsView = JSQRCodeInstructionsView()
        instructionsView.backgroundColor = .white
        instructionsView.layer.cornerRadius = 10
        instructionsView.layer.shadowColor = UIColor.black.cgColor
        instructionsView.layer.shadowOpacity = 0.8
        instructionsView.layer.shadowOffset = .zero
        instructionsView.layer.shadowRadius = 5
        instructionsView.translatesAutoresizingMaskIntoConstraints = false
        return instructionsView
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews([tappableView, scannerTargetView, instructionsView])
        updateConstraints()
        
        if let captureDevice = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                session.addInput(input)
            } catch {
                print("Error")
            }
            
            session.addOutput(output)
            
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            output.metadataObjectTypes = [.qr]
            
            video = AVCaptureVideoPreviewLayer(session: session)
            video.frame = layer.bounds
            video.videoGravity = .resizeAspectFill
            
            
            layer.addSublayer(video)
            layer.insertSublayer(instructionsView.layer, above: video)
            layer.insertSublayer(scannerTargetView.layer, above: video)
            
        }
        
        trayUp = CGPoint(x: frame.midX, y: frame.height * 1.2)
        trayDown = CGPoint(x: frame.midX, y: frame.height * 1.6)
        
        //CR: Just for testing purposes
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappableAreaTapped))
        tappableView.addGestureRecognizer(tapGestureRecognizer)
        
        let panGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(panGestureDragged))
        panGestureRecognizer.delegate = self
        instructionsView.addGestureRecognizer(panGestureRecognizer)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(shiftInstructionsView),
            name: Notification.Name(JSConstants.JSStrings.Notifications.didStartEditingTextField),
            object: nil
        )
    }
    
    override public func updateConstraints() {
        super.updateConstraints()
        
        NSLayoutConstraint.activate([
            tappableView.topAnchor.constraint(equalTo: topAnchor),
            tappableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tappableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tappableView.bottomAnchor.constraint(equalTo: instructionsView.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            scannerTargetView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 64),
            scannerTargetView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
            scannerTargetView.centerXAnchor.constraint(equalTo: centerXAnchor),
            scannerTargetView.heightAnchor.constraint(equalTo: scannerTargetView.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            instructionsView.topAnchor.constraint(equalTo: topAnchor, constant: frame.height * 0.6),
            instructionsView.leadingAnchor.constraint(equalTo: leadingAnchor),
            instructionsView.trailingAnchor.constraint(equalTo: trailingAnchor),
            instructionsView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 2)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func startScanner() {
        session.commitConfiguration()
        session.startRunning()
        
        let rect = CGRect(x: self.center.x - (self.frame.width * 0.5 / 2),
                          y: self.frame.width * 0.5 / 2,
                          width: self.frame.width * 0.5,
                          height: self.frame.width * 0.5)
        output.rectOfInterest = video.metadataOutputRectConverted(fromLayerRect: rect)
    }
    
    public func stopScanner() {
        session.startRunning()
        self.removeFromSuperview()
    }
    
    @objc private func tappableAreaTapped() {
        if keyboardIsPresent {
            instructionsViewShouldBeShiftedUp = !instructionsViewShouldBeShiftedUp
            endEditing(true)
            keyboardIsPresent = false
            UIView.animate(withDuration: 0.35, animations: {
                self.instructionsView.center = self.trayDown
                self.scannerTargetView.alpha = 1
            })
        }
    }
    
    @objc private func panGestureDragged(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: instructionsView)
        switch recognizer.state {
        case .began:
            trayOriginalCenter = instructionsView.center
        case .changed:
            instructionsView.center = CGPoint(x: trayOriginalCenter.x, y: trayOriginalCenter.y + translation.y)
        case .ended:
            let velocity = recognizer.velocity(in: instructionsView)
            if velocity.y > 0 {
                UIView.animate(withDuration: 0.35, animations: {
                    self.endEditing(true)
                    self.scannerTargetView.alpha = 1
                    self.instructionsView.center = self.trayDown
                })
            } else {
                keyboardIsPresent = true
                UIView.animate(withDuration: 0.35, animations: {
                    self.scannerTargetView.alpha = 0
                    self.instructionsView.center = self.trayUp
                })
            }
        default: break
        }
    }
    
    @objc private func shiftInstructionsView(userInfo: Notification) {
        keyboardIsPresent = true
        UIView.animate(withDuration: 0.35, animations: {
            self.instructionsView.center = self.trayUp
            self.scannerTargetView.alpha = 0
        })
    }
    
}

extension JSQRCodeScannerView: AVCaptureMetadataOutputObjectsDelegate {
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput,
                               didOutput metadataObjects: [AVMetadataObject],
                               from connection: AVCaptureConnection) {
        if !instructionsViewShouldBeShiftedUp {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            let scanSuccessfulNotificationName = JSConstants.JSStrings.Notifications.scanSuccessful
            NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: scanSuccessfulNotificationName)))
            session.stopRunning()
            if let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
                if object.type == .qr {
                    JacquardService.shared.updateJacketIDString(jacketIDString: object.stringValue)
                }
            }
        }
    }

}

extension UIView {
    
    func addSubviews(_ views: [UIView]) {
        for view in views {
            self.addSubview(view)
        }
    }
    
}
