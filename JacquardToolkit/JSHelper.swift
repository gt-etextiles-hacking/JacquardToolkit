//
//  JSHelper.swift
//  JacquardToolkit
//
//  Created by Caleb Rudnicki on 11/30/18.
//

import Foundation
import CoreBluetooth

class JSHelper {
    
    public static let shared = JSHelper()
    
    internal func gestureConverter(from characteristic: CBCharacteristic) -> JSConstants.JSGestures {
        guard let characteristicData = characteristic.value, let byte = characteristicData.first else { return JSConstants.JSGestures.undefined }
        switch byte {
        case 0: return JSConstants.JSGestures.undefined
        case 1: return JSConstants.JSGestures.doubleTap
        case 2: return JSConstants.JSGestures.brushIn
        case 3: return JSConstants.JSGestures.brushOut
        case 4: return JSConstants.JSGestures.undefined
        case 5: return JSConstants.JSGestures.undefined
        case 6: return JSConstants.JSGestures.undefined
        case 7: return JSConstants.JSGestures.cover
        case 8: return JSConstants.JSGestures.scratch
        default:
            return JSConstants.JSGestures.undefined
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
