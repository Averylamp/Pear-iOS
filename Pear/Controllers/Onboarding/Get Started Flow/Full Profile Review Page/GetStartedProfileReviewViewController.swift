//
//  GetStartedProfileReviewViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/14/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetStartedProfileReviewViewController: UIViewController {

    var gettingStartedData: GettingStartedData!
    
    @IBOutlet weak var profileReviewLabel: UILabel!
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(gettingStartedData: GettingStartedData) -> GetStartedProfileReviewViewController {
        let storyboard = UIStoryboard(name: String(describing: GetStartedProfileReviewViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GetStartedProfileReviewViewController
        vc.gettingStartedData = gettingStartedData
        return vc
    }
    
    @IBAction func continueButtonClicked(_ sender: Any) {
        let notifyFriendVC = GettingStartedNotifyFriendViewController.instantiate(gettingStartedData: self.gettingStartedData)
        self.navigationController?.pushViewController(notifyFriendVC, animated: true)
    }
}

// MARK: - Life Cycle
extension GetStartedProfileReviewViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupFullProfileView()
    }
    
    func setupFullProfileView(){
        
        let fullProfileViewController = FullProfileViewController.instantiate(profileData: self.gettingStartedData.profileData)
        self.addChild(fullProfileViewController)
        self.view.addSubview(fullProfileViewController.view)
        fullProfileViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addConstraints([
                NSLayoutConstraint(item: fullProfileViewController.view, attribute: .top, relatedBy: .equal, toItem: self.profileReviewLabel, attribute: .bottom, multiplier: 1.0, constant: 10),
                NSLayoutConstraint(item: fullProfileViewController.view, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: fullProfileViewController.view, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: fullProfileViewController.view, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0),
            ])
        
        
        fullProfileViewController.didMove(toParent: self)
        
    }
    
}
