//
//  GetStartedFriendNameViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit
import FirebaseAuth

class GetStartedCreateAccountEmailViewController: UIViewController {
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var inputTextField: UITextField!
    
    var endorsement: Endorsement!
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(endorsement: Endorsement) -> GetStartedCreateAccountEmailViewController {
        let storyboard = UIStoryboard(name: String(describing: GetStartedCreateAccountEmailViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GetStartedCreateAccountEmailViewController
        vc.endorsement = endorsement
        return vc
    }
    
    
    @IBAction func backButtonClicked(_ sender: Any) {
        if let userName = inputTextField.text{
            endorsement.name = userName
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        HapticFeedbackGenerator.generateHapticFeedback(style: .light)
        
        if let userEmail = inputTextField.text{
            self.endorsement.userEmail = userEmail
            let emailPasswordVC = GetStartedCreateAccountEmailPasswordViewController.instantiate(endorsement: endorsement)
            self.navigationController?.pushViewController(emailPasswordVC, animated: true)
        }
    }
    
    @IBAction func clearButtonClicked(_ sender: Any) {
        self.inputTextField.text = ""
    }
}


// MARK: - Life Cycle
extension GetStartedCreateAccountEmailViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nextButton.contentMode = .scaleAspectFit
        self.inputTextField.becomeFirstResponder()
    }
    
}
