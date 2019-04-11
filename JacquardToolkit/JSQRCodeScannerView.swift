//
//  JSQRCodeScannerView.swift
//  Pods
//
//  Created by Caleb Rudnicki on 4/3/19.
//

import UIKit
import AVFoundation
import JacquardToolkit

public class JSQRCodeScannerView: UIView {

    private var video = AVCaptureVideoPreviewLayer();
    private var directions = UILabel();

    private var session = AVCaptureSession();
    private var directionsLayer = CATextLayer()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        let captureDevice = AVCaptureDevice.default(for: .video)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            session.addInput(input)
        } catch {
            print("Error")
        }
        
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [.qr]
        
        video = AVCaptureVideoPreviewLayer(session: session)
        video.frame = self.layer.bounds
        
        directionsLayer.frame = self.bounds.insetBy(dx: 0, dy: 80)
        directionsLayer.string = JSConstants.JSStrings.Directions.qrInstructionPreScan
        directionsLayer.foregroundColor = UIColor.white.cgColor
        directionsLayer.isWrapped = true
        directionsLayer.alignmentMode = CATextLayerAlignmentMode.center
        directionsLayer.contentsScale = UIScreen.main.scale
        directionsLayer.backgroundColor = UIColor.black.withAlphaComponent(CGFloat(0.3)).cgColor
        directionsLayer.fontSize = CGFloat(25)
        
        self.layer.addSublayer(video)
        self.layer.insertSublayer(directionsLayer, above: video)
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func startScanner() {
        session.startRunning()
    }
    
    public func stopScanner() {
        session.startRunning()
        self.removeFromSuperview()
    }
    
}

extension JSQRCodeScannerView: AVCaptureMetadataOutputObjectsDelegate {
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
            if object.type == .qr {
                directionsLayer.string = "Scanned \(object.stringValue!)\n \(JSConstants.JSStrings.Directions.qrInstructionPostScan)"
                JacquardService.shared.updateJacketIDString(jacketIDString: object.stringValue!)
                session.stopRunning()
            }
        }
    }

}
