//
//  UserAgePreferencesViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/2/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class UserAgePreferencesViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  
  var minAge: Int = 18
  var maxAge: Int = 24
  
  @IBOutlet weak var minimumSubtitleLabel: UILabel!
  @IBOutlet weak var maximumSubtitleLabel: UILabel!
  @IBOutlet weak var minimumTextInputContainer: UIView!
  @IBOutlet weak var maximumTextInputContainer: UIView!
  @IBOutlet weak var minimumTextField: UITextField!
  @IBOutlet weak var maximumTextField: UITextField!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(minAge: Int, maxAge: Int) -> UserAgePreferencesViewController? {
    let storyboard = UIStoryboard(name: String(describing: UserAgePreferencesViewController.self), bundle: nil)
    guard let agePrefVC = storyboard.instantiateInitialViewController() as? UserAgePreferencesViewController else { return nil }
    agePrefVC.minAge = minAge
    agePrefVC.maxAge = maxAge
    return agePrefVC
  }
  
}

// MARK: - Life Cycle
extension UserAgePreferencesViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.minimumTextField.delegate = self
    self.maximumTextField.delegate = self
  }
  
  func stylize() {
    self.updateTextFields()
    
   self.titleLabel.stylizePreferencesTitleLabel()
    self.minimumSubtitleLabel.stylizeTextFieldTitle()
    self.minimumTextInputContainer.stylizeInputTextFieldContainer()
    self.minimumTextField.stylizeInputTextField()
    self.maximumSubtitleLabel.stylizeTextFieldTitle()
    self.maximumTextInputContainer.stylizeInputTextFieldContainer()
    self.maximumTextField.stylizeInputTextField()
  }
  
  func updateTextFields() {
    self.minimumTextField.text = "\(self.minAge)"
    self.maximumTextField.text = "\(self.maxAge)"
  }
  
}

extension UserAgePreferencesViewController: UITextFieldDelegate {
  
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

}
