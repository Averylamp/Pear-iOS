//
//  ProfileInformationViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/13/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class ProfileInformationViewController: UIViewController {

    var age: Int!
    var location: String?
    var school: String?
    var work: String?
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(age: Int, location: String? = nil, school: String? = nil, work: String? = nil) -> ProfileInformationViewController {
        let storyboard = UIStoryboard(name: String(describing: ProfileInformationViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! ProfileInformationViewController
        vc.age = age
        vc.location = location
        vc.school = school
        vc.work = work
        return vc
    }
    
}

// MARK: - Life Cycle
extension ProfileInformationViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
}

