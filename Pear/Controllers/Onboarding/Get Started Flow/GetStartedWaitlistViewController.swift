//
//  GetStartedWaitlistViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/28/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetStartedWaitlistViewController: UIViewController {

    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate() -> GetStartedWaitlistViewController? {
        let storyboard = UIStoryboard(name: String(describing: GetStartedWaitlistViewController.self), bundle: nil)
        guard let waitlistVC = storyboard.instantiateInitialViewController() as? GetStartedWaitlistViewController else { return nil }
        return waitlistVC
    }

}

// MARK: - Life Cycle
extension GetStartedWaitlistViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}