//
//  DiscoveryFilterViewController.swift
//  Pear
//
//  Created by Brian Gu on 4/8/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import Firebase

enum DiscoveryFilterItemType: Int {
  case personalUser = 0
  case endorsedUser = 1
  case detachedProfile = 2
}

struct DiscoveryFilterItem {
  let type: DiscoveryFilterItemType
  var endorsedUser: MatchingPearUser?
  var user: PearUser?
  var detachedProfile: PearDetachedProfile?
  var checked: Bool
}

class DiscoveryFilterViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  var isUpdating: Bool = false
  var discoveryFilterItems: [DiscoveryFilterItem] = []
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> DiscoveryFilterViewController? {
    let storyboard = UIStoryboard(name: String(describing: DiscoveryFilterViewController.self), bundle: nil)
    guard let discoveryFilterVC = storyboard.instantiateInitialViewController() as? DiscoveryFilterViewController else { return nil }
    return discoveryFilterVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func doneButtonClicked(_ sender: Any) {
    self.saveFilters()
    NotificationCenter.default.post(name: .refreshDiscoveryFeedAnimated, object: nil)
    self.dismiss(animated: true, completion: nil)
  }
  
}

// MARK: - Life Cycle
extension DiscoveryFilterViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.loadData()
    self.stylize()
    self.setup()
  }
  
  func setup() {
    self.tableView.allowsMultipleSelection = true
    self.tableView.allowsMultipleSelectionDuringEditing = true
    self.tableView.allowsSelection = true
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.tableView.reloadData()
  }
  
  func stylize() {
    
  }
  
  func saveFilters() {
    var filteredEndorsedUserIDs: [String] = []
    var filteredDetachedProfileIDs: [String] = []
    for index in 0 ..< self.discoveryFilterItems.count {
      let discoveryFilterItem = discoveryFilterItems[index]
      switch discoveryFilterItem.type {
      case .personalUser:
        DataStore.shared.updateFilteringDisabledForSelfInDefault(disabled: !discoveryFilterItem.checked)
      case .endorsedUser:
        if !discoveryFilterItem.checked,
          let endorsedUser = discoveryFilterItem.endorsedUser {
          filteredEndorsedUserIDs.append(endorsedUser.documentID)
        }
      case .detachedProfile:
        if !discoveryFilterItem.checked,
          let detachedProfile = discoveryFilterItem.detachedProfile {
          filteredDetachedProfileIDs.append(detachedProfile.documentID)
        }
      }
    }
    DataStore.shared.updateFilteredEndorsedUsersInDefault(filteredEndorsedUserIDs: filteredEndorsedUserIDs)
    DataStore.shared.updateFilteredDetachedProfilesInDefault(filteredDetachedProfileIDs: filteredDetachedProfileIDs)
  }
  
  func loadData() {
    print("loadData called")
    if let user = DataStore.shared.currentPearUser {
      var allDiscoveryFilterItems: [DiscoveryFilterItem] = []
      
      let filteringForMe = !DataStore.shared.filteringDisabledForSelfFromDefaults()
      let meDiscoveryFilterItem = DiscoveryFilterItem(type: .personalUser,
                                                      endorsedUser: nil,
                                                      user: user,
                                                      detachedProfile: nil,
                                                      checked: filteringForMe)
      allDiscoveryFilterItems.append(meDiscoveryFilterItem)
      
      let disabledEndorsedUsers = DataStore.shared.filteredEndorsedUsersFromDefaults()
      for endorsedUser in DataStore.shared.endorsedUsers {
        let enabled = !disabledEndorsedUsers.contains(endorsedUser.documentID)
        let endorsedUserDiscoveryFilterItem = DiscoveryFilterItem(type: .endorsedUser,
                                                                  endorsedUser: endorsedUser,
                                                                  user: nil,
                                                                detachedProfile: nil,
                                                                checked: enabled)
        allDiscoveryFilterItems.append(endorsedUserDiscoveryFilterItem)
      }
      
      let disabledDetachedProfiles = DataStore.shared.filteredDetachedProfilesFromDefaults()
      for detachedProfile in DataStore.shared.detachedProfiles {
        let enabled = !disabledDetachedProfiles.contains(detachedProfile.documentID)
        let detachedProfileDiscoveryFilterItem = DiscoveryFilterItem(type: .detachedProfile,
                                                                  endorsedUser: nil,
                                                                  user: nil,
                                                                  detachedProfile: detachedProfile,
                                                                  checked: enabled)
        allDiscoveryFilterItems.append(detachedProfileDiscoveryFilterItem)
      }
      self.discoveryFilterItems = allDiscoveryFilterItems
      print(self.discoveryFilterItems.map({ $0.checked }))
    }
  }
  
}

extension DiscoveryFilterViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.discoveryFilterItems.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // Fetch a cell of the appropriate type.
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoveryFilterTVC", for: indexPath) as? DiscoveryFilterTableViewCell else {
      return UITableViewCell()
    }
    cell.selectionStyle = .none
    // Configure the cell’s contents.
    print("Configuring Cell \(indexPath.row)")
    cell.configure(discoveryFilterItem: discoveryFilterItems[indexPath.row])
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    print("did select \(indexPath.row)")
    discoveryFilterItems[indexPath.row].checked = !discoveryFilterItems[indexPath.row].checked
    if let filterCell = tableView.cellForRow(at: indexPath) as? DiscoveryFilterTableViewCell {
      filterCell.configure(discoveryFilterItem: discoveryFilterItems[indexPath.row])
    }
  }
  
  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    print("did deselect \(indexPath.row)")
    discoveryFilterItems[indexPath.row].checked = !discoveryFilterItems[indexPath.row].checked
    if let filterCell = tableView.cellForRow(at: indexPath) as? DiscoveryFilterTableViewCell {
      filterCell.configure(discoveryFilterItem: discoveryFilterItems[indexPath.row])
    }
  }
}
