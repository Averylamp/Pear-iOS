//
//  ProfileBioViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class ProfileBioViewController: UIViewController {
  
  @IBOutlet weak var bioLabel: UILabel!
  @IBOutlet weak var creatorLabel: UILabel!
  
  var bioText: String!
  var creatorFirstName: String!
  
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate(bioText: String, creatorFirstName: String) -> ProfileBioViewController? {
    let storyboard = UIStoryboard(name: String(describing: ProfileBioViewController.self), bundle: nil)
    guard let bioVC = storyboard.instantiateInitialViewController() as? ProfileBioViewController else { return nil }
    bioVC.bioText = bioText
    bioVC.creatorFirstName = creatorFirstName
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
    self.bioLabel.stylizeBioLabel()
    self.creatorLabel.self.stylizeCreatorLabel(preText: "Written by ", boldText: self.creatorFirstName!)
    
    self.bioLabel.text = self.bioText
    
  }
  
}
