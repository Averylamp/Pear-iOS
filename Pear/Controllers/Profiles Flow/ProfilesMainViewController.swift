//
//  ProfilesMainViewController.swift
//  SubtleAsianMatches
//
//  Created by Avery on 1/6/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class ProfilesMainViewController: UIViewController {

    class func instantiate() -> ProfilesMainViewController? {
        let storyboard = UIStoryboard(name: String(describing: ProfilesMainViewController.self), bundle: nil)
        guard let profilesMainVC = storyboard.instantiateInitialViewController() as? ProfilesMainViewController else { return nil }
        return profilesMainVC
    }
}

// MARK: - Life Cycle
extension ProfilesMainViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
