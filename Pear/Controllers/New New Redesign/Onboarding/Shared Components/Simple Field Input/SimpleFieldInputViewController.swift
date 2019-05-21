//
//  SimpleFieldInputViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/16/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class SimpleFieldInputViewController: UIViewController {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var visibilityLabel: UILabel!
  @IBOutlet weak var inputTextField: UITextField!
  @IBOutlet weak var inputFieldContainerView: UIView!
  
  var visible: Bool!
  var fieldName: String!
  var previousValue: String?
  var placeholder: String?
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(fieldName: String, previousValue: String?, placeholder: String?, visibility: Bool = true) -> SimpleFieldInputViewController? {
    guard let inputFieldVC = R.storyboard.simpleFieldInputViewController()
      .instantiateInitialViewController() as? SimpleFieldInputViewController else {
        return nil
    }
    inputFieldVC.fieldName = fieldName
    inputFieldVC.previousValue = previousValue
    inputFieldVC.placeholder = placeholder
    inputFieldVC.visible = visibility
    return inputFieldVC
  }

  func getNewFieldValue() -> String? {
    if self.inputTextField.text != self.previousValue {
      return self.inputTextField.text
    }
    return nil
  }
  
}

// MARK: - Life Cycle
extension SimpleFieldInputViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setup()
  }
  
  func stylize() {
    if visible {
      self.visibilityLabel.text = "Visible"
    } else {
      self.visibilityLabel.text = "Hidden"
    }
    self.titleLabel.text = self.fieldName
    if let font = R.font.openSansBold(size: 14.0) {
      self.titleLabel.font = font
    }
    self.titleLabel.textColor = R.color.primaryTextColor()
    self.inputTextField.text = self.previousValue
    self.inputTextField.placeholder = self.placeholder
    self.inputTextField.tintColor = R.color.primaryBrandColor()
    if let font = R.font.openSansBold(size: 16) {
      self.inputTextField.font = font
    }
    self.inputTextField.textColor = R.color.primaryTextColor()
    self.inputFieldContainerView.layer.cornerRadius = 12
    self.inputFieldContainerView.layer.borderColor = UIColor(white: 0.95, alpha: 1.0).cgColor
    self.inputFieldContainerView.layer.borderWidth = 1.0
  }
  
  func setup() {
    
  }

}