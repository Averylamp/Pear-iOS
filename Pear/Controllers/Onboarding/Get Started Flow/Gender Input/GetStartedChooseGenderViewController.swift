//
//  GetStartedChooseGenderViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/25/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetStartedChooseGenderViewController: UIViewController {
    
    var gettingStartedData: GetttingStartedData!
    

    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var nonbinaryButton: UIButton!
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(gettingStartedData: GetttingStartedData) -> GetStartedChooseGenderViewController {
        let storyboard = UIStoryboard(name: String(describing: GetStartedChooseGenderViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GetStartedChooseGenderViewController
        vc.gettingStartedData = gettingStartedData
        return vc
    }
    
    @IBAction func chooseGenderButtonClicked(_ sender: UIButton) {
        HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
        
        switch sender.tag {
        case 0:
            self.gettingStartedData.profileData.gender = GenderEnum.male
            self.maleButton.stylizeDarkColor()
            self.femaleButton.stylizeLightColor()
            self.nonbinaryButton.stylizeLightColor()

        case 1:
            self.gettingStartedData.profileData.gender = GenderEnum.female
            self.femaleButton.stylizeDarkColor()
            self.maleButton.stylizeLightColor()
            self.nonbinaryButton.stylizeLightColor()

        case 2:
            self.gettingStartedData.profileData.gender = GenderEnum.nonbinary
            self.nonbinaryButton.stylizeDarkColor()
            self.maleButton.stylizeLightColor()
            self.femaleButton.stylizeLightColor()

        default:
            break
        }
        
        let ageVC = GetStartedAgeViewController.instantiate(gettingStartedData: self.gettingStartedData)
        self.navigationController?.pushViewController(ageVC, animated: true)
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - Life Cycle
extension GetStartedChooseGenderViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.stylize()
    }
    
    
    func stylize(){
        
        self.maleButton.stylizeLightColor()
        self.maleButton.tag = 0

        self.femaleButton.stylizeLightColor()
        self.femaleButton.tag = 1
        
        self.nonbinaryButton.stylizeLightColor()
        self.nonbinaryButton.tag = 2
        
        if let previousGender = self.gettingStartedData.profileData.gender {
            switch(previousGender){
            case .male:
                self.maleButton.stylizeDarkColor()
                break
            case .female:
                self.femaleButton.stylizeDarkColor()
                break
            case .nonbinary:
                self.nonbinaryButton.stylizeDarkColor()
                break
            }
        }
    }
    
    
}
