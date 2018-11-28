//
//  Service.swift
//  JacquardToolkit
//
//  Created by Caleb Rudnicki on 11/27/18.
//  Copyright © 2018 Caleb Rudnicki. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol ServiceDelegate {
    func getValue() -> String
}

open class Service: UIViewController, ServiceDelegate {
    
    func getValue() -> String {
        return "GOT VALUE"
    }

    public var centralManager: CBCentralManager!
    private var peripheralObject: CBPeripheral!
    private var peripheralList: [CBPeripheral] = []
    private let uuid = UUID(uuidString: "3DF4C660-AAE3-FC91-DBE5-0217FCDE7894")
    private var jacketIsConnected = false
    
//    private init() {}
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public static func doSomething() -> String {
        return "Did Some Stuff, here you go homeboi"
    }

    public func connectToJacket() -> Bool {
        if jacketIsConnected {
            centralManager.cancelPeripheralConnection(peripheralObject)
            return false
        }
        centralManager = CBCentralManager(delegate: self, queue: nil)
        return true
    }

}

extension Service: CBCentralManagerDelegate {
    
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
            peripheralList = centralManager.retrievePeripherals(withIdentifiers: [uuid!])
            peripheralObject = peripheralList[0]
            peripheralObject.delegate = self as! CBPeripheralDelegate
            centralManager.connect(peripheralObject, options: nil)
        case .poweredOff:
            print("Powered Off")
        }
    }
    
}
