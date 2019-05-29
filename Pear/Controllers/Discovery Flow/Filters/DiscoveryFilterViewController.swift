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
  var endorsedUser: PearUser?
  var user: PearUser?
  var detachedProfile: PearDetachedProfile?
  var checked: Bool
}

struct EventFilterItem {
  var event: PearEvent
  var checked: Bool
}

class DiscoveryFilterViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  var isUpdating: Bool = false
  var discoveryFilterItems: [DiscoveryFilterItem] = []
  var eventFilterItems: [EventFilterItem] = []
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> DiscoveryFilterViewController? {
    let storyboard = UIStoryboard(name: String(describing: DiscoveryFilterViewController.self), bundle: nil)
    guard let discoveryFilterVC = storyboard.instantiateInitialViewController() as? DiscoveryFilterViewController else { return nil }
    return discoveryFilterVC
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.saveFilters()
    NotificationCenter.default.post(name: .refreshDiscoveryFeedAnimated, object: nil)
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func addEventButtonClicked(_ sender: Any) {
    guard let addEventVC = JoinEventViewController.instantiate(isInOnboarding: false) else {
      print ("Failed to create join event VC")
      return
    }
    self.present(addEventVC, animated: true, completion: nil)
  }
  
}

// MARK: - Life Cycle
extension DiscoveryFilterViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.loadData()
    self.stylize()
    self.setup()
    self.navigationController?.interactivePopGestureRecognizer?.delegate = self
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
  
  func promptEventCode() {
    print("tapped enter code button")
    let alertController = UIAlertController(title: "Join Event", message: "Please enter your event code to continue.", preferredStyle: .alert)
    alertController.addTextField { (textField) in
      textField.placeholder = "Enter the code"
    }
    let submitAction = UIAlertAction(title: "Continue", style: .default) { (_) in
      let textField = alertController.textFields![0] as UITextField
      var eventCode = ""
      if let text = textField.text {
        eventCode = text
      }
      print(eventCode)
      PearUserAPI.shared.addEventCode(code: eventCode) { (result) in
        switch result {
        case .success(let successful):
          if successful {
            self.dismiss(animated: true, completion: nil)
            DataStore.shared.refreshEvents { (_) in
              DispatchQueue.main.async {
                self.alert(title: "Successfully added event.", message: "You'll be able to browse for other users at this event soon!")
                self.loadData()
                self.tableView.reloadData()
              }
            }
          } else {
            DispatchQueue.main.async {
              self.alert(title: "No event found",
                         message: "We couldn't find an event with this code.")
            }
          }
        case .failure(let error):
          print("Failure adding event code SUMMERLOVE: \(error)")
          DispatchQueue.main.async {
            self.alert(title: "No event found",
                       message: "We couldn't find an event with this code.")
          }
        }
        
      }
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    alertController.addAction(submitAction)
    alertController.addAction(cancelAction)
    self.present(alertController, animated: true, completion: nil)
  }
  
  func saveFilters() {
    var filterForUserID: String?
    for discoveryFilterItem in self.discoveryFilterItems where discoveryFilterItem.checked {
      if discoveryFilterItem.type == .personalUser,
        let user = discoveryFilterItem.user {
        filterForUserID = user.documentID
      }
      if discoveryFilterItem.type == .endorsedUser,
        let endorsedUser = discoveryFilterItem.endorsedUser {
        filterForUserID = endorsedUser.documentID
      }
    }
    if let userID = filterForUserID {
      DataStore.shared.updateFilterForUserId(userID: userID)
    } else {
      DataStore.shared.updateFilterForMeUserId()
    }
    var filterForEventID: String?
    for eventFilterItem in self.eventFilterItems where eventFilterItem.checked {
      filterForEventID = eventFilterItem.event.documentID
    }
    if let eventID = filterForEventID {
      DataStore.shared.updateFilterForEventId(eventID: eventID)
    } else {
      DataStore.shared.unsetFilterForEventId()
    }
    
  }
  
  func loadData() {
    print("loadData called")
    if let user = DataStore.shared.currentPearUser {
      let now = Date()
      var allEventFilterItems: [EventFilterItem] = []
      for event in DataStore.shared.userEvents {
        if event.endTime < now {
          continue
        }
        var eventEnabled = false
        if let filteringForEventId = DataStore.shared.filteringForEventIdFromDefaults() {
          eventEnabled = event.documentID == filteringForEventId
        }
        let eventFilterItem = EventFilterItem(event: event, checked: eventEnabled)
        allEventFilterItems.append(eventFilterItem)
      }
      allEventFilterItems.sort { (item1, item2) -> Bool in
        if item1.event.startTime < item2.event.startTime {
          return true
        }
        return false
      }
      self.eventFilterItems = allEventFilterItems
      
      var allDiscoveryFilterItems: [DiscoveryFilterItem] = []
      var userFilterSet = false
      // flag indicating whether we are filtering for some user yet.
      // we track this so that we can set meDiscoveryFilterItem.checked to true if not filtering for any endorsed users
      
      for endorsedUser in DataStore.shared.endorsedUsers {
        var enabled = false
        if let filterForUserID = DataStore.shared.filteringForUserIdFromDefaults() {
          if filterForUserID == endorsedUser.documentID {
            enabled = true
            userFilterSet = true
          }
        }
        let endorsedUserDiscoveryFilterItem = DiscoveryFilterItem(type: .endorsedUser,
                                                                  endorsedUser: endorsedUser,
                                                                  user: nil,
                                                                detachedProfile: nil,
                                                                checked: enabled)
        allDiscoveryFilterItems.append(endorsedUserDiscoveryFilterItem)
      }
    
      for detachedProfile in DataStore.shared.detachedProfiles {
        let detachedProfileDiscoveryFilterItem = DiscoveryFilterItem(type: .detachedProfile,
                                                                  endorsedUser: nil,
                                                                  user: nil,
                                                                  detachedProfile: detachedProfile,
                                                                  checked: false)
        allDiscoveryFilterItems.append(detachedProfileDiscoveryFilterItem)
      }
      
      let meDiscoveryFilterItem = DiscoveryFilterItem(type: .personalUser,
                                                      endorsedUser: nil,
                                                      user: user,
                                                      detachedProfile: nil,
                                                      checked: !userFilterSet)
      userFilterSet = true
      allDiscoveryFilterItems.append(meDiscoveryFilterItem)
      
      allDiscoveryFilterItems.sort { (item1, item2) -> Bool in
        
        // Ordering of user < endorsed < detached
        if item1.type.rawValue < item2.type.rawValue {
          return true
        } else if item1.type.rawValue > item2.type.rawValue {
          return false
        }
        
        let item1FullName = self.getNameFromDiscoveryFilterItem(item: item1)
        let item2FullName = self.getNameFromDiscoveryFilterItem(item: item2)
        if item1FullName < item2FullName {
          return true
        } else if item1FullName > item2FullName {
          return false
        }
        
        return true
      }
      
      self.discoveryFilterItems = allDiscoveryFilterItems
    }
  }
  
  func getNameFromDiscoveryFilterItem(item: DiscoveryFilterItem) -> String {
    var name = ""
    switch item.type {
    case .personalUser:
      if let fullName = item.user?.fullName() {
        name = fullName
      }
    case .endorsedUser:
      if let fullName = item.endorsedUser?.fullName() {
        name = fullName
      }
    case .detachedProfile:
      if let fullName = item.detachedProfile?.firstName {
        name = fullName
      }
    }
    return name
  }
  
}

