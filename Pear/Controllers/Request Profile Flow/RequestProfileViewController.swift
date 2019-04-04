//
//  RequestProfileViewController.swift
//  Pear
//
//  Created by Brian Gu on 4/2/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import MessageUI
import Firebase
import ContactsUI

class RequestProfileViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var nextButton: UIButton!
  
  @IBOutlet weak var inputTextFieldContainerView: UIView!
  @IBOutlet weak var inputTextField: UITextField!
  @IBOutlet weak var inputTextFieldTitle: UILabel!
  
  @IBOutlet weak var skipButtonBottomConstraint: NSLayoutConstraint!
  var activityIndicator = NVActivityIndicatorView(frame: CGRect.zero)
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> RequestProfileViewController? {
    let storyboard = UIStoryboard(name: String(describing: RequestProfileViewController.self), bundle: nil)
    guard let requestProfileVC = storyboard.instantiateInitialViewController() as? RequestProfileViewController else { return nil }
    return requestProfileVC
  }
  
  @IBAction func nextButtonClicked(_ sender: Any) {
    if let phoneNumber = inputTextField.text?.filter("0123456789".contains), phoneNumber.count == 10 {
      print("Verifying phone number")
      
      if let userPhoneNumber = DataStore.shared.currentPearUser?.phoneNumber {
        self.alert(title: "Invalid phone number", message: "Please enter a phone number that is not your own.")
        return
      }
      if let userPhoneNumber = DataStore.shared.currentPearUser?.phoneNumber, phoneNumber == userPhoneNumber && phoneNumber != "9738738225" {
        self.alert(title: "Invalid phone number", message: "Please enter a valid phone number.")
        return
      }
      
      self.inputTextField.textColor = UIColor.lightGray
      self.inputTextField.isEnabled = false
      self.nextButton.backgroundColor = UIColor.white
      self.nextButton.setTitleColor(StylingConfig.nextButtonColor, for: .normal)
      self.nextButton.isEnabled = false
      self.activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40),
                                                       type: NVActivityIndicatorType.ballScaleRippleMultiple,
                                                       color: StylingConfig.textFontColor,
                                                       padding: 0)
      self.view.addSubview(activityIndicator)
      activityIndicator.center = CGPoint(x: self.view.center.x,
                                         y: self.inputTextFieldContainerView.frame.origin.y +
                                          self.inputTextFieldContainerView.frame.height + 40)
      activityIndicator.startAnimating()
      
      // #if DEVMODE
      // if let mainVC = LoadingScreenViewController.getMainScreenVC() {
      //   self.navigationController?.setViewControllers([mainVC], animated: true)
      // } else {
      //   print("Failed to create main VC")
      // }
      // return
      // #endif
      
      if MFMessageComposeViewController.canSendText() {
        let messageVC = MFMessageComposeViewController()
        messageVC.messageComposeDelegate = self
        
        messageVC.recipients = [phoneNumber]
        messageVC.body = "Hey! Help write a profile for me on Pear 🍐. https://getpear.com/go/refer"
        
        self.present(messageVC, animated: true, completion: nil)
      } else {
        if let mainVC = LoadingScreenViewController.getMainScreenVC() {
          self.navigationController?.setViewControllers([mainVC], animated: true)
        } else {
          print("Failed to create main VC")
        }
      }
    }
  }
  @IBAction func backButtonClicked(_ sender: Any) {
    Analytics.logEvent("clicked_request_profile_back", parameters: nil)
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func skipButtonClicked(_ sender: Any) {
    if let mainVC = LoadingScreenViewController.getMainScreenVC() {
        self.navigationController?.setViewControllers([mainVC], animated: true)
    } else {
        print("Failed to create main VC")
    }
  }
    
  @IBAction func contactsButtonClicked(_ sender: Any) {
    let cnPicker = CNContactPickerViewController()
    cnPicker.delegate = self
    cnPicker.predicateForEnablingContact = NSPredicate(format: "phoneNumbers.@count >= 1", argumentArray: nil)
    cnPicker.predicateForSelectionOfContact = NSPredicate(format: "phoneNumbers.@count == 1", argumentArray: nil)
    cnPicker.predicateForSelectionOfProperty = NSPredicate(format: "key == 'phoneNumbers'", argumentArray: nil)
    cnPicker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
    self.present(cnPicker, animated: true, completion: nil)
  }
  
}

extension RequestProfileViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.inputTextField.delegate = self
    
    self.stylize()
    self.addKeyboardSizeNotifications()
  }
  
  func stylize() {
    self.nextButton.stylizeLight()
    self.titleLabel.stylizeTitleLabel()
    self.subtitleLabel.stylizeSubtitleLabel()
    
    self.inputTextFieldContainerView.stylizeInputTextFieldContainer()
    self.inputTextField.stylizeInputTextField()
    self.inputTextFieldTitle.stylizeTextFieldTitle()
    
    self.nextButton.setTitle("Send", for: .normal)
    self.subtitleLabel.text = "Ask a friend to write you a profile."
  }
  
}

