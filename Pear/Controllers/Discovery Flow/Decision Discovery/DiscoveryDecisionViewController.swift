//
//  DiscoveryDecisionViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import SDWebImage

extension Notification.Name {
  static let refreshDiscoveryFeed = Notification.Name("refreshDiscoveryFeed")
  static let showFiltersHeader = Notification.Name("showFilterHeader")
  static let hideFiltersHeader = Notification.Name("hideFilterHeader")
}

class DiscoveryDecisionViewController: UIViewController {
  
  enum HeaderState {
    case hidden
    case filters
    case profileName
  }
  
  var allFetchedProfiles: [FullProfileDisplayData] = []
  var profilesToShow: [FullProfileDisplayData] = []
  var currentDiscoveryProfileVC: DiscoveryFullProfileViewController?
  
  @IBOutlet weak var scanButton: UIButton!
  @IBOutlet weak var headerLabel: UILabel!
  @IBOutlet weak var headerContainerView: UIView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
  
  let filterContainerButton = UIButton()
  let filterNameLabel = UILabel()
  let headerHeightConstant: CGFloat = 66
  static let headerAnimationDuration: Double = 0.4
  var personalDiscovery: Bool = true
  
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
  }
  
  func setup() {
    self.registerNotifications()
    self.setupFilterView()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.checkForDetachedProfiles()
  }
  
  func registerNotifications() {
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(DiscoveryDecisionViewController.refreshDiscovery),
                   name: .refreshDiscoveryFeed,
                   object: nil)
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(DiscoveryDecisionViewController.showFiltersHeader),
                   name: .showFiltersHeader,
                   object: nil)
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(DiscoveryDecisionViewController.hideFiltersHeader),
                   name: .hideFiltersHeader,
                   object: nil)
  }
  
  @objc func refreshDiscovery() {
    self.updateFilterName()
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
            let oldProfilesToShow = self.profilesToShow
            self.profilesToShow = []
            self.allFetchedProfiles.filter({$0.decisionMade == false}).forEach({
              self.profilesToShow.append($0)
            })
            if oldProfilesToShow.count != self.profilesToShow.count {
              SlackHelper.shared.addEvent(text: "Fetched \(self.profilesToShow.count) profiles, Showing \(self.profilesToShow.count) profiles", color: UIColor.orange)
            }
            var imagesToPrefetch: [URL] = []
            self.profilesToShow.map({ $0.imageContainers }).forEach({ $0.forEach {
              let imageString = $0.large.imageURL
              if let imageURL = URL(string: imageString) {
                imagesToPrefetch.append(imageURL)
              }
              }})
            SDWebImagePrefetcher.shared.prefetchURLs(imagesToPrefetch)
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
      
      self.addChild(profileVC)
      self.view.addSubview(profileVC.view)
      profileVC.view.translatesAutoresizingMaskIntoConstraints = false
      let topConstraint = NSLayoutConstraint(item: profileVC.view as Any, attribute: .top, relatedBy: .equal,
                                             toItem: self.headerContainerView, attribute: .bottom, multiplier: 1.0, constant: -40)
      let bottomConstraint = NSLayoutConstraint(item: profileVC.view as Any, attribute: .bottom, relatedBy: .equal,
                                                toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 40)
      self.view.addConstraints([
        topConstraint,
        bottomConstraint,
        NSLayoutConstraint(item: profileVC.view as Any, attribute: .centerX, relatedBy: .equal,
                           toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
        NSLayoutConstraint(item: profileVC.view as Any, attribute: .width, relatedBy: .equal,
                           toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0.0)
        ])
      self.view.layoutIfNeeded()
      profileVC.didMove(toParent: self)
      profileVC.view.alpha = 0.0
      UIView.animate(withDuration: 0.7, animations: {
        profileVC.view.alpha = 1.0
        topConstraint.constant = 0
        bottomConstraint.constant = 0
        self.view.layoutIfNeeded()
      }, completion: { (_) in
        completion()
      })
      
//      if !DataStore.shared.fetchFlagFromDefaults(flag: .hasCompletedDiscoveryOnboarding) {
//        Analytics.logEvent(AnalyticsEventTutorialBegin, parameters: nil)
//        print("showing onboarding overlays")
//        self.onboardingOverlay1()
//      }
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

// MARK: - Discovery Detached Profiles
extension DiscoveryDecisionViewController {
  
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

}

// MARK: - Discovery Filter Header
extension DiscoveryDecisionViewController {
  
  func setupFilterView() {
    self.headerHeightConstraint.constant = self.headerHeightConstant
    self.headerContainerView.addSubview(self.filterContainerButton)
    self.filterContainerButton.translatesAutoresizingMaskIntoConstraints = false
    self.headerContainerView.addConstraints([
      NSLayoutConstraint(item: self.filterContainerButton, attribute: .centerY, relatedBy: .equal,
                         toItem: self.headerContainerView, attribute: .centerY, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: self.filterContainerButton, attribute: .centerX, relatedBy: .equal,
                         toItem: self.headerContainerView, attribute: .centerX, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: self.filterContainerButton, attribute: .height, relatedBy: .equal,
                         toItem: self.headerContainerView, attribute: .height, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: self.filterContainerButton, attribute: .left, relatedBy: .equal,
                         toItem: self.scanButton, attribute: .right, multiplier: 1.0, constant: 0.0)
      ])
    
    let filterInfoLabel = UILabel()
    self.filterContainerButton.addSubview(filterInfoLabel)
    filterInfoLabel.translatesAutoresizingMaskIntoConstraints = false
    filterInfoLabel.text = "Matching for"
    filterInfoLabel.textAlignment = .center
    filterInfoLabel.textColor = R.color.secondaryTextColor()
    if let font = R.font.openSansBold(size: 12) {
      filterInfoLabel.font = font
    }
    
    self.filterContainerButton.addConstraints([
      NSLayoutConstraint(item: filterInfoLabel, attribute: .centerX, relatedBy: .equal,
                         toItem: self.filterContainerButton, attribute: .centerX, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: filterInfoLabel, attribute: .width, relatedBy: .equal,
                         toItem: self.filterContainerButton, attribute: .width, multiplier: 1.0, constant: 0.0)
      ])
    
    self.filterContainerButton.addSubview(self.filterNameLabel)
    self.filterNameLabel.translatesAutoresizingMaskIntoConstraints = false
    self.filterNameLabel.textAlignment = .center
    self.filterNameLabel.textColor = R.color.primaryTextColor()
    if let font = R.font.openSansBold(size: 17) {
      self.filterNameLabel.font = font
    }
    self.filterNameLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    self.updateFilterName()
    
    self.filterContainerButton.addConstraints([
      NSLayoutConstraint(item: self.filterNameLabel, attribute: .top, relatedBy: .equal,
                         toItem: filterInfoLabel, attribute: .bottom, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: self.filterNameLabel, attribute: .centerX, relatedBy: .equal,
                         toItem: self.filterContainerButton, attribute: .centerX, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: self.filterNameLabel, attribute: .bottom, relatedBy: .equal,
                         toItem: self.filterContainerButton, attribute: .bottom, multiplier: 1.0, constant: -6)
      ])
    
    let downIconImageView = UIImageView()
    self.filterContainerButton.addSubview(downIconImageView)
    downIconImageView.translatesAutoresizingMaskIntoConstraints = false
    downIconImageView.contentMode = .scaleAspectFit
    downIconImageView.image = R.image.discoveryFilterIconDown()
    downIconImageView.addConstraints([
      NSLayoutConstraint(item: downIconImageView, attribute: .width, relatedBy: .equal,
                         toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 16),
      NSLayoutConstraint(item: downIconImageView, attribute: .width, relatedBy: .equal,
                         toItem: downIconImageView, attribute: .height, multiplier: 1.0, constant: 0.0)
      ])
    self.filterContainerButton.addConstraints([
      NSLayoutConstraint(item: downIconImageView, attribute: .lastBaseline, relatedBy: .equal,
                         toItem: self.filterNameLabel, attribute: .lastBaseline, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: downIconImageView, attribute: .left, relatedBy: .equal,
                         toItem: self.filterNameLabel, attribute: .right, multiplier: 1.0, constant: 10.0)
      ])
    
  }
  
  func updateFilterName() {
    DispatchQueue.main.async {
      let filters = DataStore.shared.getCurrentFilters()
      if let currentPearUser = DataStore.shared.currentPearUser,
        filters.userID == currentPearUser.documentID {
        self.personalDiscovery = true
        self.filterNameLabel.text = "You"
      } else {
        self.personalDiscovery = false
        self.filterNameLabel.text = filters.userName
      }
    }
  }
  
  @objc func hideFiltersHeader() {
    self.changeFiltersHeader(show: false)
  }
  
  @objc func showFiltersHeader() {
    self.changeFiltersHeader(show: true)
  }
  
  func changeFiltersHeader(show: Bool) {
    DispatchQueue.main.async {
      UIView.animate(withDuration: DiscoveryDecisionViewController.headerAnimationDuration, animations: {
        if show {
          self.filterContainerButton.alpha = 1.0
          self.headerHeightConstraint.constant = self.headerHeightConstant
        } else {
          self.filterContainerButton.alpha = 0.0
          self.headerHeightConstraint.constant = 0.0
        }
        self.view.layoutIfNeeded()
      })
    }
  }

}
