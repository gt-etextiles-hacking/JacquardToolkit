//
//  JSGestureTutorialView.swift
//  JacquardToolkit
//
//  Created by Caleb Rudnicki on 5/2/19.
//

import UIKit
import AVKit

class JSGestureTutorialView: UIView {
    
    var player = AVPlayer()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        guard let path = Bundle.main.path(forResource: "SampleVideo", ofType:"mp4") else {
            debugPrint("video.m4v not found")
            return
        }
        player = AVPlayer(url: URL(fileURLWithPath: path))
        let playerLayer = AVPlayerLayer(player: player)
        
        playerLayer.frame = self.layer.bounds
        playerLayer.videoGravity = .resizeAspectFill
        
        self.layer.addSublayer(playerLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func playVideo() {
        player.play()
    }

}