// MARK: - UITextFieldDelegate
extension RequestProfileViewController: UITextFieldDelegate {
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    var fullString = textField.text ?? ""
    fullString.append(string.filter("0123456789".contains))
    if range.length == 1 {
      textField.text = String.formatPhoneNumber(phoneNumber: fullString, shouldRemoveLastDigit: true)
    } else if string == " "{
      return true
    } else if string.count != 0 {
      if fullString.filter("0123456789".contains).count == 11 && "1" == fullString.filter("0123456789".contains).substring(toIndex: 1) {
        textField.text = String.formatPhoneNumber(phoneNumber: fullString.filter("0123456789".contains).substring(fromIndex: 1))
        if let phoneNumber = inputTextField.text?.filter("0123456789".contains), phoneNumber.count == 10 {
          self.nextButtonClicked(self.nextButton as Any)
        }
      } else {
        textField.text = String.formatPhoneNumber(phoneNumber: fullString)
      }
    }
    return false
  }
  
}

// MARK: - Dismiss First Responder on Click
extension RequestProfileViewController {
  func addDismissKeyboardOnViewClick() {
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RequestProfileViewController.dismissKeyboard)))
  }
  
  @objc func dismissKeyboard() {
    self.inputTextField.resignFirstResponder()
  }
}

// MARK: - Keybaord Size Notifications
extension RequestProfileViewController {
  
  func addKeyboardSizeNotifications() {
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(RequestProfileViewController.keyboardWillChange(notification:)),
                   name: UIWindow.keyboardWillChangeFrameNotification,
                   object: nil)
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(RequestProfileViewController.keyboardWillHide(notification:)),
                   name: UIWindow.keyboardWillHideNotification,
                   object: nil)
  }
  
  @objc func keyboardWillChange(notification: Notification) {
    if let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
      let targetFrameNSValue = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
      let targetFrame = targetFrameNSValue.cgRectValue
      let keyboardBottomPadding: CGFloat = 20
      if self.view.frame.height < 600 && targetFrame.height > 0 {
        self.subtitleLabel.text = ""
      }
      self.skipButtonBottomConstraint.constant = targetFrame.size.height - self.view.safeAreaInsets.bottom + keyboardBottomPadding
      UIView.animate(withDuration: duration) {
        self.view.layoutIfNeeded()
      }
    }
  }
  @objc func keyboardWillHide(notification: Notification) {
    if let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
      let keyboardBottomPadding: CGFloat = 20
      
      self.skipButtonBottomConstraint.constant = keyboardBottomPadding
      UIView.animate(withDuration: duration) {
        self.view.layoutIfNeeded()
      }
    }
  }
  
}

extension RequestProfileViewController: MFMessageComposeViewControllerDelegate {
  
  func dismissMessageVC(controller: MFMessageComposeViewController) {
    controller.dismiss(animated: true) {
      DispatchQueue.main.async {
        self.inputTextField.isEnabled = true
        self.inputTextField.stylizeInputTextField()
        self.nextButton.isEnabled = true
        self.nextButton.stylizeLight()
      }
    }
  }
  
  func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
    switch result {
    case .cancelled:
      self.dismissMessageVC(controller: controller)
    case .failed:
      self.dismissMessageVC(controller: controller)
    case .sent:
      controller.dismiss(animated: true) {
        if let mainVC = LoadingScreenViewController.getMainScreenVC() {
          self.navigationController?.setViewControllers([mainVC], animated: true)
        } else {
          print("Failed to create main VC")
        }
      }
    @unknown default:
      fatalError()
    }
  }
}

extension RequestProfileViewController: CNContactPickerDelegate {
  
  func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
    if let cnPhoneNumber = contact.phoneNumbers.first?.value {
      self.selectedPhoneNumberContactProperty(cnPhoneNumber: cnPhoneNumber)
    }
  }
  
  func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
    if let cnPhoneNumber = contactProperty.value as? CNPhoneNumber {
      self.selectedPhoneNumberContactProperty(cnPhoneNumber: cnPhoneNumber)
    }
  }
  
  func selectedPhoneNumberContactProperty(cnPhoneNumber: CNPhoneNumber) {
    var phoneNumber = cnPhoneNumber.stringValue
    phoneNumber = phoneNumber.filter("0123456789".contains)
    if phoneNumber.count == 11 && phoneNumber[0] == "1" {
      phoneNumber = phoneNumber[1..<11]
    }
    if phoneNumber.count != 10 {
      let alert = UIAlertController(title: "Not a Valid Number", message: "Contact must have a valid US phone number", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      DispatchQueue.main.async {
        self.present(alert, animated: true)
      }
    } else {
      self.inputTextField.text = phoneNumber
      self.textField(self.inputTextField, shouldChangeCharactersIn: NSRange(location: 0, length: phoneNumber.count), replacementString: phoneNumber)
    }
  }
  
  func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
    print("Cancel Contact Picker")
  }
  
}
