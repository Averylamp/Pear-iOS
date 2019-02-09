//
//  GetStartedAgeViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetStartedAgeViewController: UIViewController {
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate() -> GetStartedAgeViewController {
        let storyboard = UIStoryboard(name: String(describing: GetStartedAgeViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GetStartedAgeViewController
        return vc
    }
}


// MARK: - Life Cycle
extension GetStartedAgeViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
}
