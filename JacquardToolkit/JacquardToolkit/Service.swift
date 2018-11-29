//
//  Service.swift
//  JacquardToolkit
//
//  Created by Caleb Rudnicki on 11/27/18.
//  Copyright © 2018 Caleb Rudnicki. All rights reserved.
//

import Foundation
import CoreBluetooth

public class Service: NSObject {
    public static let shared = Service()
    private lazy var centralManager: CBCentralManager = {
        return CBCentralManager(delegate: self, queue: nil)
    }()
    private var peripheralObject: CBPeripheral!
    private var peripheralList: [CBPeripheral] = []
    private let uuid = UUID(uuidString: "3DF4C660-AAE3-FC91-DBE5-0217FCDE7894")
    private var isPowerOn = false
    private var glowCharacteristic: CBCharacteristic!
    
    private override init() {
        super.init()
    }
    
    public func activateBlutooth() {
        centralManagerDidUpdateState(centralManager)
    }
    
    public func connectToJacket(uuidString: String) {
        if isPowerOn, let uuid = UUID(uuidString: uuidString) {
            peripheralList = centralManager.retrievePeripherals(withIdentifiers: [uuid])
            peripheralObject = peripheralList[0]
            peripheralObject.delegate = self
            centralManager.connect(peripheralObject, options: nil)
        }
    }
    
    public func rainbowGlowJacket() {
        if isPowerOn {
            let dataval = dataWithHexString(hex: "801308001008180BDA060A0810107830013801")
            let dataval1 = dataWithHexString(hex: "414000")
            peripheralObject.writeValue(dataval, for: glowCharacteristic, type: .withoutResponse)
            peripheralObject.writeValue(dataval1, for: glowCharacteristic, type: .withoutResponse)
        }
    }
}

extension Service: CBCentralManagerDelegate {
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("Unknown")
            isPowerOn = false
        case .resetting:
            print("Resetting")
            isPowerOn = false
        case .unsupported:
            print("Unsupported")
            isPowerOn = false
        case .unauthorized:
            print("Unauthorized")
            isPowerOn = false
        case .poweredOn:
            print("Powered On")
            isPowerOn = true
        case .poweredOff:
            print("Powered Off")
            isPowerOn = false
        }
        
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to Jacquard")
        peripheral.discoverServices(nil)
    }
    
}

extension Service: CBPeripheralDelegate {
    
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
//            if characteristic.uuid.uuidString == HAJString.hajJacketUUID {
//                peripheral.setNotifyValue(true, for: characteristic)
//            }
            if characteristic.properties.contains(.writeWithoutResponse) {
                print("\(characteristic.uuid): properties contains .writeWithResponse")
                glowCharacteristic = characteristic
            }
//            if characteristic.uuid.uuidString == "D45C2010-4270-A125-A25D-EE458C085001" ||
//                characteristic.uuid.uuidString == "D45C2030-4270-A125-A25D-EE458C085001" {
//                peripheral.setNotifyValue(true, for: characteristic)
//            }
        }
    }
}

extension Service {
    
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
