//
//  GetStartedAgeViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetStartedAgeViewController: UIViewController {
    
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    var endorsement: Endorsement!
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(endorsement: Endorsement) -> GetStartedAgeViewController {
        let storyboard = UIStoryboard(name: String(describing: GetStartedAgeViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GetStartedAgeViewController
        vc.endorsement = endorsement
        return vc
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        if let age = Int(self.inputTextField.text!){
            self.endorsement.age = age
            let interestsVC = GetStartedInterestsViewController.instantiate(endorsement: self.endorsement)
            self.navigationController?.pushViewController(interestsVC, animated: true)
        }
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    
    
}


// MARK: - Life Cycle
extension GetStartedAgeViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        if let age = self.endorsement.age {
            self.inputTextField.text = "\(age)"
        }
        self.inputTextField.text = "22"
    }
    
}
