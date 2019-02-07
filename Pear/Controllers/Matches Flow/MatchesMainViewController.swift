//
//  MatchesMainViewController.swift
//  SubtleAsianMatches
//
//  Created by Avery on 1/6/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class MatchesMainViewController: UIViewController {

    class func instantiate()->MatchesMainViewController{
        let storyboard = UIStoryboard(name: String(describing: MatchesMainViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! MatchesMainViewController
        return vc
    }
    
}

// MARK: - Life Cycle
extension MatchesMainViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
