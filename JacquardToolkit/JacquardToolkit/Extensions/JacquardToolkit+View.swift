//
//  JacquardToolkit+View.swift
//  JacquardToolkit
//
//  Created by Caleb Rudnicki on 7/22/19.
//

import Foundation

extension UIView {
    
    func addSubviews(_ views: [UIView]) {
        for view in views {
            self.addSubview(view)
        }
    }
    
}
