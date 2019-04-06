//
//  JacquardService.swift
//  JacquardToolkit
//
//  Created by Caleb Rudnicki on 11/27/18.
//  Copyright © 2018 Caleb Rudnicki. All rights reserved.
//

import Foundation
import CoreBluetooth
import CoreML
import NotificationCenter
import AVFoundation

@objc public protocol JacquardServiceDelegate: NSObjectProtocol {
    @objc optional func didDetectDoubleTapGesture()
    @objc optional func didDetectBrushInGesture()
    @objc optional func didDetectBrushOutGesture()
    @objc optional func didDetectCoverGesture()
    @objc optional func didDetectScratchGesture()
    @objc optional func didDetectThreadTouch(threadArray: [Float])
}

public class JacquardService: NSObject, CBCentralManagerDelegate {

    public static let shared = JacquardService()
    public weak var delegate: JacquardServiceDelegate?
    
    private var centralManager: CBCentralManager!
    private var targetJacket: CBPeripheral!
    private var peripheralList: [CBPeripheral] = []
    private var glowCharacteristic: CBCharacteristic!
    private var powerOnCompletion: ((Bool) -> Void)?
    private let notificationCenter = NotificationCenter.default
    private var viewController = UIViewController()
    private var targetJacketIDString: String?
    private var jsQRCodeScannerView = JSQRCodeScannerView()
    
    // new gesture variables
    private let forceTouchModel = NewGestureClassifier_RC2()
    private var threadReadings: [Float]?
    private var input_data: MLMultiArray?
    private var forceTouchTurnedEnabled = true
    private var confidenceIntervalArray: [Double] = []

    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        do {
            input_data = try MLMultiArray(shape: [JSConstants.JSNumbers.ForceTouch.fullThreadCount as NSNumber], dataType: MLMultiArrayDataType.double);
        } catch {
            fatalError("Unexpected runtime error. MLMultiArray");
        }
        notificationCenter.addObserver(self, selector: #selector(readGesture), name: Notification.Name("ReadGesture"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(readThreads), name: Notification.Name("ReadThreads"), object: nil)
    }

    public func activateBlutooth(completion: @escaping (Bool) -> Void) {
        powerOnCompletion = completion
        if centralManager.state == .poweredOn {
            powerOnCompletion?(true)
            powerOnCompletion = nil
        }
    }
    
    public func connect(viewController: UIViewController) {
        if centralManager.state == .poweredOn {
            let serviceCBUUID = CBUUID(string: JSConstants.JSUUIDs.ServiceStrings.generalReadingUUID)
            peripheralList = centralManager.retrieveConnectedPeripherals(withServices: [serviceCBUUID])
            guard peripheralList.count > 0 else {
                jsQRCodeScannerView = JSQRCodeScannerView(frame: viewController.view.bounds)
                viewController.view.addSubview(jsQRCodeScannerView)
                jsQRCodeScannerView.startScanner()
                return
            }
            targetJacket = peripheralList[0]
            print("Connected again")
            connectHelper()
        }
    }
    
    private func connectHelper() {
        targetJacket.delegate = self
        centralManager.connect(targetJacket, options: nil)
    }
    
    public func updateJacketIDString(jacketIDString: String) {
        targetJacketIDString = jacketIDString
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == "Jacquard" {
            let adData = advertisementData["kCBAdvDataManufacturerData"]! as! Data
            var adDataArray = Array(adData.map { UInt32($0) })
            adDataArray.removeFirst()
            adDataArray.removeFirst()
            if JSHelper.shared.decodeAdvertisementData(dataIn: adDataArray) == targetJacketIDString {
                jsQRCodeScannerView.stopScanner()
                targetJacket = peripheral
                connectHelper()
                return
            }
        }
    }
    
    public func rainbowGlowJacket() {
        if centralManager.state == .poweredOn {
            let dataval = JSHelper.shared.dataWithHexString(hex: JSConstants.JSHexCodes.RainbowGlow.code1)
            let dataval1 = JSHelper.shared.dataWithHexString(hex: JSConstants.JSHexCodes.RainbowGlow.code2)
            if glowCharacteristic != nil {
                targetJacket.writeValue(dataval, for: glowCharacteristic, type: .withoutResponse)
                targetJacket.writeValue(dataval1, for: glowCharacteristic, type: .withoutResponse)
            } else {
                NSLog(JSConstants.JSStrings.ErrorMessages.rainbowGlow)
            }
        }
    }

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            NSLog(JSConstants.JSStrings.CentralManagerState.unknown)
        case .resetting:
            NSLog(JSConstants.JSStrings.CentralManagerState.resetting)
        case .unsupported:
            NSLog(JSConstants.JSStrings.CentralManagerState.unsupporting)
        case .unauthorized:
            NSLog(JSConstants.JSStrings.CentralManagerState.unauthorized)
            powerOnCompletion?(false)
            powerOnCompletion = nil
        case .poweredOn:
            NSLog(JSConstants.JSStrings.CentralManagerState.poweredOn)
            powerOnCompletion?(true)
            powerOnCompletion = nil
        case .poweredOff:
            NSLog(JSConstants.JSStrings.CentralManagerState.poweredOff)
            powerOnCompletion?(false)
            powerOnCompletion = nil
        }
    }

    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }

}

