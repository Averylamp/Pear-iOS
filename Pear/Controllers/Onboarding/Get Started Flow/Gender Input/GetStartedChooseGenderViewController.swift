//
//  GetStartedChooseGenderViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/25/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetStartedChooseGenderViewController: UIViewController {

    @IBOutlet weak var progressWidthConstraint: NSLayoutConstraint!

    var gettingStartedData: GettingStartedData!

    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var nonbinaryButton: UIButton!

    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(gettingStartedData: GettingStartedData) -> GetStartedChooseGenderViewController? {
        let storyboard = UIStoryboard(name: String(describing: GetStartedChooseGenderViewController.self), bundle: nil)
        guard let chooseGenderVC = storyboard.instantiateInitialViewController() as? GetStartedChooseGenderViewController else { return nil }
        chooseGenderVC.gettingStartedData = gettingStartedData
        return chooseGenderVC
    }

    @IBAction func chooseGenderButtonClicked(_ sender: UIButton) {
        HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)

        switch sender.tag {
        case 0:
            self.gettingStartedData.profileData.gender = GenderEnum.male
            self.maleButton.stylizeDark()
            self.femaleButton.stylizeLight()
            self.nonbinaryButton.stylizeLight()

        case 1:
            self.gettingStartedData.profileData.gender = GenderEnum.female
            self.femaleButton.stylizeDark()
            self.maleButton.stylizeLight()
            self.nonbinaryButton.stylizeLight()

        case 2:
            self.gettingStartedData.profileData.gender = GenderEnum.nonbinary
            self.nonbinaryButton.stylizeDark()
            self.maleButton.stylizeLight()
            self.femaleButton.stylizeLight()

        default:
            break
        }

        guard let ageVC = GetStartedAgeViewController.instantiate(gettingStartedData: self.gettingStartedData) else {
            print("Failed to create age VC")
            return
        }
        self.navigationController?.pushViewController(ageVC, animated: true)
    }

    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}

// MARK: - Life Cycle
extension GetStartedChooseGenderViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.stylize()
    }

    func stylize() {

        self.maleButton.stylizeLight()
        self.maleButton.tag = 0

        self.femaleButton.stylizeLight()
        self.femaleButton.tag = 1

        self.nonbinaryButton.stylizeLight()
        self.nonbinaryButton.tag = 2

        if let previousGender = self.gettingStartedData.profileData.gender {
            switch previousGender {
            case .male:
                self.maleButton.stylizeDark()
            case .female:
                self.femaleButton.stylizeDark()
            case .nonbinary:
                self.nonbinaryButton.stylizeDark()
            }
        }

        self.progressWidthConstraint.constant = 0.0 / StylingConfig.totalGettingStartedPagesNumber * self.view.frame.width
        self.view.layoutIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.layoutIfNeeded()
        self.progressWidthConstraint.constant = 1.0 / StylingConfig.totalGettingStartedPagesNumber * self.view.frame.width
        UIView.animate(withDuration: StylingConfig.progressBarAnimationDuration, delay: StylingConfig.progressBarAnimationDelay, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

}
