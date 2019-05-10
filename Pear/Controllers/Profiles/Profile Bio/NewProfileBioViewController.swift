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
  @IBOutlet weak var expandButton: UIButton!
  
  @IBOutlet weak var showMoreButtonContainerView: UIView!
  
  var bioItem: BioItem!
  var expanded: Bool = false
  let collapsedNumberOfLines = 4
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(bioItem: BioItem) -> NewProfileBioViewController? {
    guard let profileBioVC = R.storyboard.newProfileBioViewController()
      .instantiateInitialViewController() as? NewProfileBioViewController else { return nil }
    profileBioVC.bioItem = bioItem
    return profileBioVC
  }
  
  @IBAction func expandButtonClicked(_ sender: Any) {
    UIView.animate(withDuration: 0.5) {
      if !self.expanded {
        self.expanded = true
        self.expandButton.setTitle("Show less", for: .normal)
        self.bioContentLabel.numberOfLines = 0
      } else {
        self.expanded = false
        self.expandButton.setTitle("Show more", for: .normal)
        self.bioContentLabel.numberOfLines = self.collapsedNumberOfLines
      }
      self.view.layoutIfNeeded()
    }
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
    self.bioContentLabel.numberOfLines = self.collapsedNumberOfLines
  }
  
  func setup() {
    self.writtenByLabel.text = bioItem.authorFirstName
    self.bioContentLabel.text = bioItem.content
    if self.bioContentLabel.calculateMaxLines() <= self.collapsedNumberOfLines {
      self.showMoreButtonContainerView.isHidden = true
    }
  }
  
}
