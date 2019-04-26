//
//  JSQRCodeScannerView.swift
//  Pods
//
//  Created by Caleb Rudnicki on 4/3/19.
//

import UIKit
import AVFoundation

public class JSQRCodeScannerView: UIView {

    private var video = AVCaptureVideoPreviewLayer()
    private var session = AVCaptureSession()
    private let output = AVCaptureMetadataOutput()
    
    private var scannerBounds = CAShapeLayer()
    private var textLayer = CATextLayer()
    private var scannerRect = CGRect()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        scannerRect = CGRect(x: self.center.x - (self.frame.width * 0.5 / 2), y: self.frame.width * 0.5 / 2, width: self.frame.width * 0.5, height: self.frame.width * 0.5)
        
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
            video.frame = self.layer.bounds
            video.videoGravity = .resizeAspectFill
            
            scannerBounds.frame = scannerRect
            scannerBounds.borderColor = UIColor.gray.cgColor
            scannerBounds.borderWidth = 5
            
            textLayer.string = "Scan QR Code"
            textLayer.cornerRadius = 10
            textLayer.backgroundColor = UIColor.gray.cgColor
            textLayer.borderColor = UIColor.black.cgColor
            textLayer.borderWidth = 2
            textLayer.shadowColor = UIColor.black.cgColor
            textLayer.shadowOffset = CGSize(width: 3, height: 3)
            textLayer.shadowOpacity = 0.7
            textLayer.shadowRadius = 4.0
            textLayer.frame = CGRect(x: 15, y: self.frame.height - 30 - (self.frame.height * 0.25), width: self.frame.width - 30, height: self.frame.height * 0.25 - 30)
            
            self.layer.addSublayer(video)
            self.layer.insertSublayer(scannerBounds, above: video)
            self.layer.insertSublayer(textLayer, above: video)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func startScanner() {
        session.commitConfiguration()
        session.startRunning()
        output.rectOfInterest = video.metadataOutputRectConverted(fromLayerRect: scannerRect)
    }
    
    public func stopScanner() {
        session.startRunning()
        self.removeFromSuperview()
    }
    
}

extension JSQRCodeScannerView: AVCaptureMetadataOutputObjectsDelegate {
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        textLayer.string = "Pop tag in"
        session.stopRunning()
        if let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
            if object.type == .qr {
                JacquardService.shared.updateJacketIDString(jacketIDString: object.stringValue)
            }
        }
    }

}
