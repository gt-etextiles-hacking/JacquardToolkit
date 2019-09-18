//
//  JacquardToolkit+Extensions.swift
//  JacquardToolkit
//
//  Created by Caleb Rudnicki on 9/18/19.
//

import Foundation

extension UIColor {
    static let jsLightGrey = UIColor(red: 248/255, green: 247/255, blue: 243/255, alpha: 1)
    static let jsDarkGrey = UIColor(red: 231/255, green: 220/255, blue: 236/255, alpha: 1)
}

extension UIView {
    func addSubviews(_ views: [UIView]) {
        for view in views {
            self.addSubview(view)
        }
    }
}

extension String {
    var isInt: Bool {
        return Int(self) != nil
    }
}
