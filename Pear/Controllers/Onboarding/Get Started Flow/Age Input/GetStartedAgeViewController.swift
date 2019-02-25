//
//  GetStartedAgeViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/9/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GetStartedAgeViewController: UIViewController {
    
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    var gettingStartedData: GetttingStartedData!
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(gettingStartedData: GetttingStartedData) -> GetStartedAgeViewController {
        let storyboard = UIStoryboard(name: String(describing: GetStartedAgeViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GetStartedAgeViewController
        vc.gettingStartedData = gettingStartedData
        return vc
    }
    
    func saveAge(){
        if let ageText = self.inputTextField.text, let age = Int(ageText){
            self.gettingStartedData.profileData.age = age
        }
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
        
        self.saveAge()
        if self.gettingStartedData.profileData.age < 18{
            self.alert(title: "Underage", message: "You must be 18 to use this app.  Sorry :/")
            return
        }        
        let interestsVC = GetStartedInterestsViewController.instantiate(gettingStartedData: self.gettingStartedData)
        self.navigationController?.pushViewController(interestsVC, animated: true)
        
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        if let age = Int(self.inputTextField.text!){
            self.saveAge()
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
}


// MARK: - Life Cycle
extension GetStartedAgeViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.gettingStartedData.profileData.age >= 18 {
            self.inputTextField.text = "\(self.gettingStartedData.profileData.age)"
        }
        
        self.inputTextField.becomeFirstResponder()
        self.inputTextField.delegate = self
    }
    
}

// MARK: - UITextFieldDelegate
extension GetStartedAgeViewController: UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if self.inputTextField.text!.count + string.count - range.length > 2 {
            return false
        }
        return true
    }
    
}
