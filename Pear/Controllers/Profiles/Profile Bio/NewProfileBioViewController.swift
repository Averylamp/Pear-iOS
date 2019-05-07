//
//  NewProfileBioViewController.swift
//  Pear
//
//  Created by Avery Lamp on 5/7/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class NewProfileBioViewController: UIViewController {

  @IBOutlet weak var writtenByImageView: UIImageView!
  @IBOutlet weak var writtenByLabel: UILabel!
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var bioContentLabel: UILabel!
  
  var bioItem: BioItem!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(bioItem: BioItem) -> NewProfileBioViewController? {
    guard let profileBioVC = R.storyboard.newProfileBioViewController()
      .instantiateInitialViewController() as? NewProfileBioViewController else { return nil }
    profileBioVC.bioItem = bioItem
    return profileBioVC
  }
  
}

// MARK: - Life Cycle
extension NewProfileBioViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
    self.setup()
  }
  
  func stylize() {
    self.writtenByImageView.contentMode = .scaleAspectFill
    self.writtenByImageView.layer.cornerRadius = self.writtenByImageView.frame.width / 2.0
    self.writtenByImageView.clipsToBounds = true
  }
  
  func setup() {
    self.writtenByLabel.text = bioItem.authorFirstName
    self.bioContentLabel.text = bioItem.content
  }
  
}
