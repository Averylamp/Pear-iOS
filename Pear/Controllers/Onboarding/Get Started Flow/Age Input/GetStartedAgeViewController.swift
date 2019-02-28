//
//  GetStartedAgeViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetStartedAgeViewController: UIViewController {

    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var inputTextFieldTitle: UILabel!
    @IBOutlet weak var inputTextFieldContainerView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressWidthConstraint: NSLayoutConstraint!

    var gettingStartedData: GettingStartedData!

    @IBOutlet weak var firstTitleLabel: UILabel!
    @IBOutlet weak var secondTitleLabel: UILabel!

    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(gettingStartedData: GettingStartedData) -> GetStartedAgeViewController? {
        let storyboard = UIStoryboard(name: String(describing: GetStartedAgeViewController.self), bundle: nil)
        guard let ageVC = storyboard.instantiateInitialViewController() as? GetStartedAgeViewController else { return nil }
        ageVC.gettingStartedData = gettingStartedData
        return ageVC
    }

    @discardableResult
    func saveAge() -> Int? {
        if let ageText = self.inputTextField.text, let age = Int(ageText) {
            self.gettingStartedData.profileData.age = age
            return age
        }
        return nil
    }

    @IBAction func nextButtonClicked(_ sender: Any) {
        HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)

        if let age = self.saveAge() {
            if age < 18 {
                self.alert(title: "Underage", message: "You must be 18 to use this app.  Sorry :/")
                return
            }
            if let interestsVC = GetStartedInterestsViewController.instantiate(gettingStartedData: self.gettingStartedData) {
                self.navigationController?.pushViewController(interestsVC, animated: true)
            } else {
                print("Failed to create Interests VC")
            }
        } else {
            self.alert(title: "Age Error", message: "There was a problem reading your age")
        }

    }

    @IBAction func backButtonClicked(_ sender: Any) {
        self.saveAge()
        self.navigationController?.popViewController(animated: true)
    }

}

// MARK: - Life Cycle
extension GetStartedAgeViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.gettingStartedData.profileData.age >= 18 {
            self.inputTextField.text = "\(self.gettingStartedData.profileData.age)"
        }

        self.inputTextField.becomeFirstResponder()
        self.inputTextField.delegate = self
        self.stylize()
        self.addKeyboardSizeNotifications()
    }

    func stylize() {
        self.nextButton.stylizeDark()
        self.inputTextFieldContainerView.stylizeInputTextFieldContainer()
        self.inputTextFieldTitle.stylizeTextFieldTitle()
        self.inputTextField.stylizeInputTextField()

        self.progressWidthConstraint.constant = 1.0 / Config.totalGettingStartedPagesNumber * self.view.frame.width
        self.view.layoutIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.layoutIfNeeded()
        self.progressWidthConstraint.constant = 2.0 / Config.totalGettingStartedPagesNumber * self.view.frame.width
        UIView.animate(withDuration: Config.progressBarAnimationDuration, delay: Config.progressBarAnimationDelay, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

}

// MARK: - UITextFieldDelegate
extension GetStartedAgeViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if self.inputTextField.text!.count + string.count - range.length > 2 {
            return false
        }
        return true
    }

}

// MARK: - Keybaord Size Notifications
extension GetStartedAgeViewController {

    func addKeyboardSizeNotifications() {
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(GetStartedAgeViewController.keyboardWillChange(notification:)),
                         name: UIWindow.keyboardWillChangeFrameNotification,
                         object: nil)
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(GetStartedAgeViewController.keyboardWillHide(notification:)),
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
