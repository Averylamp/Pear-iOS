//
//  FullProfileScrollViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/12/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import Sentry

class DiscoveryFullProfileViewController: UIViewController {

  var fullProfileData: FullProfileDisplayData!
  
  @IBOutlet weak var scrollView: UIScrollView!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(fullProfileData: FullProfileDisplayData!) -> DiscoveryFullProfileViewController? {
    let storyboard = UIStoryboard(name: String(describing: DiscoveryFullProfileViewController.self), bundle: nil)
    guard let doDontVC = storyboard.instantiateInitialViewController() as? DiscoveryFullProfileViewController else { return nil }
    doDontVC.fullProfileData = fullProfileData
    return doDontVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func moreButtonClicked(_ sender: Any) {
    print("More Clicked")
    let actionController = UIAlertController(title: "More Options", message: nil, preferredStyle: .actionSheet)
    let matchAction = UIAlertAction(title: "Match", style: .default) { (_) in
      DispatchQueue.main.async {
        self.alert(title: "Matching not available yet 😢", message: "Coming very soon!!!")
      }
    }
    let blockAction = UIAlertAction(title: "Block User", style: .destructive) { (_) in
      DispatchQueue.main.async {
        if let userID = self.fullProfileData.userID {
          var blockedUsers = DataStore.shared.fetchListFromDefaults(type: .blockedUsers)
          if !blockedUsers.contains(userID) {
            blockedUsers.append(userID)
          }
          NotificationCenter.default.post(name: .refreshDiscoveryFeed, object: nil)
          DataStore.shared.saveListToDefaults(list: blockedUsers, type: .blockedUsers)
        }
        self.navigationController?.popViewController(animated: true)
        self.alert(title: "User Reported", message: "Thank you for your report and making Pear a safe place")
      }
    }
    let reportAction = UIAlertAction(title: "Report User", style: .destructive) { (_) in
      DispatchQueue.main.async {
        if let userID = self.fullProfileData.userID {
          let reportEvent = Event(level: .info)
          reportEvent.tags = ["reportedUserID": userID]
          reportEvent.message = "User Reported For Misconduct"
          reportEvent.extra = ["reportedUserID": userID]
          Client.shared?.send(event: reportEvent, completion: nil)
        }
        self.alert(title: "User Reported", message: "Thank you for your report and making Pear a safe place")
      }
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    actionController.addAction(matchAction)
    actionController.addAction(blockAction)
    actionController.addAction(reportAction)
    actionController.addAction(cancelAction)
    self.present(actionController, animated: true, completion: nil)
  }
  
}

// MARK: - Life Cycle
extension DiscoveryFullProfileViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.addFullStackVC()
  }
  
  func addFullStackVC() {
    guard let fullProfileStackVC = FullProfileStackViewController.instantiate(userFullProfileData: self.fullProfileData) else {
        print("Failed to create full profiles stack VC")
        return
    }
    
    self.addChild(fullProfileStackVC)
    self.scrollView.addSubview(fullProfileStackVC.view)
    fullProfileStackVC.view.translatesAutoresizingMaskIntoConstraints = false
    
    self.scrollView.addConstraints([
      NSLayoutConstraint(item: fullProfileStackVC.view!, attribute: .centerX, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .centerX, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: fullProfileStackVC.view!, attribute: .width, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .width, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: fullProfileStackVC.view!, attribute: .top, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .top, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: fullProfileStackVC.view!, attribute: .bottom, relatedBy: .equal,
                         toItem: self.scrollView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
      ])
    fullProfileStackVC.didMove(toParent: self)
  }
}