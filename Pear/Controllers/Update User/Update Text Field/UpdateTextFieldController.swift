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
  case schoolName
  case schoolYear
  case unknown
}

class UpdateTextFieldController: UpdateUIViewController {
  
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
                         textFieldTitle: String) -> UpdateTextFieldController? {
    let storyboard = UIStoryboard(name: String(describing: UpdateTextFieldController.self), bundle: nil)
    guard let textFieldVC = storyboard.instantiateInitialViewController() as? UpdateTextFieldController else { return nil }
    textFieldVC.type = type
    textFieldVC.initialText = initialText
    textFieldVC.textFieldTitle = textFieldTitle
    return textFieldVC
  }
  
  override func didMakeUpdates() -> Bool {
    return inputTextField.text != initialText
  }
  
  @IBAction func textFieldSubtitleClicked(_ sender: Any) {
    self.inputTextField.becomeFirstResponder()
  }
  
}

// MARK: - Life Cycle
extension UpdateTextFieldController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylizeForType()
    self.stylize()
  }
  
  func stylize() {
    self.expandingTextContainerView.layer.borderColor = UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.00).cgColor
    self.expandingTextContainerView.layer.borderWidth = 2
    self.expandingTextContainerView.layer.cornerRadius = 8
    
    self.textFieldSubtitleButton.stylizeTextFieldButton()
    
    self.inputTextField.delegate = self
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
  
  func stylizeForType() {
    switch self.type {
    case .firstName:
      self.editable = false
    case .lastName:
      self.editable = false
    case .birthday:
      self.editable = false
    case .gender:
      self.editable = false
    case .location:
      self.editable = true
      self.inputTextField.textContentType = .addressCityAndState
    case .schoolName:
      self.editable = true
    case .schoolYear:
      self.editable = true
      self.inputTextField.keyboardType = .numberPad
    case .unknown:
      break
    }
  }

}

extension UpdateTextFieldController: UITextFieldDelegate {
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if self.type == .schoolYear {
      if let schoolYearText = self.inputTextField.text, schoolYearText.count + string.count - range.length > 4 {
        return false
      }
    }
    return true
  }
  
}
