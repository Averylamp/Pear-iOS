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
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextButtonBottomConstraint: NSLayoutConstraint!
    
    var gettingStartedData: GetttingStartedData!
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(gettingStartedData: GetttingStartedData) -> GetStartedAgeViewController {
        let storyboard = UIStoryboard(name: String(describing: GetStartedAgeViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GetStartedAgeViewController
        vc.gettingStartedData = gettingStartedData
        return vc
    }
    
    @discardableResult
    func saveAge() -> Int?{
        if let ageText = self.inputTextField.text, let age = Int(ageText){
            self.gettingStartedData.profileData.age = age
            return age
        }
        return nil
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
        
        if let age = self.saveAge(){
            if age < 18{
                self.alert(title: "Underage", message: "You must be 18 to use this app.  Sorry :/")
                return
            }
            let interestsVC = GetStartedInterestsViewController.instantiate(gettingStartedData: self.gettingStartedData)
            self.navigationController?.pushViewController(interestsVC, animated: true)
        }else{
            self.alert(title: "Age Error", message: "There was a problem reading your age")
        }
        
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.saveAge()
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
}


// MARK: - Life Cycle
extension GetStartedAgeViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.gettingStartedData.profileData.age >= 18 {
            self.inputTextField.text = "\(self.gettingStartedData.profileData.age)"
        }
        
        self.inputTextField.becomeFirstResponder()
        self.inputTextField.delegate = self
        self.stylize()
    }
    
    func stylize(){

        self.nextButton.stylizeDarkColor()
    }
    
    func addKeyboardSizeNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(GetStartedAgeViewController.keyboardWillChange(notification:)), name: UIWindow.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GetStartedAgeViewController.keyboardWillHide(notification:)), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
}

// MARK: - UITextFieldDelegate
extension GetStartedAgeViewController: UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if self.inputTextField.text!.count + string.count - range.length > 2 {
            return false
        }
        return true
    }
    
}

// MARK: - Keybaord Size Notifications
extension GetStartedAgeViewController{
    
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
