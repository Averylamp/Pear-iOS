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
        self.messageLabel.text = "That's all your profiles.\nCheck back in a couple hours for some more"
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

// MARK: Onboarding Overlays
extension DiscoveryDecisionViewController {
  
  func createOverlay(frame: CGRect,
                     xOffset: CGFloat,
                     yOffset: CGFloat,
                     labelText: String,
                     stepNumber: Int) -> UIView {
    // Step 1
    let overlayView = UIView(frame: frame)
    overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
    // Step 2
    let path = CGMutablePath()
    path.addArc(center: CGPoint(x: xOffset, y: yOffset),
                radius: 38.0,
                startAngle: 0.0,
                endAngle: 2.0 * .pi,
                clockwise: false)
    path.addRect(CGRect(origin: .zero, size: overlayView.frame.size))
    // Step 3
    let maskLayer = CAShapeLayer()
    maskLayer.backgroundColor = UIColor.black.cgColor
    maskLayer.path = path
    maskLayer.fillRule = .evenOdd
    // Step 4
    overlayView.layer.mask = maskLayer
    overlayView.clipsToBounds = true
    
    // add UILabel
    let labelView = UILabel(frame: CGRect(x: 20, y: self.view.frame.height - 300, width: self.view.frame.width - 100, height: 110))
    labelView.numberOfLines = 0
    labelView.textAlignment = .left
    labelView.text = labelText
    labelView.textColor = .white
    if let font = R.font.openSansExtraBold(size: 24) {
      labelView.font = font
    }
    overlayView.addSubview(labelView)
    labelView.translatesAutoresizingMaskIntoConstraints = false
    overlayView.addConstraints([
      NSLayoutConstraint(item: labelView, attribute: .bottom, relatedBy: .equal,
                         toItem: overlayView, attribute: .bottom, multiplier: 1.0, constant: -200),
      NSLayoutConstraint(item: labelView, attribute: .left, relatedBy: .equal,
                         toItem: overlayView, attribute: .left, multiplier: 1.0, constant: 20),
      NSLayoutConstraint(item: labelView, attribute: .right, relatedBy: .equal,
                         toItem: overlayView, attribute: .right, multiplier: 1.0, constant: -80)
      ])
    
    // add number icons
    var image1 = R.image.unselected1()
    if stepNumber == 1 {
      image1 = R.image.selected1()
    }
    let imageView1 = UIImageView(image: image1?.imageWith(newSize: CGSize(width: 24, height: 24)))
    imageView1.translatesAutoresizingMaskIntoConstraints = false
    overlayView.addConstraints([
      NSLayoutConstraint(item: imageView1, attribute: .bottom, relatedBy: .equal,
                         toItem: labelView, attribute: .top, multiplier: 1.0, constant: -10),
      NSLayoutConstraint(item: imageView1, attribute: .left, relatedBy: .equal,
                         toItem: labelView, attribute: .left, multiplier: 1.0, constant: 0)
      ])
    overlayView.addSubview(imageView1)
    
    var image2 = R.image.unselected2()
    if stepNumber == 2 {
      image2 = R.image.selected2()
    }
    let imageView2 = UIImageView(image: image2?.imageWith(newSize: CGSize(width: 24, height: 24)))
    imageView2.translatesAutoresizingMaskIntoConstraints = false
    overlayView.addConstraints([
      NSLayoutConstraint(item: imageView2, attribute: .bottom, relatedBy: .equal,
                         toItem: labelView, attribute: .top, multiplier: 1.0, constant: -10),
      NSLayoutConstraint(item: imageView2, attribute: .left, relatedBy: .equal,
                         toItem: imageView1, attribute: .right, multiplier: 1.0, constant: 7)
      ])
    overlayView.addSubview(imageView2)
    
    var image3 = R.image.unselected3()
    if stepNumber == 3 {
      image3 = R.image.selected3()
    }
    let imageView3 = UIImageView(image: image3?.imageWith(newSize: CGSize(width: 24, height: 24)))
    imageView3.translatesAutoresizingMaskIntoConstraints = false
    overlayView.addConstraints([
      NSLayoutConstraint(item: imageView3, attribute: .bottom, relatedBy: .equal,
                         toItem: labelView, attribute: .top, multiplier: 1.0, constant: -10),
      NSLayoutConstraint(item: imageView3, attribute: .left, relatedBy: .equal,
                         toItem: imageView2, attribute: .right, multiplier: 1.0, constant: 7)
      ])
    overlayView.addSubview(imageView3)
    
    return overlayView
  }
  
  @objc func onboardingOverlay1() {
    guard let profileVC = self.currentDiscoveryProfileVC else {
      return
    }
    DispatchQueue.main.async {
      let likeOverlay = self.createOverlay(frame: self.view.frame,
                                       xOffset: profileVC.likeButton.center.x,
                                       yOffset: profileVC.likeButton.center.y,
                                       labelText: "Tap the heart to send a like",
                                       stepNumber: 1)
      let gesture = UITapGestureRecognizer(target: self, action: #selector (self.onboardingOverlay2(_:)))
      likeOverlay.addGestureRecognizer(gesture)
      self.view.addSubview(likeOverlay)
    }
  }
  
  @objc func onboardingOverlay2(_ sender: UITapGestureRecognizer) {
    guard let profileVC = self.currentDiscoveryProfileVC else {
      return
    }
    DispatchQueue.main.async {
      if let likeOverlay = sender.view {
        likeOverlay.removeFromSuperview()
      }
      let pearOverlay = self.createOverlay(frame: self.view.frame,
                                           xOffset: profileVC.pearButton.center.x,
                                           yOffset: profileVC.pearButton.center.y,
                                           labelText: "Tap the Pear to match your friend",
                                           stepNumber: 2)
      let gesture = UITapGestureRecognizer(target: self, action: #selector (self.onboardingOverlay3(_:)))
      pearOverlay.addGestureRecognizer(gesture)
      self.view.addSubview(pearOverlay)
    }
  }
  
  @objc func onboardingOverlay3(_ sender: UITapGestureRecognizer) {
    guard let profileVC = self.currentDiscoveryProfileVC else {
      return
    }
    DispatchQueue.main.async {
      if let pearOverlay = sender.view {
        pearOverlay.removeFromSuperview()
      }
      let skipOverlay = self.createOverlay(frame: self.view.frame,
                                           xOffset: profileVC.skipButton.center.x,
                                           yOffset: profileVC.skipButton.center.y,
                                           labelText: "Tap the X to skip this profile",
                                           stepNumber: 3)
      let gesture = UITapGestureRecognizer(target: self, action: #selector (self.dismissOverlay(_:)))
      skipOverlay.addGestureRecognizer(gesture)
      self.view.addSubview(skipOverlay)
    }
  }
  
  @objc func dismissOverlay(_ sender: UITapGestureRecognizer) {
    DataStore.shared.setFlagToDefaults(value: true, flag: .hasCompletedDiscoveryOnboarding)
    DispatchQueue.main.async {
      if let skipOverlay = sender.view {
        skipOverlay.removeFromSuperview()
      }
    }
  }
  
}

// MARK: - DiscoveryFullProfileDelegate
extension DiscoveryDecisionViewController: DiscoveryFullProfileDelegate {
  
  func decisionMade() {
    self.showNextProfile()
  }
  
}
