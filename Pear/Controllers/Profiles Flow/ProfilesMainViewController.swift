//
//  ProfilesMainViewController.swift
//  SubtleAsianMatches
//
//  Created by Avery on 1/6/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class ProfilesMainViewController: UIViewController {

    class func instantiate()->ProfilesMainViewController{
        let storyboard = UIStoryboard(name: String(describing: ProfilesMainViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! ProfilesMainViewController
        return vc
    }
}

// MARK: - Life Cycle
extension ProfilesMainViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
}