extension JacquardService: CBPeripheralDelegate {

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }

        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics {
            print("Service: \(service.uuid.uuidString) | Char: \(characteristic.uuid.uuidString)")
            if characteristic.uuid.uuidString == JSConstants.JSUUIDs.CharacteristicsStrings.threadReadingUUID ||
                characteristic.uuid.uuidString == JSConstants.JSUUIDs.CharacteristicsStrings.gestureReadingUUID {
                peripheral.setNotifyValue(true, for: characteristic)
            }
            if characteristic.properties.contains(.writeWithoutResponse) {
                print("\(characteristic.uuid): properties contains .writeWithResponse")
                glowCharacteristic = characteristic
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid.uuidString {
        case JSConstants.JSUUIDs.CharacteristicsStrings.threadReadingUUID:
            notificationCenter.post(name: Notification.Name("ReadThreads"), object: self, userInfo: ["characteristic": characteristic])
        case JSConstants.JSUUIDs.CharacteristicsStrings.gestureReadingUUID:
            notificationCenter.post(name: Notification.Name("ReadGesture"), object: self, userInfo: ["characteristic": characteristic])
        default:
            break
        }
    }
    
    @objc private func readThreads(userInfo: Notification) {
        if let userInfo = userInfo.userInfo {
            if let characteristic = userInfo["characteristic"] as? CBCharacteristic {
                let threadForceValueArray = JSHelper.shared.findThread(from: characteristic)
                delegate?.didDetectThreadTouch!(threadArray: threadForceValueArray)
                checkForForceTouch(threadReadings: threadForceValueArray)
            }
        }
    }
    
    @objc private func readGesture(userInfo: Notification) {
        if let userInfo = userInfo.userInfo {
            if let characteristic = userInfo["characteristic"] as? CBCharacteristic, forceTouchTurnedEnabled {
                let gesture = JSHelper.shared.gestureConverter(from: characteristic)
                switch gesture {
                case .doubleTap:
                    delegate?.didDetectDoubleTapGesture!()
                case .brushIn:
                    delegate?.didDetectBrushInGesture!()
                case .brushOut:
                    delegate?.didDetectBrushOutGesture!()
                case .cover:
                    delegate?.didDetectCoverGesture!()
                case .scratch:
                    delegate?.didDetectScratchGesture!()
                default:
                    NSLog("Detected an unknown gesture with characteristic: \(characteristic.uuid.uuidString)")
                }
            }
        }
    }
    
    private func checkForForceTouch(threadReadings: [Float]) {
        for i in 0 ..< (JSConstants.JSNumbers.ForceTouch.fullThreadCount - JSConstants.JSNumbers.ForceTouch.threadCount) {
            input_data![i] = input_data![i + JSConstants.JSNumbers.ForceTouch.threadCount]
        }
        
        // copying in the latest thread reading into the last 15 elements
        for i in 0 ..< JSConstants.JSNumbers.ForceTouch.threadCount {
            input_data![JSConstants.JSNumbers.ForceTouch.fullThreadCount - JSConstants.JSNumbers.ForceTouch.threadCount + i] = threadReadings[i] as NSNumber
        }
        
        let prediction = try? forceTouchModel.prediction(input: NewGestureClassifier_RC2Input(_15ThreadConductivityReadings: input_data!))
//        print("Prediction Result: \((prediction?.output["ForceTouch"])!)")
        
        if forceTouchTurnedEnabled {
            if ((prediction?.output["ForceTouch"])! > 0.7) {
                forceTouchTurnedEnabled = false
                delegate?.didDetectScratchGesture!()
            }
        } else {
            //add the next confidence interval into the array
            confidenceIntervalArray.append(prediction?.output["ForceTouch"] ?? 0.0)
            if confidenceIntervalArray.count > 5 {
                var reenableForceTouch = true
                for i in confidenceIntervalArray {
                    if i > 0.5 {
                        reenableForceTouch = false
                    }
                }
                if reenableForceTouch {
                    confidenceIntervalArray = []
                    forceTouchTurnedEnabled = true
                    print("Reenabling force touch")
                } else {
                    confidenceIntervalArray.removeFirst()
                }
            }
        }
    }
    
}

extension Data {

    init<T>(fromArray values: [T]) {
        var values = values
        self.init(buffer: UnsafeBufferPointer(start: &values, count: values.count))
    }

    func toArray<T>(type: T.Type) -> [T] {
        return self.withUnsafeBytes {
            [T](UnsafeBufferPointer(start: $0, count: self.count/MemoryLayout<T>.stride))
        }
    }
}
