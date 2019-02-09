
//
//  GetStartedShortBioViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetStartedShortBioViewController: UIViewController {
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate() -> GetStartedShortBioViewController {
        let storyboard = UIStoryboard(name: String(describing: GetStartedShortBioViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GetStartedShortBioViewController
        return vc
    }
}


// MARK: - Life Cycle
extension GetStartedShortBioViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
}
