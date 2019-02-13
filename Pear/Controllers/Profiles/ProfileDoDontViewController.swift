//
//  ProfileDoDontViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/13/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class ProfileDoDontViewController: UIViewController {

    var doStrings: [String]!
    var dontStrings: [String]!
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(doStrings: [String], dontStrings: [String]) -> ProfileDoDontViewController {
        let storyboard = UIStoryboard(name: String(describing: ProfileDoDontViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! ProfileDoDontViewController
        vc.doStrings = doStrings
        vc.dontStrings = dontStrings
        return vc
    }
    
}

// MARK: - Life Cycle
extension ProfileDoDontViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
}
