//
//  JSHelper.swift
//  JacquardToolkit
//
//  Created by Caleb Rudnicki on 11/30/18.
//

import Foundation
import CoreBluetooth

class JSHelper {
    
    public static let shared = Helper()
    
    internal func gestureConverter(from characteristic: CBCharacteristic) -> String {
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
    
    internal func dataWithHexString(hex: String) -> Data {
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
