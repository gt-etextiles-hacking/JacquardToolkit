//
//  JSQRCodeScannerView.swift
//  Pods
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
    private var keyboardIsPresent = false
    private var qrCodeRecognized = false
    private var keyboardFrame: CGFloat!
    
    private let tappableView: UIView = {
        let tappableView = UIView()
        tappableView.alpha = 1
        tappableView.translatesAutoresizingMaskIntoConstraints = false
        return tappableView
    }()
    
    private let scannerTargetView: UIView = {
        let scannerTargetView = UIView()
        scannerTargetView.backgroundColor = .clear
        scannerTargetView.layer.borderColor = UIColor.jsLightGrey.cgColor
        scannerTargetView.layer.borderWidth = 5
        scannerTargetView.translatesAutoresizingMaskIntoConstraints = false
        return scannerTargetView
    }()
    
    private let instructionsView: JSQRCodeInstructionsView = {
        let instructionsView = JSQRCodeInstructionsView()
        instructionsView.backgroundColor = .jsLightGrey
        instructionsView.layer.cornerRadius = 10
        instructionsView.layer.shadowColor = UIColor.black.cgColor
        instructionsView.layer.shadowOpacity = 0.8
        instructionsView.layer.shadowOffset = .zero
        instructionsView.layer.shadowRadius = 5
        instructionsView.alpha = 0.99
        instructionsView.translatesAutoresizingMaskIntoConstraints = false
        return instructionsView
    }()
    
    // MARK: Initializers
    
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
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappableAreaTapped))
        tappableView.addGestureRecognizer(tapGestureRecognizer)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(recivedKeyboardJacketID),
            name: Notification.Name(JSConstants.JSStrings.Notifications.scanSuccessfulKeyboard),
            object: nil
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Constraints
    
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
            instructionsView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1)
            ])
    }
    
    // MARK: Public Functions
    
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
    
    // MARK: Keyboard Functions
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue
            else { return }
        
        let keyboardFrame = keyboardSize.cgRectValue
        keyboardIsPresent = true
        UIView.animate(withDuration: 0.1, animations: {
            self.instructionsView.frame.origin.y -= keyboardFrame.height
            self.scannerTargetView.alpha = 0
        })
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue
            else { return }
        
        let keyboardFrame = keyboardSize.cgRectValue
        keyboardIsPresent = false
        UIView.animate(withDuration: 0.1, animations: {
            self.instructionsView.frame.origin.y += keyboardFrame.height
            self.scannerTargetView.alpha = 1
        })
    }
    
    @objc private func tappableAreaTapped() {
        if keyboardIsPresent && !qrCodeRecognized {
            endEditing(true)
            keyboardIsPresent = false
        }
    }
    
    @objc private func recivedKeyboardJacketID(notification: Notification) {
        if let jacketID = notification.userInfo?["JacketID"] as? String {
            JacquardService.shared.updateJacketIDString(jacketIDString: jacketID)
        }
    }
    
}

extension JSQRCodeScannerView: AVCaptureMetadataOutputObjectsDelegate {
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput,
                               didOutput metadataObjects: [AVMetadataObject],
                               from connection: AVCaptureConnection) {
        if !keyboardIsPresent {
            qrCodeRecognized = true
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            scannerTargetView.layer.borderColor = UIColor.green.cgColor
            NotificationCenter.default.post(
                name: NSNotification.Name(rawValue: JSConstants.JSStrings.Notifications.scanSuccessfulScanner),
                object: nil,
                userInfo: nil
            )
            session.stopRunning()
            if let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                let qrCodeString = object.stringValue {
                if object.type == .qr {
                    NotificationCenter.default.post(
                        name:  NSNotification.Name(rawValue: JSConstants.JSStrings.Notifications.scanSuccessfulKeyboard),
                        object: nil,
                        userInfo: [JSConstants.JSStrings.Notifications.jacketID: qrCodeString]
                    )
                }
            }
        }
    }
    
}

extension UIColor {
    
    static let jsLightGrey = UIColor(red: 248/255, green: 247/255, blue: 243/255, alpha: 1)
    static let jsDarkGrey = UIColor(red: 231/255, green: 220/255, blue: 236/255, alpha: 1)
    
}

extension UIView {
    
    func addSubviews(_ views: [UIView]) {
        for view in views {
            self.addSubview(view)
        }
    }
    
}

