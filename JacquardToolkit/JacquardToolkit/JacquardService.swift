//
//  JacquardService.swift
//  JacquardToolkit
//
//  Created by Caleb Rudnicki on 11/27/18.
//  Copyright © 2018 Caleb Rudnicki. All rights reserved.
//

import Foundation
import CoreBluetooth
import CoreML
import NotificationCenter

public class JacquardService: NSObject, CBCentralManagerDelegate {

    public static let shared = JacquardService()
    public weak var delegate: JacquardServiceDelegate?
    
    private var centralManager: CBCentralManager!
    private var targetJacket: CBPeripheral!
    private var peripheralList: [CBPeripheral] = []
    private var glowCharacteristic: CBCharacteristic!
    private var powerOnCompletion: ((Bool) -> Void)?
    private let notificationCenter = NotificationCenter.default
    private var viewController = UIViewController()
    private var targetJacketIDString: String?
    private var jsQRCodeScannerView = JSQRCodeScannerView()
    private var jsGestureTutorialView = JSGestureTutorialView()
    
    //Forcetouch gesture variables
    private let forceTouchModel = ForceTouch()
    private var threadReadings: [Float]?
    private var input_data: MLMultiArray?
    private var forceTouchTurnedEnabled = true
    private var forceTouchDetectionProgress = 0
    private var forceTouchCooldownProgress = 0
    private var mostRecentGesture: JSConstants.JSGestures = .undefined
    private var cachingGoogleGestures = false
    
    //Tutorial variables
    private var isDoubleTapTutorialActivated = false
    private var isBrushInTutorialActivated = false
    private var isBrushOutTutorialActivated = false
    private var isCoverTutorialActivated = false
    private var isScratchTutorialActivated = false
    private var isForceTouchTutorialActivated = false
    
