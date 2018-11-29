# JacquardToolkit

JacquardToolkit is a iOS frameowork to enable developers to develop their own applications using their Levi's Jacquard..

# New Features!

- Enable your applications bluetooth to start searching nearby devices
- Ability to easily connect with your own Levi's Jacquard
- Send a rainbow glow to your jacket with ease

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

1. Enable your device's bluetooth capabilities: 
```sh
Service.shared.activateBlutooth()
```

2. Connect to your jacket (make sure to pass in your jacket's UUID): 
```sh
Service.shared.connectToJacket(uuidString: String)
```

2. Send a colorful rainbow glow to your jacket: 
```sh
Service.shared.rainbowGlowJacket()
```

License
----
MIT
