//
//  GetStartedCreateAccountViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit
import Firebase

class GetStartedCreateAccountViewController: UIViewController {
    
    var gettingStartedData: GetttingStartedData!
    var authAPI: AuthAPI! =  FakeAuthAPI()
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(gettingStartedData: GetttingStartedData) -> GetStartedCreateAccountViewController {
        let storyboard = UIStoryboard(name: String(describing: GetStartedCreateAccountViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GetStartedCreateAccountViewController
        vc.gettingStartedData = gettingStartedData
        return vc
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func facebookButtonClicked(_ sender: Any) {

    }
    
    @IBAction func emailButtonClicked(_ sender: Any) {
        let emailVC = GetStartedCreateAccountEmailViewController.instantiate(gettingStartedData: self.gettingStartedData)
        self.navigationController?.pushViewController(emailVC, animated: true)
    }
    
}


// MARK: - Life Cycle
extension GetStartedCreateAccountViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
}
