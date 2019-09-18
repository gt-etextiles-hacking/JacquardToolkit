//
//  JTGestureTutorialViewController.swift
//  JacquardToolkit
//
//  Created by Caleb Rudnicki on 9/18/19.
//

import UIKit
import AVKit
import NotificationCenter

class JTGestureTutorialViewController: AVPlayerViewController {

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
