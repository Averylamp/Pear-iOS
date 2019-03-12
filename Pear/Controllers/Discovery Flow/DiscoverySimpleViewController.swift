//
//  DiscoverySimpleViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/12/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class DiscoverySimpleViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> DiscoverySimpleViewController? {
    let storyboard = UIStoryboard(name: String(describing: DiscoverySimpleViewController.self), bundle: nil)
    guard let discoverySimpleVC = storyboard.instantiateInitialViewController() as? DiscoverySimpleViewController else { return nil }
    
    return discoverySimpleVC
  }
  
  @IBAction func createButtonClicked(_ sender: Any) {
    if let waitlistVC = LoadingScreenViewController.getWaitlistVC() {
      self.navigationController?.setViewControllers([waitlistVC], animated: true)
    }
  }
  
}

// MARK: - Life Cycle
extension DiscoverySimpleViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.checkForDetachedProfiles()
    self.refreshFeed()
  }
  
  func stylize() {
    tableView.separatorStyle = .none
    
  }
  
  func checkForDetachedProfiles() {
    DataStore.shared.checkForDetachedProfiles(detachedProfilesFound: { (detachedProfiles) in
      print("\(detachedProfiles.count) Detached Profiles Found")
      
      if let firstDetachedProfile = detachedProfiles.first {
        guard let detachedProfileApprovalVC = DetachedProfileApprovalViewController.instantiate(detachedProfile: firstDetachedProfile) else {
          print("Failed to create detached profile vc")
          return
        }
        self.present(detachedProfileApprovalVC, animated: true, completion: nil)
      }
    }, detachedProfilesNotFound: {
      print("No detached Profiles Found")
      })
  }
  
  func refreshFeed() {
    if let userID = DataStore.shared.currentPearUser?.documentID {
      PearProfileAPI.shared.getDiscoveryFeed(user_id: userID, completion: { (result) in
        switch result {
        case .success(let feedObjects):
          print("Found \(feedObjects.count) Feed Objects")
        case .failure(let error):
          print("Error fetching feed:\(error)")
        }
      })
      
    }
  }
}
