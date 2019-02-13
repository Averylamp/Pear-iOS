//
//  ProfileAboutViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/13/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class ProfileAboutViewController: UIViewController {

    var aboutBio: String!
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(aboutBio: String) -> ProfileAboutViewController {
        let storyboard = UIStoryboard(name: String(describing: ProfileAboutViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! ProfileAboutViewController
        vc.aboutBio = aboutBio
        return vc
    }
    
}

// MARK: - Life Cycle
extension ProfileAboutViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
}

