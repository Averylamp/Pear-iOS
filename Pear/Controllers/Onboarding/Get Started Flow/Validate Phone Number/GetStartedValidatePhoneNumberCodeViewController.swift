//
//  GetStartedValidatePhoneNumberCodeViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/10/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit
import FirebaseAuth

class GetStartedValidatePhoneNumberCodeViewController: UIViewController {
    

    @IBOutlet weak var hiddenInputField: UITextField!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var verificationView: UIView!
    
    @IBOutlet weak var subtitleLabel: UILabel!
    
    
    var numberLabels: [UILabel] = []
    var circleViews: [UIView] = []
    var gettingStartedData: GetttingStartedData!
    var verificationID: String!
    
    var isVerifying: Bool = false
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(gettingStartedData: GetttingStartedData, verificationID: String) -> GetStartedValidatePhoneNumberCodeViewController {
        
        let storyboard = UIStoryboard(name: String(describing: GetStartedValidatePhoneNumberCodeViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GetStartedValidatePhoneNumberCodeViewController
        vc.gettingStartedData = gettingStartedData
        vc.verificationID = verificationID
        return vc
    }

    @IBAction func nextButtonClicked(_ sender: Any) {
        
        
//        // 3. Get Firebase Verify ID token.
//        authData!.user.getIDTokenForcingRefresh(true) { token, error in
//            if let error = error {
//                self.alert(title: "Auth Error", message: error.localizedDescription)
//                return
//            }
//
//            guard let token = token else {
//                self.alert(title: "Auth Error", message: "Unknown error occurred")
//                return
//            }
//            // 4. Trade ID token for our own auth token.
//            self.authAPI.login(with: .firebase(token: token)) { result in
//                self.hideLoadingIndicator()
//                switch result {
//                case .success:
//                    guard let user = authData?.user else { return }
//
//                    break
//                case .failure(let error):
//                    self.alert(title: "Auth Error", message: error.localizedDescription)
//                }
//            }
//        }

    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func verificationViewClicked(_ sender: Any) {
        self.hiddenInputField.becomeFirstResponder()
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
    }
    
    func stylize(){
        if let phoneNumber = self.gettingStartedData.userPhoneNumber{
            self.subtitleLabel.text = "Sent to +1 \(String.formatPhoneNumber(phoneNumber: phoneNumber))"
        }
    }

    func setupVerificationView(){
        let sideInsets: CGFloat = 30
        let numberSpacing: CGFloat = 4
        let fullUsableSpace: CGFloat = self.verificationView.frame.width - (2 * sideInsets)
        let lineWidth: CGFloat = (fullUsableSpace - (5 * numberSpacing) ) / 6.0
        for i in 0..<6{
            let circleView = UIView(frame: CGRect(x: sideInsets + CGFloat(i) * ( lineWidth + numberSpacing) , y: self.verificationView.frame.height - 1, width: lineWidth, height: lineWidth))
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
                self.alert(title: "Done", message: "Nice job")
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
