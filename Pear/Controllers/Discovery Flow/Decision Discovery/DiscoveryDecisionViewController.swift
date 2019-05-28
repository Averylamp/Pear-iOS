//
//  DiscoveryDecisionViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class DiscoveryDecisionViewController: UIViewController {
  
  var allFetchedProfiles: [FullProfileDisplayData] = []
  var profilesToShow: [FullProfileDisplayData] = []
  var currentDiscoveryProfileVC: DiscoveryFullProfileViewController?
  
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var messageLabel: UILabel!
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> DiscoveryDecisionViewController? {
    guard let decisionDiscoveryVC = R.storyboard.discoveryDecisionViewController
      .instantiateInitialViewController()  else {
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
    self.checkForDetachedProfiles()
  }
  
  func checkForDetachedProfiles() {
    DataStore.shared.checkForDetachedProfiles(detachedProfilesFound: { (detachedProfiles) in
      print("\(detachedProfiles.count) Detached Profiles Found")
      for detachedProfile in detachedProfiles {
          DispatchQueue.main.async {
            guard let detachedProfileApprovalVC = ApproveDetachedProfileNavigationViewController
              .instantiate(detachedProfile: detachedProfile) else {
                print("Failed to create detached profile navigation vc")
                return
            }
            self.present(detachedProfileApprovalVC, animated: true, completion: nil)
            return
          }
      }
    })
  }
  
  func updateProfilesToDisplay() {
    self.profilesToShow = []
    self.allFetchedProfiles.filter({$0.decisionMade == false}).forEach({
      if let matchingPreferences = $0.matchingPreferences,
        let matchingDemographics = $0.matchingDemographics,
        let userDemographics = DataStore.shared.currentPearUser?.matchingDemographics,
        let userPreferences = DataStore.shared.currentPearUser?.matchingPreferences {
        if userPreferences.matchesDemographics(demographics: matchingDemographics) &&
          matchingPreferences.matchesDemographics(demographics: userDemographics) {
          self.profilesToShow.append($0)
        }
      } else {
        self.profilesToShow.append($0)
      }
    })
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
        profiles.forEach({
          if !self.allFetchedProfiles.contains($0) {
            self.allFetchedProfiles.append($0)
          }
        })
        self.updateProfilesToDisplay()
        DispatchQueue.main.async {
          self.activityIndicator.stopAnimating()
          self.messageLabel.text = ""
        }
        self.showNextProfile()
      case .failure(let error):
        print("Error getting profiles: \(error)")
      }
    }
  }
  
  func showNextProfile() {
    
    if self.profilesToShow.count == 0 {
      DispatchQueue.main.async {
        self.messageLabel.text = "There are no more profiles for you right now. \nCheck back in a few hours!"
        self.tabBarController?.setTabBarVisible(visible: true, duration: 0.5, animated: true)
      }
    }
    self.hideProfileVC {
      if self.profilesToShow.count > 0 {
        let nextProfile = self.profilesToShow.popLast()
        guard let nextProfileVC = DiscoveryFullProfileViewController.instantiate(fullProfileData: nextProfile) else {
          print("Failed to instantiate Discovery Full Profile")
          return
        }
        nextProfileVC.delegate = self
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
                                           toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: -40)
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
      UIView.animate(withDuration: 0.7, animations: {
        profileVC.view.alpha = 1.0
        yConstraint.constant = 0.0
        self.view.layoutIfNeeded()
      }, completion: { (_) in
        completion()
      })
      
      if !DataStore.shared.fetchFlagFromDefaults(flag: .hasCompletedDiscoveryOnboarding) {
        print("showing onboarding overlays")
        self.onboardingOverlay1()
      }
    }

  }
  
}

// MARK: - DiscoveryFullProfileDelegate
extension DiscoveryDecisionViewController: DiscoveryFullProfileDelegate {
  
  func decisionMade() {
    self.showNextProfile()
  }
  
  func scannedUser(fullProfileDisplay: FullProfileDisplayData) {
    self.profilesToShow.append(fullProfileDisplay)
    self.showNextProfile()
  }
  
}
