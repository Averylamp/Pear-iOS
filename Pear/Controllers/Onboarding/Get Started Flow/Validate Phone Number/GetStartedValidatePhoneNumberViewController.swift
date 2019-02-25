//
//  GetStartedValidatePhoneNumberViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/10/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit
import FirebaseAuth

class GetStartedValidatePhoneNumberViewController: UIViewController {
    
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var gettingStartedData: GetttingStartedData!
    var formattingPattern = "***-***-****"
    var replacementChar: Character = "*"
    

    @IBOutlet weak var nextButtonBottomConstraint: NSLayoutConstraint!

    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(gettingStartedData: GetttingStartedData) -> GetStartedValidatePhoneNumberViewController {
        
        let storyboard = UIStoryboard(name: String(describing: GetStartedValidatePhoneNumberViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GetStartedValidatePhoneNumberViewController
        vc.gettingStartedData = gettingStartedData
        return vc
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        HapticFeedbackGenerator.generateHapticFeedback(style: .light)
        self.showLoadingIndicator()
        if let phoneNumber = inputTextField.text?.filter("0123456789".contains), phoneNumber.count == 10 {
            let fullPhoneNumber = "+1" + phoneNumber
            print("Verifying phone number")
            PhoneAuthProvider.provider().verifyPhoneNumber(fullPhoneNumber, uiDelegate: nil) { (verificationID, error) in
                if let error = error {
                    self.alert(title: "Error validating Phone Number", message: error.localizedDescription)
                    return
                }
                
                guard let verificationID = verificationID else { return }
                self.gettingStartedData.userPhoneNumber = phoneNumber
                print("Phone number validated, \(fullPhoneNumber), \(phoneNumber)")
                // Sign in using the verificationID and the code sent to the user
                // ...
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                
                let phoneNumberCodeVC = GetStartedValidatePhoneNumberCodeViewController.instantiate(endorsement: self.gettingStartedData, verificationID: verificationID)
                self.navigationController?.pushViewController(phoneNumberCodeVC, animated: true)
            }
        }else{
            self.alert(title: "Phone number not detected", message: "Please input your 10 digit phone number")
            
        }

    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}


// MARK: - Life Cycle
extension GetStartedValidatePhoneNumberViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        self.inputTextField.becomeFirstResponder()
        self.inputTextField.delegate = self
        self.styleViews()
        self.addKeyboardSizeNotifications()
        
    }
    
    func styleViews(){
        self.titleLabel.font = UIFont(name: Config.displayFontRegular, size: 28)
        self.titleLabel.textColor = Config.textFontColor
        if let firstName = self.gettingStartedData.userFirstName {
            self.titleLabel.text = "Hi, \(firstName)!  To verify you, we need your phone #"
        }else{
            self.titleLabel.text = "Hi!  To verify you, we need your phone #"
        }
        
        self.nextButton.backgroundColor = Config.nextButtonColor
        self.nextButton.layer.cornerRadius = self.nextButton.frame.height / 2.0
        self.nextButton.layer.shadowRadius = 1
        self.nextButton.layer.shadowColor = UIColor(white: 0.0, alpha: 0.15).cgColor
        self.nextButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.nextButton.setTitleColor(UIColor.white, for: .normal)
        self.nextButton.titleLabel?.font = UIFont(name: Config.textFontSemiBold, size: 17)
        
    }

    
    func addKeyboardSizeNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(GetStartedValidatePhoneNumberViewController.keyboardWillChange(notification:)), name: UIWindow.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GetStartedValidatePhoneNumberViewController.keyboardWillHide(notification:)), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
}

// MARK: - UITextFieldDelegate
extension GetStartedValidatePhoneNumberViewController: UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var fullString = textField.text ?? ""
        fullString.append(string.filter("0123456789".contains))
        if range.length == 1 {
            textField.text = format(phoneNumber: fullString, shouldRemoveLastDigit: true)
        } else if string == " "{
            return true
        } else if string.count != 0 {
            if fullString.filter("0123456789".contains).count == 11 && "1" == fullString.filter("0123456789".contains).substring(toIndex: 1){
                textField.text = format(phoneNumber: fullString.filter("0123456789".contains).substring(fromIndex: 1))
            }else{
                textField.text = format(phoneNumber: fullString)
            }
        }
        return false
    }
    

    func format(phoneNumber: String, shouldRemoveLastDigit: Bool = false) -> String {
        guard !phoneNumber.isEmpty else { return "" }
        guard let regex = try? NSRegularExpression(pattern: "[\\s-\\(\\)]", options: .caseInsensitive) else { return "" }
        let r = NSString(string: phoneNumber).range(of: phoneNumber)
        var number = regex.stringByReplacingMatches(in: phoneNumber, options: .init(rawValue: 0), range: r, withTemplate: "")
        
        if number.count > 10 {
            let tenthDigitIndex = number.index(number.startIndex, offsetBy: 10)
            number = String(number[number.startIndex..<tenthDigitIndex])
        }
        
        if shouldRemoveLastDigit {
            let end = number.index(number.startIndex, offsetBy: number.count-1)
            number = String(number[number.startIndex..<end])
        }
        
        if number.count < 7 {
            let end = number.index(number.startIndex, offsetBy: number.count)
            let range = number.startIndex..<end
            number = number.replacingOccurrences(of: "(\\d{3})(\\d+)", with: "($1) $2", options: .regularExpression, range: range)
            
        } else {
            let end = number.index(number.startIndex, offsetBy: number.count)
            let range = number.startIndex..<end
            number = number.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "($1) $2-$3", options: .regularExpression, range: range)
        }
        
        return number
    }

}



// MARK: - Keybaord Size Notifications
extension GetStartedValidatePhoneNumberViewController{
    
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
