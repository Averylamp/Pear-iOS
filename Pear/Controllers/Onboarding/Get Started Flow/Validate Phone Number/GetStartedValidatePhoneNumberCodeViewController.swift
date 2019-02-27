//
//  GetStartedValidatePhoneNumberCodeViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/10/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit
import FirebaseAuth
import NVActivityIndicatorView

class GetStartedValidatePhoneNumberCodeViewController: UIViewController {

    @IBOutlet weak var hiddenInputField: UITextField!
    @IBOutlet weak var verificationView: UIView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var resendCodeButton: UIButton!
    @IBOutlet weak var nextButtonBottomConstraint: NSLayoutConstraint!
    
    var numberLabels: [UILabel] = []
    var circleViews: [UIView] = []
    var gettingStartedData: GettingStartedData!
    var verificationID: String!
    var isVerifying: Bool = false
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(gettingStartedData: GettingStartedData, verificationID: String) -> GetStartedValidatePhoneNumberCodeViewController {
        
        let storyboard = UIStoryboard(name: String(describing: GetStartedValidatePhoneNumberCodeViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GetStartedValidatePhoneNumberCodeViewController
        vc.gettingStartedData = gettingStartedData
        vc.verificationID = verificationID
        return vc
    }

    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resendCodeButtonClicked(_ sender: Any) {
        self.hiddenInputField.text = ""
        self.updateCodeNumberLabels()
        if let phoneNumber = self.gettingStartedData.userPhoneNumber{
            let fullPhoneNumber = "+1" + phoneNumber
            HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
            self.hiddenInputField.isEnabled = false
            self.resendCodeButton.setTitleColor(UIColor.darkGray, for: .normal)
            self.resendCodeButton.backgroundColor = UIColor.lightGray
            self.resendCodeButton.isEnabled = false
            let activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40), type: NVActivityIndicatorType.ballScaleRippleMultiple, color: Config.textFontColor, padding: 0)
            self.view.addSubview(activityIndicator)
            activityIndicator.center = CGPoint(x: self.view.center.x, y: self.verificationView.frame.origin.y + self.verificationView.frame.height + 40)
            activityIndicator.startAnimating()
            PhoneAuthProvider.provider().verifyPhoneNumber(fullPhoneNumber, uiDelegate: nil) { (verificationID, error) in
                activityIndicator.stopAnimating()
                UIView.animate(withDuration: 0.5, animations: {
                    activityIndicator.alpha = 0.0
                }, completion: { (finished) in
                    activityIndicator.stopAnimating()
                    activityIndicator.removeFromSuperview()
                })

                self.resendCodeButton.isEnabled = true
                self.hiddenInputField.isEnabled = true
                self.resendCodeButton.setTitleColor(Config.textFontColor, for: .normal)
                self.resendCodeButton.backgroundColor = UIColor.white

                if let error = error {
                    HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .error)
                    self.alert(title: "Error validating Phone Number", message: error.localizedDescription)
                    return
                }
                
                guard let verificationID = verificationID else { return }
                // Sign in using the verificationID and the code sent to the user
                // ...
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                
                HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .success)
                self.hiddenInputField.becomeFirstResponder()
            }
        }

    }
    
    
}


