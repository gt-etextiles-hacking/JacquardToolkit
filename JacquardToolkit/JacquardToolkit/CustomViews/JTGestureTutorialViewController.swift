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
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "dismiss.png", in: Bundle(for: JacquardService.self), compatibleWith: nil), for: .normal)
        button.tintColor = .jtDarkGrey
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: .main, using: { _ in
            self.player?.seek(to: kCMTimeZero)
            self.player?.play()
        })
        
        dismissButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
        
        contentOverlayView?.addSubview(dismissButton)
        updateConstraints()
    }
    
    
    
    private func updateConstraints() {
        guard let overlayView = self.contentOverlayView else {
            return
        }
        
        NSLayoutConstraint.activate([
            dismissButton.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: 36),
            dismissButton.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 16)
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
        player?.play()
    }
    
    @objc private func dismissButtonTapped() {
        removeFromParentViewController()
    }

}
