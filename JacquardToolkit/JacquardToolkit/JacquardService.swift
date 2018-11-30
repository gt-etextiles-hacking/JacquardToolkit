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
    func gestureDetected(gestureString: String)
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
            let dataval = dataWithHexString(hex: "801308001008180BDA060A0810107830013801")
            let dataval1 = dataWithHexString(hex: "414000")
            peripheralObject.writeValue(dataval, for: glowCharacteristic, type: .withoutResponse)
            peripheralObject.writeValue(dataval1, for: glowCharacteristic, type: .withoutResponse)
        }
    }

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("Unknown")
        case .resetting:
            print("Resetting")
        case .unsupported:
            print("Unsupported")
        case .unauthorized:
            print("Unauthorized")
        case .poweredOn:
            print("Powered On")
        case .poweredOff:
            print("Powered Off")
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
        delegate?.gestureDetected(gestureString: bodyLocation(from: characteristic))
    }
    
    private func bodyLocation(from characteristic: CBCharacteristic) -> String {
        guard let characteristicData = characteristic.value,
            let byte = characteristicData.first else { return "Error" }
        
        switch byte {
        case 0: return "HAJString.hajGestureUndefined"
        case 1: return "HAJString.hajGestureDoubleTap"
        case 2: return "HAJString.hajGestureBrushIn"
        case 3: return "HAJString.hajGestureBrushOut"
        case 4: return "HAJString.hajGestureUndefined"
        case 5: return "HAJString.hajGestureUndefined"
        case 6: return "HAJString.hajGestureUndefined"
        case 7: return "HAJString.hajGestureCover"
        case 8: return "HAJString.hajGestureScratch"
        default:
            return "HAJString.hajGestureUndefined"
        }
    }
}

extension JacquardService {

    private func dataWithHexString(hex: String) -> Data {
        var hex = hex
        var data = Data()
        while(hex.count > 0) {
            let subIndex = hex.index(hex.startIndex, offsetBy: 2)
            let c = String(hex[..<subIndex])
            hex = String(hex[subIndex...])
            var ch: UInt32 = 0
            Scanner(string: c).scanHexInt32(&ch)
            var char = UInt8(ch)
            data.append(&char, count: 1)
        }
        return data
    }

}

//public protocol ServiceDelegate: NSObjectProtocol {
//    func timerFired()
//}
//
//public class Service: NSObject, ServiceDelegate {
//
//    var timer = Timer()
//    public static let shared = Service()
//    public weak var delegate: ServiceDelegate?
//
//    public func scheduledTimerWithTimeInterval(){
//        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerFired), userInfo: nil, repeats: true)
//    }
//
//    @objc public func timerFired() {
//        NSLog("timerfired")
//        delegate?.timerFired()
//    }
//
//}
