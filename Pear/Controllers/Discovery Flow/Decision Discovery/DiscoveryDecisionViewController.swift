//
//  DiscoveryDecisionViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

extension Notification.Name {
  static let refreshDiscoveryFeed = Notification.Name("refreshDiscoveryFeed")
}

class DiscoveryDecisionViewController: UIViewController {
  
  var allFetchedProfiles: [FullProfileDisplayData] = []
  var profilesToShow: [FullProfileDisplayData] = []
  var currentDiscoveryProfileVC: DiscoveryFullProfileViewController?
  
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
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
  
  @IBAction func filterButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    print("filter button clicked from decision VC")
    guard let filtersVC = DiscoveryFilterViewController.instantiate() else {
      print("Failed to create Filters VC")
      return
    }
    self.navigationController?.pushViewController(filtersVC, animated: true)
  }
  
  @IBAction func qrCodeButtonClicked(_ sender: Any) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    self.presentScanner()
  }
  
}

// MARK: - Life Cycle
extension DiscoveryDecisionViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
    self.refreshDiscovery()
    self.checkForDetachedProfiles()
  }
  
  func setup() {
    self.registerNotifications()
  }
  
  func registerNotifications() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(DiscoveryDecisionViewController.refreshDiscovery),
                                           name: .refreshDiscoveryFeed,
                                           object: nil)
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
  
  @objc func refreshDiscovery() {
    self.allFetchedProfiles = []
    self.profilesToShow = []
    self.hideProfileVC {
      DispatchQueue.main.async {
        self.activityIndicator.startAnimating()
        self.messageLabel.text = "Fetching new profiles"
      }
      PearDiscoveryAPI.shared.getDiscoveryCards { (result) in
        switch result {
        case .success(let profiles):
          print("Profiles Found: \(profiles.count)")
          if profiles.count == 0 {
            self.didReceiveNoProfiles()
          } else {
            self.allFetchedProfiles = []
            profiles.forEach({
              if !self.allFetchedProfiles.contains($0) {
                self.allFetchedProfiles.append($0)
              }
            })
            self.profilesToShow = []
            self.allFetchedProfiles.filter({$0.decisionMade == false}).forEach({
              self.profilesToShow.append($0)
            })
            DispatchQueue.main.async {
              self.activityIndicator.stopAnimating()
              self.messageLabel.text = ""
            }
            self.showNextProfile()
          }
        case .failure(let error):
          print("Error getting profiles: \(error)")
          self.didReceiveNoProfiles()
        }
      }
    }
  }
  
  func didReceiveNoProfiles() {
    self.profilesToShow = []
    self.allFetchedProfiles = []
    DispatchQueue.main.async {
      self.activityIndicator.stopAnimating()
      self.messageLabel.text = "There are no more profiles for you right now.\nCheck back in a few hours!"
      self.tabBarController?.setTabBarVisible(visible: true, duration: 0.5, animated: true)
      self.headerHeightConstraint.constant = 50.0
      UIView.animate(withDuration: 0.5, animations: {
        self.view.layoutIfNeeded()
      })
    }
  }
  
  func showNextProfile() {
    
    if self.profilesToShow.count == 0 {
      self.refreshDiscovery()
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
      } else {
        self.currentDiscoveryProfileVC = nil
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
    if let previousPerson = self.currentDiscoveryProfileVC?.fullProfileData {
      self.profilesToShow.append(previousPerson)
    }
    self.profilesToShow.append(fullProfileDisplay)
    self.showNextProfile()
  }
  
}
