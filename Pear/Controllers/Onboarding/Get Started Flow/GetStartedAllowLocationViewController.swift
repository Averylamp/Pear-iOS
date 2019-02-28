//
//  GetStartedAllowLocationViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/28/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetStartedAllowLocationViewController: UIViewController {

    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate() -> GetStartedAllowLocationViewController? {
        let storyboard = UIStoryboard(name: String(describing: GetStartedAllowLocationViewController.self), bundle: nil)
        guard let allowLocationVC = storyboard.instantiateInitialViewController() as? GetStartedAllowLocationViewController else { return nil }
        return allowLocationVC
    }

}

// MARK: - Life Cycle
extension GetStartedAllowLocationViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
