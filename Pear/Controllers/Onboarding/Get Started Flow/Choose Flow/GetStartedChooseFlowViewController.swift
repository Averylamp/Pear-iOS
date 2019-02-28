//
//  GettingStartedChooseFlowViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/25/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetStartedChooseFlowViewController: UIViewController {

    var gettingStartedData: GettingStartedData!

    @IBOutlet weak var createFriendProfileButton: UIButton!
    @IBOutlet weak var requestProfileButton: UIButton!

    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(gettingStartedData: GettingStartedData) -> GetStartedChooseFlowViewController? {
        let storyboard = UIStoryboard(name: String(describing: GetStartedChooseFlowViewController.self), bundle: nil)
        guard let chooseFlowVC = storyboard.instantiateInitialViewController() as? GetStartedChooseFlowViewController else { return nil }
        chooseFlowVC.gettingStartedData = gettingStartedData
        return chooseFlowVC
    }

    @IBAction func createFriendProfileClicked(_ sender: Any) {
        HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
        guard let seeSamplesVC = GetStartedSeeSamplesViewController.instantiate(gettingStartedData: self.gettingStartedData) else {
            print("Failed to create Samples VC")
            return
        }
        self.navigationController?.pushViewController(seeSamplesVC, animated: true)
    }

    @IBAction func requestProfileClicked(_ sender: Any) {
        HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)

    }

}

// MARK: - Life Cycle
extension GetStartedChooseFlowViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.stylize()
    }

    func stylize() {

        self.createFriendProfileButton.backgroundColor = UIColor.white
        self.createFriendProfileButton.layer.cornerRadius = self.createFriendProfileButton.frame.height / 2.0
        self.createFriendProfileButton.layer.borderColor = Config.nextButtonColor.cgColor
        self.createFriendProfileButton.layer.borderWidth = 1
        self.createFriendProfileButton.layer.shadowRadius = 1
        self.createFriendProfileButton.layer.shadowColor = UIColor(white: 0.0, alpha: 0.15).cgColor
        self.createFriendProfileButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.createFriendProfileButton.layer.shadowOpacity = 1.0
        self.createFriendProfileButton.setTitleColor(Config.nextButtonColor, for: .normal)
        self.createFriendProfileButton.titleLabel?.font = UIFont(name: Config.textFontSemiBold, size: 17)

        self.requestProfileButton.backgroundColor = UIColor.white
        self.requestProfileButton.layer.cornerRadius = self.createFriendProfileButton.frame.height / 2.0
        self.requestProfileButton.layer.shadowRadius = 1
        self.requestProfileButton.layer.shadowColor = UIColor(white: 0.0, alpha: 0.15).cgColor
        self.requestProfileButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.requestProfileButton.layer.shadowOpacity = 1.0
        self.requestProfileButton.setTitleColor(Config.nextButtonColor, for: .normal)
        self.requestProfileButton.titleLabel?.font = UIFont(name: Config.textFontSemiBold, size: 17)

    }

}
