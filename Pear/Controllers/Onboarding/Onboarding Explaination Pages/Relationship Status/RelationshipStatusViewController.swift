//
//  RelationshipStatusViewController.swift
//  Pear
//
//  Created by Brian Gu on 6/29/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import Foundation

protocol RelationshipStatusModalDelegate: class {
  func selectedRelationshipStatus(seeking: Bool)
}

class RelationshipStatusViewController: UIViewController {
  
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var singleButton: UIButton!
  @IBOutlet weak var relationshipButton: UIButton!
  
  weak var delegate: RelationshipStatusModalDelegate?
  
  let initializationTime: Double = CACurrentMediaTime()
  
  class func instantiate() -> RelationshipStatusViewController? {
    guard let relationshipStatusVC = R.storyboard.relationshipStatusViewController
      .instantiateInitialViewController()  else { return nil }
    return relationshipStatusVC
  }
  
  @IBAction func singleButtonClicked(_ sender: Any) {
    if let delegate = self.delegate {
      delegate.selectedRelationshipStatus(seeking: true)
    }
  }
  
  @IBAction func relationshipButtonClicked(_ sender: Any) {
    if let delegate = self.delegate {
      delegate.selectedRelationshipStatus(seeking: false)
    }
  }
  
}

// MARK: - Life Cycle
extension RelationshipStatusViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
  }
  
  func stylize() {
    self.view.layer.cornerRadius = 20.0
    self.titleLabel.stylizeRequestTitleLabel()
    self.subtitleLabel.stylizeRequestSubtitleLabel()
    self.titleLabel.text = "What's your status?"
    self.subtitleLabel.text = "Hey good lookin'"
    self.singleButton.stylizeDark()
    self.relationshipButton.stylizeLight()
  }
  
}
