//
//  DiscoverySimpleViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/12/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import Crashlytics

class DiscoverySimpleViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  var fullProfiles: [FullProfileDisplayData] = []
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
    self.refreshFeed()
  }
  
  func stylize() {
    tableView.separatorStyle = .none
    tableView.delegate = self
    tableView.dataSource = self   
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
          self.fullProfiles = feedObjects
          DispatchQueue.main.async {
            self.tableView.reloadData()
          }
        case .failure(let error):
          print("Error fetching feed:\(error)")
        }
      })
      
    }
  }
}

extension DiscoverySimpleViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.fullProfiles.count
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 360
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "SimpleDiscoveryTVC", for: indexPath) as? DiscoverySimpleTableViewCell else {
      return UITableViewCell()
    }
    let fullProfile = self.fullProfiles[indexPath.row]
    cell.selectionStyle = .none
    cell.cardView.layer.cornerRadius = 8
    cell.cardView.clipsToBounds = true
    cell.firstImageView.image = nil
    if let imageContainer = fullProfile.imageContainers.first,
      let imageURL = URL(string: imageContainer.medium.imageURL) {
      cell.firstImageView.sd_setImage(with: imageURL, completed: nil)
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    Crashlytics.sharedInstance().crash()
    let fullProfile = self.fullProfiles[indexPath.row]
    guard let fullProfileScrollVC = FullProfileScrollViewController.instantiate(fullProfileData: fullProfile) else {
      print("Failed to create full profile Scroll View")
      return
    }
    self.navigationController?.pushViewController(fullProfileScrollVC, animated: true)
  }
  
}
