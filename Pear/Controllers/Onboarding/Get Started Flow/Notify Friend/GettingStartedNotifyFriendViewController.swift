//
//  GettingStartedNotifyFriendViewController.swift
//  Pear
//
//  Created by Avery Lamp on 2/14/19.
//  Copyright © 2019 sam. All rights reserved.
//

import UIKit

class GettingStartedNotifyFriendViewController: UIViewController {

    
    var gettingStartedData: GetttingStartedData!
    
    @IBOutlet weak var readyTitleLabel: UILabel!
    @IBOutlet weak var readySubtextLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    /// Factory method for creating this view controller.
    ///
    /// - Returns: Returns an instance of this view controller.
    class func instantiate(gettingStartedData: GetttingStartedData) -> GettingStartedNotifyFriendViewController {
        let storyboard = UIStoryboard(name: String(describing: GettingStartedNotifyFriendViewController.self), bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GettingStartedNotifyFriendViewController
        vc.gettingStartedData = gettingStartedData
        return vc
    }
    
    @IBAction func sendButton(_ sender: Any) {
        HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
        self.saveProfileNumber()
        var profiles = FakeProfileData.listOfFakeProfiles()
        profiles.append(self.gettingStartedData.profileData)
        let simpleDiscoveryVC = DiscoverySimpleScrollViewController.instantiate(profiles: profiles)
        self.navigationController?.setViewControllers([simpleDiscoveryVC], animated: true)
    }
    
    func saveProfileNumber(){
        if let phoneNumber = self.inputTextField.text{
            self.gettingStartedData.profileData.phoneNumber = phoneNumber
        }
    }
}

extension GettingStartedNotifyFriendViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.stylize()
        self.addDismissKeyboardOnViewClick()
    }
    
    func addDismissKeyboardOnViewClick(){
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GettingStartedNotifyFriendViewController.dismissKeyboard)))
    }
    
    @objc func dismissKeyboard(){
        self.inputTextField.resignFirstResponder()
    }
    

    
    func stylize(){
        self.sendButton.layer.cornerRadius = 8
        self.readyTitleLabel.text = "Ready to send it to\n\(self.gettingStartedData.profileData.fullName)"
        self.readySubtextLabel.text = "All profiles must be approved before appearing on Pear. \(self.gettingStartedData.profileData.firstName) will be able to see your responses, edit photos, update basic info, and approve the profile."
        
    }
    
}
