//
//  VersionBlockViewController.swift
//  Pear
//
//  Created by Brian Gu on 3/29/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class VersionBlockViewController: UIViewController {
    
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var updateButton: UIButton!
    
  /// Factory method for creating this view controller.
  ///
  /// - Returns: Returns an instance of this view controller.
  class func instantiate() -> VersionBlockViewController? {
    let storyboard = UIStoryboard(name: String(describing: VersionBlockViewController.self), bundle: nil)
    guard let versionBlockVC = storyboard.instantiateInitialViewController() as? VersionBlockViewController else { return nil }
    
    return versionBlockVC
  }
  
  @IBAction func updateButtonClicked(_ sender: Any) {
    print("update button clicked")
    if let urlString = DataStore.shared.remoteConfig.configValue(forKey: "update_app_version_url").stringValue {
      if let url = URL(string: urlString) {
        UIApplication.shared.open(url)
      }
    }
  }
  
}

// MARK: - Life Cycle
extension VersionBlockViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylize()
  }
  
  func stylize() {
    self.updateButton.stylizeDark()
    self.titleLabel.stylizeTitleLabel()
    self.subtitleLabel.stylizeSubtitleLabel()
  }
  
}
