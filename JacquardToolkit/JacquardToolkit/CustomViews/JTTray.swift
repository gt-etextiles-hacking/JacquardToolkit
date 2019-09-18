//
//  JTTray.swift
//  JacquardToolkit
//
//  Created by Caleb Rudnicki on 9/17/19.
//

import UIKit

internal protocol JTTrayDelegate {
    func didEnterValidJacketID(with id: String)
}

internal class JTTray: UIView {
    
    var jtTrayDelegate: JTTrayDelegate?
    
    private let containerView: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 30)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    private var textField = JTTextField()
    private var button = JTButton()

    // MARK: Initializers
    
    convenience init(frame: CGRect, title: String, textFieldPlaceholder: String, buttonTitle: String) {
        self.init(frame: frame)
        
        titleLabel.text = title
        textField = JTTextField(frame: frame, placeholder: textFieldPlaceholder)
        button = JTButton(frame: frame, title: buttonTitle)
        
        backgroundColor = .jtLightGrey
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.8
        layer.shadowOffset = .zero
        layer.shadowRadius = 5
        alpha = 0.99
        translatesAutoresizingMaskIntoConstraints = false
        
        textField.jtTextFieldDelegate = self
        button.jtButtonDelegate = self
        
        addSubviews([containerView, titleLabel, textField, button])
        updateConstraints()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Constraints
    
    public override func updateConstraints() {
        super.updateConstraints()
        
        guard let superview = self.superview else {
            return
        }
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            containerView.heightAnchor.constraint(equalTo: superview.heightAnchor, multiplier: 0.35)
            ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8)
            ])
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(greaterThanOrEqualTo: titleLabel.bottomAnchor, constant: 32),
            textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
            ])
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(greaterThanOrEqualTo: textField.bottomAnchor, constant: 32),
            button.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            button.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            button.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.25)
            ])
        
    }
    
    // MARK: Public functions
    
    func updateTitle(to string: String) {
        titleLabel.text = string
    }

}

extension JTTray: JTTextFieldDelegate {
    
    func didBeginEditing(_ textField: JTTextField) {
        //TextField did begin editing
    }
    
    func didEndEditing(_ textField: JTTextField) {
        //TextField did end editing
    }
    
    func textFieldValidationStateDidChange(to state: Bool) {
        button.isEnabled = state
    }
    
}

extension JTTray: JTButtonDelegate {
    
    func didTap(_ button: JTButton) -> Bool {
        if let text = textField.text?.uppercased() {
            jtTrayDelegate?.didEnterValidJacketID(with: text)
            return true
        }
        return false
    }
    
}
