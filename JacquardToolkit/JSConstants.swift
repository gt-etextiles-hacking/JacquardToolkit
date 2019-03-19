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
        
        struct ErrorMessages {
            static let reconnectJacket = "ERROR: It doesn't seem like your Jacquard is connected. Make sure to manually connect and pair your jacket in the settings app..."
            static let emptyPeriphalList = "ERROR: It seems that your list of peripherals is empty..."
            static let rainbowGlow = "ERROR: Glow is not availible because it seems like your Jacquard is not connected. Make sure to manually connect and pair your jacket in the settings app..."
        }
        
    }
    
    struct JSNumbers {
        
        struct ForceTouch {
            static let threadCount = 15
            static let fullThreadCount = 675
        }
        
    }
    
    struct JSHexCodes {
        
        struct RainbowGlow {
            static let code1 = "801308001008180BDA060A0810107830013801"
            static let code2 = "414000"
        }
        
    }
    
    struct JSUUIDs {
        
        struct ServiceStrings {
            static let generalReadingUUID = "D45C2000-4270-A125-A25D-EE458C085001"
        }
        
        struct CharacteristicsStrings {
            static let gestureReadingUUID = "D45C2030-4270-A125-A25D-EE458C085001"
            static let threadReadingUUID = "D45C2010-4270-A125-A25D-EE458C085001"
        }
        
    }

}
