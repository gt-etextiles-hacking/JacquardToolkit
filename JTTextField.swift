//
//  JTTextField.swift
//  JacquardToolkit
//
//  Created by Caleb Rudnicki on 9/16/19.
//

import UIKit

protocol JTTextFieldDelegate {
    func didBeginEditing(_ textField: JTTextField)
    func didEndEditing(_ textField: JTTextField)
    func textFieldValidationStateDidChange(to state: Bool)
}

class JTTextField: UITextField {
    
    enum ValidationState {
        case empty //TODO: Implement the empty case
        case valid
        case invalid
    }
    
    var validationState: ValidationState = .valid
    var jtTextFieldDelegate: JTTextFieldDelegate?
    
    // MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        placeholder = "Jacket ID"
        font = UIFont(name: "HelveticaNeue-Thin", size: 24)
        borderStyle = .roundedRect
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 1
        backgroundColor = .jsDarkGrey
        autocapitalizationType = UITextAutocapitalizationType(rawValue: 3)!
        clearButtonMode = .whileEditing
        translatesAutoresizingMaskIntoConstraints = false
        delegate = self
        
                
        addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc private func textFieldDidChange() {
        if let enteredText = text, enteredText.count > 9, enteredText.count < 12 {
            if String(enteredText.prefix(5)).isInt && String(enteredText.suffix(4)).isInt {
                changeValidationState(to: .valid)
                return
            }
        }
        changeValidationState(to: .invalid)
    }
    
    private func changeValidationState(to state: ValidationState) {
        if state != validationState {
            validationState = state
            switch state {
            case .invalid:
                self.layer.borderColor = UIColor.red.cgColor
                jtTextFieldDelegate?.textFieldValidationStateDidChange(to: false)
            case .valid:
                self.layer.borderColor = UIColor.gray.cgColor
                jtTextFieldDelegate?.textFieldValidationStateDidChange(to: true)
            case .empty:
                //TODO: Implement the empty case
                break
            }
        }
    }

}

extension JTTextField: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        jtTextFieldDelegate?.didBeginEditing(self)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        jtTextFieldDelegate?.didEndEditing(self)
    }
    
}
