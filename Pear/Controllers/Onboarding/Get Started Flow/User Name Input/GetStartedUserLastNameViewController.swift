//
//  GetStartedYourNameViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/26/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetStartedUserLastNameViewController: UIViewController {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var inputTextField: UITextField!
    
    var gettingStartedUserData: GettingStartedUserData!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var nextButtonBottomConstraint: NSLayoutConstraint!
    
    
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(gettingStartedUserData: GettingStartedUserData) -> GetStartedUserLastNameViewController {
        let storyboard = UIStoryboard(name: String(describing: GetStartedUserLastNameViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GetStartedUserLastNameViewController
        vc.gettingStartedUserData = gettingStartedUserData
        return vc
    }
    
    @discardableResult
    func saveLastName() -> String?{
        if let userLastName = inputTextField.text{
            self.gettingStartedUserData.lastName = userLastName
            return userLastName
        }
        return nil
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
        if let userFirstName = self.saveLastName(), userFirstName.count > 0{
            let phoneVerificationVC = GetStartedValidatePhoneNumberViewController.instantiate(gettingStartedUserData: self.gettingStartedUserData)
            self.navigationController?.pushViewController(phoneVerificationVC, animated: true)
        }else{
            self.alert(title: "Name Missing", message: "Please fill out your first name")
        }
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.saveLastName()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clearButtonClicked(_ sender: Any) {
        self.inputTextField.text = ""
    }
}

// MARK: - Life Cycle
extension GetStartedUserLastNameViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nextButton.contentMode = .scaleAspectFit
        if let userLastName = self.gettingStartedUserData.lastName{
            self.inputTextField.text = userLastName
        }
        self.inputTextField.becomeFirstResponder()
        self.stylize()
        self.addKeyboardSizeNotifications()
    }
    
    func stylize(){
        self.titleLabel.stylizeTitleLabel()
        
        self.nextButton.stylizeDarkColor()
    }
    
    func addKeyboardSizeNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(GetStartedUserLastNameViewController.keyboardWillChange(notification:)), name: UIWindow.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GetStartedUserLastNameViewController.keyboardWillHide(notification:)), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    
}

// MARK: - Keybaord Size Notifications
extension GetStartedUserLastNameViewController{
    
    @objc func keyboardWillChange(notification: Notification){
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let targetFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let bottomSpacing: CGFloat = 20
        self.nextButtonBottomConstraint.constant = targetFrame.size.height - self.view.safeAreaInsets.bottom + bottomSpacing
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: Notification){
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        self.nextButtonBottomConstraint.constant = 0
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
}
