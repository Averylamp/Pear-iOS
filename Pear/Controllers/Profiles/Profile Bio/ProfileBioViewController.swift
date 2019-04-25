//
//  ProfileBioViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

struct BioContent {
  let bio: String
  let creatorName: String
}

class ProfileBioViewController: UIViewController {
  
  var bioItem: BioItem!
  var maxLines: Int!
  
  @IBOutlet weak var iconImageView: UIImageView!
  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var creatorLabel: UILabel!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(bioItem: BioItem, maxLines: Int = 0) -> ProfileBioViewController? {
    let storyboard = UIStoryboard(name: String(describing: ProfileBioViewController.self), bundle: nil)
    guard let bioVC = storyboard.instantiateInitialViewController() as? ProfileBioViewController else { return nil }
    bioVC.bioItem = bioItem
    bioVC.maxLines = maxLines
    return bioVC
  }
  
}

// MARK: - Life Cycle
extension ProfileBioViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
  }
  
  func stylize() {
    self.contentLabel.numberOfLines = maxLines
    self.contentLabel.text = bioItem.content
    self.creatorLabel.text = "Written by \(bioItem.authorFirstName)"
  }
  
}
