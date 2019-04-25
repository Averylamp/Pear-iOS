//
//  ProfileBoastRoastViewController.swift
//  Pear
//
//  Created by Avery Lamp on 4/25/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

enum ItemStyle {
  case discovery
  case profile
}

class ProfileBoastRoastViewController: UIViewController {

  var boastRoastItem: BoastRoastItem!
  var userName: String?
  var maxLines: Int!
  var itemStyle: ItemStyle!
  
  @IBOutlet weak var iconImageView: UIImageView!
  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(boastRoastItem: BoastRoastItem, userName: String?,
                         style: ItemStyle, maxLines: Int = 0) -> ProfileBoastRoastViewController? {
    guard let profileBoastRoastVC = R.storyboard.profileBoastRoastViewController()
      .instantiateInitialViewController() as? ProfileBoastRoastViewController else { return nil }
    profileBoastRoastVC.boastRoastItem = boastRoastItem
    profileBoastRoastVC.userName = userName
    profileBoastRoastVC.itemStyle = style
    profileBoastRoastVC.maxLines = maxLines
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
    self.contentLabel.numberOfLines = self.maxLines
    self.contentLabel.text = boastRoastItem.content
    switch self.itemStyle! {
    case .discovery:
      if let font = R.font.openSansBold(size: 12) {
        self.titleLabel.font = font
      }
      if let font = R.font.openSansRegular(size: 12) {
        self.contentLabel.font = font
      }
      self.titleLabel.textColor = UIColor.black
      self.contentLabel.textColor = UIColor.black
    case .profile:
      if let font = R.font.openSansBold(size: 16) {
        self.titleLabel.font = font
      }
      if let font = R.font.openSansBold(size: 16) {
        self.contentLabel.font = font
      }
      self.titleLabel.textColor = UIColor.black
      self.contentLabel.textColor = UIColor(white: 0.0, alpha: 0.5)
    }
  }
  
}
