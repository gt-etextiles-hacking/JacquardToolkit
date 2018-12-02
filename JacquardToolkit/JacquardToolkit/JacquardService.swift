//
//  JacquardService.swift
//  JacquardToolkit
//
//  Created by Caleb Rudnicki on 11/27/18.
//  Copyright © 2018 Caleb Rudnicki. All rights reserved.
//

import Foundation
import CoreBluetooth

public protocol JacquardServiceDelegate: NSObjectProtocol {
    func didDetectDoubleTapGesture()
    func didDetectBrushInGesture()
    func didDetectBrushOutGesture()
    func didDetectCoverGesture()
    func didDetectScratchGesture()
}

public class JacquardService: NSObject, CBCentralManagerDelegate {

    public static let shared = JacquardService()
    public weak var delegate: JacquardServiceDelegate?
    private lazy var centralManager: CBCentralManager = {
        return CBCentralManager(delegate: self, queue: nil)
    }()
    private var peripheralObject: CBPeripheral!
    private var peripheralList: [CBPeripheral] = []
    private var glowCharacteristic: CBCharacteristic!

    private override init() {
        super.init()
    }

    public func activateBlutooth() {
        centralManagerDidUpdateState(centralManager)
    }

    public func connectToJacket(uuidString: String) {
        if CBManagerState.poweredOn.rawValue == 5, let uuid = UUID(uuidString: uuidString) {
            peripheralList = centralManager.retrievePeripherals(withIdentifiers: [uuid])
            peripheralObject = peripheralList[0]
            peripheralObject.delegate = self
            centralManager.connect(peripheralObject, options: nil)
        }
    }

    public func rainbowGlowJacket() {
        if CBManagerState.poweredOn.rawValue == 5 {
            let dataval = JSHelper.shared.dataWithHexString(hex: "801308001008180BDA060A0810107830013801")
            let dataval1 = JSHelper.shared.dataWithHexString(hex: "414000")
            if glowCharacteristic != nil {
                peripheralObject.writeValue(dataval, for: glowCharacteristic, type: .withoutResponse)
                peripheralObject.writeValue(dataval1, for: glowCharacteristic, type: .withoutResponse)
            } else {
                NSLog("The glow characteristic has not yet been registered...it doesn't seem like the core bluetooth manager has connected to your jacket. Trying to connect core blutetooth...")
                centralManager.connect(peripheralObject, options: nil)
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
        case .poweredOn:
            NSLog(JSConstants.JSStrings.CentralManagerState.poweredOn)
        case .poweredOff:
            NSLog(JSConstants.JSStrings.CentralManagerState.poweredOff)
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
            print(characteristic.uuid.uuidString)
            if characteristic.uuid.uuidString == "3DF4C660-AAE3-FC91-DBE5-0217FCDE7894" {
                peripheral.setNotifyValue(true, for: characteristic)
            }
            if characteristic.uuid.uuidString == "D45C2030-4270-A125-A25D-EE458C085001" {
                peripheral.setNotifyValue(true, for: characteristic)
            }
            if characteristic.properties.contains(.writeWithoutResponse) {
                print("\(characteristic.uuid): properties contains .writeWithResponse")
                glowCharacteristic = characteristic
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
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
