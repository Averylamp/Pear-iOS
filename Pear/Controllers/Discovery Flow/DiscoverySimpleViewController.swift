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
  
}

// MARK: - Life Cycle
extension DiscoverySimpleViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.checkForDetachedProfiles()
  }
  
  func stylize() {
    tableView.separatorStyle = .none
    
  }
  
  func checkForDetachedProfiles() {
    DataStore.shared.checkForDetachedProfiles(detachedProfilesFound: { (detachedProfiles) in
      print("\(detachedProfiles.count) Detached Profiles Found")
    }, detachedProfilesNotFound: {
      print("No detached Profiles Found")
      })
  }
  
}
