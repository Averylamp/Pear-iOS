//
//  DiscoverMainViewController.swift
//  SubtleAsianMatches
//
//  Created by Avery on 1/6/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class DiscoverMainViewController: UIViewController {
    
    class func instantiate() ->DiscoverMainViewController{
        let storyboard = UIStoryboard(name: String(describing: DiscoverMainViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! DiscoverMainViewController
        return vc
    }
    
}


// MARK: - Life Cycle
extension DiscoverMainViewController{

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    
}
