//
//  AgeRangeInputViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/22/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class AgeRangeInputViewController: UIViewController {
  
    private var initialMinAge: Int = 18
    private var initialMaxAge: Int = 24
    var minAge: Int = 18
    var maxAge: Int = 24
    
    @IBOutlet weak var minimumTextInputContainer: UIView!
    @IBOutlet weak var maximumTextInputContainer: UIView!
    @IBOutlet weak var minimumTextField: UITextField!
    @IBOutlet weak var maximumTextField: UITextField!
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(minAge: Int, maxAge: Int) -> AgeRangeInputViewController? {
      guard let agePrefVC = R.storyboard.ageRangeInputViewController
        .instantiateInitialViewController() as? AgeRangeInputViewController else { return nil }
      agePrefVC.initialMinAge = minAge
      agePrefVC.initialMaxAge = maxAge
      agePrefVC.minAge = minAge
      agePrefVC.maxAge = maxAge
      return agePrefVC
    }
    
  }
  
  // MARK: - Life Cycle
  extension AgeRangeInputViewController {
    
    override func viewDidLoad() {
      super.viewDidLoad()
      self.setup()
      self.stylize()
      self.minimumTextField.delegate = self
      self.maximumTextField.delegate = self
    }
    
    func setup() {
      self.minimumTextField.addTarget(self, action: #selector(AgeRangeInputViewController.textFieldDidChange), for: .editingChanged)
      self.maximumTextField.addTarget(self, action: #selector(AgeRangeInputViewController.textFieldDidChange), for: .editingChanged)
    }
    
    func stylize() {
      self.minimumTextInputContainer.layer.cornerRadius = 12
      self.minimumTextInputContainer.layer.borderColor = UIColor(white: 0.95, alpha: 1.0).cgColor
      self.minimumTextInputContainer.layer.borderWidth = 1.0

      self.maximumTextInputContainer.layer.cornerRadius = 12
      self.maximumTextInputContainer.layer.borderColor = UIColor(white: 0.95, alpha: 1.0).cgColor
      self.maximumTextInputContainer.layer.borderWidth = 1.0
      
      self.updateTextFields()
      if let font = R.font.openSansBold(size: 16.0) {
        self.minimumTextField.font = font
        self.maximumTextField.font = font
      }
      self.minimumTextField.textColor = R.color.primaryTextColor()
      self.maximumTextField.textColor = R.color.primaryTextColor()
      
      self.minimumTextField.placeholder = "Min"
      self.maximumTextField.placeholder = "Max"
    }
    
    func updateTextFields() {
      self.minimumTextField.text = "\(self.minAge)"
      self.maximumTextField.text = "\(self.maxAge)"
    }
    
  }
  
  extension AgeRangeInputViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
      if let text = textField.text, let age = Int(text), age >= 18 && age < 80 {
        if textField == self.minimumTextField {
          if age <= self.maxAge {
            self.minAge = age
          }
        } else {
          if age >= self.minAge {
            self.maxAge = age
          }
        }
      }
      self.updateTextFields()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      if let text = textField.text, text.count + string.count - range.length > 2 {
        return false
      }
      return true
    }
    
    @objc func textFieldDidChange() {
      if let minText = self.minimumTextField.text,
        let minAge = Int(minText), minAge >= 18 {
        if minAge < self.maxAge {
          self.minAge = minAge
        }
      }
      if let maxText = self.maximumTextField.text,
        let maxAge = Int(maxText), maxAge <= 80 {
        if maxAge >= self.minAge {
          self.maxAge = maxAge
        }
      }
    }
    
}
