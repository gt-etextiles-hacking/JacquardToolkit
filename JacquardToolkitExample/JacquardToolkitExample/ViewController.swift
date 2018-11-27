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

    override func viewDidLoad() {
        super.viewDidLoad()
        let myString = Service.doSomething()
        print(myString)
    }


}