extension DiscoveryFilterViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return self.discoveryFilterItems.count
    } else if section == 1 {
      return self.eventFilterItems.count + 1
    }
    return 0
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return "Preferences"
    } else if section == 1 {
      return "Event Group"
    }
    return nil
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    let now = Date()
    if now > Date(timeIntervalSince1970: 1559620799000) {
      return 1
    }
    return 2
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    print(indexPath)
    if indexPath.section == 0 {
      // Fetch a cell of the appropriate type.
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoveryFilterTVC", for: indexPath) as? DiscoveryFilterTableViewCell else {
        return UITableViewCell()
      }
      cell.selectionStyle = .none
      // Configure the cell’s contents.
      print("Configuring Cell \(indexPath.section), \(indexPath.row)")
      cell.configure(discoveryFilterItem: discoveryFilterItems[indexPath.row])
      return cell
    } else if indexPath.section == 1 {
      if indexPath.row < self.eventFilterItems.count {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EventFilterTVC", for: indexPath) as? EventFilterTableViewCell else {
          return UITableViewCell()
        }
        cell.selectionStyle = .none
        print("Configuring Cell \(indexPath.section), \(indexPath.row)")
        cell.configure(eventFilterItem: eventFilterItems[indexPath.row])
        return cell
      } else {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddEventTVC", for: indexPath) as? AddEventTableViewCell else {
          return UITableViewCell()
        }
        cell.selectionStyle = .none
        return cell
      }
    }
    return UITableViewCell()
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    print("did select \(indexPath.section), \(indexPath.row)")
    toggleForRowAt(indexPath: indexPath, tableView: tableView)
  }
  
  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    print("did deselect \(indexPath.section), \(indexPath.row)")
    toggleForRowAt(indexPath: indexPath, tableView: tableView)
  }
  
  func toggleForRowAt(indexPath: IndexPath, tableView: UITableView) {
    if indexPath.section == 0 {
      if self.discoveryFilterItems[indexPath.row].type != .detachedProfile {
        for idx in 0..<self.discoveryFilterItems.count {
          discoveryFilterItems[idx].checked = indexPath.row == idx
          if let filterCell = tableView.cellForRow(at: IndexPath(row: idx, section: 0)) as? DiscoveryFilterTableViewCell {
            filterCell.configure(discoveryFilterItem: discoveryFilterItems[idx])
          }
        }
      }
    } else if indexPath.section == 1 {
      if indexPath.row < self.eventFilterItems.count {
        let now = Date()
        if eventFilterItems[indexPath.row].event.startTime > now {
          DispatchQueue.main.async {
            self.alert(title: "Come back soon!",
                       message: "You'll be able to start using this event filter beginning 8:30PM on Sunday 6/2.")
          }
          return
        }
        for idx in 0..<self.eventFilterItems.count {
          if indexPath.row == idx {
            eventFilterItems[idx].checked = !eventFilterItems[idx].checked
          }
          if let filterCell = tableView.cellForRow(at: IndexPath(row: idx, section: 1)) as? EventFilterTableViewCell {
            filterCell.configure(eventFilterItem: eventFilterItems[idx])
          }
        }
      } else {
        self.promptEventCode()
      }
    }
  }
}

extension DiscoveryFilterViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
}
