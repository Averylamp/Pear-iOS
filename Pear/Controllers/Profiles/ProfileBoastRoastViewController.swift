//
//  ProfileBoastRoastViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/25/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class ProfileBoastRoastViewController: UIViewController {

  var boastRoastItem: BoastRoastItem!
  var userName: String?
  
  @IBOutlet weak var iconImageView: UIImageView!
  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(boastRoastItem: BoastRoastItem, userName: String?) -> ProfileBoastRoastViewController? {
    guard let profileBoastRoastVC = R.storyboard.profileBoastRoastViewController()
      .instantiateInitialViewController() as? ProfileBoastRoastViewController else { return nil }
    profileBoastRoastVC.boastRoastItem = boastRoastItem
    profileBoastRoastVC.userName = userName
    return profileBoastRoastVC
  }
  
}

// MARK: - Life Cycle
extension ProfileBoastRoastViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
  }
  
  func stylize() {
    if self.boastRoastItem is BoastItem {
      self.iconImageView.image = R.image.iconBoast()
      self.titleLabel.text = "\(boastRoastItem.authorFirstName) boasted \(self.userName ?? "")"
    } else if self.boastRoastItem is RoastItem {
      self.iconImageView.image = R.image.iconRoast()
      self.titleLabel.text = "\(boastRoastItem.authorFirstName) roasted \(self.userName ?? "")"
    }
    self.contentLabel.text = boastRoastItem.content
  }
  
}
