//
//  GetStartedCreateAccountViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetStartedCreateAccountViewController: UIViewController {
    
    var endorsement: Endorsement!
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(endorsement: Endorsement) -> GetStartedCreateAccountViewController {
        let storyboard = UIStoryboard(name: String(describing: GetStartedCreateAccountViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GetStartedCreateAccountViewController
        vc.endorsement = endorsement
        return vc
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}


// MARK: - Life Cycle
extension GetStartedCreateAccountViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
}
