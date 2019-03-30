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

@objc public protocol JacquardServiceDelegate: NSObjectProtocol {
    @objc optional func didDetectDoubleTapGesture()
    @objc optional func didDetectBrushInGesture()
    @objc optional func didDetectBrushOutGesture()
    @objc optional func didDetectCoverGesture()
    @objc optional func didDetectScratchGesture()
    @objc optional func didDetectForceTouchGesture()
    @objc optional func didDetectThreadTouch(threadArray: [Float])
}

public class JacquardService: NSObject, CBCentralManagerDelegate {

    public static let shared = JacquardService()
    public weak var delegate: JacquardServiceDelegate?
    
    private var centralManager: CBCentralManager!
    private var peripheralObject: CBPeripheral!
    private var peripheralList: [CBPeripheral] = []
    private var glowCharacteristic: CBCharacteristic!
    private var powerOnCompletion: ((Bool) -> Void)?
    private let notificationCenter = NotificationCenter.default
    
    // forcetouch gesture variables
    private let forceTouchModel = ForceTouch()
    private var threadReadings: [Float]?
    private var input_data: MLMultiArray?
    private var forceTouchTurnedEnabled = true
    // forcetouch detection
    private var forceTouchDetectionProgress = 0
    private var forceTouchDetectionLength = 6
    private var forceTouchDetectionThreshold = 0.9
    // forcetouch detection cooldown
    private var forceTouchCooldownProgress = 0
    private var minForceTouchCooldownLength = 6
    private var forceTouchCooldownThreshold = 0.4

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
    
    public func searchForJacket() {
        if centralManager.state == .poweredOn {
            let serviceCBUUID = CBUUID(string: JSConstants.JSUUIDs.ServiceStrings.generalReadingUUID)
            peripheralList = centralManager.retrieveConnectedPeripherals(withServices: [serviceCBUUID])
            guard peripheralList.count > 0 else {
                NSLog(JSConstants.JSStrings.ErrorMessages.reconnectJacket)
                return
            }
            connectHelper(targetJacket: peripheralList[0])
        }
    }

    public func connectToJacket(uuidString: String) {
        if centralManager.state == .poweredOn, let uuid = UUID(uuidString: uuidString) {
            peripheralList = centralManager.retrievePeripherals(withIdentifiers: [uuid])
            guard peripheralList.count > 0 else {
                NSLog(JSConstants.JSStrings.ErrorMessages.emptyPeriphalList)
                return
            }
            connectHelper(targetJacket: peripheralList[0])
        }
    }
    
    public func rainbowGlowJacket() {
        if centralManager.state == .poweredOn {
            let dataval = JSHelper.shared.dataWithHexString(hex: JSConstants.JSHexCodes.RainbowGlow.code1)
            let dataval1 = JSHelper.shared.dataWithHexString(hex: JSConstants.JSHexCodes.RainbowGlow.code2)
            if glowCharacteristic != nil {
                peripheralObject.writeValue(dataval, for: glowCharacteristic, type: .withoutResponse)
                peripheralObject.writeValue(dataval1, for: glowCharacteristic, type: .withoutResponse)
            } else {
                NSLog(JSConstants.JSStrings.ErrorMessages.rainbowGlow)
            }
        }
    }
    
    private func connectHelper(targetJacket: CBPeripheral) {
        peripheralObject = targetJacket
        peripheralObject.delegate = self
        centralManager.connect(peripheralObject, options: nil)
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
        
        let prediction = try? forceTouchModel.prediction(input: ForceTouchInput(_15ThreadConductivityReadings: input_data!))
//        print("Prediction Result: \((prediction?.output["ForceTouch"])!)")

        if forceTouchTurnedEnabled {
            if ((prediction?.output[JSConstants.JSStrings.ForceTouch.outputLabel])! > forceTouchDetectionThreshold) {
                // increment detection progress with each sufficiently high prediction confidence
                forceTouchDetectionProgress += 1
                // if enough detection progress has elapsed, register a detection of ForceTouch and reset
                if forceTouchDetectionProgress >= forceTouchDetectionLength {
                    forceTouchDetectionProgress = 0
                    forceTouchTurnedEnabled = false
                    delegate?.didDetectForceTouchGesture!()
                }
                
            } else {
                forceTouchDetectionProgress = 0
            }
        } else {
            if prediction?.output[JSConstants.JSStrings.ForceTouch.outputLabel] ?? 1.0 > forceTouchCooldownThreshold {
                // reset cooldown progress any time we get too confident of a prediction
                forceTouchCooldownProgress = 0
            } else {
                // increment cooldown progress with each sufficiently low prediction confidence
                forceTouchCooldownProgress += 1
            }
            // if enough cooldown progress has elapsed, prime service for next ForceTouch recognition
            if forceTouchCooldownProgress >= minForceTouchCooldownLength {
                forceTouchCooldownProgress = 0
                forceTouchTurnedEnabled = true
                print(JSConstants.JSStrings.ForceTouch.reenableMessage)
            }
       
        }
    }
    
}
