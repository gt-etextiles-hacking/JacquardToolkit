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

public protocol JacquardServiceDelegate: NSObjectProtocol {
    func didDetectDoubleTapGesture()
    func didDetectBrushInGesture()
    func didDetectBrushOutGesture()
    func didDetectCoverGesture()
    func didDetectScratchGesture()
    func didDetectThreadTouch(threadArray: [Float])
    func didDetectForceTouchGesture()
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
    
    // new gesture variables
    private let model = NewGestureClassifier_RC2()
    private let input_data_dim = 675
    private let numThreads = 15
    private var threadReadings: [Float]?
    private var input_data: MLMultiArray?
    private var forceTouchTurnedEnabled = true
    private var confidenceIntervalArray: [Double] = []

    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)

        do {
            input_data = try MLMultiArray(shape:[675], dataType:MLMultiArrayDataType.double);
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
            let serviceCBUUID = CBUUID(string: "D45C2000-4270-A125-A25D-EE458C085001")
            peripheralList = centralManager.retrieveConnectedPeripherals(withServices: [serviceCBUUID])
            guard peripheralList.count > 0 else {
                NSLog("ERROR: It doesn't seem like your Jacquard is connected. Make sure to manually connect and pair your jacket in the settings app...")
                return
            }
            connectHelper(targetJacket: peripheralList[0])
        }
    }

    public func connectToJacket(uuidString: String) {
        if centralManager.state == .poweredOn, let uuid = UUID(uuidString: uuidString) {
            peripheralList = centralManager.retrievePeripherals(withIdentifiers: [uuid])
            guard peripheralList.count > 0 else {
                NSLog("Error: It seems that your list of peripherals is empty...")
                return
            }
            connectHelper(targetJacket: peripheralList[0])
        }
    }
    
    public func connectHelper(targetJacket: CBPeripheral) {
        peripheralObject = targetJacket
        peripheralObject.delegate = self
        centralManager.connect(peripheralObject, options: nil)
    }

    public func rainbowGlowJacket() {
        if centralManager.state == .poweredOn {
            let dataval = JSHelper.shared.dataWithHexString(hex: "801308001008180BDA060A0810107830013801")
            let dataval1 = JSHelper.shared.dataWithHexString(hex: "414000")
            if glowCharacteristic != nil {
                peripheralObject.writeValue(dataval, for: glowCharacteristic, type: .withoutResponse)
                peripheralObject.writeValue(dataval1, for: glowCharacteristic, type: .withoutResponse)
            } else {
                NSLog("ERROR: Glow is not availible because it seems like your Jacquard is not connected. Make sure to manually connect and pair your jacket in the settings app...")
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
            //For Gestures
            if characteristic.uuid.uuidString == "D45C2030-4270-A125-A25D-EE458C085001" {
                peripheral.setNotifyValue(true, for: characteristic)
            }
            //For Threads
            if characteristic.uuid.uuidString == "D45C2010-4270-A125-A25D-EE458C085001" {
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
        case "D45C2010-4270-A125-A25D-EE458C085001":
            notificationCenter.post(name: Notification.Name("ReadThreads"), object: self, userInfo: ["characteristic": characteristic])
        case "D45C2030-4270-A125-A25D-EE458C085001":
            notificationCenter.post(name: Notification.Name("ReadGesture"), object: self, userInfo: ["characteristic": characteristic])
        default:
            break
        }
    }
    
    @objc func readThreads(userInfo: Notification) {
        if let userInfo = userInfo.userInfo {
            if let characteristic = userInfo["characteristic"] as? CBCharacteristic {
                let threadForceValueArray = JSHelper.shared.findThread(from: characteristic)
                delegate?.didDetectThreadTouch(threadArray: threadForceValueArray)
                checkForForceTouch(threadReadings: threadForceValueArray)
            }
        }
    }
    
    @objc func readGesture(userInfo: Notification) {
        if let userInfo = userInfo.userInfo {
            if let characteristic = userInfo["characteristic"] as? CBCharacteristic {
                let gesture = JSHelper.shared.gestureConverter(from: characteristic)
                switch gesture {
                case .doubleTap:
                    delegate?.didDetectDoubleTapGesture()
                case .brushIn:
                    delegate?.didDetectBrushInGesture()
                case .brushOut:
                    delegate?.didDetectBrushOutGesture()
                case .cover:
                    delegate?.didDetectCoverGesture()
                case .scratch:
                    delegate?.didDetectScratchGesture()
                default:
                    NSLog("Detected an unknown gesture with characteristic: \(characteristic.uuid.uuidString)")
                }
            }
        }
    }
    
    func checkForForceTouch(threadReadings: [Float]) -> Bool {
        for i in 0 ..< (input_data_dim - numThreads) {
            input_data![i] = input_data![i + numThreads]
        }
        
        // copying in the latest thread reading into the last 15 elements
        for i in 0 ..< numThreads {
//            let ch = threadReadings[threadReadings.index(threadReadings.startIndex, offsetBy: i)]
            input_data![input_data_dim - numThreads + i] = threadReadings[i] as! NSNumber ?? NSNumber(floatLiteral: 0.0)
        }
        
        let prediction = try? model.prediction(input: NewGestureClassifier_RC2Input(_15ThreadConductivityReadings: input_data!))
        print("Prediction Result: \((prediction?.output["ForceTouch"])!)")
        
        if forceTouchTurnedEnabled {
            if ((prediction?.output["ForceTouch"])! > 0.7) {
                forceTouchTurnedEnabled = false
                delegate?.didDetectForceTouchGesture()
                return true
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
        return false
    }
    
}
