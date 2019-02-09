//
//  LandingNavigationViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/8/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class LandingNavigationViewController: UINavigationController {
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate() -> LandingNavigationViewController {
        let storyboard = UIStoryboard(name: String(describing: LandingNavigationViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! LandingNavigationViewController
        vc.viewControllers = [LandingScreenViewController.instantiate()]
        return vc
    }
}

// MARK: - Life Cycle
extension LandingNavigationViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
