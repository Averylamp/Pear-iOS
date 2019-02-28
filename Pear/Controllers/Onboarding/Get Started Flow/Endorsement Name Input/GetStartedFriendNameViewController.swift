//
//  GetStartedFriendNameViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetStartedFriendNameViewController: UIViewController {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var inputTextField: UITextField!

    var gettingStartedData: GettingStartedData!
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var nextButtonBottomConstraint: NSLayoutConstraint!

    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(gettingStartedData: GettingStartedData) -> GetStartedFriendNameViewController? {
        let storyboard = UIStoryboard(name: String(describing: GetStartedFriendNameViewController.self), bundle: nil)
        guard let endorsedFriendNameVC = storyboard.instantiateInitialViewController() as? GetStartedFriendNameViewController else { return nil }
        endorsedFriendNameVC.gettingStartedData = gettingStartedData
        return endorsedFriendNameVC
    }

    @discardableResult
    func saveEndorsementFirstName() -> String? {
        if let endorsementFirstName = inputTextField.text {
            self.gettingStartedData.profileData.endorsedFirstName = endorsementFirstName
            return endorsementFirstName
        }
        return nil
    }

    @IBAction func nextButtonClicked(_ sender: Any) {
        HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
        if let endorseeFirstName = saveEndorsementFirstName() {
            if endorseeFirstName.count < 1 {
                self.alert(title: "Name Missing", message: "Please enter your name")
                return
            }

            guard let chooseGenderVC = GetStartedChooseGenderViewController.instantiate(gettingStartedData: self.gettingStartedData) else {
                print("Failed to create Gender VC")
                return
            }
            self.navigationController?.pushViewController(chooseGenderVC, animated: true)
        }
    }

    @IBAction func backButtonClicked(_ sender: Any) {
        self.saveEndorsementFirstName()
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func clearButtonClicked(_ sender: Any) {
        self.inputTextField.text = ""
    }
}

// MARK: - Life Cycle
extension GetStartedFriendNameViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.nextButton.contentMode = .scaleAspectFit
        if let endorseeFirst = self.gettingStartedData.profileData.endorsedFirstName {
            self.inputTextField.text = endorseeFirst
        }
        self.inputTextField.becomeFirstResponder()
        self.styleViews()
        self.addKeyboardSizeNotifications()
    }

    func styleViews() {
        self.titleLabel.font = UIFont(name: Config.displayFontRegular, size: 28)
        self.titleLabel.textColor = Config.textFontColor

        self.nextButton.stylizeDarkColor()

    }

}

// MARK: - Keybaord Size Notifications
extension GetStartedFriendNameViewController {

    func addKeyboardSizeNotifications() {
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(GetStartedFriendNameViewController.keyboardWillChange(notification:)),
                         name: UIWindow.keyboardWillChangeFrameNotification,
                         object: nil)
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(GetStartedFriendNameViewController.keyboardWillHide(notification:)),
                         name: UIWindow.keyboardWillHideNotification,
                         object: nil)
    }

    @objc func keyboardWillChange(notification: Notification) {
        if let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let targetFrameNSValue = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let targetFrame = targetFrameNSValue.cgRectValue
            self.nextButtonBottomConstraint.constant = targetFrame.size.height - self.view.safeAreaInsets.bottom
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    @objc func keyboardWillHide(notification: Notification) {
        if let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            self.nextButtonBottomConstraint.constant = 0
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }

}
