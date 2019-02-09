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
            let friendNameVC = GetStartedFriendNameViewController.instantiate(endorsement: self.endorsement)
            self.navigationController?.pushViewController(friendNameVC, animated: true)
        }
    }
    
}


// MARK: - Life Cycle
extension GetStartedFriendNameViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nextButton.contentMode = .scaleAspectFit
        self.nextButton.layer.shadowRadius = 3
        self.nextButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.nextButton.layer.shadowOpacity = 0.4
        self.nextButton.layer.shadowColor = UIColor.black.cgColor
    }
    
}
