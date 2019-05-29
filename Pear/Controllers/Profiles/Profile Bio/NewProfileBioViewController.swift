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
    guard let profileBioVC = R.storyboard.newProfileBioViewController
      .instantiateInitialViewController()  else { return nil }
    profileBioVC.bioItem = bioItem
    return profileBioVC
  }
  
  @IBAction func expandButtonClicked(_ sender: Any) {
    if !self.expanded {
      self.expanded = true
    } else {
      self.expanded = false
    }
    UIView.animate(withDuration: 0.5, animations: {
      if self.expanded {
        self.expandButton.setTitle("Show less", for: .normal)
        self.bioContentLabel.numberOfLines = 0
        self.bioContentLabel.layoutIfNeeded()
      } else {
        self.bioContentLabel.numberOfLines = self.collapsedNumberOfLines
        self.expandButton.setTitle("Show more", for: .normal)
        self.bioContentLabel.layoutIfNeeded()
      }
    }, completion: { (_) in
      UIView.animate(withDuration: 0.2, animations: {
        self.view.layoutIfNeeded()
      })
    })

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
