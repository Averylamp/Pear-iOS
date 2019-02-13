//
//  ProfileImageViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/13/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class ProfileImageViewController: UIViewController {

    
    var images: [UIImage]!
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(images: [UIImage]) -> ProfileImageViewController {
        let storyboard = UIStoryboard(name: String(describing: ProfileImageViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! ProfileImageViewController
        vc.images = images
        return vc
    }
    
}


// MARK: - Life Cycle
extension ProfileImageViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
}

