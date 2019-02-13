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
            gettingStartedData.name = userName
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        HapticFeedbackGenerator.generateHapticFeedback(style: .light)
        if let userName = inputTextField.text{
            gettingStartedData.name = userName
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
        if let name = self.gettingStartedData.name{
            self.inputTextField.text = name
        }
        self.inputTextField.becomeFirstResponder()
    }
    
}
