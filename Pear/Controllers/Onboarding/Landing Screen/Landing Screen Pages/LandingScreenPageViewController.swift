//
//  LandingScreenPageViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/8/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class LandingScreenPageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView?

    @IBOutlet weak var backgroundImageView: UIImageView?

    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subtitleLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.stylize()
    }

    func stylize() {
        if let titleLabel = self.titleLabel {
            titleLabel.stylizeLogoLabel()
        }
        if let subtitleLabel = self.subtitleLabel {
            subtitleLabel.stylizeSubtitleLabel()
        }
    }

    /// Function to scale the landing page vc and give realtime scroll value
    ///
    /// - Parameter percent: percent of the view controller showing on screen
    func scaleImageView(percent: CGFloat, before: Bool = true) {
        let scaleSize: CGFloat = 0.6
        let percent = 1 - (1 - percent) * scaleSize
        if let imageView = self.imageView {
            imageView.transform = CGAffineTransform(scaleX: percent, y: percent)
        }
        if let backgroundImageView = self.backgroundImageView {
            let minPercentBackground: CGFloat = 0.7
            let rotationAmount: CGFloat = 2.0
            if percent > minPercentBackground {
                let scaleAmount = (percent - minPercentBackground) / (1 - minPercentBackground)
                backgroundImageView.transform = CGAffineTransform(scaleX: scaleAmount, y: scaleAmount)
                let rotationAmount = before ? rotationAmount / 2 * percent - rotationAmount / 2 : rotationAmount / 2 + (1 - percent) * rotationAmount - rotationAmount / 2
                backgroundImageView.transform = backgroundImageView.transform.rotated(by: rotationAmount)
            } else {
                backgroundImageView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            }
        }
    }

}
