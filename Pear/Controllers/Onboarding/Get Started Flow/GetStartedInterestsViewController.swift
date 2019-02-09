
//
//  GetStartedInterestsViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetStartedInterestsViewController: UIViewController {
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate() -> GetStartedInterestsViewController {
        let storyboard = UIStoryboard(name: String(describing: GetStartedInterestsViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GetStartedInterestsViewController
        return vc
    }
}


// MARK: - Life Cycle
extension GetStartedInterestsViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
}
