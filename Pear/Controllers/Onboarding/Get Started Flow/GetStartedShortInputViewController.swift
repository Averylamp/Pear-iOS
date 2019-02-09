//
//  GetStartedShortInputViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/8/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetStartedShortInputViewController: UIViewController {
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate() -> GetStartedShortInputViewController {
        let storyboard = UIStoryboard(name: String(describing: GetStartedShortInputViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GetStartedShortInputViewController
        return vc
    }
}


// MARK: - Life Cycle
extension GetStartedShortInputViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
}
