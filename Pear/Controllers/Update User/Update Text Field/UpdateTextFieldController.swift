//
//  UpdateExpandingTextViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/7/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

enum UpdateTextFieldType: String {
  case firstName
  case lastName
  case birthday
  case gender
  case location
  case unknown
}

class UpdateTextFieldController: UIViewController {
  
  var initialText: String!
  var textFieldTitle: String!
  
  @IBOutlet weak var expandingTextContainerView: UIView!
  @IBOutlet weak var textFieldSubtitleButton: UIButton!
  @IBOutlet weak var inputTextField: UITextField!
  
  var type: UpdateTextFieldType = .unknown
  var editable: Bool = true
  var textContentType: UITextContentType?
  
  class func instantiate(type: UpdateTextFieldType,
                         initialText: String,
                         textFieldTitle: String,
                         allowEditing: Bool = true,
                         textContentType: UITextContentType? = nil) -> UpdateTextFieldController? {
    let storyboard = UIStoryboard(name: String(describing: UpdateTextFieldController.self), bundle: nil)
    guard let textFieldVC = storyboard.instantiateInitialViewController() as? UpdateTextFieldController else { return nil }
    textFieldVC.type = type
    textFieldVC.initialText = initialText
    textFieldVC.textFieldTitle = textFieldTitle
    textFieldVC.editable = allowEditing
    textFieldVC.textContentType = textContentType
    return textFieldVC
  }
  
  @IBAction func textFieldSubtitleClicked(_ sender: Any) {
    self.inputTextField.becomeFirstResponder()
  }
  
}

// MARK: - Life Cycle
extension UpdateTextFieldController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
  }
  
  func stylize() {
    self.expandingTextContainerView.layer.borderColor = UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.00).cgColor
    self.expandingTextContainerView.layer.borderWidth = 2
    self.expandingTextContainerView.layer.cornerRadius = 8
    
    self.textFieldSubtitleButton.stylizeTextFieldButton()
    
    if let contentType = self.textContentType {
      self.inputTextField.textContentType = contentType
    }
    
    self.inputTextField.text = initialText
    self.inputTextField.stylizeUpdateInputTextField()
    
    self.textFieldSubtitleButton.setTitle(self.textFieldTitle, for: .normal)
    
    if editable {
      self.inputTextField.isEnabled = true
      self.expandingTextContainerView.backgroundColor = nil
    } else {
      self.inputTextField.isEnabled = false
      self.expandingTextContainerView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.00)
    }
    
  }
  
}
