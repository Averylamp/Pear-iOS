//
//  GetStartedFriendNameViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetStartedStartFriendProfileViewController: UIViewController {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var inputTextField: UITextField!

    var gettingStartedData: GettingStartedData!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    @IBOutlet weak var bottomButtonBottomConstraint: NSLayoutConstraint!

    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate() -> GetStartedStartFriendProfileViewController? {
        let storyboard = UIStoryboard(name: String(describing: GetStartedStartFriendProfileViewController.self), bundle: nil)
        guard let startFriendProfileVC = storyboard.instantiateInitialViewController() as? GetStartedStartFriendProfileViewController else { return nil }
        startFriendProfileVC.gettingStartedData = GettingStartedData()
        return startFriendProfileVC
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

    @IBAction func skipProfileCreationButtonClicked(_ sender: Any) {

    }

}

// MARK: - Life Cycle
extension GetStartedStartFriendProfileViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.stylize()
        self.addKeyboardSizeNotifications()
    }

    func stylize() {
        self.titleLabel.stylizeTitleLabel()
        self.subtitleLabel.stylizeSubtitleLabel()
        self.nextButton.stylizeDarkColor()
    }

}

// MARK: - Keybaord Size Notifications
extension GetStartedStartFriendProfileViewController {

    func addKeyboardSizeNotifications() {
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(GetStartedStartFriendProfileViewController.keyboardWillChange(notification:)),
                         name: UIWindow.keyboardWillChangeFrameNotification,
                         object: nil)
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(GetStartedStartFriendProfileViewController.keyboardWillHide(notification:)),
                         name: UIWindow.keyboardWillHideNotification,
                         object: nil)
    }

    @objc func keyboardWillChange(notification: Notification) {
        if let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let targetFrameNSValue = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let targetFrame = targetFrameNSValue.cgRectValue
            let keyboardBottomPadding: CGFloat = 20
            self.bottomButtonBottomConstraint.constant = targetFrame.size.height - self.view.safeAreaInsets.bottom + keyboardBottomPadding
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    @objc func keyboardWillHide(notification: Notification) {
        if let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            let keyboardBottomPadding: CGFloat = 20
            self.bottomButtonBottomConstraint.constant = keyboardBottomPadding
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }

}
