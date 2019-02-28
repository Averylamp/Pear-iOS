//
//  GetStartedNotifyFriendViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/14/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetStartedNotifyFriendViewController: UIViewController {

    var gettingStartedData: GettingStartedData!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var nextButtonBottomConstraint: NSLayoutConstraint!

    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(gettingStartedData: GettingStartedData) -> GetStartedNotifyFriendViewController? {
        let storyboard = UIStoryboard(name: String(describing: GetStartedNotifyFriendViewController.self), bundle: nil)
        guard let notifyFriendVC = storyboard.instantiateInitialViewController() as? GetStartedNotifyFriendViewController else { return nil }
        notifyFriendVC.gettingStartedData = gettingStartedData
        return notifyFriendVC
    }

    @IBAction func nextButtonClicked(_ sender: Any) {

    }

    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}

extension GetStartedNotifyFriendViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.stylize()
        self.addKeyboardSizeNotifications()
    }

    func stylize() {
        self.nextButton.stylizeLightColor()
        self.titleLabel.stylizeTitleLabel()
        self.subtitleLabel.stylizeSubtitleLabel()
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
            self.nextButtonBottomConstraint.constant = targetFrame.size.height - self.view.safeAreaInsets.bottom + keyboardBottomPadding
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    @objc func keyboardWillHide(notification: Notification) {
        if let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            let keyboardBottomPadding: CGFloat = 20
            self.nextButtonBottomConstraint.constant = keyboardBottomPadding
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }

}
