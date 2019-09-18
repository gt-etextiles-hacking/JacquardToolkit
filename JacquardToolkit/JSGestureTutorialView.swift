//
//  JSGestureTutorialView.swift
//  JacquardToolkit
//
//  Created by Caleb Rudnicki on 5/2/19.
//

import UIKit
import AVKit
import NotificationCenter

class JSGestureTutorialView: AVPlayerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: .main, using: { _ in
            self.player?.seek(to: kCMTimeZero)
            self.player?.play()
        })
    }
    
    public func playVideo(tutorialURL: String) {
        guard let movieURL = URL(string: tutorialURL) else {
            debugPrint("video not found")
            return
        }
        
        player = AVPlayer(url: movieURL)
        player?.isMuted = true
        videoGravity = "resizeAspectFill"
        showsPlaybackControls = false
        
        player?.play()
    }
    
}