    // csv logging
    private var csvText = ""
    public var loggingThreads = false
    
    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        do {
            input_data = try MLMultiArray(shape: [JSConstants.JSNumbers.ForceTouch.fullThreadCount as NSNumber], dataType: MLMultiArrayDataType.double);
        } catch {
            fatalError("Unexpected runtime error. MLMultiArray");
        }
        notificationCenter.addObserver(self, selector: #selector(readGesture), name: Notification.Name(JSConstants.JSStrings.Notifications.readGesture), object: nil)
        notificationCenter.addObserver(self, selector: #selector(readThreads), name: Notification.Name(JSConstants.JSStrings.Notifications.readThreads), object: nil)
    }
    
    //MARK: Developer Functions

    /**
     Turns on your phone's bluetooth capabilities
     
     This function is used to make sure that your phone's bluetooth is in the right state to connect to
     a Jacquard. You will need to call this function before `connect()` to ensure the connection process
     runs smoothly.
     
     - Parameter completion: completion handler for inserting `connect()`
     */
    public func activateBluetooth(completion: @escaping (Bool) -> Void) {
        powerOnCompletion = completion
        if centralManager.state == .poweredOn {
            powerOnCompletion?(true)
            powerOnCompletion = nil
        }
    }
    
    /**
     Allows you to easily connect to your Jacquard
     
     If you already have a Jacquard in your list of connected bluetooth devices in your phone's settings,
     this function will choose that Jacquard to connect to. Otherwise, you will need your phone's camera
     to scan the code on the inside right of the Jacquard to pair a new Jacquard. For best practice, call
     this function in the completion handler of `activateBluetooth()`
     
     - Parameter viewController: the class you would like to have the camera open up on
     */
    public func connect(viewController: UIViewController) {
        if centralManager.state == .poweredOn {
            let serviceCBUUID = CBUUID(string: JSConstants.JSUUIDs.ServiceStrings.generalReadingUUID)
            peripheralList = centralManager.retrieveConnectedPeripherals(withServices: [serviceCBUUID])
            guard peripheralList.count > 0 else {
                jsQRCodeScannerView = JSQRCodeScannerView(frame: viewController.view.bounds)
                viewController.view.addSubview(jsQRCodeScannerView)
                jsQRCodeScannerView.startScanner()
                return
            }
            targetJacket = peripheralList[0]
            connectHelper()
        }
    }
    
    /**
     Allows you to tell if your Jacquard is currently connected or not
     
     You will be returned the boolean value true if your Jacquard is connected or false otherwise
     */
    public func isJacquardConnected() -> Bool {
        guard targetJacket != nil else {
            return false
        }
        return true
    }
    
    /**
     Sends a rainbow strobe glow to your Jacquard's tag
     
     Be sure that you are connected and paired to your Jacquard or else this function will not work
     */
    public func rainbowGlowJacket() {
        if centralManager.state == .poweredOn {
            let dataval = JSHelper.shared.dataWithHexString(hex: JSConstants.JSHexCodes.RainbowGlow.code1)
            let dataval1 = JSHelper.shared.dataWithHexString(hex: JSConstants.JSHexCodes.RainbowGlow.code2)
            if glowCharacteristic != nil {
                targetJacket.writeValue(dataval, for: glowCharacteristic, type: .withoutResponse)
                targetJacket.writeValue(dataval1, for: glowCharacteristic, type: .withoutResponse)
            } else {
                NSLog(JSConstants.JSStrings.ErrorMessages.rainbowGlow)
            }
        }
    }
    
    /**
     Exports .csv log of timestamped thread readings as a string and flushes JacquardToolkit logs
     
     Be sure that you are connected and paired to your Jacquard or else this function will not work
     */
    public func exportLog() -> String {
        let csvTextStore = csvText
        csvText.removeAll()
        return csvTextStore
    }
    
    /**
     Plays the video tutorial for the Double Tap gesture
     
     Be sure that you have an internet connection
     
     - Parameter viewController: the class you would like to have the video appear over
     */
    public func playDoubleTapTutorial(viewController: UIViewController) {
        isDoubleTapTutorialActivated = true
        viewController.view.addSubview(jsGestureTutorialView.view)
        jsGestureTutorialView.playVideo(tutorialURL: JSConstants.JSURLs.Tutorial.doubleTap)
    }
    
    /**
     Plays the video tutorial for the Brush in gesture
     
     Be sure that you have an internet connection
     
     - Parameter viewController: the class you would like to have the video appear over
     */
    public func playBrushInTutorial(viewController: UIViewController) {
        isBrushInTutorialActivated = true
        viewController.view.addSubview(jsGestureTutorialView.view)
        jsGestureTutorialView.playVideo(tutorialURL: JSConstants.JSURLs.Tutorial.brushIn)
    }
    
    /**
     Plays the video tutorial for the Brush Out gesture
     
     Be sure that you have an internet connection
     
     - Parameter viewController: the class you would like to have the video appear over
     */
    public func playBrushOutTutorial(viewController: UIViewController) {
        isBrushOutTutorialActivated = true
        viewController.view.addSubview(jsGestureTutorialView.view)
        jsGestureTutorialView.playVideo(tutorialURL: JSConstants.JSURLs.Tutorial.brushOut)
    }
    
    /**
     Plays the video tutorial for the Cover gesture
     
     Be sure that you have an internet connection
     
     - Parameter viewController: the class you would like to have the video appear over
     */
    public func playCoverTutorial(viewController: UIViewController) {
        isCoverTutorialActivated = true
        viewController.view.addSubview(jsGestureTutorialView.view)
        jsGestureTutorialView.playVideo(tutorialURL: JSConstants.JSURLs.Tutorial.cover)
    }
    
    /**
     Plays the video tutorial for the Scratch gesture
     
     Be sure that you have an internet connection
     
     - Parameter viewController: the class you would like to have the video appear over
     */
    public func playScratchTutorial(viewController: UIViewController) {
        isScratchTutorialActivated = true
        viewController.view.addSubview(jsGestureTutorialView.view)
        jsGestureTutorialView.playVideo(tutorialURL: JSConstants.JSURLs.Tutorial.scratch)
    }
    
    /**
     Plays the video tutorial for the Force Touch gesture
     
     Be sure that you have an internet connection
     
     - Parameter viewController: the class you would like to have the video appear over
     */
    public func playForceTouchTutorial(viewController: UIViewController) {
        isForceTouchTutorialActivated = true
        viewController.view.addSubview(jsGestureTutorialView.view)
        jsGestureTutorialView.playVideo(tutorialURL: JSConstants.JSURLs.Tutorial.forceTouch)
    }
    
    //MARK: Helper Functions
    
    private func connectHelper() {
        targetJacket.delegate = self
        centralManager.connect(targetJacket, options: nil)
    }
    
    public func updateJacketIDString(jacketIDString: String?) {
        guard let jacketIDString = jacketIDString else {
            return
        }
        targetJacketIDString = jacketIDString
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    @objc private func readThreads(userInfo: Notification) {
        if let userInfo = userInfo.userInfo {
            if let characteristic = userInfo["characteristic"] as? CBCharacteristic {
                let threadForceValueArray = JSHelper.shared.findThread(from: characteristic)
                delegate?.didDetectThreadTouch?(threadArray: threadForceValueArray)
                checkForForceTouch(threadReadings: threadForceValueArray)

                if self.loggingThreads {
                    let strArray = threadForceValueArray.map { String($0) }
                    csvText.append("\(strArray.joined(separator:",")),\n")
                }
            }
        }
    }
    
    @objc private func readGesture(userInfo: Notification) {
        if let userInfo = userInfo.userInfo {
            if let characteristic = userInfo["characteristic"] as? CBCharacteristic, forceTouchTurnedEnabled {
                let gesture = JSHelper.shared.gestureConverter(from: characteristic)
                if cachingGoogleGestures {
                    mostRecentGesture = gesture
                    print("cached \(mostRecentGesture)")
                } else {
                    switch gesture {
                    case .doubleTap:
                        delegate?.didDetectDoubleTapGesture?()
                        if isDoubleTapTutorialActivated {
                            jsGestureTutorialView.view.removeFromSuperview()
                            isDoubleTapTutorialActivated = false
                        }
                    case .brushIn:
                        delegate?.didDetectBrushInGesture?()
                        if isBrushInTutorialActivated {
                            jsGestureTutorialView.view.removeFromSuperview()
                            isBrushInTutorialActivated = false
                        }
                    case .brushOut:
                        delegate?.didDetectBrushOutGesture?()
                        if isBrushOutTutorialActivated {
                            jsGestureTutorialView.view.removeFromSuperview()
                            isBrushOutTutorialActivated = false
                        }
                    case .cover:
                        delegate?.didDetectCoverGesture?()
                        if isCoverTutorialActivated {
                            jsGestureTutorialView.view.removeFromSuperview()
                            isCoverTutorialActivated = false
                        }
                    case .scratch:
                        delegate?.didDetectScratchGesture?()
                        if isScratchTutorialActivated {
                            jsGestureTutorialView.view.removeFromSuperview()
                            isScratchTutorialActivated = false
                        }
                    default:
                        NSLog("Detected an unknown gesture with characteristic: \(characteristic.uuid.uuidString)")
                    }
                }
            }
        }
    }
    
    private func checkForForceTouch(threadReadings: [Float]) {
        guard let input_data = input_data else {
            return
        }
        for index in 0 ..< (JSConstants.JSNumbers.ForceTouch.fullThreadCount - JSConstants.JSNumbers.ForceTouch.threadCount) {
            input_data[index] = input_data[index + JSConstants.JSNumbers.ForceTouch.threadCount]
        }
        
        // copying in the latest thread reading into the last 15 elements
        for i in 0 ..< JSConstants.JSNumbers.ForceTouch.threadCount {
            input_data[JSConstants.JSNumbers.ForceTouch.fullThreadCount - JSConstants.JSNumbers.ForceTouch.threadCount + i] = threadReadings[i] as NSNumber
        }
        
        let prediction = try? forceTouchModel.prediction(input: ForceTouchInput(_15ThreadConductivityReadings: input_data))
        //        print("Prediction Result: \((prediction?.output["ForceTouch"])!)")
        
        if forceTouchTurnedEnabled {
            if let prediction = prediction?.output[JSConstants.JSStrings.ForceTouch.outputLabel], prediction > JSConstants.JSNumbers.ForceTouch.detectionThreshhold {
                
                if forceTouchDetectionProgress == 0 {
                    // Point A: The first confident prediction for Force Touch has been recieved
                    cachingGoogleGestures = true
                }
                
                // increment detection progress with each sufficiently high prediction confidence
                forceTouchDetectionProgress += 1
                // if enough detection progress has elapsed, register a detection of Force Touch and reset
                if forceTouchDetectionProgress >= JSConstants.JSNumbers.ForceTouch.detectionLength {
                    // Point C: enough consecutive and confident predictions have transpired to warrant Force Touch detection
                    forceTouchDetectionProgress = 0
                    forceTouchTurnedEnabled = false
                    cachingGoogleGestures = false
                    mostRecentGesture = .undefined
                    delegate?.didDetectForceTouchGesture?()
                    if isForceTouchTutorialActivated {
                        jsGestureTutorialView.view.removeFromSuperview()
                        isForceTouchTutorialActivated = false
                    }
                }
            } else {
                if forceTouchDetectionProgress > 0 {
                    // Point B: did not complete all n timesteps, so take the most recently cached official gesture
                    switch mostRecentGesture {
                    case .doubleTap:
                        delegate?.didDetectDoubleTapGesture?()
                        if isDoubleTapTutorialActivated {
                            jsGestureTutorialView.view.removeFromSuperview()
                            isDoubleTapTutorialActivated = false
                        }
                    case .brushIn:
                        delegate?.didDetectBrushInGesture?()
                        if isBrushInTutorialActivated {
                            jsGestureTutorialView.view.removeFromSuperview()
                            isBrushInTutorialActivated = false
                        }
                    case .brushOut:
                        delegate?.didDetectBrushOutGesture?()
                        if isBrushOutTutorialActivated {
                            jsGestureTutorialView.view.removeFromSuperview()
                            isBrushOutTutorialActivated = false
                        }
                    case .cover:
                        delegate?.didDetectCoverGesture?()
                        if isCoverTutorialActivated {
                            jsGestureTutorialView.view.removeFromSuperview()
                            isCoverTutorialActivated = false
                        }
                    case .scratch:
                        delegate?.didDetectScratchGesture?()
                        if isScratchTutorialActivated {
                            jsGestureTutorialView.view.removeFromSuperview()
                            isScratchTutorialActivated = false
                        }
                    default:
                        print("default placeholder")
                    }
                    cachingGoogleGestures = false
                    mostRecentGesture = .undefined
                }
                
                forceTouchDetectionProgress = 0
            }
        } else {
            if prediction?.output[JSConstants.JSStrings.ForceTouch.outputLabel] ?? 1.0 > JSConstants.JSNumbers.ForceTouch.cooldownDetectionThreshhold {
                // reset cooldown progress any time we get too confident of a prediction
                forceTouchCooldownProgress = 0
            } else {
                // increment cooldown progress with each sufficiently low prediction confidence
                forceTouchCooldownProgress += 1
            }
            // if enough cooldown progress has elapsed, prime service for next ForceTouch recognition
            if forceTouchCooldownProgress >= JSConstants.JSNumbers.ForceTouch.cooldownDetectionLength {
                forceTouchCooldownProgress = 0
                forceTouchTurnedEnabled = true
                print(JSConstants.JSStrings.ForceTouch.reenableMessage)
            }
        }
    }
    
    //MARK: Central Manager Functions
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == "Jacquard" {
            guard let adData = advertisementData["kCBAdvDataManufacturerData"] as? Data else {
                return
            }
            var adDataArray = Array(adData.map { UInt32($0) })
            adDataArray.removeFirst()
            adDataArray.removeFirst()
            if JSHelper.shared.decodeAdvertisementData(dataIn: adDataArray) == targetJacketIDString {
                jsQRCodeScannerView.stopScanner()
                targetJacket = peripheral
                connectHelper()
                return
            }
        }
    }

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            NSLog(JSConstants.JSStrings.CentralManagerState.unknown.rawValue)
        case .resetting:
            NSLog(JSConstants.JSStrings.CentralManagerState.resetting.rawValue)
        case .unsupported:
            NSLog(JSConstants.JSStrings.CentralManagerState.unsupporting.rawValue)
        case .unauthorized:
            NSLog(JSConstants.JSStrings.CentralManagerState.unauthorized.rawValue)
            powerOnCompletion?(false)
            powerOnCompletion = nil
        case .poweredOn:
            NSLog(JSConstants.JSStrings.CentralManagerState.poweredOn.rawValue)
            powerOnCompletion?(true)
            powerOnCompletion = nil
        case .poweredOff:
            NSLog(JSConstants.JSStrings.CentralManagerState.poweredOff.rawValue)
            powerOnCompletion?(false)
            powerOnCompletion = nil
        }
    }

    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        delegate?.didDetectConnection!(isConnected: true)
        peripheral.discoverServices(nil)
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        delegate?.didDetectConnection!(isConnected: false)
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
            print("Service: \(service.uuid.uuidString) | Char: \(characteristic.uuid.uuidString)")
            if characteristic.uuid.uuidString == JSConstants.JSUUIDs.CharacteristicsStrings.threadReadingUUID ||
                characteristic.uuid.uuidString == JSConstants.JSUUIDs.CharacteristicsStrings.gestureReadingUUID {
                peripheral.setNotifyValue(true, for: characteristic)
            }
            if characteristic.properties.contains(.writeWithoutResponse) {
                print("\(characteristic.uuid): properties contains .writeWithResponse")
                glowCharacteristic = characteristic
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid.uuidString {
        case JSConstants.JSUUIDs.CharacteristicsStrings.threadReadingUUID:
            notificationCenter.post(name: Notification.Name(JSConstants.JSStrings.Notifications.readThreads), object: self, userInfo: ["characteristic": characteristic])
        case JSConstants.JSUUIDs.CharacteristicsStrings.gestureReadingUUID:
            notificationCenter.post(name: Notification.Name(JSConstants.JSStrings.Notifications.readGesture), object: self, userInfo: ["characteristic": characteristic])
        default:
            break
        }
    }
    
}
