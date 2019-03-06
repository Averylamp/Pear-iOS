//
//  GetStartedNotifyFriendViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/14/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class GetStartedNotifyFriendViewController: UIViewController {
    
    var gettingStartedData: GettingStartedUserProfileData!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var inputTextFieldContainerView: UIView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var inputTextFieldTitle: UILabel!
    
    @IBOutlet weak var nextButtonBottomConstraint: NSLayoutConstraint!
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(gettingStartedData: GettingStartedUserProfileData) -> GetStartedNotifyFriendViewController? {
        let storyboard = UIStoryboard(name: String(describing: GetStartedNotifyFriendViewController.self), bundle: nil)
        guard let notifyFriendVC = storyboard.instantiateInitialViewController() as? GetStartedNotifyFriendViewController else { return nil }
        notifyFriendVC.gettingStartedData = gettingStartedData
        return notifyFriendVC
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        if let phoneNumber = inputTextField.text?.filter("0123456789".contains), phoneNumber.count == 10 {
            print("Verifying phone number")
            self.inputTextField.textColor = UIColor.lightGray
            self.inputTextField.isEnabled = false
            self.nextButton.backgroundColor = UIColor.white
            self.nextButton.setTitleColor(StylingConfig.nextButtonColor, for: .normal)
            self.nextButton.isEnabled = false
            let activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40),
                                                            type: NVActivityIndicatorType.ballScaleRippleMultiple,
                                                            color: StylingConfig.textFontColor,
                                                            padding: 0)
            self.view.addSubview(activityIndicator)
            activityIndicator.center = CGPoint(x: self.view.center.x, y: self.inputTextFieldContainerView.frame.origin.y + self.inputTextFieldContainerView.frame.height + 40)
            activityIndicator.startAnimating()
            
            self.delay(delay: 2.0) {
                guard let allowNotificationVC = GetStartedAllowNotificationsViewController.instantiate(friendName: self.gettingStartedData.profileFirstName) else {
                    print("Failed to create Allow Notifications VC")
                    return
                }
                self.navigationController?.pushViewController(allowNotificationVC, animated: true)
            }
        }
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension GetStartedNotifyFriendViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.inputTextField.delegate = self
        
        self.stylize()
        self.addKeyboardSizeNotifications()
        print(self.gettingStartedData)
    }
    
    func stylize() {
        self.nextButton.stylizeLight()
        self.titleLabel.stylizeTitleLabel()
        self.subtitleLabel.stylizeSubtitleLabel()
        
        self.inputTextFieldContainerView.stylizeInputTextFieldContainer()
        self.inputTextField.stylizeInputTextField()
        self.inputTextFieldTitle.stylizeTextFieldTitle()
        
        if let profileFirstName = self.gettingStartedData.profileFirstName {
            self.nextButton.setTitle("Send to \(profileFirstName)", for: .normal)
            self.subtitleLabel.text = "We'll send \(profileFirstName) a link to the profile so they can approve it."
        }
    }
    
}

// MARK: - UITextFieldDelegate
extension GetStartedNotifyFriendViewController: UITextFieldDelegate {
    
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
                    self.nextButtonClicked(self.nextButton)
                }
            } else {
                textField.text = String.formatPhoneNumber(phoneNumber: fullString)
            }
        }
        return false
        
    }
    
}

// MARK: - Dismiss First Responder on Click
extension GetStartedNotifyFriendViewController {
    func addDismissKeyboardOnViewClick() {
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GetStartedNotifyFriendViewController.dismissKeyboard)))
    }
    
    @objc func dismissKeyboard() {
        self.inputTextField.resignFirstResponder()
    }
}

// MARK: - Keybaord Size Notifications
extension GetStartedNotifyFriendViewController {
    
    func addKeyboardSizeNotifications() {
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(GetStartedNotifyFriendViewController.keyboardWillChange(notification:)),
                         name: UIWindow.keyboardWillChangeFrameNotification,
                         object: nil)
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(GetStartedNotifyFriendViewController.keyboardWillHide(notification:)),
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
            self.nextButtonBottomConstraint.constant = targetFrame.size.height - self.view.safeAreaInsets.bottom + keyboardBottomPadding
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    @objc func keyboardWillHide(notification: Notification) {
        if let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            let keyboardBottomPadding: CGFloat = 20
            
            if let profileFirstName = self.gettingStartedData.profileFirstName {
                self.subtitleLabel.text = "We'll send \(profileFirstName) a link to the profile so they can approve it."
            } else {
                self.subtitleLabel.text = "We'll send them a link to the profile so they can approve it."
            }
            self.nextButtonBottomConstraint.constant = keyboardBottomPadding
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
}
