//
//  DiscoverMainViewController.swift
//  SubtleAsianMatches
//
//  Created by Avery on 1/6/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class DiscoverMainViewController: UIViewController {

    class func instantiate() -> DiscoverMainViewController? {
        let storyboard = UIStoryboard(name: String(describing: DiscoverMainViewController.self), bundle: nil)
        guard let discoverVC = storyboard.instantiateInitialViewController() as? DiscoverMainViewController else { return nil }
        return discoverVC
    }

}

// MARK: - Life Cycle
extension DiscoverMainViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
