//
//  GetStartedFriendNameViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetStartedFriendNameViewController: UIViewController {
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var inputTextField: UITextField!
    
    var gettingStartedData: GetttingStartedData!
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(gettingStartedData: GetttingStartedData) -> GetStartedFriendNameViewController {
        let storyboard = UIStoryboard(name: String(describing: GetStartedFriendNameViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GetStartedFriendNameViewController
        vc.gettingStartedData = gettingStartedData
        return vc
    }
    
    
    @IBAction func backButtonClicked(_ sender: Any) {
        if let userName = inputTextField.text{
            self.gettingStartedData.profileData.fullName = userName
            let splitNames = userName.splitIntoFirstLastName()
            self.gettingStartedData.profileData.firstName = splitNames.0
            self.gettingStartedData.profileData.lastName = splitNames.1
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        HapticFeedbackGenerator.generateHapticFeedback(style: .light)
        if let userName = inputTextField.text{
            self.gettingStartedData.profileData.fullName = userName
            let splitNames = userName.splitIntoFirstLastName()
            self.gettingStartedData.profileData.firstName = splitNames.0
            self.gettingStartedData.profileData.lastName = splitNames.1
            if splitNames.0.count < 1{
                self.alert(title: "Name Missing", message: "Please enter your name")
                return
            }else if splitNames.1.count < 1{
                self.alert(title: "Last Name Missing", message: "Please enter your last name.  Don't worry we won't show it to anyone.  If necessary feel free to use just a last initial.")
                return
            }
            
            let friendNameVC = GetStartedAgeViewController.instantiate(gettingStartedData: self.gettingStartedData)
            self.navigationController?.pushViewController(friendNameVC, animated: true)
        }
    }
    
    @IBAction func clearButtonClicked(_ sender: Any) {
        self.inputTextField.text = ""
    }
}


// MARK: - Life Cycle
extension GetStartedFriendNameViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nextButton.contentMode = .scaleAspectFit
        self.inputTextField.text = self.gettingStartedData.profileData.fullName
        self.inputTextField.becomeFirstResponder()
    }
    
}
