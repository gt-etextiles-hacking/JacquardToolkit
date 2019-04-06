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
    
    internal func findThread(from characteristic: CBCharacteristic) -> [Float] {
        guard let characteristicData = characteristic.value else { return [] }
        let fullStr = characteristicData.hexEncodedString()
        let partStr = fullStr[21...35]
        return threadStrToArray(threadStr: partStr)
    }
    
    internal func threadStrToArray(threadStr: String) -> [Float] {
        var threadArr: [Float] = []
        for i in 0..<threadStr.count {
            let index = threadStr.index(threadStr.startIndex, offsetBy: i)
            switch threadStr[index] {
            case "0":
                threadArr.append(0/15)
            case "1":
                threadArr.append(1/15)
            case "2":
                threadArr.append(2/15)
            case "3":
                threadArr.append(3/15)
            case "4":
                threadArr.append(4/15)
            case "5":
                threadArr.append(5/15)
            case "6":
                threadArr.append(6/15)
            case "7":
                threadArr.append(7/15)
            case "8":
                threadArr.append(8/15)
            case "9":
                threadArr.append(9/15)
            case "a":
                threadArr.append(10/15)
            case "b":
                threadArr.append(11/15)
            case "c":
                threadArr.append(12/15)
            case "d":
                threadArr.append(13/15)
            case "e":
                threadArr.append(14/15)
            case "f":
                threadArr.append(1/15)
            default:
                threadArr.append(0/14)
            }
        }
        return threadArr
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
    
    internal func decodeAdvertisementData(dataIn: [UInt32]) -> String {
        var accumulator: UInt32 = 0 // Accumulator to aggregate multiple bytes' worth of bits.
        var bitsLeft = 0 // How many bits of valid data are in the LSB of the accumulator.
        var bytesUsed = 0 // How many bytes from the input data have been shifted into the accumulator.
        var finalArr: [UInt8] = []
        
        for _ in 0...dataIn.count {
            //Check if we need to load more bits into the accumulator
            if bitsLeft < 6 {
                //Load the next byte in, shifted to the left to avoid bits already in the accumulator
                accumulator += dataIn[bytesUsed] << bitsLeft
                bytesUsed += 1 //Mark one more byte used
                bitsLeft += 8 //Mark 8 bits available
            }
            
            // Take the lowest 6 bits of the accumulator
            var sixBitCode: UInt8 = UInt8(accumulator & 0x3f)
            
            //Decode the encoded character into [0-9;A-Z;a-z;-]
            if sixBitCode <= 0x09 {
                sixBitCode += UInt8(Character(unicodeScalarLiteral: "0").asciiValue)
            } else if sixBitCode <= 0x22 {
                sixBitCode += UInt8(Character(unicodeScalarLiteral: "A").asciiValue - 0x0a)
            } else if sixBitCode <= 0x3b {
                sixBitCode += UInt8(Character(unicodeScalarLiteral: "a").asciiValue - 0x23)
            } else if sixBitCode == 0x3c {
                sixBitCode = 0x2d
            } else if sixBitCode == 0x3f {
                break //End-of-string character
            } else {
                continue //Invalid characters are skipped
            }
            
            accumulator >>= 6 //Chop the bits out of the accumulator
            bitsLeft -= 6 //Mark those bits as used
            finalArr.append(sixBitCode)
        }
        return String(bytes: finalArr, encoding: .ascii) ?? "N/A"
    }
    
}

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    
    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
}

extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}

extension Character {
    var asciiValue: Int {
        get {
            let s = String(self).unicodeScalars
            return Int(s[s.startIndex].value)
        }
    }
}
