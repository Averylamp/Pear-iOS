//
//  FriendsTabViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/15/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import Firebase

class FriendsTabViewController: UIViewController {
  
  var userProfiles: [FullProfileDisplayData] = []

  @IBOutlet weak var createFriendProfileButton: UIButton!
  @IBOutlet weak var tableView: UITableView!
  
  class func instantiate() -> FriendsTabViewController? {
    let storyboard = UIStoryboard(name: String(describing: FriendsTabViewController.self), bundle: nil)
    guard let matchesVC = storyboard.instantiateInitialViewController() as? FriendsTabViewController else { return nil }
    return matchesVC
  }
  
  @IBAction func createFriendProfileButtonClicked(_ sender: Any) {
    guard let startFriendVC = GetStartedStartFriendProfileViewController.instantiate() else {
      print("Failed to create get started friend profile vc")
      return
    }
    self.navigationController?.setViewControllers([startFriendVC], animated: true)
  }
  
}

// MARK: - Life Cycle
extension FriendsTabViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
  
    self.loadNewEndorsedDetachedProfiles(endorsedProfiles: DataStore.shared.endorsedUsers,
                                         detachedProfiles: DataStore.shared.detachedProfiles)
    
    self.tableView.dataSource = self
    self.tableView.delegate = self
    self.stylize()
  }
  
  func loadNewEndorsedDetachedProfiles(endorsedProfiles: [MatchingPearUser], detachedProfiles: [PearDetachedProfile]) {
    let newEndorsedProfiles = DataStore.shared.endorsedUsers.map({ FullProfileDisplayData(matchingUser: $0) })
    let newDetachedProfiles = DataStore.shared.detachedProfiles.map({ FullProfileDisplayData(pdp: $0) })
    var fullList: [FullProfileDisplayData] = []
    fullList.append(contentsOf: newEndorsedProfiles)
    fullList.append(contentsOf: newDetachedProfiles)
    if FullProfileDisplayData.compareListsForNewItems(oldList: self.userProfiles, newList: fullList) {
      self.userProfiles = fullList
      DispatchQueue.main.async {      
        self.tableView.reloadData()
      }
    }
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    self.reloadEndorsedProfiles()
  }
  
  func stylize() {
    self.createFriendProfileButton.stylizeDark()
  }
  
  func reloadEndorsedProfiles() {
    self.loadNewEndorsedDetachedProfiles(endorsedProfiles: DataStore.shared.endorsedUsers,
                                         detachedProfiles: DataStore.shared.detachedProfiles)
    DataStore.shared.refreshEndorsedUsers { (endorsedUsers, detachedProfiles) in
      self.loadNewEndorsedDetachedProfiles(endorsedProfiles: endorsedUsers,
                                           detachedProfiles: detachedProfiles)
    }
  }
  
}

// MARK: - UITableViewDelegate/DataSource
extension FriendsTabViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 120
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.userProfiles.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileMadeByTVC", for: indexPath) as? ProfileMadeByTableViewCell {
      let profileData = self.userProfiles[indexPath.row]
      cell.selectionStyle = .none
      cell.profileFirstImageView.clipsToBounds = true
      cell.profileFirstImageView.contentMode = .scaleAspectFill
      cell.profileFirstImageView.image = nil
      if let firstImageURL = profileData.imageContainers.first?.medium.imageURL, let imageURL = URL(string: firstImageURL) {
        cell.profileFirstImageView.sd_setImage(with: imageURL, completed: nil)
      }
      cell.subtextLabel.stylizeSubtitleLabel()
      cell.subtextLabel.text = "Made for \(profileData.firstName!)"
      if let statusLabel = cell.statusLabel, let profileOrigin = profileData.profileOrigin {
        if profileOrigin == .detachedProfile {
          statusLabel.text = "Status: Not Accepted"
        } else if profileOrigin == .userProfile {
          statusLabel.text = "Status: Accepted"
        }
      }
      return cell
    } else {
      return UITableViewCell()
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let fullProfile = self.userProfiles[indexPath.row]
    guard let fullProfileScrollVC = FullProfileScrollViewController.instantiate(fullProfileData: fullProfile) else {
      print("Failed to create full profile Scroll View")
      return
    }
    self.navigationController?.pushViewController(fullProfileScrollVC, animated: true)
  }
  
}
