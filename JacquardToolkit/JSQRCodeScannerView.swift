//
//  JSQRCodeScannerView.swift
//  Pods
//
//  Created by Caleb Rudnicki on 4/3/19.
//

import UIKit
import AVFoundation
import JacquardToolkit

public class JSQRCodeScannerView: UIView, AVCaptureMetadataOutputObjectsDelegate {

    private var video = AVCaptureVideoPreviewLayer()
    private var session = AVCaptureSession()
    
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
        self.layer.addSublayer(video)
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
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
            if object.type == .qr {
                print(object.stringValue!)
                JacquardService.shared.updateJacketIDString(jacketIDString: object.stringValue!)
                session.startRunning()
            }
        }
    }

}
