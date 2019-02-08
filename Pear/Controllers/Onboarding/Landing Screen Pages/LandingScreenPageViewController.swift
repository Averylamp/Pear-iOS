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
    
    func scaleImageView(percent: CGFloat){
        if let imageView = self.imageView{
            imageView.transform = CGAffineTransform(scaleX: percent, y: percent)
        }
    }

}
