//
//  GetStartedYourNameViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetStartedYourNameViewController: UIViewController {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var inputTextField: UITextField!
    
    var gettingStartedData: GetttingStartedData!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var nextButtonBottomConstraint: NSLayoutConstraint!
    
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(gettingStartedData: GetttingStartedData) -> GetStartedYourNameViewController {
        let storyboard = UIStoryboard(name: String(describing: GetStartedYourNameViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GetStartedYourNameViewController
        vc.gettingStartedData = gettingStartedData
        return vc
    }
    
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        HapticFeedbackGenerator.generateHapticFeedback(style: .light)
        if let userName = inputTextField.text{
            self.gettingStartedData.profileData.endorsedFullName = userName
            self.gettingStartedData.userFullName = userName
            let splitNames = userName.splitIntoFirstLastName()
            self.gettingStartedData.userFirstName = splitNames.0
            self.gettingStartedData.userLastName = splitNames.1
            self.gettingStartedData.profileData.endorsedFirstName = splitNames.0
            self.gettingStartedData.profileData.endorsedLastName = splitNames.1
            if splitNames.0.count < 1{
                self.alert(title: "Name Missing", message: "Please enter your name")
                return
            }
            
            let phoneVerificationVC = GetStartedValidatePhoneNumberViewController.instantiate(gettingStartedData: self.gettingStartedData)
            self.navigationController?.pushViewController(phoneVerificationVC, animated: true)
        }
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        if let userName = inputTextField.text{
            self.gettingStartedData.profileData.endorsedFullName = userName
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clearButtonClicked(_ sender: Any) {
        self.inputTextField.text = ""
    }
}

// MARK: - Life Cycle
extension GetStartedYourNameViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nextButton.contentMode = .scaleAspectFit
        if let endorseeName = self.gettingStartedData.profileData.endorsedFullName{
            self.inputTextField.text = endorseeName
        }
        self.inputTextField.becomeFirstResponder()
        self.styleViews()
        self.addKeyboardSizeNotifications()
    }
    
    func styleViews(){
        self.titleLabel.font = UIFont(name: Config.displayFontRegular, size: 28)
        self.titleLabel.textColor = Config.textFontColor
        
        self.nextButton.backgroundColor = Config.nextButtonColor
        self.nextButton.layer.cornerRadius = self.nextButton.frame.height / 2.0
        self.nextButton.layer.shadowRadius = 1
        self.nextButton.layer.shadowColor = UIColor(white: 0.0, alpha: 0.15).cgColor
        self.nextButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.nextButton.setTitleColor(UIColor.white, for: .normal)
        self.nextButton.titleLabel?.font = UIFont(name: Config.textFontSemiBold, size: 17)
        
    }
    
    func addKeyboardSizeNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(GetStartedYourNameViewController.keyboardWillChange(notification:)), name: UIWindow.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GetStartedYourNameViewController.keyboardWillHide(notification:)), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    
}

// MARK: - Keybaord Size Notifications
extension GetStartedYourNameViewController{
    
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
