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
    
    
    var numberLabels: [UILabel] = []
    var endorsement: Endorsement!
    var verificationID: String!
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(endorsement: Endorsement, verificationID: String) -> GetStartedValidatePhoneNumberCodeViewController {
        
        let storyboard = UIStoryboard(name: String(describing: GetStartedValidatePhoneNumberCodeViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GetStartedValidatePhoneNumberCodeViewController
        vc.endorsement = endorsement
        vc.verificationID = verificationID
        return vc
    }
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        if let inputText = sender.text{
            for i in 0..<inputText.count{
                if i < self.numberLabels.count{
                    let numberLabel = self.numberLabels[i]
                    numberLabel.text = inputText[i ..< i + 1]
                }
            }
            if inputText.count == 6 {
                HapticFeedbackGenerator.generateHapticFeedback(style: .light)
                let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: inputText)
                Auth.auth().currentUser!.linkAndRetrieveData(with: credential) { (authData, error) in
                    if let error = error {
                        self.alert(title: "Auth Error", message: error.localizedDescription)
                    }
                    self.alert(title: "Done", message: "Nice job")
                    
                    
                }
                
            }
        }
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
    
}


// MARK: - Life Cycle
extension GetStartedValidatePhoneNumberCodeViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hiddenInputField.becomeFirstResponder()
        self.setupVerificationView()
    }

    func setupVerificationView(){
        let numberSpacing: CGFloat = 16
        let lineWidth: CGFloat = (self.verificationView.frame.width - (5 * numberSpacing) - (2 * numberSpacing)) / 6.0
        let numberHeight: CGFloat = 30
        for i in 0..<6{
            let underlineView = UIView(frame: CGRect(x: numberSpacing + CGFloat(i) * ( lineWidth + numberSpacing) , y: self.verificationView.frame.height - 1, width: lineWidth, height: 1))
            underlineView.backgroundColor = UIColor.lightGray
            self.verificationView.addSubview(underlineView)
            
            let numberLabel = UILabel(frame: CGRect(x: underlineView.frame.origin.x, y: self.verificationView.frame.height - numberHeight, width: underlineView.frame.width, height: numberHeight))
            numberLabel.font = UIFont.systemFont(ofSize: 30, weight: .regular)
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
        if let text =  textField.text, text.count - range.length + string.count == 6 {
            // Finished typing in code
            self.numberLabels.forEach{
                $0.textColor = UIColor.lightGray
            }
            self.showLoadingIndicator()
        }
        return true
    }

    
}
