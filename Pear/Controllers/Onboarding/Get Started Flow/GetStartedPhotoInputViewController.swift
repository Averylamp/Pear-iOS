//
//  GetStartedPhotoInputViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetStartedPhotoInputViewController: UIViewController {
    
    var endorsement: Endorsement!
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(endorsement: Endorsement) -> GetStartedPhotoInputViewController {
        let storyboard = UIStoryboard(name: String(describing: GetStartedPhotoInputViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GetStartedPhotoInputViewController
        vc.endorsement = endorsement
        return vc
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        HapticFeedbackGenerator.shared.generateHapticFeedback(style: .light)
    }
    
}


// MARK: - Life Cycle
extension GetStartedPhotoInputViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
}
