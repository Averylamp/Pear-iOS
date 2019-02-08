//
//  LandingScreenPage1ViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/8/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class LandingScreenPage1ViewController: LandingScreenPageViewController {

    

    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate() -> LandingScreenPage1ViewController {
        let storyboard = UIStoryboard(name: String(describing: LandingScreenPage1ViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! LandingScreenPage1ViewController
        return vc
    }

}

// MARK: - Life Cycle
extension LandingScreenPage1ViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
}
