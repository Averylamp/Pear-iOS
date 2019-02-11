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
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(endorsement: Endorsement) -> GetStartedValidatePhoneNumberCodeViewController {
        
        let storyboard = UIStoryboard(name: String(describing: GetStartedValidatePhoneNumberCodeViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GetStartedValidatePhoneNumberCodeViewController
        vc.endorsement = endorsement
        return vc
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        HapticFeedbackGenerator.generateHapticFeedback(style: .light)
        
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
        for i in 0..<6{
            let underlineView = UIView(frame: CGRect(x: numberSpacing + CGFloat(i) * ( lineWidth + numberSpacing) , y: self.verificationView.frame.height - 1, width: lineWidth, height: 1))
            underlineView.backgroundColor = UIColor.lightGray
            self.verificationView.addSubview(underlineView)
            
            let numberLabel = UILabel(frame: CGRect(x: CGFloat(i) * self.verificationView.frame.width / 6, y: 0, width: self.verificationView.frame.width, height: self.verificationView.frame.height))
            numberLabel.font = UIFont.systemFont(ofSize: 22, weight: .medium)
            numberLabel.tag = i
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
