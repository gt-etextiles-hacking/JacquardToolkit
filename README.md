# JacquardToolkit

JacquardToolkit is a iOS framework to enable developers to develop their own applications using their Levi's Jacquard.

# What can I do with the Toolkit?

- Enable your applications bluetooth to start searching nearby devices
- Ability to easily connect with your own Levi's Jacquard
- Send a rainbow glow to your jacket
- React to gesture the user performs on their jacket
- Access each specific threads value at any point in time
- Play gesture tutorial videos for your users
- Tell if you are currently connected to your jacket

### Installation

JacquardToolkit is currently only availible as a Cocoapod.

1. Add a pod entry for JacquardToolkit to your Podfile: 
```sh
pod 'JacquardToolkit'
```
2. Update your Popdfile by running:
```sh
pod update
```
3. Don't forget to include the necessary import statement in your target class:
```sh
import JacquardToolkit
```

### Development

1. Add the 'Privacy - Camera Usage Description' to your Info.plist:
![Image of Privacy - Camera Usage Description](https://i.imgur.com/Ki84eK3.png)

2. Enable your device's bluetooth capabilities and connect to your jacket by passing in your jacket's UUID: 
```sh
import UIKit
import JacquardToolkit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        JacquardService.shared.activateBluetooth { _ in 
            JacquardService.shared.connect(viewController: self)
        }
    }
}
```

3. Send a colorful rainbow glow to your jacket: 
```sh
@IBAction func glowButtonTapped(_ sender: Any) {
    JacquardService.shared.rainbowGlowJacket()
}
```

4. Use the JacquardServiceDelegate to react to all of the user gestures (including Double Tap, Brush In, Brush Out, Cover, Scratch & Force Touch): 
```sh
override func viewDidLoad() {
    super.viewDidLoad()
    JacquardService.shared.delegate = self
}

extension ViewController: JacquardServiceDelegate {

    func didDetectDoubleTapGesture() {
        //Detected Double Tap Gesture
    }

    func didDetectBrushInGesture() {
        //Detected Brush In Gesture
    }

    func didDetectBrushOutGesture() {
        //Detected Brush Out Gesture
    }

    func didDetectCoverGesture() {
        //Detected Cover Gesture
    }

    func didDetectScratchGesture() {
        //Detected Scratch Gesture
    }

    func didDetectForceTouch() {
        //Detected Force Touch Gesture 
    }

}
```

5. Additionally, you can uncover the values of each specific thread: 
```sh
override func viewDidLoad() {
    super.viewDidLoad()
    JacquardService.shared.delegate = self
}

extension ViewController: JacquardServiceDelegate {

    func didDetectThreadTouch(threadArray: [Float]) {
        //Dected an array of 15 values that represent 
        //the intensity each thread is being touched by
    }

}
```

6. Show your user how to correctly perform the gestures with tutorial videos:
```sh
@IBAction func doubleTapTutorialButtonTapped(_ sender: Any) {
    JacquardService.shared.playDoubleTapTutorial(viewController: self, showDismissButton: true)
}

@IBAction func brushInTutorialButtonTapped(_ sender: Any) {
    JacquardService.shared.playBrushInTutorial(viewController: self, showDismissButton: true)
}

@IBAction func brushOutTutorialButtonTapped(_ sender: Any) {
    JacquardService.shared.playBrushOutTutorial(viewController: self, showDismissButton: true)
}

@IBAction func coverTutorialButtonTapped(_ sender: Any) {
    JacquardService.shared.playCoverTutorial(viewController: self, showDismissButton: true)
}

@IBAction func scratchTutorialButtonTapped(_ sender: Any) {
    JacquardService.shared.playScratchTutorial(viewController: self, showDismissButton: true)
}

@IBAction func forceTouchTutorialButtonTapped(_ sender: Any) {
    JacquardService.shared.playForceTouchTutorial(viewController: self, showDismissButton: true)
}
```

Be sure to check out the example application for more information (JacquardToolkitExample).

### Want to contribute?!
This is an open-source project so any additions, fixes, or cool new ideas are welcomed! If you have interest in contributing to JacquardToolkit, be sure to create your own fork of the repo and then submit a pull request when you are done.

### E-Textile Hacking 
This framework is just a small part of the project that our team at Georgia Tech has been working on. If you are interested in learning more about our project, please visit [our Medium publication](https://medium.com/e-textile-hacking).

![Jacquard Logo](https://i.imgur.com/DXSKUx9.jpg)

License
----
MIT
