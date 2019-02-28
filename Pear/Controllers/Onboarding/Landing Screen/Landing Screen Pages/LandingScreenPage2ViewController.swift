//
//  LandingScreenPage2ViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/8/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class LandingScreenPage2ViewController: LandingScreenPageViewController {

    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate() -> LandingScreenPage2ViewController? {
        let storyboard = UIStoryboard(name: String(describing: LandingScreenPage2ViewController.self), bundle: nil)
        guard let landingPage2 = storyboard.instantiateInitialViewController() as? LandingScreenPage2ViewController else { return nil }
        return landingPage2
    }

}

// MARK: - Life Cycle
extension LandingScreenPage2ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
