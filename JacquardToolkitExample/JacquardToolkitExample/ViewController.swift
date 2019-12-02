//
//  ViewController.swift
//  JacquardToolkitExample
//
//  Created by Caleb Rudnicki on 11/27/18.
//  Copyright © 2018 Caleb Rudnicki. All rights reserved.
//

import UIKit
import JacquardToolkit

class ViewController: UIViewController {

    // MARK: Properties

    private let threadArray: [UIView] = {
        var threadArray: [UIView] = []
        for _ in 0...14 {
            let view = UIView()
            view.alpha = 0.3
            view.backgroundColor = .white
            view.layer.cornerRadius = 6
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.black.cgColor
            view.translatesAutoresizingMaskIntoConstraints = false
            threadArray.append(view)
        }
        return threadArray
    }()

    private let verticalStackView: UIStackView = {
        let verticalStackView = UIStackView()
        verticalStackView.axis = .vertical
        verticalStackView.alignment = .fill
        verticalStackView.distribution = .equalSpacing
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        return verticalStackView
    }()

    private let horizontalStackView: UIStackView = {
        let horizontalStackView = UIStackView()
        horizontalStackView.axis = .horizontal
        horizontalStackView.alignment = .fill
        horizontalStackView.distribution = .fillEqually
        horizontalStackView.spacing = 24
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        return horizontalStackView
    }()

    private let gestureLabel: UILabel = {
        let gestureLabel = UILabel()
        gestureLabel.font = .systemFont(ofSize: 48, weight: .medium)
        gestureLabel.textColor = .label
        gestureLabel.text = "GESTURE"
        gestureLabel.textAlignment = .center
        gestureLabel.translatesAutoresizingMaskIntoConstraints = false
        return gestureLabel
    }()

    private let connectButton: UIButton = {
        let connectButton = UIButton()
        connectButton.setTitle("Connect", for: .normal)
        connectButton.layer.cornerRadius = 10
        connectButton.backgroundColor = .systemBlue
        connectButton.setTitleColor(.white, for: .normal)
        connectButton.translatesAutoresizingMaskIntoConstraints = false
        return connectButton
    }()

    private let rainbowGlowButton: UIButton = {
        let rainbowGlowButton = UIButton()
        rainbowGlowButton.setTitle("Rainbow Glow", for: .normal)
        rainbowGlowButton.layer.cornerRadius = 10
        rainbowGlowButton.backgroundColor = .systemPink
        rainbowGlowButton.setTitleColor(.white, for: .normal)
        rainbowGlowButton.translatesAutoresizingMaskIntoConstraints = false
        return rainbowGlowButton
    }()

    // MARK: Init

    override func viewDidLoad() {
        super.viewDidLoad()

        JacquardService.shared.delegate = self

        title = "JacquardToolkit"
        navigationController?.navigationBar.prefersLargeTitles = true

        if #available(iOS 13.0, *){
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .black
        }

        rainbowGlowButton.addTarget(self, action: #selector(rainbowGlowButtonTapped), for: .touchUpInside)
        connectButton.addTarget(self, action: #selector(connectButtonTapped), for: .touchUpInside)

        for thread in threadArray {
            thread.heightAnchor.constraint(equalToConstant: 12).isActive = true
            verticalStackView.addArrangedSubview(thread)
        }

        view.addSubview(verticalStackView)
        view.addSubview(gestureLabel)

        horizontalStackView.addArrangedSubview(connectButton)
        horizontalStackView.addArrangedSubview(rainbowGlowButton)
        view.addSubview(horizontalStackView)

        updateViewConstraints()

    }

    override func updateViewConstraints() {
        super.updateViewConstraints()

        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16.0),
            verticalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24.0),
            verticalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24.0),
            verticalStackView.bottomAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            gestureLabel.topAnchor.constraint(equalTo: verticalStackView.bottomAnchor, constant: 64.0),
            gestureLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24.0),
            gestureLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24.0)
        ])

        NSLayoutConstraint.activate([
            horizontalStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16.0),
            horizontalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24.0),
            horizontalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24.0),
            horizontalStackView.heightAnchor.constraint(equalToConstant: 60.0)
        ])
    }

    // MARK: Action Functions

    @objc private func connectButtonTapped() {
        UIView.animate(withDuration: 0.3, animations: {
            self.connectButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.connectButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: { _ in
            if !JacquardService.shared.isJacquardConnected() {
                JacquardService.shared.activateBluetooth { _ in
                    guard self.navigationController != nil else {
                        JacquardService.shared.connect(viewController: self)
                        return
                    }
                    JacquardService.shared.connect(viewController: self.navigationController!)
                }
            }
        })
    }

    @objc private func rainbowGlowButtonTapped() {
        UIView.animate(withDuration: 0.3, animations: {
            self.rainbowGlowButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.rainbowGlowButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: { _ in
            JacquardService.shared.rainbowGlowJacket()
        })
    }

}

extension ViewController: JacquardServiceDelegate {

    // MARK: Built-in Gesture Handlers

    func didDetectDoubleTapGesture() {
        gestureLabel.text = "Double Tap"
    }

    func didDetectBrushInGesture() {
        gestureLabel.text = "Brush In"
    }

    func didDetectBrushOutGesture() {
        gestureLabel.text = "Brush Out"
    }

    func didDetectCoverGesture() {
        gestureLabel.text = "Cover"
    }

    func didDetectScratchGesture() {
        gestureLabel.text = "Scratch"
    }

    func didDetectForceTouchGesture() {
        gestureLabel.text = "Force Touch"
    }

    func didDetectZoomInGesture() {
        gestureLabel.text = "Zoom In"
    }

    func didDetectZoomOutGesture() {
        gestureLabel.text = "Zoom Out"
    }

    func didDetectThreadTouch(threadArray: [Float]) {
        for (thread, threadValue) in zip(self.threadArray, threadArray) {
            if threadValue > 0 {
                UIView.animate(withDuration: 0.1) {
                    thread.alpha = 1
                    thread.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                }
            } else {
                UIView.animate(withDuration: 0.1) {
                    thread.alpha = 0.3
                    thread.transform = CGAffineTransform(scaleX: 1, y: 1)
                }
            }
        }
    }

    func didDetectConnection(isConnected: Bool) {
        connectButton.setTitle(isConnected ? "Connected" : "Connect", for: .normal)
        connectButton.isEnabled = !isConnected
        rainbowGlowButton.isEnabled = isConnected
        for thread in threadArray {
            thread.alpha = isConnected ? 1.0 : 0.3
        }
    }

}
