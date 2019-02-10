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
    
    var endorsement: Endorsement!
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(endorsement: Endorsement) -> GetStartedFriendNameViewController {
        let storyboard = UIStoryboard(name: String(describing: GetStartedFriendNameViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GetStartedFriendNameViewController
        vc.endorsement = endorsement
        return vc
    }
    
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        if let userName = inputTextField.text{
            endorsement.name = userName
            let friendNameVC = GetStartedAgeViewController.instantiate(endorsement: self.endorsement)
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
        if let name = self.endorsement.name{
            self.inputTextField.text = name
        }
    }
    
}
