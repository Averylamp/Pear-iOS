//
//  GetStartedSampleBiosViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetStartedSampleBiosViewController: UIViewController {
    
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate() -> GetStartedSampleBiosViewController {
        let storyboard = UIStoryboard(name: String(describing: GetStartedSampleBiosViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GetStartedSampleBiosViewController
        return vc
    }
    
    
}


// MARK: - Life Cycle
extension GetStartedSampleBiosViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
}
