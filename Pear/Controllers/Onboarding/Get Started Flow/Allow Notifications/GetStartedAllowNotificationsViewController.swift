//
//  GetStartedAllowNotificationsViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/28/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit
import UserNotifications

class GetStartedAllowNotificationsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    @IBOutlet weak var enableNotificationsButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!

    var friendName: String?

    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(friendName: String? = nil) -> GetStartedAllowNotificationsViewController? {
        let storyboard = UIStoryboard(name: String(describing: GetStartedAllowNotificationsViewController.self), bundle: nil)
        guard let allowNotificationsVC = storyboard.instantiateInitialViewController() as? GetStartedAllowNotificationsViewController else { return nil }
        allowNotificationsVC.friendName = friendName
        return allowNotificationsVC
    }

    @IBAction func enableNotificationsClicked(_ sender: Any) {
        // iOS 12 support
        if #available(iOS 12, *) {
            UNUserNotificationCenter.current()
                .requestAuthorization(
                    options: [.badge, .alert, .sound, .provisional, .providesAppNotificationSettings, .criticalAlert]) { (_, error) in
                DispatchQueue.main.sync {
                    UIApplication.shared.registerForRemoteNotifications()
                    if let error = error {
                        print(error)
                    }
                    guard let allowLocationVC = GetStartedAllowLocationViewController.instantiate() else {
                        print("Failed to create Allow Location VC")
                        return
                    }
                    self.navigationController?.pushViewController(allowLocationVC, animated: true)
                }
            }

        } else if #available(iOS 11, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { (_, error) in
                DispatchQueue.main.sync {
                    UIApplication.shared.registerForRemoteNotifications()
                    if let error = error {
                        print(error)
                    }
                    guard let allowLocationVC = GetStartedAllowLocationViewController.instantiate() else {
                        print("Failed to create Allow Location VC")
                        return
                    }
                    self.navigationController?.pushViewController(allowLocationVC, animated: true)
                }
            }
        }

    }

}

// MARK: - Life Cycle
extension GetStartedAllowNotificationsViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.stylize()

    }

    func stylize() {
        self.enableNotificationsButton.stylizeDark()
        self.skipButton.stylizeSubtle()
        self.titleLabel.stylizeTitleLabel()
        self.subtitleLabel.stylizeSubtitleLabel()
        if let friendName = self.friendName {
            self.subtitleLabel.text = "You'll be able to pear \(friendName) with potential matches, and more!"
        }

    }

}
