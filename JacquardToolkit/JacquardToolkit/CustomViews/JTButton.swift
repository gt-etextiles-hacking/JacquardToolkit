//
//  JTButton.swift
//  JacquardToolkit
//
//  Created by Caleb Rudnicki on 9/17/19.
//

import UIKit

internal protocol JTButtonDelegate {
    func didTap(_ button: JTButton) -> Bool
}

internal class JTButton: UIButton {
    
    var jtButtonDelegate: JTButtonDelegate?
    
    // MARK: Initializers
    
    convenience init(frame: CGRect, title: String) {
        self.init(frame: frame)
        
        setTitle(title, for: .normal)
        backgroundColor = .gray
        layer.cornerRadius = 10
        isEnabled = false
        translatesAutoresizingMaskIntoConstraints = false
        
        addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Actions
    
    @objc private func searchButtonTapped() {
        let _ = jtButtonDelegate?.didTap(self)
        //TODO: Do something with the button state
    }

}
