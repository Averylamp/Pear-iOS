//
//  DiscoveryDecisionViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class DiscoveryDecisionViewController: UIViewController {
  
  var profilesToShow: [FullProfileDisplayData] = []
  var currentDiscoveryProfileVC: DiscoveryFullProfileViewController?
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> DiscoveryDecisionViewController? {
    guard let decisionDiscoveryVC = R.storyboard.discoveryDecisionViewController()
      .instantiateInitialViewController() as? DiscoveryDecisionViewController else {
        print("Failed to create decision based discovery VC")
        return nil
    }
    return decisionDiscoveryVC
  }
  
}

// MARK: - Life Cycle
extension DiscoveryDecisionViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.fetchDiscoveryQueue()
  }
  
  func fetchDiscoveryQueue() {
    guard let userID = DataStore.shared.currentPearUser?.documentID  else {
      print("Cant find logged in user")
      return
    }
    PearDiscoveryAPI.shared.getDiscoveryFeed(userID: userID, last: 15) { (result) in
      switch result {
      case .success(let profiles):
        print("Profiles Found: \(profiles.count)")
        self.profilesToShow = profiles
        self.showNextProfile()
      case .failure(let error):
        print("Error getting profiles: \(error)")
      }
    }
  }

  func showNextProfile() {
    if let nextProfile = self.profilesToShow.popLast() {
      self.hideProfileVC {
        guard let nextProfileVC = DiscoveryFullProfileViewController.instantiate(fullProfileData: nextProfile) else {
          print("Failed to instantiate Discovery Full Profile")
          return
        }
        self.showProfileVC(profileVC: nextProfileVC, completion: {
          
        })
      }
    }
    
  }
  
  func hideProfileVC(completion: @escaping() -> Void) {
    DispatchQueue.main.async {
      if let profileVC = self.currentDiscoveryProfileVC {
        UIView.animate(withDuration: 0.5, animations: {
          profileVC.view.alpha = 0.0
          profileVC.view.center.y  += 40
        }, completion: { (_) in
//          profileVC.dismiss(animated: true, completion: completion)
          profileVC.view.removeFromSuperview()
          profileVC.removeFromParent()
          completion()
        })
      } else {
        completion()
      }
    }
  }
  
  func showProfileVC(profileVC: DiscoveryFullProfileViewController, completion: @escaping() -> Void) {
    DispatchQueue.main.async {
      self.currentDiscoveryProfileVC = profileVC
//    self.present(profileVC, animated: true, completion: completion)
      self.addChild(profileVC)
      self.view.addSubview(profileVC.view)
      profileVC.view.translatesAutoresizingMaskIntoConstraints = false
      let yConstraint = NSLayoutConstraint(item: profileVC.view as Any, attribute: .centerY, relatedBy: .equal,
                                           toItem: nil, attribute: .centerY, multiplier: 1.0, constant: -40)
      self.view.addConstraints([
        yConstraint,
        NSLayoutConstraint(item: profileVC.view as Any, attribute: .centerX, relatedBy: .equal,
                           toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: profileVC.view as Any, attribute: .width, relatedBy: .equal,
                           toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: profileVC.view as Any, attribute: .height, relatedBy: .equal,
                           toItem: self.view, attribute: .height, multiplier: 1.0, constant: 0.0)
        ])
      self.view.layoutIfNeeded()
      profileVC.didMove(toParent: self)
      profileVC.view.alpha = 0.0
      UIView.animate(withDuration: 1.0, animations: {
        profileVC.view.alpha = 1.0
        yConstraint.constant = 0.0
      }, completion: { (_) in
        completion()
      })
      
    }
    
  }
  
}
