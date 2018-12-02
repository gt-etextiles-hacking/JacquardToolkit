//
//  JSConstants.swift
//  JacquardToolkit
//
//  Created by Caleb Rudnicki on 12/1/18.
//

import Foundation

struct JSConstants {
    
    enum JSGestures {
        case doubleTap
        case brushIn
        case brushOut
        case cover
        case scratch
        case undefined
    }
    
    struct JSStrings {
        
        struct CentralManagerState {
            static let unknown = "Bluetooth Manager's state is unknown"
            static let resetting = "Bluetooth Manager's state is resetting"
            static let unsupporting = "Bluetooth Manager's state is unsupporting"
            static let unauthorized = "Bluetooth Manager's state is unauthorized"
            static let poweredOn = "Bluetooth Manager's state is powered on"
            static let poweredOff = "Bluetooth Manager's state is powered off"
        }
        
    }

}
