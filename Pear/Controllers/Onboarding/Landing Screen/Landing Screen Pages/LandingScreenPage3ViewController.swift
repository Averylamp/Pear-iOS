//
//  LandingScreenPage3ViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/8/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class LandingScreenPage3ViewController: LandingScreenPageViewController {
    

    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate() -> LandingScreenPage3ViewController {
        let storyboard = UIStoryboard(name: String(describing: LandingScreenPage3ViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! LandingScreenPage3ViewController
        return vc
    }

}

// MARK: - Life Cycle
extension LandingScreenPage3ViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
}
