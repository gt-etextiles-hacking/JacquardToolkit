//
//  JSGestureTutorialView.swift
//  JacquardToolkit
//
//  Created by Caleb Rudnicki on 5/2/19.
//

import UIKit
import AVKit
import NotificationCenter

class JSGestureTutorialView: UIView {
    
    var player = AVPlayer()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        NotificationCenter.default.addObserver(self, selector: Selector(("playerDidFinishPlaying:")), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func playVideo() {
        
//        let frameworkBundle = Bundle(for: JSGestureTutorialView.self)
//        let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("JacquardToolkit.bundle")
//        let resourceBundle = Bundle(url: bundleURL!)
//        let image = UIImage(named: "Suit.jpg", in: resourceBundle, compatibleWith: nil)
//        print(image)
        
        let podBundle = Bundle(for: JSGestureTutorialView.self)
        if let bundleURL = podBundle.url(forResource: "JacquardToolkit", withExtension: "bundle") {
            if let bundle = Bundle(url: bundleURL) {
                print(bundle.bundleIdentifier)
                print("I'm here")
            } else {
                
                assertionFailure("Could not load the bundle")
                
            }
            
        } else {
            
            assertionFailure("Could not create a path to the bundle")
            // This keeps getting called
        }
        
//        if let bundleURL = podBundle.url(forResource: "JaquardToolkit", withExtension: "bundle") {
//
//            if let bundle = Bundle(url: bundleURL) {
//
//                let image = UIImage(named: "Suit.jpg", in: bundle, compatibleWith: nil)
//                print(image)
//                  let cellNib = UINib(nibName: classNameToLoad, bundle: bundle)
//                  self.collectionView!.registerNib(cellNib, forCellWithReuseIdentifier: classNameToLoad)
//
//            } else {
//
//                assertionFailure("Could not load the bundle")
//
//            }
//
//        } else {
//
//            assertionFailure("Could not create a path to the bundle")
//
//        }
        guard let path = Bundle.main.path(forResource: "SampleVideo", ofType:"mp4") else {
            debugPrint("SampleVideo.mp4 not found")
            return
        }
        player = AVPlayer(url: URL(fileURLWithPath: path))
        let playerLayer = AVPlayerLayer(player: player)

        playerLayer.frame = self.layer.bounds
        playerLayer.videoGravity = .resizeAspectFill
        player.play()
        
        self.layer.addSublayer(playerLayer)
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        print("Video Finished")
    }

}
