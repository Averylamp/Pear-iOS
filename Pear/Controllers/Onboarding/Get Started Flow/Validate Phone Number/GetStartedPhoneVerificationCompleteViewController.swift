//
//  GetStartedPhoneVerificationCompleteViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/28/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetStartedPhoneVerificationCompleteViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextButtonBottomConstraint: NSLayoutConstraint!

    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate() -> GetStartedPhoneVerificationCompleteViewController? {
        let storyboard = UIStoryboard(name: String(describing: GetStartedPhoneVerificationCompleteViewController.self), bundle: nil)
        guard let phoneVerificationCompleteVC = storyboard.instantiateInitialViewController() as? GetStartedPhoneVerificationCompleteViewController else { return nil }
        return phoneVerificationCompleteVC
    }

    @IBAction func nextButtonClicked(_ sender: Any) {
        HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
        guard let startFriendProfileVC = GetStartedStartFriendProfileViewController.instantiate() else {
            print("Failed to create Choose flow VC")
            return
        }
        self.navigationController?.setViewControllers([startFriendProfileVC], animated: true)
    }
}

// MARK: - Life Cycle
extension GetStartedPhoneVerificationCompleteViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addKeyboardSizeNotifications()
        self.stylize()
    }

    func stylize() {
        self.nextButton.stylizeDarkColor()
        self.titleLabel.stylizeTitleLabel()
        self.subtitleLabel.stylizeSubtitleLabel()
    }

}

// MARK: - Keybaord Size Notifications
extension GetStartedPhoneVerificationCompleteViewController {
    func addKeyboardSizeNotifications() {
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(GetStartedPhoneVerificationCompleteViewController.keyboardWillChange(notification:)),
                         name: UIWindow.keyboardWillChangeFrameNotification,
                         object: nil)
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(GetStartedPhoneVerificationCompleteViewController.keyboardWillHide(notification:)),
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
