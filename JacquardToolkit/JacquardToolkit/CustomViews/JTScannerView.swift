//
//  JTScannerView.swift
//  JacquardToolkit
//
//  Created by Caleb Rudnicki on 9/18/19.
//

import UIKit
import AVFoundation
import NotificationCenter

internal class JTScannerView: UIView {
    
    struct Constants {
        static let trayTitleInitial = "Scan QR Code"
        static let trayTitleSecondary = "Pop Tag In"
        static let trayTextFieldPlaceholder = "Jacket ID"
        static let trayButtonTitle = "Connect"
    }

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
        scannerTargetView.layer.borderColor = UIColor.jtLightGrey.cgColor
        scannerTargetView.layer.borderWidth = 5
        scannerTargetView.translatesAutoresizingMaskIntoConstraints = false
        return scannerTargetView
    }()
    
    private let tray = JTTray(frame: CGRect.zero,
                              title: Constants.trayTitleInitial,
                              textFieldPlaceholder: Constants.trayTextFieldPlaceholder,
                              buttonTitle: Constants.trayButtonTitle)
    
    // MARK: Initializers
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        tray.jtTrayDelegate = self
        
        addSubviews([tappableView, scannerTargetView, tray])
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
            layer.insertSublayer(tray.layer, above: video)
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
            tappableView.bottomAnchor.constraint(equalTo: tray.topAnchor)
            ])
        
        NSLayoutConstraint.activate([
            scannerTargetView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 64),
            scannerTargetView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
            scannerTargetView.centerXAnchor.constraint(equalTo: centerXAnchor),
            scannerTargetView.heightAnchor.constraint(equalTo: scannerTargetView.widthAnchor)
            ])
        
        NSLayoutConstraint.activate([
            tray.topAnchor.constraint(equalTo: topAnchor, constant: frame.height * 0.6),
            tray.leadingAnchor.constraint(equalTo: leadingAnchor),
            tray.trailingAnchor.constraint(equalTo: trailingAnchor),
            tray.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1)
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
            self.tray.frame.origin.y -= keyboardFrame.height
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
            self.tray.frame.origin.y += keyboardFrame.height
            self.scannerTargetView.alpha = 1
        })
    }
    
    @objc private func tappableAreaTapped() {
        if keyboardIsPresent && !qrCodeRecognized {
            endEditing(true)
            keyboardIsPresent = false
        }
    }
    
}

extension JTScannerView: AVCaptureMetadataOutputObjectsDelegate {
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput,
                               didOutput metadataObjects: [AVMetadataObject],
                               from connection: AVCaptureConnection) {
        if !keyboardIsPresent {
            qrCodeRecognized = true
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            scannerTargetView.layer.borderColor = UIColor.green.cgColor
            tray.updateTitle(to: Constants.trayTitleSecondary)
            session.stopRunning()
            if let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                let qrCodeString = object.stringValue {
                if object.type == .qr {
                    JacquardService.shared.updateJacketIDString(jacketIDString: qrCodeString)
                }
            }
        }
    }
    
}

extension JTScannerView: JTTrayDelegate {
    
    func didEnterValidJacketID(with id: String) {
        JacquardService.shared.updateJacketIDString(jacketIDString: id)
        tray.updateTitle(to: Constants.trayTitleSecondary)
    }

}
