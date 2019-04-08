//
//  DiscoverySimpleViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/12/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import SDWebImage

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
  
  @IBAction func discoveryIconClicked(_ sender: Any) {
    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
  }
  
}

// MARK: - Life Cycle
extension DiscoverySimpleViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
    self.stylize()
    self.tableView.setContentOffset(CGPoint(x: 0, y: -refreshControl.frame.size.height), animated: true)
    self.fullDataReload(animated: true)
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
                         selector: #selector(DiscoverySimpleViewController.reloadFullDataIfNeeded),
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
    self.reloadFullDataIfNeeded()
  }
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
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
    self.fullDataReload(animated: true)
  }
  
  @objc func reloadFullDataIfNeeded() {
    if lastRefreshTime < Date(timeIntervalSinceNow: -self.minRefreshTime) {
      self.fullDataReload()
    }
  }
  
  func fullDataReload(animated: Bool = false) {
    print("Discovery Full Reload")
    if animated {
      self.refreshControl.beginRefreshing()
    }
    self.lastRefreshTime = Date()
    self.blockedUsers = DataStore.shared.fetchListFromDefaults(type: .blockedUsers)
    self.skippedDetachedProfiles = DataStore.shared.fetchListFromDefaults(type: .skippedDetachedProfiles)
    self.checkForDetachedProfiles()
    self.refreshFeed(animated: animated)
  }
  
  func checkForDetachedProfiles() {
    DataStore.shared.checkForDetachedProfiles(detachedProfilesFound: { (detachedProfiles) in
      print("\(detachedProfiles.count) Detached Profiles Found")
      for detachedProfile in detachedProfiles
        where !self.skippedDetachedProfiles.contains(detachedProfile.creatorUserID) {
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
  
  func refreshFeed(animated: Bool = false) {
    if let userID = DataStore.shared.currentPearUser?.documentID {
      PearProfileAPI.shared.getDiscoveryFeed(user_id: userID, completion: { (result) in
        switch result {
        case .success(let feedObjects):
          print("Found \(feedObjects.count) Feed Objects Total")
          let newFeed = feedObjects.filter({
            if let userID = $0.userID {
              let blocked =  !self.blockedUsers.contains(userID)
              return blocked
            }
            return true
          })
          print("Found \(newFeed.count) Feed Objects Filtered")
          if FullProfileDisplayData.compareListsForNewItems(oldList: self.fullProfiles, newList: newFeed) {
            
            self.fullProfiles = newFeed
            var prefetchURLS: [URL] = []
            self.fullProfiles.forEach({
              if let firstImageMediumString = $0.imageContainers.first?.medium.imageURL,
                let firstImageMediumURL = URL(string: firstImageMediumString) {
                prefetchURLS.append(firstImageMediumURL)
              }
            })
            SDWebImagePrefetcher.shared().prefetchURLs(prefetchURLS)
            
            DispatchQueue.main.async {
              self.tableView.reloadData()
            }
          }
        case .failure(let error):
          print("Error fetching feed:\(error)")
        }
        if animated {
          DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
          }
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
    cell.delegate = self
    let fullProfile = self.fullProfiles[indexPath.row]
    cell.selectionStyle = .none
    cell.configureCell(profileData: fullProfile)
    cell.cardView.layer.cornerRadius = 12
    cell.cardView.layer.borderColor = UIColor(white: 0.95, alpha: 1.0).cgColor
    cell.cardView.layer.borderWidth = 1
    cell.cardView.clipsToBounds = true
    cell.cardShadowView.layer.shadowOpacity = 0.4
    cell.cardShadowView.layer.shadowColor = R.color.shadowColor()?.cgColor
    cell.cardShadowView.layer.shadowOffset = CGSize(width: 1, height: 1 )
    cell.cardShadowView.layer.shadowRadius = 2
    cell.cardShadowView.layer.cornerRadius = cell.cardView.layer.cornerRadius
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    let fullProfile = self.fullProfiles[indexPath.row]
    self.presentFullProfile(fullProfile: fullProfile)
  }
  
  func presentFullProfile(fullProfile: FullProfileDisplayData) {
    guard let fullProfileScrollVC = DiscoveryFullProfileViewController.instantiate(fullProfileData: fullProfile) else {
      print("Failed to create full profile Scroll View")
      return
    }
    self.navigationController?.pushViewController(fullProfileScrollVC, animated: true)
  }
  
}

extension DiscoverySimpleViewController: DiscoveryTableViewCellDelegate {
  
  func receivedVerticalPanTranslation(yTranslation: CGFloat) {
    self.tableView.setContentOffset(CGPoint(x: self.tableView.contentOffset.x,
                                            y: self.tableView.contentOffset.y - yTranslation), animated: false)
  }
  
  func endedVerticalPanTranslation(yVelocity: CGFloat) {
    
  }
  
  func fullProfileViewTriggered(profileData: FullProfileDisplayData) {
    self.presentFullProfile(fullProfile: profileData)
  }
  
}
