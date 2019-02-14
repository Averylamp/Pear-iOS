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
            self.gettingStartedData.profileData.endorsedName = userName
            self.gettingStartedData.userFullName = userName
            let splitNames = userName.splitIntoFirstLastName()
            self.gettingStartedData.userFirstName = splitNames.0
            self.gettingStartedData.userLastName = splitNames.1
            if splitNames.0.count < 1{
                self.alert(title: "Name Missing", message: "Please enter your name")
                return
            }else if splitNames.1.count < 1{
                self.alert(title: "Last Name Missing", message: "Please enter your last name.  Don't worry we won't show it to anyone.  If necessary feel free to use just a last initial.")
                return
            }
            
            let friendNameVC = GetStartedFriendNameViewController.instantiate(gettingStartedData: self.gettingStartedData)
            self.navigationController?.pushViewController(friendNameVC, animated: true)
        }
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        if let userName = inputTextField.text{
            self.gettingStartedData.profileData.endorsedName = userName
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
        if let endorseeName = self.gettingStartedData.profileData.endorsedName{
            self.inputTextField.text = endorseeName
        }
        self.inputTextField.becomeFirstResponder()
    }
    
}
