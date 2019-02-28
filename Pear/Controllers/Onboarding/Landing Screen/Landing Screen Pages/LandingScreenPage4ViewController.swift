//
//  LandingScreenPage4ViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/8/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class LandingScreenPage4ViewController: LandingScreenPageViewController {

    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate() -> LandingScreenPage4ViewController? {
        let storyboard = UIStoryboard(name: String(describing: LandingScreenPage4ViewController.self), bundle: nil)
        guard let page4VC = storyboard.instantiateInitialViewController() as? LandingScreenPage4ViewController else { return nil }
        return page4VC
    }

}

// MARK: - Life Cycle
extension LandingScreenPage4ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
