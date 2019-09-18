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
    
    private let dismissButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.text = "Button"
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: .main, using: { _ in
            self.player?.seek(to: kCMTimeZero)
            self.player?.play()
        })
        
        contentOverlayView?.addSubview(dismissButton)
        updateConstraints()
    }
    
    
    
    private func updateConstraints() {
        guard let overlayView = self.contentOverlayView else {
            return
        }
        
        NSLayoutConstraint.activate([
            dismissButton.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: 8),
            dismissButton.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 8)
        ])
    }
    
    public func playVideo(tutorialURL: String, withDismissButton: Bool) {
        guard let movieURL = URL(string: tutorialURL) else {
            debugPrint("video not found")
            return
        }
        
        player = AVPlayer(url: movieURL)
        player?.isMuted = true
        videoGravity = "resizeAspectFill"
        showsPlaybackControls = false
        contentOverlayView?.addSubview(dismissButton)
//        updateConstraints()
//        self.contentOverlayView
            //= JTTray(frame: CGRect.zero, title: "Title", textFieldPlaceholder: "Placeholder", buttonTitle: "Button Title")
        
        
        player?.play()
    }
    
    @objc private func dismissView() {
        print("Dismissing")
    }

}
