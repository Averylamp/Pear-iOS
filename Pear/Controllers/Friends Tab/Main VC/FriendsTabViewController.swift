//
//  FriendsTabViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/15/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import Firebase

extension Notification.Name {
  static let refreshFriendTab = Notification.Name("refreshFriendTab")
}

class FriendsTabViewController: UIViewController {
  
  var userProfiles: [FullProfileDisplayData] = []

  let betweenImageSpacing: CGFloat = 0
  
  @IBOutlet weak var collectionView: UICollectionView!
  
  class func instantiate() -> FriendsTabViewController? {
    let storyboard = UIStoryboard(name: String(describing: FriendsTabViewController.self), bundle: nil)
    guard let matchesVC = storyboard.instantiateInitialViewController() as? FriendsTabViewController else { return nil }
    return matchesVC
  }

}

// MARK: - Life Cycle
extension FriendsTabViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
  
    self.loadNewEndorsedDetachedProfiles(endorsedProfiles: DataStore.shared.endorsedUsers,
                                         detachedProfiles: DataStore.shared.detachedProfiles)
    self.collectionView.delegate = self
    self.collectionView.dataSource = self
    self.stylize()
    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(FriendsTabViewController.reloadEndorsedProfiles),
                   name: .refreshFriendTab, object: nil)
  }
  
  func loadNewEndorsedDetachedProfiles(endorsedProfiles: [PearUser], detachedProfiles: [PearDetachedProfile]) {
    let newEndorsedProfiles = DataStore.shared.endorsedUsers.map({ FullProfileDisplayData(user: $0) })
    let newDetachedProfiles = DataStore.shared.detachedProfiles.map({ FullProfileDisplayData(detachedProfile: $0) })
    var fullList: [FullProfileDisplayData] = []
    fullList.append(contentsOf: newEndorsedProfiles)
    fullList.append(contentsOf: newDetachedProfiles)
    if FullProfileDisplayData.compareListsForNewItems(oldList: self.userProfiles, newList: fullList) {
      self.userProfiles = fullList
      DispatchQueue.main.async {
        self.collectionView.reloadData()
      }
    }
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    self.reloadEndorsedProfiles()
  }
  
  func stylize() {
  }
  
  @objc func reloadEndorsedProfiles() {
    print("Reloaded Friends Tab")
    self.loadNewEndorsedDetachedProfiles(endorsedProfiles: DataStore.shared.endorsedUsers,
                                         detachedProfiles: DataStore.shared.detachedProfiles)
  }
  
}

// MARK: - CollectionViewDataSource/Delegate
extension FriendsTabViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.userProfiles.count + 1
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if indexPath.item < self.userProfiles.count {
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendProfileTVC", for: indexPath) as? FriendProfileCollectionViewCell else {
        return UICollectionViewCell()
      }
      cell.configureForProfileType(profileData: self.userProfiles[indexPath.item])
      return cell
    } else {
      return collectionView.dequeueReusableCell(withReuseIdentifier: "CreateProfileVCV", for: indexPath)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .light)
    if indexPath.item < self.userProfiles.count {
      let fullProfile = self.userProfiles[indexPath.row]
      guard let friendFullProfileVC = FriendFullProfileViewController.instantiate(fullProfileData: fullProfile) else {
        print("Failed to create full friend profile Scroll View")
        return
      }
      self.navigationController?.pushViewController(friendFullProfileVC, animated: true)
    } else {
      guard let startFriendVC = GetStartedStartFriendProfileViewController.instantiate() else {
        print("Failed to create get started friend profile vc")
        return
      }
      self.navigationController?.setViewControllers([startFriendVC], animated: true)
    }
  }
  
}

// MARK: - UICollectionViewDelegateFlowLayout
extension FriendsTabViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let sideLength: CGFloat = (collectionView.frame.size.width  - betweenImageSpacing - collectionView.contentInset.left - collectionView.contentInset.right) / 2.0
    return CGSize(width: sideLength, height: sideLength)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return betweenImageSpacing
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return betweenImageSpacing
  }
  
}
