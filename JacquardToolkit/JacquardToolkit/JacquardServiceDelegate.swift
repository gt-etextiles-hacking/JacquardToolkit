//
//  JacquardServiceDelegate.swift
//  JacquardToolkit
//
//  Created by Caleb Rudnicki on 4/28/19.
//

import Foundation

@objc public protocol JacquardServiceDelegate: NSObjectProtocol {
    
    /**
     Invoked when a double tap gesture is performed on the Jacquard
     */
    @objc optional func didDetectDoubleTapGesture()
    
    /**
     Invoked when a brush in gesture is performed on the Jacquard
     */
    @objc optional func didDetectBrushInGesture()
    
    /**
     Invoked when a brush out gesture is performed on the Jacquard
     */
    @objc optional func didDetectBrushOutGesture()
    
    /**
     Invoked when a cover gesture is performed on the Jacquard
     */
    @objc optional func didDetectCoverGesture()
    
    /**
     Invoked when a scratch gesture is performed on the Jacquard
     */
    @objc optional func didDetectScratchGesture()
    
    /**
     Invoked when a force touch gesture is performed on the Jacquard
     */
    @objc optional func didDetectForceTouchGesture()
    
    /**
     Invoked when at least one of the Jacquard threads is being touch
     
     - Parameter threadArray: an array of 15 values representing the
     that is applied to that specific thread (`threadArray[0]` corresponds
     to the thread closest to the hand / `threadArray[14] corresponds
     to the thread closest to the elbow)
     */
    @objc optional func didDetectThreadTouch(threadArray: [Float])
}
