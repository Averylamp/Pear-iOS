//
//  SettingsMainViewController.swift
//  SubtleAsianMatches
//
//  Created by Avery on 1/6/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class SettingsMainViewController: UIViewController {
    
    class func instantiate()-> SettingsMainViewController{
        let storyboard = UIStoryboard(name: String(describing: SettingsMainViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! SettingsMainViewController
        return vc
    }
    
}

// MARK: - Life Cycle
extension SettingsMainViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
}