// MARK: - Life Cycle
extension GetStartedValidatePhoneNumberCodeViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hiddenInputField.becomeFirstResponder()
        self.hiddenInputField.delegate = self
        self.stylize()
        self.setupVerificationView()
        self.updateCodeNumberLabels()
        self.addKeyboardSizeNotifications()
    }
    
    
    func stylize(){
        if let phoneNumber = self.gettingStartedData.userPhoneNumber{
            self.subtitleLabel.text = "Sent to +1 \(String.formatPhoneNumber(phoneNumber: phoneNumber))"
        }
        
        self.resendCodeButton.stylizeLightColor()
    }
    

    func setupVerificationView(){
        let sideInsets: CGFloat = 30
        let numberSpacing: CGFloat = 4
        let fullUsableSpace: CGFloat = self.verificationView.frame.width - (2 * sideInsets)
        let lineWidth: CGFloat = (fullUsableSpace - (5 * numberSpacing) ) / 6.0
        for i in 0..<6{
            let circleView = UIView(frame: CGRect(x: sideInsets + CGFloat(i) * ( lineWidth + numberSpacing) , y: 0, width: lineWidth, height: lineWidth))
            circleView.layer.cornerRadius = lineWidth / 2.0
            circleView.layer.borderWidth = 1
            circleView.layer.borderColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.00).cgColor
            circleView.tag = i
            self.circleViews.append(circleView)
            self.verificationView.addSubview(circleView)
            
            let numberLabel = UILabel(frame: CGRect(x: circleView.frame.origin.x, y: circleView.frame.origin.y, width: circleView.frame.width, height: circleView.frame.height))
            numberLabel.font = UIFont(name: Config.displayFontMedium, size: 26)
            numberLabel.textColor = Config.textFontColor
            numberLabel.tag = i
            numberLabel.textAlignment = .center
            self.numberLabels.append(numberLabel)
            self.verificationView.addSubview(numberLabel)
        }
    }
    
    func addKeyboardSizeNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(GetStartedValidatePhoneNumberCodeViewController.keyboardWillChange(notification:)), name: UIWindow.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GetStartedValidatePhoneNumberCodeViewController.keyboardWillHide(notification:)), name: UIWindow.keyboardWillHideNotification, object: nil)
    }

    
}

// MARK: - UITextFieldDelegate
extension GetStartedValidatePhoneNumberCodeViewController: UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard !isVerifying else { return false }
        var fullString = textField.text ?? ""
        fullString.append(string.filter("0123456789".contains))
        if range.length == 1 && fullString.count > 0 {
            fullString = fullString.substring(toIndex: fullString.count - 1)
        }
        
        // Prevent from overflowing
        fullString = fullString.substring(toIndex: 6)
        
        textField.text = fullString
        self.updateCodeNumberLabels()
        
        if fullString.count == 6 {
            self.isVerifying = true
            HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: fullString)
            Auth.auth().signInAndRetrieveData(with: credential) { (authData, error) in
                self.isVerifying = false
                if let error = error {
                    HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .error)
                    self.alert(title: "Auth Error", message: error.localizedDescription)
                    self.hiddenInputField.text = ""
                    self.updateCodeNumberLabels()
                }
                HapticFeedbackGenerator.generateHapticFeedbackNotification(style: .success)
                self.gettingStartedData.phoneNumberVerified = true
                
                
                let chooseFlowVC = GetStartedChooseFlowViewController.instantiate(gettingStartedData: self.gettingStartedData)
                self.navigationController?.setViewControllers([chooseFlowVC], animated: true)
            }
        }
        
        return false
    }
    
    
    func updateCodeNumberLabels(){
        if let text = self.hiddenInputField.text {
            for i in 0 ..< self.numberLabels.count{
                if i < text.count {
                    self.numberLabels[i].text = text[i..<i+1]
                    self.numberLabels[i].textColor = Config.textFontColor
                    self.circleViews[i].layer.borderColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.00).cgColor
                }else if i == text.count{
                    self.numberLabels[i].text = ""
                    self.numberLabels[i].textColor = Config.textFontColor
                    self.circleViews[i].layer.borderColor = UIColor(red:0.26, green:0.29, blue:0.33, alpha:1.00).cgColor
                }else{
                    self.numberLabels[i].text = ""
                    self.numberLabels[i].textColor = Config.textFontColor
                    self.circleViews[i].layer.borderColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.00).cgColor
                }
            }
        }
    }

}

// MARK: - Keybaord Size Notifications
extension GetStartedValidatePhoneNumberCodeViewController{
    
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
