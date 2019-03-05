//
//  GetStartedWaitlistViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/28/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetStartedWaitlistViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var createProfileButton: UIButton!
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate() -> GetStartedWaitlistViewController? {
        let storyboard = UIStoryboard(name: String(describing: GetStartedWaitlistViewController.self), bundle: nil)
        guard let waitlistVC = storyboard.instantiateInitialViewController() as? GetStartedWaitlistViewController else { return nil }
        return waitlistVC
    }

    @IBAction func createFriendsProfileClicked(_ sender: Any) {
        guard let startFriendProfileVC = GetStartedStartFriendProfileViewController.instantiate() else{
            print("Failed to create Start Friend Profile VC")
            return
        }
        self.navigationController?.setViewControllers([startFriendProfileVC], animated: true)
    }
}

// MARK: - Life Cycle
extension GetStartedWaitlistViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.stylize()
    }

    func stylize() {
        self.titleLabel.stylizeTitleLabel()
        self.subtitleLabel.stylizeSubtitleLabel()
        self.createProfileButton.stylizeDark()
    }

}
