//
//  LandingScreenPageViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/8/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class LandingScreenPageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView?
    
    @IBOutlet weak var backgroundImageView: UIImageView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    /// Function to scale the landing page vc and give realtime scroll value
    ///
    /// - Parameter percent: percent of the view controller showing on screen
    func scaleImageView(percent: CGFloat, before: Bool = true){
        let scaleSize: CGFloat = 0.6
        let percent = 1 - (1 - percent) * scaleSize
        if let imageView = self.imageView{
            imageView.transform = CGAffineTransform(scaleX: percent, y: percent)
        }
        if let backgroundImageView = self.backgroundImageView{
            let minPercentBackground: CGFloat = 0.7
            if percent > minPercentBackground {
                let scaleAmount = (percent - minPercentBackground) / (1 - minPercentBackground)
                backgroundImageView.transform = CGAffineTransform(scaleX: scaleAmount, y: scaleAmount)
            }else{
                backgroundImageView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            }
        }
    }

}
