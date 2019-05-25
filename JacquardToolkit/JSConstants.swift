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
        
        enum CentralManagerState: String {
            case unknown = "Bluetooth Manager's state is unknown"
            case resetting = "Bluetooth Manager's state is resetting"
            case unsupporting = "Bluetooth Manager's state is unsupporting"
            case unauthorized = "Bluetooth Manager's state is unauthorized"
            case poweredOn = "Bluetooth Manager's state is powered on"
            case poweredOff = "Bluetooth Manager's state is powered off"
        }
        
        struct ErrorMessages {
            static let reconnectJacket = "ERROR: It doesn't seem like your Jacquard is connected. Make sure to manually connect and pair your jacket in the settings app..."
            static let emptyPeriphalList = "ERROR: It seems that your list of peripherals is empty..."
            static let rainbowGlow = "ERROR: Glow is not availible because it seems like your Jacquard is not connected. Make sure to manually connect and pair your jacket in the settings app..."
        }
        
        struct Notifications {
            static let readGesture = "ReadGesture"
            static let readThreads = "ReadThreads"
        }
        
        struct ForceTouch {
            static let outputLabel = "ForceTouch"
            static let reenableMessage = "Reenabling force touch"
        }
        
    }
    
    struct JSNumbers {
        
        struct ForceTouch {
            static let threadCount = 15
            static let fullThreadCount = 675
            static let detectionLength = 16
            static let detectionThreshhold = 0.9
            static let cooldownDetectionLength = 6
            static let cooldownDetectionThreshhold = 0.4
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
    
    struct JSURLs {
        
        struct Tutorial {
            static let doubleTap = "https://cdn-b-east.streamable.com/video/mp4/rzpud.mp4?token=-qqRR9SaWO6s6Y5z-NW_vA&expires=1558822200"
            static let brushIn = "https://cdn-b-east.streamable.com/video/mp4/pl2ku.mp4?token=nMJ_OMPv7ajoLiy8w8zMpA&expires=1558822560"
            static let brushOut = "https://cdn-b-east.streamable.com/video/mp4/ht3oh.mp4?token=E8WLjT3HSR4hgwSQH5XLyw&expires=1558822740"
            static let cover = "https://cdn-b-east.streamable.com/video/mp4/zi9gn.mp4?token=X-BMVh1yOWyHZgirbi29kQ&expires=1558822740"
            static let scratch = "https://cdn-b-east.streamable.com/video/mp4/ytw3g.mp4?token=MwO30M-e4f58eUbb0eO9jw&expires=1558822740"
            static let forceTouch = "https://cdn-b-east.streamable.com/video/mp4/a9ij7.mp4?token=cux_TjMhTM7cJymB3w20LA&expires=1558822800"
        }
        
    }

}
