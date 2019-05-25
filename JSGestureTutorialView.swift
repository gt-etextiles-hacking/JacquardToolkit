//
//  JSGestureTutorialView.swift
//  JacquardToolkit
//
//  Created by Caleb Rudnicki on 5/2/19.
//

import UIKit
import AVKit

class JSGestureTutorialView: UIView {
    
    private var player = AVPlayer()
    private var session = AVCaptureSession()
    private var playerController = AVPlayerViewController()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func playVideo(tutorialURL: String) {
        guard let movieURL = URL(string: tutorialURL) else {
            debugPrint("video not found")
            return
        }
        
        player = AVPlayer(url: movieURL)
        playerController.player = player
        playerController.view.frame = self.layer.bounds
        playerController.videoGravity = .resizeAspectFill
        playerController.showsPlaybackControls = false
        player.play()
        
        self.layer.addSublayer(playerController.view.layer)
    }
    
    public func stopVideo() {
        player.pause()
    }
    
}
