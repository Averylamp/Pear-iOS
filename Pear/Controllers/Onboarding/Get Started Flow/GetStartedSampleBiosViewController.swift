//
//  GetStartedSampleBiosViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetStartedSampleBiosViewController: UIViewController {
    
    
    @IBOutlet weak var profileCardView: UIView!
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate() -> GetStartedSampleBiosViewController {
        let storyboard = UIStoryboard(name: String(describing: GetStartedSampleBiosViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GetStartedSampleBiosViewController
        return vc
    }
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}


// MARK: - Life Cycle
extension GetStartedSampleBiosViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
 
        self.profileCardView.layer.shadowRadius = 1
        self.profileCardView.layer.shadowColor = UIColor.black.cgColor
        self.profileCardView.layer.shadowOpacity = 0.3
        self.profileCardView.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.profileCardView.layer.cornerRadius = 10
    }
    
}
