//
//  GettingStartedSeeSamplesViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/25/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetStartedSeeSamplesViewController: UIViewController {

    var gettingStartedData: GettingStartedData!

    @IBOutlet weak var seeSamplesButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!

    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(gettingStartedData: GettingStartedData) -> GetStartedSeeSamplesViewController? {
        let storyboard = UIStoryboard(name: String(describing: GetStartedSeeSamplesViewController.self), bundle: nil)
        guard let seeSamplesVC = storyboard.instantiateInitialViewController() as? GetStartedSeeSamplesViewController else { return nil }
        seeSamplesVC.gettingStartedData = gettingStartedData
        return seeSamplesVC
    }

    @IBAction func seeSamplesButtonClicked(_ sender: Any) {
        HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
        guard let endorsementNameVC = GetStartedFriendNameViewController.instantiate(gettingStartedData: self.gettingStartedData) else {
            print("Failed to create Endorsement Name VC")
            return
        }
        self.navigationController?.pushViewController(endorsementNameVC, animated: true)
    }

    @IBAction func skipButtonClicked(_ sender: Any) {
        HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
        guard let endorsementNameVC = GetStartedFriendNameViewController.instantiate(gettingStartedData: self.gettingStartedData) else {
            print("Failed to create Endorsement Name VC")
            return
        }
        self.navigationController?.pushViewController(endorsementNameVC, animated: true)

    }

    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}

// MARK: - Life Cycle
extension GetStartedSeeSamplesViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.stylize()
    }

    func stylize() {

        self.seeSamplesButton.backgroundColor = UIColor.white
        self.seeSamplesButton.layer.cornerRadius = self.seeSamplesButton.frame.height / 2.0
        self.seeSamplesButton.layer.borderColor = Config.nextButtonColor.cgColor
        self.seeSamplesButton.layer.borderWidth = 1
        self.seeSamplesButton.layer.shadowRadius = 1
        self.seeSamplesButton.layer.shadowColor = UIColor(white: 0.0, alpha: 0.15).cgColor
        self.seeSamplesButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.seeSamplesButton.layer.shadowOpacity = 1.0
        self.seeSamplesButton.setTitleColor(Config.nextButtonColor, for: .normal)
        self.seeSamplesButton.titleLabel?.font = UIFont(name: Config.textFontSemiBold, size: 17)
        self.seeSamplesButton.setTitle("View Samples", for: .normal)

        self.skipButton.setTitleColor(Config.inactiveTextFontColor, for: .normal)
        self.skipButton.titleLabel?.font = UIFont(name: Config.textFontSemiBold, size: 17)
        self.skipButton.setTitle("Skip", for: .normal)
    }

}