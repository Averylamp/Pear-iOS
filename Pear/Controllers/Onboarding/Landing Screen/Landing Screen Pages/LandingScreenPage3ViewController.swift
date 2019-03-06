//
//  LandingScreenPage3ViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/8/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class LandingScreenPage3ViewController: LandingScreenPageViewController {

    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate() -> LandingScreenPage3ViewController? {
        let storyboard = UIStoryboard(name: String(describing: LandingScreenPage3ViewController.self), bundle: nil)
        guard let page3VC = storyboard.instantiateInitialViewController() as? LandingScreenPage3ViewController else { return nil }
        return page3VC
    }

    override func scaleImageView(percent: CGFloat, before: Bool = true) {
        let scaleSize: CGFloat = 0.6
        let percent = 1 - (1 - percent) * scaleSize
        if let imageView = self.imageView {
            imageView.transform = CGAffineTransform(scaleX: percent, y: percent)
        }
        if let backgroundImageView = self.backgroundImageView {
            let movementDistance: CGFloat = 200
            let initialOffset: CGFloat = 70
            let fullDistance = before ? movementDistance / 2 * percent : movementDistance / 2 + (1 - percent) * movementDistance
            backgroundImageView.transform = CGAffineTransform(translationX: 0, y: -fullDistance + initialOffset)
        }

    }

}

// MARK: - Life Cycle
extension LandingScreenPage3ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
