//
//  MeTabViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/15/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class MeTabViewController: UIViewController {

  var userProfiles: [FullProfileDisplayData] = []
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var requestProfileButton: UIButton!
  class func instantiate() -> MeTabViewController? {
    let storyboard = UIStoryboard(name: String(describing: MeTabViewController.self), bundle: nil)
    guard let matchesVC = storyboard.instantiateInitialViewController() as? MeTabViewController else { return nil }
    return matchesVC
  }
  
  @IBAction func requestProfileButtonClicked(_ sender: Any) {
    
    // swiftlint:disable:next line_length
    self.alert(title: "Sorry 😢", message: "This feature is currently disabled in beta. If your friend also has beta access, have them make a profile for you and input your phone number.")
  }
  
}

// MARK: - Life Cycle
extension MeTabViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    
    if let user = DataStore.shared.currentPearUser {
      for userProfile in user.userProfiles {
        if let fullProfile = try? FullProfileDisplayData(user: user, profiles: [userProfile]) {
          self.userProfiles.append(fullProfile)
        }
      }
    }
    
    self.tableView.dataSource = self
    self.tableView.delegate = self
  }
  
  func stylize() {
    self.requestProfileButton.stylizeDark()
  }
  
}

// MARK: - UITableViewDelegate/DataSource
extension MeTabViewController: UITableViewDelegate, UITableViewDataSource {
  
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
      if let originalCreatorName = profileData.originalCreatorName {
        cell.subtextLabel.text = "Made by \(originalCreatorName)"
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
