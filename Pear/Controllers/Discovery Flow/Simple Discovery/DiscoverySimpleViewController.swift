//
//  DiscoverySimpleViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/12/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

extension Notification.Name {
  static let refreshDiscoveryFeed = Notification.Name("refreshDiscoveryFeed")
}

class DiscoverySimpleViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  var fullProfiles: [FullProfileDisplayData] = []
  var blockedUsers: [String] = []
  var skippedDetachedProfiles: [String] = []
  var lastRefreshTime: Date = Date()
  let minRefreshTime: Double = 60 // Minimum time to wait before refreshing feed
  private let refreshControl = UIRefreshControl()
  private var refreshTimer: Timer = Timer()
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
    self.setup()
    self.stylize()
    self.fullDataReload()
  }
  
  func setup() {
    tableView.separatorStyle = .none
    tableView.delegate = self
    tableView.dataSource = self
    tableView.refreshControl = refreshControl
    self.refreshControl
      .addTarget(self,
                 action: #selector(DiscoverySimpleViewController.refreshControlChanged(sender:)),
                 for: .valueChanged)
    self.refreshTimer = Timer.scheduledTimer(timeInterval: 10,
                         target: self,
                         selector: #selector(DiscoverySimpleViewController.reloadeFullDataIfNeeded),
                         userInfo: nil,
                         repeats: true)
    self.registerNotifications()
  }
  
  func stylize() {
    if let refreshFont = UIFont(name: R.font.nunitoRegular.fontName, size: 14) {
      
      self.refreshControl
        .attributedTitle = NSAttributedString(string: "Finding Your Latest Matches...",
                                              attributes: [NSAttributedString.Key.font: refreshFont,
                                                           NSAttributedString.Key.foregroundColor: UIColor(white: 0.7, alpha: 1.0)])
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.reloadeFullDataIfNeeded()
    print("View appearing")
  }
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    print("View dissappearing")
  }
  
  func registerNotifications() {
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(DiscoverySimpleViewController.didRecieveRefreshFeedNotification),
                   name: .refreshDiscoveryFeed, object: nil)
  }
  
  @objc func didRecieveRefreshFeedNotification() {
    print("Received Refresh notification")
    self.fullDataReload()
  }
  
  @objc func refreshControlChanged(sender: UIRefreshControl) {
    self.fullDataReload()
  }
  
  @objc func reloadeFullDataIfNeeded() {
    if lastRefreshTime < Date(timeIntervalSinceNow: -self.minRefreshTime) {
      self.fullDataReload()
    } else {
      print("Discovery Reload not needed")
    }
  }
  
  func fullDataReload() {
    print("Discovery Full Reload")
    self.lastRefreshTime = Date()
    self.blockedUsers = DataStore.shared.fetchListFromDefaults(type: .blockedUsers)
    self.skippedDetachedProfiles = DataStore.shared.fetchListFromDefaults(type: .skippedDetachedProfiles)
    self.checkForDetachedProfiles()
    self.refreshFeed()
  }
  
  func checkForDetachedProfiles() {
    DataStore.shared.checkForDetachedProfiles(detachedProfilesFound: { (detachedProfiles) in
      print("\(detachedProfiles.count) Detached Profiles Found")
      for detachedProfile in detachedProfiles
        where !self.skippedDetachedProfiles.contains(detachedProfile.creatorUserID) {
          guard let detachedProfileApprovalVC = ApproveDetachedProfileNavigationViewController
            .instantiate(detachedProfile: detachedProfile) else {
              print("Failed to create detached profile navigation vc")
              return
          }
          self.present(detachedProfileApprovalVC, animated: true, completion: nil)
          return
      }
    })
  }
  
  func newItemsFound(fullProfileData: [FullProfileDisplayData], otherFullProfileData: [FullProfileDisplayData]) -> Bool {
    var newItems = false
    for prof1 in fullProfileData {
      var foundMatch = false
      for prof2 in otherFullProfileData where prof1 == prof2 {
        foundMatch = true
      }
      if !foundMatch {
        newItems = true
      }
    }
    return newItems
  }
  
  func refreshFeed() {
    if let userID = DataStore.shared.currentPearUser?.documentID {
      PearProfileAPI.shared.getDiscoveryFeed(user_id: userID, completion: { (result) in
        switch result {
        case .success(let feedObjects):
          print("Found \(feedObjects.count) Feed Objects Total")
          let newFeed = feedObjects.filter({
            if let userID = $0.userID {
              return !self.blockedUsers.contains(userID)
            }
            return true
          })
          print("Found \(feedObjects.count) Feed Objects Filtered")
          if self.newItemsFound(fullProfileData: newFeed, otherFullProfileData: self.fullProfiles) {
            self.fullProfiles = newFeed
            DispatchQueue.main.async {
              self.tableView.reloadData()
            }
          }
        case .failure(let error):
          print("Error fetching feed:\(error)")
        }
        DispatchQueue.main.async {
          self.refreshControl.endRefreshing()
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
    return UITableView.automaticDimension
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "SimpleDiscoveryTVC", for: indexPath) as? DiscoveryTableViewCell else {
      return UITableViewCell()
    }
    let fullProfile = self.fullProfiles[indexPath.row]
    cell.selectionStyle = .none
    cell.configureCell(profileData: fullProfile)
//    cell.cardView.layer.cornerRadius = 8
//    cell.cardView.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
//    cell.cardView.layer.borderWidth = 2
//    cell.cardView.clipsToBounds = true
//    cell.firstImageView.image = nil
//    if let imageContainer = fullProfile.imageContainers.first,
//      let imageURL = URL(string: imageContainer.medium.imageURL) {
//      cell.firstImageView.sd_setImage(with: imageURL) { (_, _, _, _) in
//        cell.cardView.layer.borderColor = nil
//        cell.cardView.layer.borderWidth = 0
//      }
//    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let fullProfile = self.fullProfiles[indexPath.row]
    guard let fullProfileScrollVC = DiscoveryFullProfileViewController.instantiate(fullProfileData: fullProfile) else {
      print("Failed to create full profile Scroll View")
      return
    }
    self.navigationController?.pushViewController(fullProfileScrollVC, animated: true)
  }
  
}
