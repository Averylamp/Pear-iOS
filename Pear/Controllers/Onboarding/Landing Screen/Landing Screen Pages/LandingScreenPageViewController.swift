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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    /// Function to scale the landing page vc and give realtime scroll value
    ///
    /// - Parameter percent: percent of the view controller showing on screen
    func scaleImageView(percent: CGFloat){
        let scaleSize: CGFloat = 0.6
        let percent = 1 - (1 - percent) * scaleSize
        if let imageView = self.imageView{
            imageView.transform = CGAffineTransform(scaleX: percent, y: percent)
        }
    }

}
