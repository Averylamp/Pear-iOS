//
//  MeTabViewController.swift
//  Pear
//
//  Created by Avery Lamp on 3/15/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit

class MeTabViewController: UIViewController {

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
  }
  
  func stylize() {
    self.requestProfileButton.stylizeDark()
  }
  
}
