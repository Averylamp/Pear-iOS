//
//  LandingScreenViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/17/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import SafariServices

class LandingScreenViewController: UIViewController {
  
  @IBOutlet weak var termsButton: UIButton!
  @IBOutlet weak var phoneNumberContainerView: UIView!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> LandingScreenViewController? {
    let landingScreenVC = R.storyboard.landingScreenViewController().instantiateInitialViewController() as? LandingScreenViewController
    return landingScreenVC
  }
  
  @IBAction func termsButtonClicked(_ sender: Any) {
    let actionSheet = UIAlertController(title: "Terms of Service",
                                        message: "What would you like to see?",
                                        preferredStyle: .actionSheet)
    let eulaAction = UIAlertAction(title: "End User License Agreement", style: .default) { (_) in
      self.present(SFSafariViewController(url: NetworkingConfig.eulaURL), animated: true, completion: nil)
    }
    let privacyPolicyAction = UIAlertAction(title: "Privacy Policy", style: .default) { (_) in
      self.present(SFSafariViewController(url: NetworkingConfig.eulaURL), animated: true, completion: nil)
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    actionSheet.addAction(eulaAction)
    actionSheet.addAction(privacyPolicyAction)
    actionSheet.addAction(cancelAction)
    self.present(actionSheet, animated: true, completion: nil)
  }
  
}

// MARK: - Life Cycle
extension LandingScreenViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
  }
  
  func stylize() {
//    self.view.background
    guard let textFont = R.font.openSansLight(size: 11),
      let boldFont = R.font.openSansSemiBold(size: 11) else {
        print("Failed to load in fonts")
        return
    }
    let subtleAttributes = [NSAttributedString.Key.font: textFont,
                            NSAttributedString.Key.foregroundColor: UIColor(white: 0.7, alpha: 1.0)]
    let boldAttributes = [NSAttributedString.Key.font: boldFont,
                          NSAttributedString.Key.foregroundColor: UIColor(white: 0.6, alpha: 1.0)]
    let termsString = NSMutableAttributedString(string: "By continuing you agree to our ",
                                                attributes: subtleAttributes)
    let eulaString = NSMutableAttributedString(string: "EULA",
                                               attributes: boldAttributes)
    let andString = NSMutableAttributedString(string: " and ",
                                              attributes: subtleAttributes)
    let privacyPolicyString = NSMutableAttributedString(string: "privacy policy",
                                                        attributes: boldAttributes)
    termsString.append(eulaString)
    termsString.append(andString)
    termsString.append(privacyPolicyString)
    self.termsButton.setAttributedTitle(termsString, for: .normal)
    
    self.phoneNumberContainerView.layer.cornerRadius = 8
    
  }
  
}
