//
//  LandingScreenViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/8/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class LandingScreenViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate() -> LandingScreenViewController {
        let storyboard = UIStoryboard(name: String(describing: LandingScreenViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! LandingScreenViewController
        return vc
    }
    
    
}


// MARK: - Life Cycle
extension LandingScreenViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleButtons()
    }
    
    func styleButtons(){
        signupButton.layer.shadowRadius = 3
        signupButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        signupButton.layer.shadowColor = UIColor.black.cgColor
        signupButton.layer.shadowOpacity = 0.4
        
        loginButton.layer.shadowRadius = 3
        loginButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        loginButton.layer.shadowColor = UIColor.black.cgColor
        loginButton.layer.shadowOpacity = 0.4
        
    }

}


// MARK: - @IBActions
private extension LandingScreenViewController{
    
    
    
}



